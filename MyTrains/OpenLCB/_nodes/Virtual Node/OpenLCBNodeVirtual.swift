//
//  OpenLCBNodeVirtual.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/05/2023.
//

import Foundation

public class OpenLCBNodeVirtual : OpenLCBNode, OpenLCBNetworkLayerDelegate, OpenLCBMemorySpaceDelegate, MTPipeDelegate {
  
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    networkLayer = appDelegate.networkLayer
    
    lfsr1 = UInt32(nodeId >> 24)
    
    lfsr2 = UInt32(nodeId & 0xffffff)

    acdiManufacturerSpace = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.acdiManufacturer.rawValue, defaultMemorySize: 125, isReadOnly: true, description: "")

    acdiUserSpace = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.acdiUser.rawValue, defaultMemorySize: 128, isReadOnly: false, description: "")

    virtualNodeConfigSpace = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.virtualNodeConfig.rawValue, defaultMemorySize: 36, isReadOnly: false, description: "")

    super.init(nodeId: nodeId)

    acdiManufacturerSpace.delegate = self

    memorySpaces[acdiManufacturerSpace.space] = acdiManufacturerSpace
    
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.acdiManufacturer.rawValue, address: addressACDIManufacturerSpaceVersion)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.acdiManufacturer.rawValue, address: addressACDIManufacturerName)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.acdiManufacturer.rawValue, address: addressACDIModelName)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.acdiManufacturer.rawValue, address: addressACDIHardwareVersion)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.acdiManufacturer.rawValue, address: addressACDISoftwareVersion)
    
    acdiUserSpace.delegate = self

    memorySpaces[acdiUserSpace.space] = acdiUserSpace

    registerVariable(space: OpenLCBNodeMemoryAddressSpace.acdiUser.rawValue, address: addressACDIUserSpaceVersion)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.acdiUser.rawValue, address: addressACDIUserNodeName)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.acdiUser.rawValue, address: addressACDIUserNodeDescription)

    virtualNodeConfigSpace.delegate = self
    
    memorySpaces[virtualNodeConfigSpace.space] = virtualNodeConfigSpace

    registerVariable(space: OpenLCBNodeMemoryAddressSpace.virtualNodeConfig.rawValue, address: addressVirtualNodeConfigSpaceVersion)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.virtualNodeConfig.rawValue, address: addressVirtualNodeConfigLayoutNodeId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.virtualNodeConfig.rawValue, address: addressVirtualNodeConfigNodeType)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.virtualNodeConfig.rawValue, address: addressVirtualNodeConfigUniqueEventId)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.virtualNodeConfig.rawValue, address: addressVirtualNodeConfigNextNodeIdSeed)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.virtualNodeConfig.rawValue, address: addressVirtualNodeConfigHostAppNodeId)

    isSimpleNodeInformationProtocolSupported = true
    
    isDatagramProtocolSupported = true
    
    isMemoryConfigurationProtocolSupported = true
    
    isAbbreviatedDefaultCDIProtocolSupported = true
    
    isEventExchangeProtocolSupported = true
    
    isFirmwareUpgradeProtocolSupported = false
    
    setupConfigurationOptions()

  }
  
  // MARK: Private Properties
  
  public var pipeName : String {
    return "MyTrains_Node_\(nodeId.toHex(numberOfDigits: 12))"
  }
  
  private var lockedNodeId : UInt64 = 0
  
  internal var userConfigEventConsumedAddresses : Set<Int> = []
  internal var userConfigEventProducedAddresses : Set<Int> = []

  internal var memorySpaces : [UInt8:OpenLCBMemorySpace] = [:]
  
  internal var cdiFilename : String? 
  
  internal var registeredVariables : [UInt8:Set<Int>] = [:]
  
  internal var unitConversions : [UInt8:[Int:UnitConversionType]] = [:]
  
  internal let addressACDIManufacturerSpaceVersion    : Int = 0
  internal let addressACDIManufacturerName            : Int = 1
  internal let addressACDIModelName                   : Int = 42
  internal let addressACDIHardwareVersion             : Int = 83
  internal let addressACDISoftwareVersion             : Int = 104
  
  internal let addressACDIUserSpaceVersion            : Int = 0
  internal let addressACDIUserNodeName                : Int = 1
  internal let addressACDIUserNodeDescription         : Int = 64
  
  internal let addressVirtualNodeConfigSpaceVersion   : Int = 0
  internal let addressVirtualNodeConfigLayoutNodeId   : Int = 2
  internal let addressVirtualNodeConfigNodeType       : Int = 10
  internal let addressVirtualNodeConfigUniqueEventId  : Int = 12
  internal let addressVirtualNodeConfigNextNodeIdSeed : Int = 20
  internal let addressVirtualNodeConfigHostAppNodeId  : Int = 28 // 36

  internal var datagramTypesSupported : Set<OpenLCBDatagramType> = [
    .writeCommandGeneric,
    .writeCommand0xFD,
    .writeCommand0xFE,
    .writeCommand0xFF,
    .writeReply0xFD,
    .writeReply0xFE,
    .writeReply0xFF,
    .writeReplyGeneric,
    .writeReplyFailure0xFD,
    .writeReplyFailure0xFE,
    .writeReplyFailure0xFF,
    .writeReplyFailureGeneric,
//  .writeUnderMaskCommandGeneric,
//  .writeUnderMaskCommand0xFD,
//  .writeUnderMaskCommand0xFE,
//  .writeUnderMaskCommand0xFF,
    .readCommandGeneric,
    .readCommand0xFD,
    .readCommand0xFE,
    .readCommand0xFF,
    .readReply0xFD,
    .readReply0xFE,
    .readReply0xFF,
    .readReplyGeneric,
    .readReplyFailure0xFD,
    .readReplyFailure0xFE,
    .readReplyFailure0xFF,
    .readReplyFailureGeneric,
    .getConfigurationOptionsCommand,
    .getConfigurationOptionsReply,
    .getAddressSpaceInformationCommand,
    .getAddressSpaceInformationReply,
    .getAddressSpaceInformationReplyLowAddressPresent,
    .lockReserveCommand,
    .lockReserveReply,
    .getUniqueEventIDCommand,
    .getUniqueEventIDReply,
    .unfreezeCommand,
    .freezeCommand,
    .updateCompleteCommand,
    .resetRebootCommand,
    .reinitializeFactoryResetCommand,
  ]
  
  internal var hardwareNodeState : OpenLCBHardwareNodeState = .operating {
    didSet {
      isFirmwareUpgradeActive = hardwareNodeState == .firmwareUpgrade
    }
  }
  
  internal var firmwareBuffer : [UInt8] = []
  
//  internal var txPipe : MTPipe?
  
  // MARK: Public Properties
  
  public var visibility : OpenLCBNodeVisibility {
    return virtualNodeType.visibility
  }

  public var isFullProtocolRequired = false
  
  public var eventsConsumed : Set<UInt64> = []
  
  public var eventsProduced : Set<UInt64> = []
  
  public var userConfigEventsConsumed : Set<UInt64> = []
  
  public var userConfigEventsProduced : Set<UInt64> = []
  
  public var eventRangesConsumed : [EventRange] = []
  
  public var eventRangesProduced : [EventRange] = []

  public var lfsr1 : UInt32
  
  public var lfsr2 : UInt32

  public var state : OpenLCBTransportLayerState = .inhibited
  
  public var networkLayer : OpenLCBNetworkLayer?
  
  public var memorySpacesInitialized : Bool {
    return acdiManufacturerSpace.getUInt8(address: addressACDIManufacturerSpaceVersion) != 0
  }
    
  public var acdiManufacturerSpace : OpenLCBMemorySpace
  
  public var acdiUserSpace : OpenLCBMemorySpace
  
  public var virtualNodeConfigSpace : OpenLCBMemorySpace
  
  public var configuration : OpenLCBMemorySpace?

  public override var acdiManufacturerSpaceVersion : UInt8 {
    get {
      return acdiManufacturerSpace.getUInt8(address: addressACDIManufacturerSpaceVersion)!
    }
    set(value) {
      acdiManufacturerSpace.setUInt(address: addressACDIManufacturerSpaceVersion, value: value)
    }
  }
  
  public override var manufacturerName : String {
    get {
      return acdiManufacturerSpace.getString(address: addressACDIManufacturerName, count: 41)!
    }
    set(value) {
      acdiManufacturerSpace.setString(address: addressACDIManufacturerName, value: String(value.prefix(40)), fieldSize: 41)
    }
  }
  
  public override var nodeModelName : String {
    get {
      return acdiManufacturerSpace.getString(address: addressACDIModelName, count: 41)!
    }
    set(value) {
      acdiManufacturerSpace.setString(address: addressACDIModelName, value: String(value.prefix(40)), fieldSize: 41)
    }
  }
  
  public override var nodeHardwareVersion : String {
    get {
      return acdiManufacturerSpace.getString(address: addressACDIHardwareVersion, count: 21)!
    }
    set(value) {
      acdiManufacturerSpace.setString(address: addressACDIHardwareVersion, value: String(value.prefix(20)), fieldSize: 21)
    }
  }
  
  public override var nodeSoftwareVersion : String {
    get {
      return acdiManufacturerSpace.getString(address: addressACDISoftwareVersion, count: 21)!
    }
    set(value) {
      acdiManufacturerSpace.setString(address: addressACDISoftwareVersion, value: String(value.prefix(20)), fieldSize: 21)
    }

  }
  
  public override var acdiUserSpaceVersion : UInt8 {
    get {
      return acdiUserSpace.getUInt8(address: addressACDIUserSpaceVersion)!
    }
    set(value) {
      acdiUserSpace.setUInt(address: addressACDIUserSpaceVersion, value: value)
    }
  }

  public override var userNodeName : String { 
    get {
      return acdiUserSpace.getString(address: addressACDIUserNodeName, count: 63)!
    }
    set(value) {
      acdiUserSpace.setString(address: addressACDIUserNodeName, value: String(value.prefix(62)), fieldSize: 63)
    }
  }

  public override var userNodeDescription : String {
    get {
      return acdiUserSpace.getString(address: addressACDIUserNodeDescription, count: 64)!
    }
    set(value) {
      acdiUserSpace.setString(address: addressACDIUserNodeDescription, value: String(value.prefix(63)), fieldSize: 64)
    }
  }
  
  public var virtualNodeConfigSpaceVersion : UInt16 {
    get {
      return virtualNodeConfigSpace.getUInt16(address: addressVirtualNodeConfigSpaceVersion)!
    }
    set(value) {
      virtualNodeConfigSpace.setUInt(address: addressVirtualNodeConfigSpaceVersion, value:value)
    }
  }

  public var layoutNodeId : UInt64 {
    get {
      return virtualNodeConfigSpace.getUInt64(address: addressVirtualNodeConfigLayoutNodeId)!
    }
    set(value) {
      virtualNodeConfigSpace.setUInt(address: addressVirtualNodeConfigLayoutNodeId, value:value)
    }
  }

  public var virtualNodeType : MyTrainsVirtualNodeType {
    get {
      return MyTrainsVirtualNodeType(rawValue: virtualNodeConfigSpace.getUInt16(address: addressVirtualNodeConfigNodeType)!)!
    }
    set(value) {
      virtualNodeConfigSpace.setUInt(address: addressVirtualNodeConfigNodeType, value:value.rawValue)
    }
  }
  
  public var isSwitchboardNode : Bool {
    
    let switchboardNodeTypes : Set<MyTrainsVirtualNodeType> = [
      .switchboardPanelNode,
      .switchboardItemNode,
    ]
    
    return switchboardNodeTypes.contains(virtualNodeType)
    
  }

  public var nextUniqueEventId : UInt64 {
    get {
      let id = virtualNodeConfigSpace.getUInt64(address: addressVirtualNodeConfigUniqueEventId)!
      self.nextUniqueEventId = id + 1
      return id
    }
    set(value) {
      virtualNodeConfigSpace.setUInt(address: addressVirtualNodeConfigUniqueEventId, value:value)
      virtualNodeConfigSpace.save()
    }
  }

  public var nextUniqueNodeIdSeed : UInt64 {
    get {
      return virtualNodeConfigSpace.getUInt64(address: addressVirtualNodeConfigNextNodeIdSeed)!
    }
    set(value) {
      virtualNodeConfigSpace.setUInt(address: addressVirtualNodeConfigNextNodeIdSeed, value:value)
      virtualNodeConfigSpace.save()
    }
  }

  public var hostAppNodeId : UInt64 {
    get {
      return virtualNodeConfigSpace.getUInt64(address: addressVirtualNodeConfigHostAppNodeId)!
    }
    set(value) {
      virtualNodeConfigSpace.setUInt(address: addressVirtualNodeConfigHostAppNodeId, value:value)
      virtualNodeConfigSpace.save()
    }
  }

  // MARK: Private Methods
  
  internal func getUserConfigEvents(eventAddresses:Set<Int>) -> Set<UInt64> {
  
    var result : Set<UInt64> = []
    
    if let configuration {
      
      for address in eventAddresses {
        if let eventId = configuration.getUInt64(address: address), eventId != 0 {
          result.insert(eventId)
        }
      }
      
    }
    
    return result
    
  }
  
  internal func standardACDI(cdi:String) -> String {
 
    var acdi = "<acdi/>\n"
    
    acdi += "<segment space='251' origin='1'>\n"
    
    let nodeId = String(localized: "Node ID", comment: "Used for title of the Node ID segment of a CDI")
    
    acdi += "<name>\(nodeId)</name>\n"
    acdi += "<string size='63'>\n"
    
    let userName = String(localized: "User Name", comment: "Used for the title of the User Name input field in CDI")
    
    acdi += "<name>\(userName)</name>\n"
    
    let userNameDescription = String(localized: "This name will appear in network browsers for this device.", comment: "Used for the description of the user name input field in the CDI")
    
    acdi += "<description>\(userNameDescription)</description>\n"
    
    acdi += "</string>\n"
    
    acdi += "<string size='64'>"

    let userDescription = String(localized: "User Description", comment: "Used for the title of the User Description input field in CDI")

    acdi += "<name>\(userDescription)</name>\n"

    let userDescriptionDescription = String(localized: "This description will appear in network browsers for this device.", comment: "Used for the description of the user description input field in the CDI")

    acdi += "<description>\(userDescriptionDescription)</description>\n"
                                                                        
    acdi += "</string>\n"
    acdi += "</segment>\n"

    return cdi.replacingOccurrences(of: CDI.ACDI, with: acdi)
    
  }

  internal func standardVirtualNodeConfig(cdi:String) -> String {
 
    var config = ""
    
    #if DEBUG
    
    config += "<segment space='0' origin='0'>\n<name>Virtual Node Configuration</name>\n"

    config += "<int size='2'>\n"
    config += "  <name>Configuration Space Version</name>\n"
    config += "  <description>This is the number of items in the configuration space.</description>\n"
    config += "</int>\n"

    config += "<eventid>\n"
    config += "  <name>Layout Node</name>\n"
    config += "  %%LAYOUT_NODES%%\n"
    config += "</eventid>\n"

    config += "<int size='2'>\n"
    config += "  <name>Virtual Node Type</name>\n"
    config += "  <description>The type of this node.</description>\n"
    config += "%%VIRTUAL_NODE_TYPE%%"
    config += "</int>\n"

    config += "<eventid>\n"
    config += "  <name>This is the next Unique Event ID that will be returned upon request.</name>\n"
    config += "  <description>This is the next unique event ID.</description>\n"
    config += "</eventid>\n"

    config += "<eventid>\n"
    config += "  <name>Next Unique Node ID Seed</name>\n"
    config += "  <description>This is the seed that will be used to generate the next unique node ID.</description>\n"
    config += "</eventid>\n"

    config += "<eventid>\n"
    config += "  <name>Application Node ID</name>\n"
    config += "  <description>This is the node ID of the host application instance.</description>\n"
    config += "</eventid>\n"

    config += "</segment>\n"

    config = MyTrainsVirtualNodeType.insertMap(cdi: config)
    
    if let appNode {
      config = appNode.insertLayoutMap(cdi: config)
    }

    #endif
    
    return cdi.replacingOccurrences(of: CDI.VIRTUAL_NODE_CONFIG, with: config)
    
  }

  internal func initCDI() {
    
    if let cdiFilename, let filepath = Bundle.main.path(forResource: cdiFilename, ofType: "xml") {
      do {
        
        var cdi = try String(contentsOfFile: filepath)

        // Apply substitutions for dynamic elements such as node ids.
        
        cdi = customizeDynamicCDI(cdi: cdi)
        
          // Do mappings for Layouts
          
        // Apply these after the previous call so that the previous call
        // can override the substitutions if necessary.
        
        cdi = cdi.replacingOccurrences(of: CDI.MANUFACTURER, with: manufacturerName)
        cdi = cdi.replacingOccurrences(of: CDI.MODEL, with: nodeModelName)
        cdi = cdi.replacingOccurrences(of: CDI.SOFTWARE_VERSION, with: nodeSoftwareVersion)
        cdi = cdi.replacingOccurrences(of: CDI.HARDWARE_VERSION, with: nodeHardwareVersion)
        cdi = standardACDI(cdi: cdi)
        cdi = standardVirtualNodeConfig(cdi: cdi)
/*
        cdi = OpenLCBFunction.insertMap(cdi: cdi)
 
        cdi = MTSerialPortManager.insertMap(cdi: cdi)
        cdi = BaudRate.insertMap(cdi: cdi)
        cdi = Parity.insertMap(cdi: cdi)
        cdi = FlowControl.insertMap(cdi: cdi)
 
        cdi = OpenLCBClockOperatingMode.insertMap(cdi: cdi)
        cdi = OpenLCBClockType.insertMap(cdi: cdi)
        cdi = ClockCustomIdType.insertMap(cdi: cdi)
        cdi = OpenLCBClockState.insertMap(cdi: cdi)
        cdi = EnableState.insertMap(cdi: cdi)
        cdi = OpenLCBClockInitialDateTime.insertMap(cdi: cdi)

 
        cdi = UnitLength.insertMap(cdi: cdi)
        cdi = UnitSpeed.insertMap(cdi: cdi)
 
        cdi = TrackCode.insertMap(cdi: cdi)
        cdi = TrackGauge.insertMap(cdi: cdi, scale: .scale1to76dot2)
        cdi = TrackElectrificationType.insertMap(cdi: cdi)
        cdi = TurnoutMotorType.insertMap(cdi: cdi)
        cdi = Orientation.insertMap(cdi: cdi)
        cdi = SwitchBoardItemType.insertMap(cdi: cdi)
        cdi = BlockDirection.insertMap(cdi: cdi)

        if let app = networkLayer?.myTrainsNode {
          cdi = app.insertPanelMap(cdi: cdi, layoutId: layoutNodeId)
          cdi = app.insertGroupMap(cdi: cdi, layoutId: layoutNodeId)
        }

        cdi = CountryCode.insertMap(cdi: cdi)
        cdi = YesNo.insertMap(cdi: cdi)
        cdi = TrackGauge.insertMap(cdi: cdi)

*/
        
        let memorySpace = OpenLCBMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.cdi.rawValue, isReadOnly: true, description: "")
        
        memorySpace.memory = [UInt8]()
        memorySpace.memory.append(contentsOf: cdi.utf8)
        memorySpace.memory.append(contentsOf: [UInt8](repeating: 0, count: 64))
        
        memorySpaces[OpenLCBNodeMemoryAddressSpace.cdi.rawValue] = memorySpace
        
        isConfigurationDescriptionInformationProtocolSupported = true
        
        setupConfigurationOptions()
        
      }
      catch {
      }
    }
    
  }
  
  internal func customizeDynamicCDI(cdi:String) -> String {
    return cdi
  }

  internal func resetReboot() {
    lockedNodeId = 0
    setupConfigurationOptions()
  }
  
  internal func resetToFactoryDefaults() {
    
    acdiManufacturerSpaceVersion = 4
    
    manufacturerName     = virtualNodeType.manufacturerName
    nodeModelName        = virtualNodeType.title
    nodeHardwareVersion  = "\(Bundle.main.releaseVersionNumberPretty)"
    nodeSoftwareVersion  = "\(Bundle.main.releaseVersionNumberPretty)"

    acdiUserSpaceVersion = 2
    
    userNodeName         = virtualNodeType.defaultUserNodeName
    userNodeDescription  = ""
    
    lockedNodeId = 0

    if virtualNodeConfigSpaceVersion == 0 {
      virtualNodeConfigSpaceVersion = 5
      nextUniqueEventId = nodeId << 16
      nextUniqueNodeIdSeed = nodeId
    }

  }
  
  internal func saveMemorySpaces() {
    for (_, memorySpace) in memorySpaces {
      if memorySpace.space != OpenLCBNodeMemoryAddressSpace.cdi.rawValue {
        memorySpace.save()
      }
    }
  }
  
  internal func readCVs(sourceNodeId:UInt64, memorySpace:OpenLCBMemorySpace, startAddress:UInt32, count:UInt8) {
    
    guard OpenLCBProgrammingMode(rawValue: startAddress & OpenLCBProgrammingMode.modeMask) != nil else {
      sendReadReplyFailure(destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress, errorCode: .permanentErrorInvalidArguments)
      return
    }
    
    let address = startAddress & OpenLCBProgrammingMode.addressMask
    
    if let data = memorySpace.getBlock(address: Int(address), count: Int(count)) {
      sendReadReply(destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress, data: data)
    }
    else {
      sendReadReplyFailure(destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress, errorCode: .permanentErrorAddressOutOfBounds)
    }

  }
  
  internal func writeCVs(sourceNodeId:UInt64, memorySpace:OpenLCBMemorySpace, startAddress:UInt32, data: [UInt8]) {
    
    guard OpenLCBProgrammingMode(rawValue: startAddress & OpenLCBProgrammingMode.modeMask) != nil else {
      sendWriteReplyFailure(destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress, errorCode: .permanentErrorInvalidArguments)
      return
    }
    
    let address = startAddress & OpenLCBProgrammingMode.addressMask
    
    if memorySpace.isWithinSpace(address: Int(address), count: data.count) {
      memorySpace.setBlock(address: Int(address), data: data, isInternal: false)
      memorySpace.save()
      sendWriteReply(destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress)
    }
    else {
      sendWriteReplyFailure(destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress, errorCode: .permanentErrorAddressOutOfBounds)
    }

  }
  
  internal func setupConfigurationOptions() {
    
    var minSpace : UInt8 = 0xff
    var maxSpace : UInt8 = 0x00
    
    for (key, _) in memorySpaces {
      if key < minSpace {
        minSpace = key
      }
      if key > maxSpace {
        maxSpace = key
      }
    }
    
    configurationOptions.highestAddressSpace = maxSpace
    configurationOptions.lowestAddressSpace = minSpace
    
    configurationOptions.is1ByteWriteSupported = true
    configurationOptions.is2ByteWriteSupported = true
    configurationOptions.is4ByteWriteSupported = true
    configurationOptions.isStreamSupported = false
    configurationOptions.is64ByteWriteSupported = false
    configurationOptions.isAnyLengthWriteSupported = true
    configurationOptions.isReadFromACDIManufacturerAvailable = true
    configurationOptions.isReadFromACDIUserAvailable = true
    configurationOptions.isUnalignedReadsSupported = true
    configurationOptions.isUnalignedWritesSupported = true
    configurationOptions.isWriteUnderMaskSupported = false
    configurationOptions.isWriteToACDIUserAvailable = true

  }
  
  internal func willDelete() {
  }
  
  // MARK: Public Methods
  
  public func gatewayStart() {
  }
  
  public func start() {
    
    state = .permitted

    if cdiFilename != nil {
      isConfigurationDescriptionInformationProtocolSupported = true
    }

    sendInitializationComplete()
    
    resetReboot()

    userConfigEventsConsumed = getUserConfigEvents(eventAddresses: userConfigEventConsumedAddresses)
    userConfigEventsProduced = getUserConfigEvents(eventAddresses: userConfigEventProducedAddresses)

    for eventId in eventsConsumed.union(userConfigEventsConsumed) {
      if !OpenLCBWellKnownEvent.isAutomaticallyRouted(eventId: eventId) {
        var validity : OpenLCBValidity = .unknown
        setValidity(eventId: eventId, validity: &validity)
        sendConsumerIdentified(eventId: eventId, validity: validity)
      }
    }

    for eventId in eventsProduced.union(userConfigEventsProduced) {
      if !OpenLCBWellKnownEvent.isAutomaticallyRouted(eventId: eventId) {
        var validity : OpenLCBValidity = .unknown
        setValidity(eventId: eventId, validity: &validity)
        sendProducerIdentified(eventId: eventId, validity: validity)
      }
    }
    
    for eventRange in eventRangesConsumed {
      sendConsumerRangeIdentified(eventId: eventRange.eventId)
    }

    for eventRange in eventRangesProduced {
      sendProducerRangeIdentified(eventId: eventRange.eventId)
    }

    completeStartUp()

  }
  
  internal func completeStartUp() {
  }
  
  internal func setValidity(eventId:UInt64, validity: inout OpenLCBValidity) {
  }

  internal func setValidity(eventAddress:Int, validity: inout OpenLCBValidity) {
  }

  public func stop() {
//    txPipe?.close()
    state = .inhibited
  }
  
  public func registerVariable(space:UInt8, address:Int, unitConversionType:UnitConversionType = .none) {
    
    var addresses  = Set<Int>()
    if let temp = registeredVariables[space] {
      addresses = temp
    }
    addresses.insert(address)
    registeredVariables[space] = addresses
    
  }
  
  public func variableChanged(space:OpenLCBMemorySpace, address:Int) {
    
  }
  
  // MARK: OpenLCBMemorySpaceDelegate Methods
  
  public func memorySpaceChanged(memorySpace: OpenLCBMemorySpace, startAddress: Int, endAddress: Int) {
    
    var newUserConfigEventsConsumed = userConfigEventsConsumed
    var newUserConfigEventsProduced = userConfigEventsProduced
    
    if let addresses = self.registeredVariables[memorySpace.space] {
      for address in addresses {
        if address >= startAddress && address <= endAddress {
          if userConfigEventConsumedAddresses.contains(address) {
            if address + 7 <= endAddress, let eventId = configuration?.getUInt64(address: address) {
              newUserConfigEventsConsumed.insert(eventId)
            }
          }
          else if userConfigEventProducedAddresses.contains(address) {
            if address + 7 <= endAddress, let eventId = configuration?.getUInt64(address: address) {
              newUserConfigEventsProduced.insert(eventId)
            }
          }
          else {
            variableChanged(space: memorySpace, address: address)
          }
        }
      }
    }
    
    for eventId in newUserConfigEventsConsumed.subtracting(userConfigEventsConsumed) {
      if !OpenLCBWellKnownEvent.isAutomaticallyRouted(eventId: eventId) {
        var validity : OpenLCBValidity = .unknown
        setValidity(eventId: eventId, validity: &validity)
        sendConsumerIdentified(eventId: eventId, validity: validity)
      }
    }

    for eventId in newUserConfigEventsProduced.subtracting(userConfigEventsProduced) {
      if !OpenLCBWellKnownEvent.isAutomaticallyRouted(eventId: eventId) {
        var validity : OpenLCBValidity = .unknown
        setValidity(eventId: eventId, validity: &validity)
        sendProducerIdentified(eventId: eventId, validity: validity)
      }
    }
    
    userConfigEventsConsumed = getUserConfigEvents(eventAddresses: userConfigEventConsumedAddresses)
    userConfigEventsProduced = getUserConfigEvents(eventAddresses: userConfigEventProducedAddresses)

  }
    
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public func networkLayerStateChanged(networkLayer: OpenLCBNetworkLayer) {
  }
  
  public func openLCBMessageReceived(message: OpenLCBMessage) {
    
    guard let sourceNodeId = message.sourceNodeId else {
      #if DEBUG
      debugLog("no sourceNodeId")
      #endif
      return
    }

    switch message.messageTypeIndicator {
      
    case .simpleNodeIdentInfoRequest:
      if let data = encodedNodeInformation {
        sendSimpleNodeInformationReply(destinationNodeId: sourceNodeId, data: data)
      }

    case .verifyNodeIDAddressed:
      sendVerifiedNodeId(isSimpleSetSufficient: false)

    case .verifyNodeIDGlobal:
      let id = UInt64(bigEndianData: message.payload)
      if message.payload.isEmpty || id! == nodeId {
       sendVerifiedNodeId(isSimpleSetSufficient: false)
      }
      
    case .protocolSupportInquiry:
      
      var data = supportedProtocols
      /*
      if isSwitchboardNode && !networkLayer.isInternalVirtualNode(nodeId: sourceNodeId) {
        let mask : UInt8 = 0x08
        data[1] = data[1] & ~mask
      }
      */
      sendProtocolSupportReply(destinationNodeId: sourceNodeId, data: data)

    case .datagram:
      
      if let datagramType = message.datagramType {
        
        switch datagramType {
          
        case .getUniqueEventIDCommand:
          
          sendDatagramReceivedOK(destinationNodeId: sourceNodeId, timeOut: .replyPendingNoTimeout)
          
          var payload = OpenLCBDatagramType.getUniqueEventIDReply.bigEndianData
          
          let numberRequested = message.payload.count >= 3 ? (message.payload[2] & 0b00000111) : 0
          
          if numberRequested > 0 {
            for _ in 1 ... numberRequested {
              payload.append(contentsOf: nextUniqueEventId.bigEndianData)
            }
          }
        
          sendDatagram(destinationNodeId: sourceNodeId, data: payload)

        case.getConfigurationOptionsCommand:
          sendDatagramReceivedOK(destinationNodeId: sourceNodeId, timeOut: .replyPendingNoTimeout)
          sendGetConfigurationOptionsReply(destinationNodeId: sourceNodeId, node: self)

        case .reinitializeFactoryResetCommand:
          sendDatagramReceivedOK(destinationNodeId: sourceNodeId, timeOut: .ok)
          self.resetToFactoryDefaults()

        case .resetRebootCommand:
          sendDatagramReceivedOK(destinationNodeId: sourceNodeId, timeOut: .ok)
          self.stop()
          self.start()

        case.lockReserveCommand:
          
          sendDatagramReceivedOK(destinationNodeId: sourceNodeId, timeOut: .replyPendingNoTimeout)

          message.payload.removeFirst(2)
          
          if let id = UInt64(bigEndianData: message.payload) {
            if lockedNodeId == 0 || id == 0 {
              lockedNodeId = id
            }
          }
          
          sendLockReserveReply(destinationNodeId: sourceNodeId, reservedNodeId: lockedNodeId)

        case .getAddressSpaceInformationCommand:
          
          message.payload.removeFirst(2) 
          
          let space = message.payload[0]
          
          if OpenLCBNodeMemoryAddressSpace.cdi.rawValue == space {
            initCDI()
          }
          
          if let memorySpace = memorySpaces[space] {
            sendDatagramReceivedOK(destinationNodeId: sourceNodeId, timeOut: .replyPendingNoTimeout)
            sendGetAddressSpaceInformationReply(destinationNodeId: sourceNodeId, memorySpace: memorySpace)
          }
          else {
            sendDatagramRejected(destinationNodeId: sourceNodeId, errorCode: .permanentErrorAddressSpaceUnknown)
          }

        case .readCommandGeneric, .readCommand0xFD, .readCommand0xFE, .readCommand0xFF:
 
          sendDatagramReceivedOK(destinationNodeId: sourceNodeId, timeOut: .replyPendingNoTimeout)
          
          var data = message.payload
          
          var bytesToRemove = 6
          
          var space : UInt8
          
          switch message.datagramType {
          case .readCommand0xFD:
            space = 0xfd
          case .readCommand0xFE:
            space = 0xfe
          case .readCommand0xFF:
            space = 0xff
          default:
            space = data[6]
            bytesToRemove = 7
          }

          let startAddress = UInt32(bigEndianData: [data[2], data[3], data[4], data[5]])!

          if OpenLCBNodeMemoryAddressSpace.cdi.rawValue == space && startAddress == 0 {
            initCDI()
          }

          if let memorySpace = memorySpaces[space] {
            
            data.removeFirst(bytesToRemove)
            let readCount = data[0] & 0x7f
            
            if readCount == 0 || readCount > 64 {
              sendReadReplyFailure(destinationNodeId: sourceNodeId, addressSpace: space, startAddress: startAddress, errorCode: .permanentErrorInvalidArguments)
            }
            else if let spaceId = memorySpace.standardSpace, spaceId == .cv {
              readCVs(sourceNodeId: sourceNodeId, memorySpace: memorySpace, startAddress: startAddress, count: readCount)
            }
            else {
              if memorySpace.isWithinSpace(address: Int(startAddress), count: 1) {
                let remaining = memorySpace.addressSpaceInformation.realHighestAddress - startAddress + 1
                if let data = memorySpace.getBlock(address: Int(startAddress), count: min(Int(remaining), Int(readCount)), isInternal: false) {
                  sendReadReply(destinationNodeId: sourceNodeId, addressSpace: space, startAddress: startAddress, data: data)
                }
              }
              else {
                sendReadReplyFailure(destinationNodeId: sourceNodeId, addressSpace: space, startAddress: startAddress, errorCode: .permanentErrorAddressOutOfBounds)
              }
              
            }
            
          }
          else {
            sendReadReplyFailure(destinationNodeId: sourceNodeId, addressSpace: space, startAddress: startAddress, errorCode: .permanentErrorAddressSpaceUnknown)
          }

        case .unfreezeCommand:
          
          if let spaceId = OpenLCBNodeMemoryAddressSpace(rawValue: message.payload[2]), spaceId == .firmware {
            hardwareNodeState = .operating
            sendInitializationComplete()
          }
          else {
            sendDatagramRejected(destinationNodeId: sourceNodeId, errorCode: .permanentErrorAddressSpaceUnknown)
          }

        case .freezeCommand:
          
          if let spaceId = OpenLCBNodeMemoryAddressSpace(rawValue: message.payload[2]), spaceId == .firmware {
            hardwareNodeState = .firmwareUpgrade
            sendDatagramReceivedOK(destinationNodeId: sourceNodeId, timeOut: .ok)
            sendInitializationComplete()
            firmwareBuffer = []
          }
          else {
            sendDatagramRejected(destinationNodeId: sourceNodeId, errorCode: .permanentErrorAddressSpaceUnknown)
          }
          
        case .writeCommandGeneric, .writeCommand0xFD, .writeCommand0xFE, .writeCommand0xFF:

          sendDatagramReceivedOK(destinationNodeId: sourceNodeId, timeOut: .replyPendingNoTimeout)
          
          var data = message.payload
          
          var bytesToRemove = 6
          
          var space : UInt8
          
          switch message.datagramType {
          case .writeCommand0xFD:
            space = 0xfd
          case .writeCommand0xFE:
            space = 0xfe
          case .writeCommand0xFF:
            space = 0xff
          default:
            space = data[6]
            bytesToRemove = 7
          }
          
          let startAddress = UInt32(bigEndianData: [data[2], data[3], data[4], data[5]])!
          
          data.removeFirst(bytesToRemove)

          if let spaceId = OpenLCBNodeMemoryAddressSpace(rawValue: space), spaceId == .firmware && hardwareNodeState == .firmwareUpgrade {
            
            if startAddress == 0 {
              firmwareBuffer.removeAll()
            }
            
            firmwareBuffer.append(contentsOf: data)
 
            sendWriteReply(destinationNodeId: sourceNodeId, addressSpace: space, startAddress: startAddress)

          }
          else if let memorySpace = memorySpaces[space] {
            
            if let spaceId = memorySpace.standardSpace, spaceId == .cv {
              writeCVs(sourceNodeId: sourceNodeId, memorySpace: memorySpace, startAddress: startAddress, data: data)
            }
            else if memorySpace.isWithinSpace(address: Int(startAddress), count: data.count) {
              memorySpace.setBlock(address: Int(startAddress), data: data, isInternal: false)
              memorySpace.save()
              sendWriteReply(destinationNodeId: sourceNodeId, addressSpace: space, startAddress: startAddress)
            }
            else {
              sendWriteReplyFailure(destinationNodeId: sourceNodeId, addressSpace: space, startAddress: startAddress, errorCode: .permanentErrorAddressOutOfBounds)
            }
            
          }
          else {
            sendWriteReplyFailure(destinationNodeId: sourceNodeId, addressSpace: space, startAddress: startAddress, errorCode: .permanentErrorAddressSpaceUnknown)
          }

        default:
          
          if !datagramTypesSupported.contains(datagramType) {
            #if DEBUG
            debugLog("\(datagramType.title)")
            #endif
            sendDatagramRejected(destinationNodeId: sourceNodeId, errorCode: .permanentErrorNotImplementedSubcommandUnknown)
          }
    
        }
        
      }
      
    case .identifyEventsGlobal, .identifyEventsAddressed:
      
      userConfigEventsConsumed = getUserConfigEvents(eventAddresses: userConfigEventConsumedAddresses)
      userConfigEventsProduced = getUserConfigEvents(eventAddresses: userConfigEventProducedAddresses)

      for eventId in eventsConsumed.union(userConfigEventsConsumed) {
        if !OpenLCBWellKnownEvent.isAutomaticallyRouted(eventId: eventId) {
          var validity : OpenLCBValidity = .unknown
          setValidity(eventId: eventId, validity: &validity)
          sendConsumerIdentified(eventId: eventId, validity: validity)
        }
      }

      for eventId in eventsProduced.union(userConfigEventsProduced) {
        if !OpenLCBWellKnownEvent.isAutomaticallyRouted(eventId: eventId) {
          var validity : OpenLCBValidity = .unknown
          setValidity(eventId: eventId, validity: &validity)
          sendProducerIdentified(eventId: eventId, validity: validity)
        }
      }
      
      for eventRange in eventRangesConsumed {
        sendConsumerRangeIdentified(eventId: eventRange.eventId)
      }

      for eventRange in eventRangesProduced {
        sendProducerRangeIdentified(eventId: eventRange.eventId)
      }

    case .identifyConsumer:
      // TODO: Event Ranges
      if let eventId = message.eventId, !OpenLCBWellKnownEvent.isAutomaticallyRouted(eventId: eventId) && eventsConsumed.union(userConfigEventsConsumed).contains(eventId) {
        var validity : OpenLCBValidity = .unknown
        setValidity(eventId: eventId, validity: &validity)
        sendConsumerIdentified(eventId: eventId, validity: validity)
      }

    case .identifyProducer:
      // TODO: Event Ranges
      if let eventId = message.eventId, !OpenLCBWellKnownEvent.isAutomaticallyRouted(eventId: eventId) && eventsProduced.union(userConfigEventsProduced).contains(eventId) {
        var validity : OpenLCBValidity = .unknown
        setValidity(eventId: eventId, validity: &validity)
        sendProducerIdentified(eventId: eventId, validity: validity)
      }

    default:
      break
    }
    
  }

}
