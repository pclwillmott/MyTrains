//
//  OpenLCBNodeVirtual.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/05/2023.
//

import Foundation

public class OpenLCBNodeVirtual : OpenLCBNode, OpenLCBNetworkLayerDelegate, OpenLCBMemorySpaceDelegate {
  
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    lfsr1 = UInt32(nodeId >> 24)
    
    lfsr2 = UInt32(nodeId & 0xffffff)

    acdiManufacturerSpace = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.acdiManufacturer.rawValue, defaultMemorySize: 125, isReadOnly: true, description: "")

    acdiUserSpace = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.acdiUser.rawValue, defaultMemorySize: 128, isReadOnly: false, description: "")

    virtualNodeConfigSpace = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.virtualNodeConfig.rawValue, defaultMemorySize: 28, isReadOnly: false, description: "")

    super.init(nodeId: nodeId)

    if nextUniqueEventId == 0 {
      nextUniqueEventId = nodeId << 16
      nextUniqueNodeIdSeed = nodeId
    }

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

    virtualNodeConfigSpaceVersion = 5
    
    isSimpleNodeInformationProtocolSupported = true
    
    isDatagramProtocolSupported = true
    
    isMemoryConfigurationProtocolSupported = true
    
    isAbbreviatedDefaultCDIProtocolSupported = true
    
    isEventExchangeProtocolSupported = true
    
    isFirmwareUpgradeProtocolSupported = false
    
    setupConfigurationOptions()
    
  }
  
  // MARK: Private Properties
  
  private var lockedNodeId : UInt64 = 0
  
  internal var memorySpaces : [UInt8:OpenLCBMemorySpace] = [:]
  
  internal var cdiFilename : String? {
    didSet {
      initCDI()
    }
  }
  
  internal var registeredVariables : [UInt8:Set<Int>] = [:]
  
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

  internal var datagramTypesSupported : Set<OpenLCBDatagramType> = [
    .writeCommandGeneric,
    .writeCommand0xFD,
    .writeCommand0xFE,
    .writeCommand0xFF,
//  .writeUnderMaskCommandGeneric,
//  .writeUnderMaskCommand0xFD,
//  .writeUnderMaskCommand0xFE,
//  .writeUnderMaskCommand0xFF,
    .readCommandGeneric,
    .readCommand0xFD,
    .readCommand0xFE,
    .readCommand0xFF,
    .getConfigurationOptionsCommand,
    .getAddressSpaceInformationCommand,
    .LockReserveCommand,
    .getUniqueIDCommand,
    .unfreezeCommand,
    .freezeCommand,
//   .updateCompleteCommand,
    .resetRebootCommand,
    .reinitializeFactoryResetCommand,
  ]
  
  internal var hardwareNodeState : OpenLCBHardwareNodeState = .operating {
    didSet {
      isFirmwareUpgradeActive = hardwareNodeState == .firmwareUpgrade
    }
  }
  
  internal var firmwareBuffer : [UInt8] = []
  
  // MARK: Public Properties
  
  public var lfsr1 : UInt32
  
  public var lfsr2 : UInt32

  public var state : OpenLCBTransportLayerState = .inhibited
  
  public var networkLayer : OpenLCBNetworkLayer?
  
  public var memorySpacesInitialized : Bool {
    get {
      return acdiManufacturerSpace.getUInt8(address: addressACDIManufacturerSpaceVersion) != 0
    }
  }
    
  public var acdiManufacturerSpace : OpenLCBMemorySpace
  
  public var acdiUserSpace : OpenLCBMemorySpace
  
  public var virtualNodeConfigSpace : OpenLCBMemorySpace
  
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

  // MARK: Private Methods
  
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
  
  internal func initCDI() {
    
    if let cdiFilename, let filepath = Bundle.main.path(forResource: cdiFilename, ofType: "xml") {
      do {
        
        var cdi = try String(contentsOfFile: filepath)

        // Apply substitutions for dynamic elements such as node ids.
        
        cdi = customizeDynamicCDI(cdi: cdi)

        // Apply these after the previous call so that the previous call
        // can override the substitutions if necessary.
        
        cdi = cdi.replacingOccurrences(of: CDI.MANUFACTURER, with: manufacturerName)
        cdi = cdi.replacingOccurrences(of: CDI.MODEL, with: nodeModelName)
        cdi = cdi.replacingOccurrences(of: CDI.SOFTWARE_VERSION, with: nodeSoftwareVersion)
        cdi = cdi.replacingOccurrences(of: CDI.HARDWARE_VERSION, with: nodeHardwareVersion)
        
        cdi = standardACDI(cdi: cdi)
        cdi = Scale.insertMap(cdi: cdi)
        cdi = MTSerialPortManager.insertMap(cdi: cdi)
        cdi = OpenLCBFunction.insertMap(cdi: cdi)
        cdi = BaudRate.insertMap(cdi: cdi)
        cdi = Parity.insertMap(cdi: cdi)
        cdi = FlowControl.insertMap(cdi: cdi)
        cdi = OpenLCBClockOperatingMode.insertMap(cdi: cdi)
        cdi = OpenLCBClockType.insertMap(cdi: cdi)
        cdi = OpenLCBClockState.insertMap(cdi: cdi)
        cdi = EnableState.insertMap(cdi: cdi)
        cdi = ClockCustomIdType.insertMap(cdi: cdi)
        
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

  }
  
  internal func saveMemorySpaces() {
    for (_, memorySpace) in memorySpaces {
      if memorySpace.space != OpenLCBNodeMemoryAddressSpace.cdi.rawValue {
        memorySpace.save()
      }
    }
  }
  
  internal func readCVs(sourceNodeId:UInt64, memorySpace:OpenLCBMemorySpace, startAddress:UInt32, count:UInt8) {
    
    guard let progMode = OpenLCBProgrammingMode(rawValue: startAddress & OpenLCBProgrammingMode.modeMask) else {
      networkLayer?.sendReadReplyFailure(sourceNodeId: nodeId, destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress, errorCode: .permanentErrorInvalidArguments)
      return
    }
    
    let address = startAddress & OpenLCBProgrammingMode.addressMask
    
    if let data = memorySpace.getBlock(address: Int(address), count: Int(count)) {
      networkLayer?.sendReadReply(sourceNodeId: nodeId, destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress, data: data)
    }
    else {
      networkLayer?.sendReadReplyFailure(sourceNodeId: nodeId, destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress, errorCode: .permanentErrorAddressOutOfBounds)
    }

  }
  
  internal func writeCVs(sourceNodeId:UInt64, memorySpace:OpenLCBMemorySpace, startAddress:UInt32, data: [UInt8]) {
    
    guard let progMode = OpenLCBProgrammingMode(rawValue: startAddress & OpenLCBProgrammingMode.modeMask) else {
      networkLayer?.sendWriteReplyFailure(sourceNodeId: nodeId, destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress, errorCode: .permanentErrorInvalidArguments)
      return
    }
    
    let address = startAddress & OpenLCBProgrammingMode.addressMask
    
    if memorySpace.isWithinSpace(address: Int(address), count: data.count) {
      memorySpace.setBlock(address: Int(address), data: data, isInternal: false)
      memorySpace.save()
      networkLayer?.sendWriteReply(sourceNodeId: nodeId, destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress)
    }
    else {
      networkLayer?.sendWriteReplyFailure(sourceNodeId: nodeId, destinationNodeId: sourceNodeId, addressSpace: memorySpace.space, startAddress: startAddress, errorCode: .permanentErrorAddressOutOfBounds)
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
  
  // MARK: Public Methods
  
  public func start() {
  
    if let network = networkLayer {
      state = .permitted
      network.sendInitializationComplete(sourceNodeId: nodeId, isSimpleSetSufficient: false)
      resetReboot()
    }
    
  }
  
  public func stop() {
    state = .inhibited
  }
  
  public func registerVariable(space:UInt8, address:Int) {
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
    
    if let addresses = self.registeredVariables[memorySpace.space] {
      for address in addresses {
        if address >= startAddress && address <= endAddress {
          variableChanged(space: memorySpace, address: address)
        }
      }
    }
    
  }
    
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public func networkLayerStateChanged(networkLayer: OpenLCBNetworkLayer) {
    
  }
  
  public func openLCBMessageReceived(message: OpenLCBMessage) {
    
    switch message.messageTypeIndicator {
      
    case .simpleNodeIdentInfoRequest:
      if message.destinationNodeId! == nodeId {
        networkLayer?.sendSimpleNodeInformationReply(sourceNodeId: self.nodeId, destinationNodeId: message.sourceNodeId!, data: encodedNodeInformation)
      }
      
    case .verifyNodeIDNumberAddressed:
      if message.destinationNodeId! == nodeId {
        networkLayer?.sendVerifiedNodeIdNumber(sourceNodeId: nodeId, isSimpleSetSufficient: false)
      }
      
    case .verifyNodeIDNumberGlobal:
      let id = UInt64(bigEndianData: message.payload)
      if message.payload.isEmpty || id! == nodeId {
        networkLayer?.sendVerifiedNodeIdNumber(sourceNodeId: nodeId, isSimpleSetSufficient: false)
      }
      
    case .protocolSupportInquiry:
      if message.destinationNodeId! == nodeId {
        let data = supportedProtocols
        networkLayer?.sendProtocolSupportReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, data: data)
      }
      
    case .datagram:
      
      if message.destinationNodeId! == nodeId, let datagramType = message.datagramType {
        
        switch datagramType {
        
        case .getUniqueIDCommand:
          
          networkLayer?.sendDatagramReceivedOK(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, timeOut: .replyPendingNoTimeout)
          
          var payload : [UInt8] = OpenLCBDatagramType.getUniqueIDReply.rawValue.bigEndianData

          for _ in 1 ... message.payload[2] {
            payload.append(contentsOf: nextUniqueEventId.bigEndianData)
          }
          
          networkLayer?.sendDatagram(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, data: payload)

        case.getConfigurationOptionsCommand:

          networkLayer?.sendDatagramReceivedOK(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, timeOut: .replyPendingNoTimeout)
          
          networkLayer?.sendGetConfigurationOptionsReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, node: self)

        case .reinitializeFactoryResetCommand:
          networkLayer?.sendDatagramReceivedOK(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, timeOut: .ok)
          DispatchQueue.main.async {
            self.resetToFactoryDefaults()
          }
          
        case .resetRebootCommand:
          
          networkLayer?.sendDatagramReceivedOK(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, timeOut: .ok)
          
          DispatchQueue.main.async {
            self.stop()
            self.start()
          }
          
        case.LockReserveCommand:
          
          networkLayer?.sendDatagramReceivedOK(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, timeOut: .replyPendingNoTimeout)

          message.payload.removeFirst(2)
          
          if let id = UInt64(bigEndianData: message.payload) {
            if lockedNodeId == 0 || id == 0 {
              lockedNodeId = id
            }
          }
          
          networkLayer?.sendLockReserveReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, reservedNodeId: lockedNodeId)

        case .getAddressSpaceInformationCommand:
          
          message.payload.removeFirst(2) 
          
          let space = message.payload[0]

          if let memorySpace = memorySpaces[space] {
            networkLayer?.sendDatagramReceivedOK(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, timeOut: .replyPendingNoTimeout)
            networkLayer?.sendGetAddressSpaceInformationReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, memorySpace: memorySpace)
          }
          else {
            networkLayer?.sendDatagramRejected(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, errorCode: .permanentErrorAddressSpaceUnknown)
          }
          
        case .readCommandGeneric, .readCommand0xFD, .readCommand0xFE, .readCommand0xFF:
 
          networkLayer?.sendDatagramReceivedOK(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, timeOut: .replyPendingNoTimeout)
          
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
          
          if let memorySpace = memorySpaces[space] {

            data.removeFirst(bytesToRemove)
            let readCount = data[0] & 0x7f
            
            if readCount == 0 || readCount > 64 {
              networkLayer?.sendReadReplyFailure(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, addressSpace: space, startAddress: startAddress, errorCode: .permanentErrorInvalidArguments)
            }
            else if let spaceId = memorySpace.standardSpace, spaceId == .cv {
              readCVs(sourceNodeId: message.sourceNodeId!, memorySpace: memorySpace, startAddress: startAddress, count: readCount)
            }
            else {
              
              if let data = memorySpace.getBlock(address: Int(startAddress), count: Int(readCount)) {
                networkLayer?.sendReadReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, addressSpace: space, startAddress: startAddress, data: data)
              }
              else {
                networkLayer?.sendReadReplyFailure(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, addressSpace: space, startAddress: startAddress, errorCode: .permanentErrorAddressOutOfBounds)
              }
            
            }
          }
          else {
            networkLayer?.sendReadReplyFailure(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, addressSpace: space, startAddress: startAddress, errorCode: .permanentErrorAddressSpaceUnknown)
          }

        case .unfreezeCommand:
          
          if let spaceId = OpenLCBNodeMemoryAddressSpace(rawValue: message.payload[2]), spaceId == .firmware {
            
            hardwareNodeState = .operating
            
//          networkLayer?.sendDatagramReceivedOK(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, timeOut: .ok)

            networkLayer?.sendInitializationComplete(sourceNodeId: nodeId, isSimpleSetSufficient: false)
            
//            firmwareBuffer.append(0)
//            print(String(cString: firmwareBuffer))
            
          }
          else {
            networkLayer?.sendDatagramRejected(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, errorCode: .permanentErrorAddressSpaceUnknown)
          }

        case .freezeCommand:
          
          if let spaceId = OpenLCBNodeMemoryAddressSpace(rawValue: message.payload[2]), spaceId == .firmware {
            
            hardwareNodeState = .firmwareUpgrade
            
            networkLayer?.sendDatagramReceivedOK(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, timeOut: .ok)

            networkLayer?.sendInitializationComplete(sourceNodeId: nodeId, isSimpleSetSufficient: false)
            
            firmwareBuffer = []
            
          }
          else {
            networkLayer?.sendDatagramRejected(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, errorCode: .permanentErrorAddressSpaceUnknown)
          }
          
        case .writeCommandGeneric, .writeCommand0xFD, .writeCommand0xFE, .writeCommand0xFF:

          networkLayer?.sendDatagramReceivedOK(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, timeOut: .replyPendingNoTimeout)
          
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

          if let spaceId = OpenLCBNodeMemoryAddressSpace(rawValue: space), spaceId == .firmware &&  hardwareNodeState == .firmwareUpgrade {
            
            if startAddress == 0 {
              firmwareBuffer.removeAll()
            }
            
            firmwareBuffer.append(contentsOf: data)
 
            networkLayer?.sendWriteReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, addressSpace: space, startAddress: startAddress)

          }
          else if let memorySpace = memorySpaces[space] {
            
            if let spaceId = memorySpace.standardSpace, spaceId == .cv {
              writeCVs(sourceNodeId: message.sourceNodeId!, memorySpace: memorySpace, startAddress: startAddress, data: data)
            }
            else if memorySpace.isWithinSpace(address: Int(startAddress), count: data.count) {
              memorySpace.setBlock(address: Int(startAddress), data: data, isInternal: false)
              memorySpace.save()
              networkLayer?.sendWriteReply(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, addressSpace: space, startAddress: startAddress)
            }
            else {
              networkLayer?.sendWriteReplyFailure(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, addressSpace: space, startAddress: startAddress, errorCode: .permanentErrorAddressOutOfBounds)
            }
            
          }
          else {
            networkLayer?.sendWriteReplyFailure(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, addressSpace: space, startAddress: startAddress, errorCode: .permanentErrorAddressSpaceUnknown)
          }

        default:
          
          if !datagramTypesSupported.contains(datagramType) {
            networkLayer?.sendDatagramRejected(sourceNodeId: nodeId, destinationNodeId: message.sourceNodeId!, errorCode: .permanentErrorNotImplementedSubcommandUnknown)
          }
    
        }
        
      }
      
    default:
      break
    }
    
  }
    
}
