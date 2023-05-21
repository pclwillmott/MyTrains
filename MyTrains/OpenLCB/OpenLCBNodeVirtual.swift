//
//  OpenLCBNodeVirtual.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/05/2023.
//

import Foundation

public class OpenLCBNodeVirtual : OpenLCBNode, OpenLCBNetworkLayerDelegate {
  
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    self.lfsr1 = UInt32(nodeId >> 24)
    
    self.lfsr2 = UInt32(nodeId & 0xffffff)

    super.init(nodeId: nodeId)

    isIdentificationSupported = true
    
    isSimpleNodeInformationProtocolSupported = true
    
    isSimpleProtocolSubsetSupported = true
    
  }
  
  // MARK: Private Properties
  
  // MARK: Public Properties
  
  public var lfsr1 : UInt32
  
  public var lfsr2 : UInt32

  public var state : OpenLCBTransportLayerState = .inhibited
  
  public var networkLayer : OpenLCBNetworkLayer?
    
  // MARK: Public Methods
  
  public func start() {
  
    if let network = networkLayer {
      state = .permitted
      network.sendInitializationComplete(sourceNodeId: nodeId, isSimpleSetSufficient: false)
    }
    
  }
  
  public func stop() {
    if let network = networkLayer {
      state = .inhibited
    }
  }
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public func networkLayerStateChanged(networkLayer: OpenLCBNetworkLayer) {
    
  }
  
  public func openLCBMessageReceived(message: OpenLCBMessage) {
    
    switch message.messageTypeIndicator {
    case .simpleNodeIdentInfoRequest:
      if message.payload.isEmpty || message.payloadAsHex == nodeId.toHex(numberOfDigits: 12) {
        networkLayer?.sendSimpleNodeInformationReply(sourceNodeId: self.nodeId, destinationNodeId: message.sourceNodeId!, data: encodedNodeInformation)
      }
    case .verifyNodeIDNumberGlobal:
      if message.payload.isEmpty || message.payloadAsHex == nodeId.toHex(numberOfDigits: 12) {
        networkLayer?.sendVerifiedNodeIdNumber(sourceNodeId: nodeId, isSimpleSetSufficient: false)
      }
    case .protocolSupportInquiry:
      if message.destinationNodeId! == nodeId {
        var data = supportedProtocols
        networkLayer?.sendProtocolSupportReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, data: data)
      }
    default:
      break
    }
    
  }
  
}
