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

  }
  
  // MARK: Private Properties
  
  private var gateways : [UInt64:String] = [:]
  
  private var _delegate : OpenLCBLocoNetMonitorDelegate?
  
  private var _gatewayId : UInt64 = 0
  
  private var locoNet : LocoNet?
  
  // MARK: Public Properties
  
  public var monitorId : UInt8
  
  public var gatewayId : UInt64 {
    get {
      return _gatewayId
    }
    set(value) {
      _gatewayId = value
      locoNet = LocoNet(gatewayNodeId: _gatewayId, virtualNode: self)
      locoNet?.delegate = self
    }
  }
  
  public var delegate : OpenLCBLocoNetMonitorDelegate? {
    get {
      return _delegate
    }
    set(value) {
      
      _delegate = value
      
      gateways.removeAll()
      
      networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .nodeIsALocoNetGateway)
      
      delegate?.locoNetGatewaysUpdated?(monitorNode: self, gateways: gateways)
      
    }
  }
  
  // MARK: Private Methods
  
  internal override func resetToFactoryDefaults() {

    acdiManufacturerSpaceVersion = 4
    
    manufacturerName    = virtualNodeType.manufacturerName
    nodeModelName       = virtualNodeType.name
    nodeHardwareVersion = "\(Bundle.main.releaseVersionNumberPretty)"
    nodeSoftwareVersion = "\(Bundle.main.releaseVersionNumberPretty)"

    acdiUserSpaceVersion = 2
    
    userNodeName        = ""
    userNodeDescription = ""
    
    saveMemorySpaces()
    
  }

  internal override func resetReboot() {
    
    gateways.removeAll()
    
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .nodeIsALocoNetGateway)
    
    delegate?.locoNetGatewaysUpdated?(monitorNode: self, gateways: gateways)
    
  }
  
  // MARK: Public Methods
  
  public func sendMessage(message:LocoNetMessage) {
    locoNet?.sendMessage(message: message)
  }
  
  // MARK: LocoNetDelegate Methods
  
  @objc public func locoNetInitializationComplete() {
    
  }
  
  @objc public func locoNetMessageReceived(message:LocoNetMessage) {
    delegate?.locoNetMessageReceived?(message: message)
  }

  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    super.openLCBMessageReceived(message: message)
    
    locoNet?.openLCBMessageReceived(message: message)

    switch message.messageTypeIndicator {
    
    case .simpleNodeIdentInfoReply:
      
      if let _ = gateways[message.sourceNodeId!] {
        
        let gateway = OpenLCBNode(nodeId: message.sourceNodeId!)
        gateway.encodedNodeInformation = message.payload
        
        gateways[gateway.nodeId] = gateway.userNodeName
        
        delegate?.locoNetGatewaysUpdated?(monitorNode: self, gateways: gateways)
        
      }
      
    case .producerIdentifiedAsCurrentlyValid, .producerIdentifiedAsCurrentlyInvalid, .producerIdentifiedWithValidityUnknown:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        switch event {
        case .nodeIsALocoNetGateway:
          gateways[message.sourceNodeId!] = ""
          networkLayer?.sendSimpleNodeInformationRequest(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!)
        default:
          break
        }
      }
      
    default:
      break
    }
    
  }
  
}
