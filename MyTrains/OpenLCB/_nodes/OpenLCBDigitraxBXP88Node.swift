//
//  OpenLCBDigitraxBXP88Node.swift
//  MyTrains
//
//  Created by Paul Willmott on 26/08/2023.
//

import Foundation

public class OpenLCBDigitraxBXP88Node : OpenLCBNodeVirtual, LocoNetDelegate {
  
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    let configSize = 1318
    
    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configSize, isReadOnly: false, description: "")
    
    super.init(nodeId: nodeId)
    
    virtualNodeType = MyTrainsVirtualNodeType.digitraxBXP88Node
    
    isDatagramProtocolSupported = true
    
    isIdentificationSupported = true
    
    isSimpleNodeInformationProtocolSupported = true
    
    configuration.delegate = self
    
    memorySpaces[configuration.space] = configuration
    
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressLocoNetGateway)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressBoardId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressWriteBoardId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressResetToDefaults)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressWriteChanges)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressPowerManagerStatus)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressPowerManagerReporting)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressShortCircuitDetection)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDetectionSensitivity)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressOccupiedWhenFaulted)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressTranspondingState)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressFastFind)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressOperationsModeFeedback)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressSelectiveTransponding)
    
    for zone in 0 ... 7 {

      let baseAddress = zone * 162
      
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressOccupancyReporting + baseAddress)
      registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressTranspondingReporting + baseAddress)

      for event in 0 ... 15 {
        
        let eventBaseAddress = baseAddress + event * 10
        
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressLocoNetEventType)
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressIndicatorEventId)
        registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressPayloadType)

      }
    }
    
    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }
    
    initCDI(filename: "Digitrax BXP88", manufacturer: manufacturerName, model: nodeModelName)
    
  }
  
  deinit {
    locoNet = nil
  }
  
  // MARK: Private Properties
  
  internal var configuration : OpenLCBMemorySpace
  
  internal let addressLocoNetGateway         : Int = 0
  internal let addressBoardId                : Int = 8
  internal let addressWriteBoardId           : Int = 10
  internal let addressResetToDefaults        : Int = 11
  internal let addressWriteChanges           : Int = 12
  internal let addressPowerManagerStatus     : Int = 13
  internal let addressPowerManagerReporting  : Int = 14
  internal let addressShortCircuitDetection  : Int = 15
  internal let addressDetectionSensitivity   : Int = 16
  internal let addressOccupiedWhenFaulted    : Int = 17
  internal let addressTranspondingState      : Int = 18
  internal let addressFastFind               : Int = 19
  internal let addressOperationsModeFeedback : Int = 20
  internal let addressSelectiveTransponding  : Int = 21
  internal let addressOccupancyReporting     : Int = 22
  internal let addressTranspondingReporting  : Int = 23
  internal let addressLocoNetEventType       : Int = 24
  internal let addressIndicatorEventId       : Int = 25
  internal let addressPayloadType            : Int = 26

  private var locoNet : LocoNet?
  
  private var locoNetGateways : [UInt64:String] = [:]
  
  private var activeEvents : [UInt64] {
    
    var result : [UInt64] = []
    
    for zone in 0 ... 7 {
      for event in 0 ... 15 {
        if let et = locoNetEventType(zone: zone, event: event), et != .none, let eventId = indicatorEventId(zone: zone, event: event) {
          result.append(eventId)
        }
      }
    }
    
    return result
    
  }
  
  private var boardId : UInt16 {
    get {
      return configuration.getUInt16(address: addressBoardId)!
    }
    set(value) {
      configuration.setUInt(address: addressBoardId, value: value)
    }
  }
  
  private var isTranspondingEnabled : Bool {
    get {
      return configuration.getUInt8(address: addressTranspondingState)! != 0
    }
    set(value) {
      configuration.setUInt(address: addressTranspondingState, value: UInt8(value ? 1 : 0))
    }
  }
  
  private var isPowerManagerEnabled : Bool {
    get {
      return configuration.getUInt8(address: addressPowerManagerStatus)! != 0
    }
    set(value) {
      configuration.setUInt(address: addressPowerManagerStatus, value: UInt8(value ? 1 : 0))
    }
  }
  
  private var isPowerManagerReportingEnabled : Bool {
    get {
      return configuration.getUInt8(address: addressPowerManagerReporting)! != 0
    }
    set(value) {
      configuration.setUInt(address: addressPowerManagerReporting, value: UInt8(value ? 1 : 0))
    }
  }
  
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
  
  private enum LocoNetEventType : UInt8 {
    case none = 0
    case locomotiveReport = 1
    case shortCircuitReport = 2
    case shortCircuitClearedReport = 3
    case locomotiveEnteredTranspondingZone = 4
    case locomotiveExitedTranspondingZone = 5
    case locomotiveEnteredDetectionZone = 6
    case locomotiveExitedDetectionZone = 7
  }
  
  private func baseAddress(zone:Int, event:Int) -> Int {
    return zone * 162 + event * 10
  }
  
  private func locoNetEventType(zone:Int, event:Int) -> LocoNetEventType? {
    let baseAddress = baseAddress(zone: zone, event: event)
    if let et = configuration.getUInt8(address: addressLocoNetEventType + baseAddress) {
      return LocoNetEventType(rawValue: et)
    }
    return nil
  }
  
  private func indicatorEventId(zone:Int, event:Int) -> UInt64? {
    let baseAddress = baseAddress(zone: zone, event: event)
    return configuration.getUInt64(address: addressIndicatorEventId + baseAddress)
  }
  
  internal override func resetToFactoryDefaults() {

    acdiManufacturerSpaceVersion = 4
    
    manufacturerName    = virtualNodeType.manufacturerName
    nodeModelName       = virtualNodeType.name
    nodeHardwareVersion = "\(Bundle.main.releaseVersionNumberPretty)"
    nodeSoftwareVersion = "\(Bundle.main.releaseVersionNumberPretty)"

    acdiUserSpaceVersion = 2
    
    userNodeName        = ""
    userNodeDescription = ""
    
    configuration.zeroMemory()
    
    boardId = 1
    
    isTranspondingEnabled = true
    
    isPowerManagerEnabled = true
    
    isPowerManagerReportingEnabled = true
    
    var eventId = nodeId << 16
    for zone in 0 ... 7 {
      for event in 0 ... 15 {
        let baseAddress = zone * 162 + event * 10
        configuration.setUInt(address: addressIndicatorEventId + baseAddress, value: eventId)
        eventId += 1
      }
    }
    
    saveMemorySpaces()
    
  }

  internal override func resetReboot() {
    
    super.resetReboot()
    
    networkLayer?.sendConsumerIdentified(sourceNodeId: nodeId, wellKnownEvent: .nodeIsALocoNetGateway, validity: .unknown)
    
    networkLayer?.sendIdentifyProducer(sourceNodeId: nodeId, event: .nodeIsALocoNetGateway)
    
    for eventId in activeEvents {
      networkLayer?.sendProducerIdentified(sourceNodeId: nodeId, eventId: eventId, validity: .unknown)
    }
    
    guard locoNetGatewayNodeId != 0 else {
      return
    }
    
    locoNet = LocoNet(gatewayNodeId: locoNetGatewayNodeId, virtualNode: self)
    
    locoNet?.delegate = self
    
  }
  
  // MARK: Public Methods
  
  public func reloadCDI() {
    memorySpaces.removeValue(forKey: OpenLCBNodeMemoryAddressSpace.cdi.rawValue)
    initCDI(filename: "Digitrax BXP88", manufacturer: manufacturerName, model: nodeModelName)
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
      
      guard let networkLayer else {
        return
      }
      
      for eventId in activeEvents {
        if message.eventId == eventId {
          networkLayer.sendProducerIdentified(sourceNodeId: nodeId, eventId: eventId, validity: .unknown)
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
    
  }
  
  @objc public func locoNetMessageReceived(message:LocoNetMessage) {
    
    switch message.messageType {
    default:
      break
    }
    
  }
  
}

