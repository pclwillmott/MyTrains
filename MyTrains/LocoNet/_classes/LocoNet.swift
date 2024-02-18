//
//  LocoNet.swift
//  MyTrains
//
//  Created by Paul Willmott on 02/07/2023.
//

import Foundation

// private typealias QueueItem = (message:LocoNetMessage, spacingDelay:UInt8)

private enum State {
  case idle
  case initialized
}

internal enum MessageState {
  case idle
  case waitingForDatagramReceivedOK
  case waitingForSendLocoNetMessageReply
}

public class LocoNet {
  
  // MARK: Constructors & Destructors
  
  init(gatewayNodeId: UInt64, virtualNode: OpenLCBNodeVirtual) {
    
    self.gatewayNodeId = gatewayNodeId
    
    self.virtualNode = virtualNode
    
    self.networkLayer = virtualNode.networkLayer!
    
    self.nodeId = virtualNode.nodeId
    
    getOpSwDataAP1()
    
  }
  
  // MARK: Private Properties
  
  internal var gatewayNodeId : UInt64
  
  internal var virtualNode : OpenLCBNodeVirtual
  
  internal var networkLayer : OpenLCBNetworkLayer
  
  internal var nodeId : UInt64
  
  private var state : State = .idle
  
  private var buffer : [UInt8] = []
  
  internal var immPacketQueue : [LocoNetMessage] = []
  
  internal var outputQueue : [LocoNetMessage] = []
  
  internal var currentMessage : LocoNetMessage?
  
  internal var timeoutTimer : Timer?
  
  internal var messageState : MessageState = .idle
  
  internal var retryCount : Int = 10
  
  private var lastTimeStamp : TimeInterval = Date().timeIntervalSinceReferenceDate

  // MARK: Public Properties
  
  public var delegate : LocoNetDelegate?
  
  public var trackPowerOn : Bool = false
  
  public var globalEmergencyStop : Bool = false
  
  public var commandStationType : LocoNetCommandStationType = .DT200
  
  public var implementsProtocol0 : Bool {
    get {
      return commandStationType.protocolsSupported.contains(.protocol0)
    }
  }
  
  public var implementsProtocol1 : Bool {
    get {
      return commandStationType.protocolsSupported.contains(.protocol1)
    }
  }

  public var implementsProtocol2 : Bool {
    get {
      return commandStationType.protocolsSupported.contains(.protocol2)
    }
  }

  // MARK: Private Methods
  
  @objc internal func timeoutTimerAction() {
    
    stopTimeoutTimer()
    
    switch messageState {
    case .idle:
      break
    case .waitingForDatagramReceivedOK:
      currentMessage = nil
      outputQueue.removeAll()
    case .waitingForSendLocoNetMessageReply:
      currentMessage = nil
      sendNext()
    }

  }
  
  internal func startTimeoutTimer(interval: TimeInterval) {
    guard currentMessage != nil else {
      return
    }
    timeoutTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timeoutTimerAction), userInfo: nil, repeats: false)
    RunLoop.current.add(timeoutTimer!, forMode: .common)
  }
  
  internal func stopTimeoutTimer() {
    timeoutTimer?.invalidate()
    timeoutTimer = nil
  }

  internal func sendNext() {
    
    guard currentMessage == nil && !outputQueue.isEmpty else {
      return
    }
    
    currentMessage = outputQueue.removeFirst()
    
    messageState = .waitingForDatagramReceivedOK
    
    retryCount = 10
    
    startTimeoutTimer(interval: 1.0)
    
//    networkLayer.sendLocoNetMessage(sourceNodeId: nodeId, destinationNodeId: gatewayNodeId, locoNetMessage: currentMessage!)
    
  }
  
  internal func addToQueue(message:LocoNetMessage) {
    outputQueue.append(message)
    sendNext()
  }
  

  // MARK: Public Methods
 
  public func locoNetMessageReceived(message:LocoNetMessage) {
    
    switch message.messageType {
      
    case .opSwDataAP1:
      
      let trackByte = message.message[7]
      
      let mask_TrackPower    : UInt8 = 0b00000001
      let mask_EmergencyStop : UInt8 = 0b00000010
      let mask_Protocol1     : UInt8 = 0b00000100
      
      if (trackByte & mask_Protocol1) == mask_Protocol1, let csType = LocoNetCommandStationType(rawValue: message.message[11]) {
        commandStationType = csType
      }
      
      trackPowerOn = (trackByte & mask_TrackPower) == mask_TrackPower
      
      if commandStationType.idleSupportedByDefault {
        globalEmergencyStop = (trackByte & mask_EmergencyStop) != mask_EmergencyStop
      }

      if state == .idle {
        state = .initialized
        self.delegate?.locoNetInitializationComplete?()
      }

    case .immPacketOK:
      
      if !immPacketQueue.isEmpty {
        immPacketQueue.removeFirst()
      }
      
      if !immPacketQueue.isEmpty {
        addToQueue(message: immPacketQueue.first!)
      }
      
    case .immPacketBufferFull:

      if !immPacketQueue.isEmpty {
        addToQueue(message: immPacketQueue.first!)
      }

    default:
      break
    }
    
    delegate?.locoNetMessageReceived?(message: message)
    
  }
  
  public func openLCBMessageReceived(message: OpenLCBMessage) {
    
    switch message.messageTypeIndicator {
    
    case .producerConsumerEventReport:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
        case .emergencyOffAll:
          powerOff()
        case .clearEmergencyOffAll:
          powerOn()
        case .emergencyStopAll:
          emergencyStop()
        case .clearEmergencyStopAll:
          clearEmergencyStop()
        default:
          break
        }

      }
      
      // Handle leading two byte event id cases
      
      else if let event = OpenLCBWellKnownEvent(rawValue: message.eventId! & 0xffff000000000000) {

        switch event {

        case .locoNetMessage:

          if message.sourceNodeId! == gatewayNodeId, let locoNetMessage = message.locoNetMessage {
              
            locoNetMessage.timeStamp = Date.timeIntervalSinceReferenceDate
            locoNetMessage.timeSinceLastMessage = locoNetMessage.timeStamp - lastTimeStamp
            lastTimeStamp = locoNetMessage.timeStamp
            locoNetMessageReceived(message: locoNetMessage)
            
          }
          
        default:
          break
        }

      }
      
    case .sendLocoNetMessageReply:
      
      if message.destinationNodeId! == nodeId && message.sourceNodeId! == gatewayNodeId, let locoNetMessage = currentMessage {
        
        stopTimeoutTimer()
        
        let errorCode = message.errorCode
        
        switch errorCode {
        case .success:
          messageState = .idle
          currentMessage = nil
          sendNext()
        case .temporaryErrorLocoNetCollision:
          retryCount -= 1
          if retryCount == 0 {
            messageState = .idle
            currentMessage = nil
            sendNext()
          }
          else {
            messageState = .waitingForDatagramReceivedOK
            startTimeoutTimer(interval: 1.0)
 //           networkLayer.sendLocoNetMessage(sourceNodeId: nodeId, destinationNodeId: gatewayNodeId, locoNetMessage: locoNetMessage)
          }
        default:
          print("error: \(errorCode)")
          messageState = .idle
          currentMessage = nil
          sendNext()
        }
        
      }
      
    case .datagramReceivedOK:
      
      if message.destinationNodeId! == nodeId && message.sourceNodeId! == gatewayNodeId, let _ = currentMessage {
        
        stopTimeoutTimer()
        
        var data = message.payload
        
        if data.isEmpty {
          data.append(0)
        }
        
        if let flags = OpenLCBDatagramTimeout(rawValue: data[0]) {
          
          messageState = .waitingForSendLocoNetMessageReply
          
          startTimeoutTimer(interval: flags.timeout)
          
        }
        
      }
      
    case .datagramRejected:
      
      if message.destinationNodeId! == nodeId && message.sourceNodeId! == gatewayNodeId, let locoNetMessage = currentMessage {
        
        stopTimeoutTimer()
        
        let errorCode = message.errorCode
        
        switch errorCode {
        case .permanentErrorNoConnection:
          print("error: \(errorCode)")
          currentMessage = nil
          outputQueue.removeAll()
        case .permanentErrorInvalidArguments:
          print("error: \(errorCode)")
          currentMessage = nil
          sendNext()
        case .temporaryErrorBufferUnavailable:
          print("error: \(errorCode)")
          retryCount -= 1
          if retryCount == 0 {
            print("max retries exceeded")
            messageState = .idle
            currentMessage = nil
            sendNext()
          }
          else {
            startTimeoutTimer(interval: 1.0)
     //       networkLayer.sendLocoNetMessage(sourceNodeId: nodeId, destinationNodeId: gatewayNodeId, locoNetMessage: locoNetMessage)
          }
        default:
          print("unexpected error: \(errorCode)")
        }
        
      }
/*
    case .locoNetMessageReceivedOnlyFrame, .locoNetMessageReceivedFirstFrame, .locoNetMessageReceivedMiddleFrame, .locoNetMessageReceivedLastFrame:
    
      if message.sourceNodeId! == gatewayNodeId {
        locoNetMessagePartReceived(message: message)
      }
      */
    default:
      break
      
    }
    
  }

}
