//
//  LocoNet.swift
//  MyTrains
//
//  Created by Paul Willmott on 02/07/2023.
//

import Foundation
import AppKit

// private typealias QueueItem = (message:LocoNetMessage, spacingDelay:UInt8)

private enum State {
  case idle
  case waitingForOpSwDataAP1
  case initialized
}

internal enum MessageState {
  case idle
  case waitingForDatagramReceivedOK1
  case waitingForSendLocoNetMessageReply1
  case waitingForDatagramReceivedOK2
  case waitingForSendLocoNetMessageReply2
}

public class LocoNet {
  
  // MARK: Constructors & Destructors
  
  init(gatewayNodeId: UInt64, node: OpenLCBNodeVirtual) {
    self.gatewayNodeId = gatewayNodeId
    self.node = node
    addInit()
  }
  
  deinit {
    node = nil
    buffer.removeAll()
    immPacketQueue.removeAll()
    outputQueue.removeAll()
    outputQueueLock = nil
    currentMessage = nil
    timeoutTimer?.invalidate()
    timeoutTimer = nil
    retryTimer?.invalidate()
    retryTimer = nil
    delegate = nil
    addDeinit()
  }
  
  // MARK: Private Properties
  
  internal var gatewayNodeId : UInt64
  
  internal weak var node : OpenLCBNodeVirtual?
  
  internal var gatewayConnected = false
  
  private var state : State = .idle
  
  private var buffer : [UInt8] = []
  
  internal var immPacketQueue : [LocoNetMessage] = []
  
  internal var outputQueue : [LocoNetMessage] = []
  
  internal var outputQueueLock : NSLock? = NSLock()
  
  internal var currentMessage : LocoNetMessage?
  
  internal var timeoutTimer : Timer?
  
  internal var retryTimer : Timer?
  
  internal var messageState : MessageState = .idle
  
  internal var retryCount : Int = 10
  
  private var lastTimeStamp : TimeInterval = Date().timeIntervalSinceReferenceDate

  // MARK: Public Properties
  
  public weak var delegate : LocoNetDelegate?
  
  public var trackPowerOn : Bool = false
  
  public var globalEmergencyStop : Bool = false
  
  public var commandStationType : LocoNetCommandStationType?
  
  public var implementsProtocol0 : Bool {
    guard let commandStationType else {
      return false
    }
    return commandStationType.protocolsSupported.contains(.protocol0)
  }
  
  public var implementsProtocol1 : Bool {
    guard let commandStationType else {
      return false
    }
    return commandStationType.protocolsSupported.contains(.protocol1)
  }

  public var implementsProtocol2 : Bool {
    guard let commandStationType else {
      return false
    }
    return commandStationType.protocolsSupported.contains(.protocol2)
  }

  // MARK: Private Methods
  
  @objc internal func timeoutTimerAction() {
    
    if state == .initialized {
      
      let alert = NSAlert()
      
      alert.messageText = String(localized: "Timeout")
      alert.informativeText = String(localized: "A reply from the LocoNet gateway was not received within the expected time period.")
      alert.addButton(withTitle: String(localized: "OK"))
      alert.alertStyle = .critical
      
      alert.runModal()
      
    }
    else {
      self.delegate?.locoNetStartupComplete?()
    }
    
  }
  
  internal func startTimeoutTimer(interval:TimeInterval = 0.250) {
    guard currentMessage != nil else {
      return
    }
    timeoutTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timeoutTimerAction), userInfo: nil, repeats: false)
    if let timeoutTimer {
      RunLoop.current.add(timeoutTimer, forMode: .common)
    }
    else {
      #if DEBUG
      debugLog("failed to create timeoutTimer")
      #endif
    }
  }
  
  internal func stopTimeoutTimer() {
    timeoutTimer?.invalidate()
    timeoutTimer = nil
  }

  @objc internal func retryTimerAction() {
    
    guard let currentMessage else {
      return
    }
    
    messageState = .waitingForDatagramReceivedOK1
    startTimeoutTimer()
    node?.sendLocoNetMessage(destinationNodeId: gatewayNodeId, locoNetMessage: currentMessage)
    
  }

  internal func startRetryTimer() {
    
    retryTimer?.invalidate()
    
    retryTimer = Timer.scheduledTimer(timeInterval: 0.050, target: self, selector: #selector(retryTimerAction), userInfo: nil, repeats: false)
    
    if let retryTimer {
      RunLoop.current.add(retryTimer, forMode: .common)
    }
    else {
      #if DEBUG
      debugLog("failed to create retryTimer")
      #endif
    }
    
  }
  
  internal func sendNext() {
    
    var ok = false
    
    outputQueueLock!.lock()
    
    if currentMessage == nil && !outputQueue.isEmpty {
      currentMessage = outputQueue.removeFirst()
      ok = true
    }
    
    outputQueueLock!.unlock()
    
    if ok, let currentMessage {
      messageState = .waitingForDatagramReceivedOK1
      startTimeoutTimer()
      node?.sendLocoNetMessage(destinationNodeId: gatewayNodeId, locoNetMessage: currentMessage)
    }
    
  }
  
  internal func addToQueue(message:LocoNetMessage) {
    outputQueue.append(message)
    sendNext()
  }
  
  // MARK: Public Methods
 
  public func start() {
    
    guard state == .idle else {
      return
    }
    
    node?.datagramTypesSupported.insert(.sendLocoNetMessageReply)
    node?.datagramTypesSupported.insert(.sendLocoNetMessageReplyFailure)
    
    state = .waitingForOpSwDataAP1
    
    startTimeoutTimer()
    
    getOpSwDataAP1()
    
  }
  
  public func stop() {
    
  }
  
  public func locoNetMessageReceived(message:LocoNetMessage) {
    
    switch message.messageType {
      
    case .opSwDataAP1:

      stopTimeoutTimer()

      let trackByte = message.message[7]
      
      let mask_TrackPower    : UInt8 = 0b00000001
      let mask_EmergencyStop : UInt8 = 0b00000010
      let mask_Protocol1     : UInt8 = 0b00000100
      
      if (trackByte & mask_Protocol1) == mask_Protocol1, let csType = LocoNetCommandStationType(rawValue: message.message[11]) {
        commandStationType = csType
      }
      
      trackPowerOn = (trackByte & mask_TrackPower) == mask_TrackPower
      
      if let commandStationType, commandStationType.idleSupportedByDefault {
        globalEmergencyStop = (trackByte & mask_EmergencyStop) != mask_EmergencyStop
      }

      if state == .waitingForOpSwDataAP1 {
        state = .initialized
        self.delegate?.locoNetStartupComplete?()
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
    
    guard let sourceNodeId = message.sourceNodeId else {
      return
    }
    
    switch message.messageTypeIndicator {
      
    case .datagramReceivedOK:
      
      if let currentMessage, sourceNodeId == gatewayNodeId {
        
        stopTimeoutTimer()
        
        var data = message.payload
        
        if data.isEmpty {
          data.append(0)
        }
        
        if let flags = OpenLCBDatagramTimeout(rawValue: data[0]), flags.replyPending {
          
          messageState = messageState == .waitingForDatagramReceivedOK1 ? .waitingForSendLocoNetMessageReply1 : .waitingForSendLocoNetMessageReply2
          
          if let timeout = flags.timeout {
            startTimeoutTimer(interval: timeout)
          }
          
        }
        
        // If there is no reply pending then we assume that the first part of
        // the message has been sent.
        
        else {
          
          if currentMessage.datagramFinalPart != nil {
            messageState = .waitingForDatagramReceivedOK2
            startTimeoutTimer()
            node?.sendLocoNetMessage(destinationNodeId: gatewayNodeId, locoNetMessage: currentMessage, isFinalPart: true)
          }
          else {
            outputQueueLock!.lock()
            self.currentMessage = nil
            messageState = .idle
            outputQueueLock!.unlock()
            sendNext()
          }
          
        }
        
      }
      
    case .datagramRejected:
      
      if  let currentMessage, sourceNodeId == gatewayNodeId {
        
        stopTimeoutTimer()
        
        let errorCode = message.errorCode
        
        if OpenLCBErrorCode.isPermanentError(errorCode: errorCode) {
          
          OpenLCBErrorCode.showAlert(messageText: String(localized: "LocoNet gateway has rejected a datagram with the following error:"), errorCode: errorCode)
          
          switch message.error {
          case .permanentErrorInvalidArguments:
            outputQueueLock!.lock()
            self.currentMessage = nil
            outputQueueLock!.unlock()
            messageState = .idle
            sendNext()
          default:
            outputQueueLock!.lock()
            self.currentMessage = nil
            outputQueue.removeAll()
            outputQueueLock!.unlock()
            messageState = .idle
          }
          
        }
        else if OpenLCBErrorCode.isTemporaryError(errorCode: errorCode) {
          
          switch message.error {
          case .temporaryErrorBufferUnavailable, .temporaryErrorLocoNetCollision, .temporaryErrorOutOfOrderFinalPartOfLocoNetMessageBeforeFirstPart, .temporaryErrorOutOfOrderFirstPartOfLocoNetMessageBeforeFinishingPreviousMessage:
            startRetryTimer()
          default:
            break
          }
          
        }
        
      }

    case .datagram:
      
      if let currentMessage, sourceNodeId == gatewayNodeId {
        
        var doNext = true
        
        switch message.datagramType {
          
        case .sendLocoNetMessageReply:
          
          switch messageState {
            
          case .waitingForSendLocoNetMessageReply1:
            
            stopTimeoutTimer()
            
            if currentMessage.datagramFinalPart != nil {
              doNext = false
              messageState = .waitingForDatagramReceivedOK2
              startTimeoutTimer()
              node?.sendLocoNetMessage(destinationNodeId: gatewayNodeId, locoNetMessage: currentMessage, isFinalPart: true)
            }
            
          case .waitingForSendLocoNetMessageReply2:
            stopTimeoutTimer()
            break
            
          default:
            doNext = false
          }
          
        case .sendLocoNetMessageReplyFailure:
          
          stopTimeoutTimer()
          
          if let errorCode = UInt16(bigEndianData: [UInt8](message.payload.suffix(2))), let error = OpenLCBErrorCode(rawValue: errorCode) {
            switch error {
            case .temporaryErrorLocoNetCollision:
              doNext = false
              startRetryTimer()
            default:
              break
            }
          }
          
        default:
          doNext = false
        }
        
        if doNext {
          outputQueueLock!.lock()
          self.currentMessage = nil
          messageState = .idle
          outputQueueLock!.unlock()
          sendNext()
        }
        
      }
      
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

          if sourceNodeId == gatewayNodeId, let locoNetMessage = message.locoNetMessage {
            locoNetMessage.timeStamp = message.timeStamp
            locoNetMessage.timeSinceLastMessage = locoNetMessage.timeStamp - lastTimeStamp
            lastTimeStamp = locoNetMessage.timeStamp
            locoNetMessageReceived(message: locoNetMessage)
          }
          
        default:
          break
        }

      }
      
    default:
      break
      
    }
    
  }

}
