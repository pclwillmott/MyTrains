//
//  OpenLCBLocoNetMonitorNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/07/2023.
//

import Foundation

public class OpenLCBLocoNetMonitorNode : OpenLCBNodeVirtual, LocoNetGatewayDelegate {
  
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    self.monitorId = UInt8(nodeId & 0xff)
    
    super.init(nodeId: nodeId)

    virtualNodeType = MyTrainsVirtualNodeType.locoNetMonitorNode
    
    isDatagramProtocolSupported = true

    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }
    
    #if DEBUG
    addInit()
    #endif

  }
  
  deinit {
    
    delegate = nil
    
    #if DEBUG
    addDeinit()
    #endif
    
  }
  // MARK: Private Properties
  
  private var _gatewayId : UInt64 = 0
  
  public var locoNetGateway : LocoNetGateway?
  
  // MARK: Public Properties
  
  public var monitorId : UInt8
  
  public var gatewayId : UInt64 {
    get {
      return _gatewayId
    }
    set(value) {
      _gatewayId = value
      locoNetGateway = appNode?.locoNetGateways[value]
      locoNetGateway?.addObserver(observer: self)
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
    locoNetGateway?.sendMessage(message: message)
  }
  
  // MARK: LocoNetGatewayDelegate Methods
  
  @objc public func locoNetMessageReceived(message:LocoNetMessage) {
    delegate?.locoNetMessageReceived?(message: message)
  }

}
