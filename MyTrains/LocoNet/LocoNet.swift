//
//  LocoNet.swift
//  MyTrains
//
//  Created by Paul Willmott on 02/07/2023.
//

import Foundation

private typealias QueueItem = (message:LocoNetMessage, spacingDelay:UInt8)

private enum State {
  case idle
  case waitingForDatagramReceivedOK
  case waitingForReply
}

public class LocoNet : NSObject, OpenLCBNetworkLayerDelegate {
  
  // MARK: Constructors & Destructors
  
  init(gatewayNodeId: UInt64, virtualNode: OpenLCBNodeVirtual) {
    
    self.gatewayNodeId = gatewayNodeId
    
    self.virtualNode = virtualNode
    
    self.networkLayer = virtualNode.networkLayer!
    
    self.nodeId = virtualNode.nodeId
    
    super.init()
    
    self.observerId = networkLayer.addObserver(observer: self)
    
    networkLayer.sendConsumerIdentifiedValid(sourceNodeId: nodeId, eventId: OpenLCBWellKnownEvent.locoNetMessage.rawValue)

    getOpSwDataAP1()
    
  }
  
  deinit {
    networkLayer.removeObserver(observerId: observerId)
  }
  
  // MARK: Private Properties
  
  private var gatewayNodeId : UInt64
  
  private var virtualNode : OpenLCBNodeVirtual
  
  private var networkLayer : OpenLCBNetworkLayer
  
  private var nodeId : UInt64
  
  private var observerId : Int = -1
  
  private var outputQueue : [QueueItem] = []
  
  private var currentItem : QueueItem? = nil
  
  private var state : State = .idle
  
  private var retryCount : UInt16 = 10
  
  private var timeoutTimer : Timer? = nil
  
  private var tempErrorTimer : Timer? = nil
  
  private var initComplete = false
  
  internal var commandStationType : LocoNetCommandStationType = .DT200

  // MARK: Public Properties
  
  public var delegate : LocoNetDelegate?
  
  public var trackPowerOn : Bool = false
  
  public var globalEmergencyStop : Bool = false
  
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
  
  @objc func timeoutTimerAction() {
    
    delegate?.locoNetError?(gatewayNodeId: gatewayNodeId, errorCode: OpenLCBErrorCode.temporaryErrorTimeOut.rawValue)

    currentItem = nil
    
    state = .idle
    
    send()
    
  }
  
  func startTimeoutTimer(timeInterval:TimeInterval) {
    timeoutTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timeoutTimerAction), userInfo: nil, repeats: false)
    RunLoop.current.add(timeoutTimer!, forMode: .common)
  }
  
  func stopTimeoutTimer() {
    timeoutTimer?.invalidate()
    timeoutTimer = nil
  }

  @objc func tempErrorTimerAction() {
    
    state = .waitingForDatagramReceivedOK
    
    networkLayer.sendLocoNetMessage(sourceNodeId: nodeId, destinationNodeId: gatewayNodeId, locoNetMessage: currentItem!.message.message, spacingDelay: currentItem!.spacingDelay)
    
  }
  
  func startTempErrorTimer() {
    let timeInterval:TimeInterval = 0.1
    tempErrorTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(tempErrorTimerAction), userInfo: nil, repeats: false)
    RunLoop.current.add(tempErrorTimer!, forMode: .common)
  }

  private func send() {
    
    guard !outputQueue.isEmpty else {
      return
    }
    
    currentItem = outputQueue.removeFirst()
    
    state = .waitingForDatagramReceivedOK
    
    retryCount = 10
    
    networkLayer.sendLocoNetMessage(sourceNodeId: nodeId, destinationNodeId: gatewayNodeId, locoNetMessage: currentItem!.message.message, spacingDelay: currentItem!.spacingDelay)
    
  }

  internal func addToQueue(message:LocoNetMessage, spacingDelay:UInt8) {
 
    outputQueue.append((message:message, spacingDelay:spacingDelay))
    
    if outputQueue.count == 1 {
      send()
    }

  }
 
  // MARK: Public Methods
 
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public func networkLayerStateChanged(networkLayer: OpenLCBNetworkLayer) {
    
  }
  
  public func openLCBMessageReceived(message: OpenLCBMessage) {
    
    guard let sourceNodeId = message.sourceNodeId, sourceNodeId == gatewayNodeId else {
      return
    }
    
    switch message.messageTypeIndicator {
    
    case .datagramReceivedOK:
      
      if message.destinationNodeId! == nodeId, state != .idle {
        
        if let timeout = OpenLCBDatagramTimeout(rawValue: message.payload.count == 0 ? 0 : message.payload[0]) {

          state = .waitingForReply

          switch timeout {
          case .ok, .replyPendingNoTimeout:
            startTimeoutTimer(timeInterval: 2.0)
          default:
            startTimeoutTimer(timeInterval: timeout.timeout)
          }
          
        }
        
      }
      
    case .datagramRejected:
      
      if message.destinationNodeId! == nodeId, state != .idle {
        
        if message.payload.count == 1 {
          message.payload.append(0)
        }
        
        let ec = UInt16(bigEndianData: [message.payload[0], message.payload[1]])!
        
        if let errorCode = OpenLCBErrorCode(rawValue: ec) {
          
          switch errorCode {
          case .permanentErrorInvalidArguments:
            delegate?.locoNetError?(gatewayNodeId: gatewayNodeId, errorCode: ec)
            currentItem = nil
            state = .idle
            send()
          case .permanentErrorNoConnection:
            delegate?.locoNetError?(gatewayNodeId: gatewayNodeId, errorCode: ec)
            currentItem = nil
            outputQueue.removeAll()
            state = .idle
          case .temporaryErrorBufferUnavailable:
            retryCount -= 1
            if retryCount == 0 {
              delegate?.locoNetError?(gatewayNodeId: gatewayNodeId, errorCode: ec)
              currentItem = nil
              outputQueue.removeAll()
              state = .idle
            }
            else {
              startTempErrorTimer()
            }
          default:
            if errorCode.isPermanent {
              delegate?.locoNetError?(gatewayNodeId: gatewayNodeId, errorCode: ec)
              currentItem = nil
              state = .idle
              send()
            }
            else if errorCode.isTemporary {
              retryCount -= 1
              if retryCount == 0 {
                delegate?.locoNetError?(gatewayNodeId: gatewayNodeId, errorCode: ec)
                currentItem = nil
                state = .idle
                send()
              }
              else {
                startTempErrorTimer()
              }
            }
            break
          }
          
        }
        
      }
     
    case .datagram:
      
      if message.destinationNodeId! == nodeId, let dt = message.datagramType, dt == .sendLocoNetMessageReply, state != .idle {
        
        while message.payload.count < 4 {
          message.payload.append(0)
        }
        
        if let errorCode = OpenLCBErrorCode(rawValue: UInt16(bigEndianData: [message.payload[2], message.payload[3]])!) {

          stopTimeoutTimer()

          if errorCode != .success {
            delegate?.locoNetError?(gatewayNodeId: gatewayNodeId, errorCode: errorCode.rawValue)
          }
          
          currentItem = nil
          state = .idle
          send()

        }
        
      }
      
    case .producerConsumerEventReport:
      
      if message.eventId == OpenLCBWellKnownEvent.locoNetMessage.rawValue, let locoNetMessage = LocoNetMessage(payload: message.payload), message.sourceNodeId! == gatewayNodeId {
        
        switch locoNetMessage.messageType {
          
        case .opSwDataAP1:
          
          let trackByte = locoNetMessage.message[7]
          
          let mask_TrackPower    : UInt8 = 0b00000001
          let mask_EmergencyStop : UInt8 = 0b00000010
          let mask_Protocol1     : UInt8 = 0b00000100
          
          if (trackByte & mask_Protocol1) == mask_Protocol1, let csType = LocoNetCommandStationType(rawValue: locoNetMessage.message[11]) {
            commandStationType = csType
          }
          
          trackPowerOn = (trackByte & mask_TrackPower) == mask_TrackPower
          
          if commandStationType.idleSupportedByDefault {
            globalEmergencyStop = (trackByte & mask_EmergencyStop) != mask_EmergencyStop
          }

          if !initComplete {
            initComplete = true
            self.delegate?.locoNetInitializationComplete?(locoNet: self)
          }
          
        default:
          break
        }
 
        self.delegate?.locoNetMessageReceived?(gatewayNodeId: self.gatewayNodeId, message: locoNetMessage)

      }
      
    default:
      break
    }

  }
  
}
