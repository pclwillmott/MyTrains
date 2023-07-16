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
  case initialized
}

public class LocoNet {
  
  // MARK: Constructors & Destructors
  
  init(gatewayNodeId: UInt64, virtualNode: OpenLCBNodeVirtual) {
    
    self.gatewayNodeId = gatewayNodeId
    
    self.virtualNode = virtualNode
    
    self.networkLayer = virtualNode.networkLayer!
    
    self.nodeId = virtualNode.nodeId
    
    networkLayer.sendConsumerIdentifiedValid(sourceNodeId: nodeId, eventId: OpenLCBWellKnownEvent.nodeIsALocoNetGateway.rawValue)

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
  
  // MARK: Public Methods
 
  public func locoNetMessagePartReceived(message:OpenLCBMessage) {
    
    switch message.messageTypeIndicator {
      
    case .locoNetMessageReceivedOnlyFrame:
      
      if let locoNetMessage = LocoNetMessage(payload: message.payload) {
        locoNetMessageReceived(message: locoNetMessage)
      }
      
    case .locoNetMessageReceivedFirstFrame:
      
      buffer = message.payload
      
    case .locoNetMessageReceivedMiddleFrame:
      
      buffer.append(contentsOf: message.payload)
      
    case .locoNetMessageReceivedLastFrame:
      
      buffer.append(contentsOf: message.payload)
      
      if let locoNetMessage = LocoNetMessage(payload: buffer) {
        locoNetMessageReceived(message: locoNetMessage)
      }
      
    default:
      break
    }
        
  }
  
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
  
}
