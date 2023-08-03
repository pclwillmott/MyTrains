//
//  OpenLCBProgrammingTrackNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/08/2023.
//

import Foundation

public class OpenLCBProgrammingTrackNode : OpenLCBNodeVirtual, LocoNetDelegate {
  
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    let configSize = addressDeleteFromRoster + 1
    
    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configSize, isReadOnly: false, description: "")
    
    super.init(nodeId: nodeId)

    virtualNodeType = MyTrainsVirtualNodeType.programmingTrackNode
    
    isDatagramProtocolSupported = true

    isIdentificationSupported = true
    
    isSimpleNodeInformationProtocolSupported = true
    
    configuration.delegate = self
    
    memorySpaces[configuration.space] = configuration
    
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressLocoNetGateway)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDeleteFromRoster)

    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }
    
    initCDI(filename: "MyTrains DCC Programming Track", manufacturer: manufacturerName, model: nodeModelName)

  }
  
  deinit {
    locoNet = nil
  }
  
  // MARK: Private Properties
  
  internal var configuration : OpenLCBMemorySpace
  
  internal let addressLocoNetGateway   : Int = 0
  internal let addressDeleteFromRoster : Int = 8
  
  private var locoNet : LocoNet?
  
  private var locoNetGateways : [UInt64:String] = [:]

  // MARK: Public Properties
  
  public var locoNetGatewayNodeId : UInt64 {
    get {
      return configuration.getUInt64(address: addressLocoNetGateway)!
    }
    set(value) {
      configuration.setUInt(address: addressLocoNetGateway, value: value)
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

  // MARK: Private Methods
  
  internal override func resetReboot() {
    
    super.resetReboot()
    
    networkLayer?.sendConsumerIdentified(sourceNodeId: nodeId, wellKnownEvent: .nodeIsALocoNetGateway, validity: .unknown)
    
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .nodeIsALocoNetGateway)
    
    guard locoNetGatewayNodeId != 0 else {
      return
    }
    
    locoNet = LocoNet(gatewayNodeId: locoNetGatewayNodeId, virtualNode: self)
    
    locoNet?.delegate = self
    
  }
  
  // MARK: Public Methods
  
  public func reloadCDI() {
    memorySpaces.removeValue(forKey: OpenLCBNodeMemoryAddressSpace.cdi.rawValue)
    initCDI(filename: "MyTrains DCC Programming Track", manufacturer: manufacturerName, model: nodeModelName)
  }

  public override func initCDI(filename:String, manufacturer:String, model:String) {
    
    if let filepath = Bundle.main.path(forResource: filename, ofType: "xml") {
      do {
        
        var contents = try String(contentsOfFile: filepath)
        
        contents = contents.replacingOccurrences(of: "%%MANUFACTURER%%", with: manufacturer)
        contents = contents.replacingOccurrences(of: "%%MODEL%%", with: model)
        
        var sorted : [(nodeId:UInt64, name:String)] = []
        
        for (key, name) in locoNetGateways {
          sorted.append((nodeId:key, name:name))
        }
        
        sorted.sort {$0.name < $1.name}
        
        var gateways = "<relation><property>00.00.00.00.00.00.00.00</property><value>No Gateway Selected</value></relation>\n"
        
        for gateway in sorted {
          gateways += "<relation><property>\(gateway.nodeId.toHexDotFormat(numberOfBytes: 8))</property><value>\(gateway.name)</value></relation>\n"
        }

        contents = contents.replacingOccurrences(of: "%%LOCONET_GATEWAYS%%", with: gateways)

        let memorySpace = OpenLCBMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.cdi.rawValue, isReadOnly: true, description: "")
        memorySpace.memory = [UInt8]()
        memorySpace.memory.append(contentsOf: contents.utf8)
        memorySpace.memory.append(contentsOf: [UInt8](repeating: 0, count: 64))
        memorySpaces[memorySpace.space] = memorySpace
        
        isConfigurationDescriptionInformationProtocolSupported = true
        
        setupConfigurationOptions()
        
      }
      catch {
      }
    }
    
  }

  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    super.openLCBMessageReceived(message: message)
    
    locoNet?.openLCBMessageReceived(message: message)
    
    switch message.messageTypeIndicator {
    
    case .producerIdentifiedAsCurrentlyValid, .producerIdentifiedAsCurrentlyInvalid, .producerIdentifiedWithValidityUnknown, .producerConsumerEventReport:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
        case .nodeIsALocoNetGateway:
          
          locoNetGateways[message.sourceNodeId!] = ""
          networkLayer?.sendSimpleNodeInformationRequest(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!)
          
        default:
          break
        }
        
      }

    case .simpleNodeIdentInfoReply:
      
      if let _ = locoNetGateways[message.sourceNodeId!] {
        let node = OpenLCBNode(nodeId: message.sourceNodeId!)
        node.encodedNodeInformation = message.payload
        locoNetGateways[node.nodeId] = node.userNodeName
        reloadCDI()
      }

    case .identifyProducer:
      
      if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
        
        switch event {
        case .nodeIsADCCProgrammingTrack:
          if locoNet!.commandStationType.programmingTrackExists {
            networkLayer?.sendProducerIdentified(sourceNodeId: nodeId, wellKnownEvent: .nodeIsADCCProgrammingTrack, validity: .unknown)
          }
        default:
          break
        }
        
      }
      
    default:
      break
    }
    
  }
  
  // MARK: LocoNetDelegate Methods
  
  @objc public func locoNetInitializationComplete() {
    
    guard let locoNet else {
      return
    }
    
    if locoNet.commandStationType.programmingTrackExists {
      networkLayer?.sendWellKnownEvent(sourceNodeId: nodeId, eventId: .nodeIsADCCProgrammingTrack)
    }
    
  }
  
  @objc public func locoNetMessageReceived(message:LocoNetMessage) {
  }

}
