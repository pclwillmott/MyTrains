//
//  OpenLCBLocoNetMonitorNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/07/2023.
//

import Foundation

public class OpenLCBLocoNetMonitorNode : OpenLCBNodeVirtual, LocoNetDelegate {
  
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    self.monitorId = UInt8(nodeId & 0xff)
    
    super.init(nodeId: nodeId)

    virtualNodeType = MyTrainsVirtualNodeType.locoNetMonitorNode
    
    isDatagramProtocolSupported = true

    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }
    
    addInit()

  }
  
  deinit {
    
    locoNet = nil
    
    delegate = nil
    
    addDeinit()
    
  }
  // MARK: Private Properties
  
  private var _gatewayId : UInt64 = 0
  
  // MARK: Public Properties
  
  public var locoNet : LocoNet?
  
  public var monitorId : UInt8
  
  public var gatewayId : UInt64 {
    get {
      return _gatewayId
    }
    set(value) {
      _gatewayId = value
      locoNet = LocoNet(gatewayNodeId: _gatewayId, node: self)
      locoNet?.start()
      locoNet?.delegate = self
    }
  }
  
  public weak var delegate : OpenLCBLocoNetMonitorDelegate?
  
  // MARK: Private Methods
  
  internal override func resetToFactoryDefaults() {
    super.resetToFactoryDefaults()
    saveMemorySpaces()
  }

  // MARK: Public Methods
  
  public func sendMessage(message:LocoNetMessage) {
    locoNet?.sendMessage(message: message)
  }
  
  // MARK: LocoNetDelegate Methods
  
  @objc public func locoNetMessageReceived(message:LocoNetMessage) {
    delegate?.locoNetMessageReceived?(message: message)
  }

  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    super.openLCBMessageReceived(message: message)
    locoNet?.openLCBMessageReceived(message: message)
  }
  
}
