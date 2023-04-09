//
//  LCCNetworkLayer.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/04/2023.
//

import Foundation

public class LCCNetworkLayer : NSObject, LCCTransportLayerDelegate {
  
  // MARK: Constructors
  
  public init(nodeId: UInt64) {
    
    self.nodeId = nodeId
    
    super.init()
    
  }
  
  // MARK: Private Properties
  
  internal var _state : LCCNetworkLayerState = .uninitialized
  
  // MARK: Public Properties
  
  public var state : LCCNetworkLayerState {
    get {
      return _state
    }
  }
  
  public var nodeId : UInt64
  
  public var transportLayers : [ObjectIdentifier:LCCTransportLayer] = [:]
  
  // MARK: Public Methods
  
  public func addTransportLayer(transportLayer: LCCTransportLayer) {
    transportLayers[ObjectIdentifier(transportLayer)] = transportLayer
    transportLayer.delegate = self
  }
  
  public func removeTransportLayer(transportLayer: LCCTransportLayer) {
    transportLayer.delegate = nil
    transportLayers[ObjectIdentifier(transportLayer)] = nil
  }
  
  // MARK: TransportLayerDelegate Methods
  
  public func openLCBMessageReceived(message: OpenLCBMessage) {
    print("SRC: \(message.sourceNodeId!.toHex(numberOfDigits: 12))")
    print("MTI: \(message.messageTypeIndicator)")
    if message.isAddressPresent {
      print("DST: \(message.destinationNodeId!.toHex(numberOfDigits: 12))\n")
    }
  }
  
  public func transportLayerStateChanged(transportLayer: LCCTransportLayer) {
    
  }
  
}
