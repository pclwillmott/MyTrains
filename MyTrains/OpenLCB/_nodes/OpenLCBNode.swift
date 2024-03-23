//
//  OpenLCBNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 15/04/2023.
//

import Foundation

public class OpenLCBNode : NSObject {
  
  // MARK: Constructors & Destructors
  
  public init(nodeId:UInt64) {
    
    UNDERSTOOD_BYTES = 3
    
    _supportedProtocols = [UInt8](repeating: 0, count: UNDERSTOOD_BYTES)
    
    self.nodeId = nodeId
    
    super.init()
    
    #if DEBUG
    addInit()
    #endif
    
  }
  
  deinit {
    addressSpaceInformation.removeAll()
    configurationOptions = nil
    _supportedProtocols.removeAll()
    #if DEBUG
    addDeinit()
    #endif
  }
  
  // MARK: Private Properties
  
  private let UNDERSTOOD_BYTES : Int
  
  private var _supportedProtocols : [UInt8]
  
  // THESE VARIABLES ARE ONLY USED FOR THE RAW OpenLCBNode. THEY FAKE THE ACDI.
  
  private var _acdiManufacturerSpaceVersion : UInt8 = 4
  private var _manufacturerName             = ""
  private var _nodeModelName                = ""
  private var _nodeHardwareVersion          = ""
  private var _nodeSoftwareVersion          = ""
  private var _acdiUserSpaceVersion         : UInt8 = 2
  private var _userNodeName                 = ""
  private var _userNodeDescription          = ""
           
  // MARK: Public Properties
  
  public var nodeId : UInt64
  
  public var acdiManufacturerSpaceVersion : UInt8 {
    get {
      return _acdiManufacturerSpaceVersion
    }
    set(value) {
      _acdiManufacturerSpaceVersion = value
    }
  }

  public var manufacturerName : String {
    get {
      return _manufacturerName
    }
    set(value) {
      _manufacturerName = String(value.prefix(40))
    }
  }
  
  public var nodeModelName : String {
    get {
      return _nodeModelName
    }
    set(value) {
      _nodeModelName = String(value.prefix(40))
    }
  }
  
  public var nodeHardwareVersion : String {
    get {
      return _nodeHardwareVersion
    }
    set(value) {
      _nodeHardwareVersion = String(value.prefix(20))
    }
  }
  
  public var nodeSoftwareVersion : String {
    get {
      return _nodeSoftwareVersion
    }
    set(value) {
      _nodeSoftwareVersion = String(value.prefix(20))
    }

  }
  
  public var acdiUserSpaceVersion : UInt8 {
    get {
      return _acdiUserSpaceVersion
    }
    set(value) {
      _acdiUserSpaceVersion = value
    }
  }

  public var userNodeName : String {
    get {
      return _userNodeName
    }
    set(value) {
      _userNodeName = String(value.prefix(62))
    }
  }
  
  public var userNodeDescription : String {
    get {
      return _userNodeDescription
    }
    set(value) {
      _userNodeDescription = String(value.prefix(63))
    }
  }
  
  public var addressSpaceInformation : [UInt8:OpenLCBNodeAddressSpaceInformation] = [:]
  
  public var encodedNodeInformation : [UInt8]? {
    
    get {
      
      guard acdiManufacturerSpaceVersion == 0x01 || acdiManufacturerSpaceVersion == 0x04 else {
        #if DEBUG
        debugLog("invalid acdiManufacturerSpaceVersion: 0x\(acdiManufacturerSpaceVersion.toHex(numberOfDigits: 2)) \(nodeId.toHexDotFormat(numberOfBytes: 6))")
        #endif
        return nil
      }

      var data : [UInt8] = []
      
      data.append(acdiManufacturerSpaceVersion)
      
      for index in 1 ... max(acdiManufacturerSpaceVersion, 0x04) {
        
        var temp = ""
        
        switch index {
        case 1:
          temp = String(manufacturerName.prefix(40))
        case 2:
          temp = String(nodeModelName.prefix(40))
        case 3:
          temp = String(nodeHardwareVersion.prefix(20))
        case 4:
          temp = String(nodeSoftwareVersion.prefix(20))
        default:
          break
        }
        
        data.append(contentsOf: temp.utf8)
        data.append(0)
        
      }
      
      guard acdiUserSpaceVersion == 0x01 || acdiUserSpaceVersion == 0x02 else {
        #if DEBUG
        debugLog("invalid acdiUserSpaceVersion: 0x\(acdiUserSpaceVersion.toHex(numberOfDigits: 2))")
        #endif
        return nil
      }

      data.append(acdiUserSpaceVersion)
      
      for index in 1 ... max(acdiUserSpaceVersion, 0x02) {
        
        var temp = ""
        
        switch index {
        case 1:
          temp = String(userNodeName.prefix(62))
        case 2:
          temp = String(userNodeDescription.prefix(63))
        default:
          break
        }

        data.append(contentsOf: temp.utf8)
        data.append(0)
        
      }
      
      return data
      
    }
    
    set(value) {
      
      guard let value, !value.isEmpty else {
        #if DEBUG
        debugLog("nil or no data bytes")
        #endif
        return
      }
      
      var _value = value
      
      acdiManufacturerSpaceVersion = _value.removeFirst()
      
      guard acdiManufacturerSpaceVersion == 0x01 || acdiManufacturerSpaceVersion == 0x04 else {
        #if DEBUG
        debugLog("invalid acdiManufacturerSpaceVersion: 0x\(acdiManufacturerSpaceVersion.toHex(numberOfDigits: 2)) id: \(nodeId.toHexDotFormat(numberOfBytes: 6))")
        debugLog("\(value)")
        #endif
        return
      }

      for index in 1 ... max(acdiManufacturerSpaceVersion, 0x04) {
        
        let temp = String(cString: _value)
        _value.removeFirst(temp.utf8.count + 1)
        
        switch index {
        case 1:
          manufacturerName = temp
        case 2:
          nodeModelName = temp
        case 3:
          nodeHardwareVersion = temp
        case 4:
          nodeSoftwareVersion = temp
        default:
          break
        }
        
      }
      
      #if DEBUG
      guard !_value.isEmpty else {
        debugLog("no data bytes")
        return
      }
      #endif
      
      acdiUserSpaceVersion = _value.removeFirst()
      
      guard acdiUserSpaceVersion == 0x01 || acdiUserSpaceVersion == 0x02 else {
        #if DEBUG
        debugLog("invalid acdiUserSpaceVersion: 0x(\(acdiUserSpaceVersion.toHex(numberOfDigits: 2))")
        #endif
        return
      }
      
      for index in 1 ... max(acdiUserSpaceVersion, 0x02) {
        
        let temp = String(cString: _value)
        _value.removeFirst(temp.utf8.count + 1)
        
        switch index {
        case 1:
          userNodeName = temp
        case 2:
          userNodeDescription = temp
        default:
          break
        }
        
      }
      
    }
    
  }
  
  public var configurationOptions : OpenLCBNodeConfigurationOptions? = OpenLCBNodeConfigurationOptions()
  
  public var supportedProtocols : [UInt8] {
    get {
      while _supportedProtocols.count < 6 {
        _supportedProtocols.append(0x00)
      }
      return _supportedProtocols
    }
    set(value) {
      _supportedProtocols = value
    }
  }
  
  public var isSimpleProtocolSubsetSupported : Bool {
    get {
      let mask : UInt8 = 0x80
      return (_supportedProtocols[0] & mask) == mask
    }
    set(value) {
      let mask : UInt8 = 0x80
      _supportedProtocols[0] &= ~mask
      _supportedProtocols[0] |= value ? mask : 0x00
    }
  }
  
  public var isDatagramProtocolSupported : Bool {
    get {
      let mask : UInt8 = 0x40
      return (_supportedProtocols[0] & mask) == mask
    }
    set(value) {
      let mask : UInt8 = 0x40
      _supportedProtocols[0] &= ~mask
      _supportedProtocols[0] |= value ? mask : 0x00
    }
  }
  
  public var isStreamProtocolSupported : Bool {
    get {
      let mask : UInt8 = 0x20
      return (_supportedProtocols[0] & mask) == mask
    }
    set(value) {
      let mask : UInt8 = 0x20
      _supportedProtocols[0] &= ~mask
      _supportedProtocols[0] |= value ? mask : 0x00
    }
  }
  
  public var isMemoryConfigurationProtocolSupported : Bool {
    get {
      let mask : UInt8 = 0x10
      return (_supportedProtocols[0] & mask) == mask
    }
    set(value) {
      let mask : UInt8 = 0x10
      _supportedProtocols[0] &= ~mask
      _supportedProtocols[0] |= value ? mask : 0x00
    }
  }
  
  public var isReservationProtocolSupported : Bool {
    get {
      let mask : UInt8 = 0x08
      return (_supportedProtocols[0] & mask) == mask
    }
    set(value) {
      let mask : UInt8 = 0x08
      _supportedProtocols[0] &= ~mask
      _supportedProtocols[0] |= value ? mask : 0x00
    }
  }
  
  public var isEventExchangeProtocolSupported : Bool {
    get {
      let mask : UInt8 = 0x04
      return (_supportedProtocols[0] & mask) == mask
    }
    set(value) {
      let mask : UInt8 = 0x04
      _supportedProtocols[0] &= ~mask
      _supportedProtocols[0] |= value ? mask : 0x00
    }
  }
  
  public var isIdentificationSupported : Bool {
    get {
      let mask : UInt8 = 0x02
      return (_supportedProtocols[0] & mask) == mask
    }
    set(value) {
      let mask : UInt8 = 0x02
      _supportedProtocols[0] &= ~mask
      _supportedProtocols[0] |= value ? mask : 0x00
    }
  }
  
  public var isTeachingLearningConfigurationProtocolSupported : Bool {
    get {
      let mask : UInt8 = 0x01
      return (_supportedProtocols[0] & mask) == mask
    }
    set(value) {
      let mask : UInt8 = 0x01
      _supportedProtocols[0] &= ~mask
      _supportedProtocols[0] |= value ? mask : 0x00
    }
  }
  
  public var isRemoteButtonProtocolSupported : Bool {
    get {
      let mask : UInt8 = 0x80
      return (_supportedProtocols[1] & mask) == mask
    }
    set(value) {
      let mask : UInt8 = 0x80
      _supportedProtocols[1] &= ~mask
      _supportedProtocols[1] |= value ? mask : 0x00
    }
  }
  
  public var isAbbreviatedDefaultCDIProtocolSupported : Bool {
    get {
      let mask : UInt8 = 0x40
      return (_supportedProtocols[1] & mask) == mask
    }
    set(value) {
      let mask : UInt8 = 0x40
      _supportedProtocols[1] &= ~mask
      _supportedProtocols[1] |= value ? mask : 0x00
    }
  }
  
  public var isDisplayProtocolSupported : Bool {
    get {
      let mask : UInt8 = 0x20
      return (_supportedProtocols[1] & mask) == mask
    }
    set(value) {
      let mask : UInt8 = 0x20
      _supportedProtocols[1] &= ~mask
      _supportedProtocols[1] |= value ? mask : 0x00
    }
  }
  
  public var isSimpleNodeInformationProtocolSupported : Bool {
    get {
      let mask : UInt8 = 0x10
      return (_supportedProtocols[1] & mask) == mask
    }
    set(value) {
      let mask : UInt8 = 0x10
      _supportedProtocols[1] &= ~mask
      _supportedProtocols[1] |= value ? mask : 0x00
    }
  }
  
  public var isConfigurationDescriptionInformationProtocolSupported : Bool {
    get {
      let mask : UInt8 = 0x08
      return (_supportedProtocols[1] & mask) == mask
    }
    set(value) {
      let mask : UInt8 = 0x08
      _supportedProtocols[1] &= ~mask
      _supportedProtocols[1] |= value ? mask : 0x00
    }
  }
  
  public var isTractionControlProtocolSupported : Bool {
    get {
      let mask : UInt8 = 0x04
      return (_supportedProtocols[1] & mask) == mask
    }
    set(value) {
      let mask : UInt8 = 0x04
      _supportedProtocols[1] &= ~mask
      _supportedProtocols[1] |= value ? mask : 0x00
    }
  }
  
  public var isFunctionDescriptionInformationProtocolSupported : Bool {
    get {
      let mask : UInt8 = 0x02
      return (_supportedProtocols[1] & mask) == mask
    }
    set(value) {
      let mask : UInt8 = 0x02
      _supportedProtocols[1] &= ~mask
      _supportedProtocols[1] |= value ? mask : 0x00
    }
  }
  
  public var isDCCCommandStationProtocolSupported : Bool {
    get {
      let mask : UInt8 = 0x01
      return (_supportedProtocols[1] & mask) == mask
    }
    set(value) {
      let mask : UInt8 = 0x01
      _supportedProtocols[1] &= ~mask
      _supportedProtocols[1] |= value ? mask : 0x00
    }
  }
  
  public var isSimpleTrainNodeInformationProtocolSupported : Bool {
    get {
      let mask : UInt8 = 0x80
      return (_supportedProtocols[2] & mask) == mask
    }
    set(value) {
      let mask : UInt8 = 0x80
      _supportedProtocols[2] &= ~mask
      _supportedProtocols[2] |= value ? mask : 0x00
    }
  }
  
  public var isFunctionConfigurationProtocolSupported : Bool {
    get {
      let mask : UInt8 = 0x40
      return (_supportedProtocols[2] & mask) == mask
    }
    set(value) {
      let mask : UInt8 = 0x40
      _supportedProtocols[2] &= ~mask
      _supportedProtocols[2] |= value ? mask : 0x00
    }
  }
  
  public var isFirmwareUpgradeProtocolSupported : Bool {
    get {
      let mask : UInt8 = 0x20
      return (_supportedProtocols[2] & mask) == mask
    }
    set(value) {
      let mask : UInt8 = 0x20
      _supportedProtocols[2] &= ~mask
      _supportedProtocols[2] |= value ? mask : 0x00
    }
  }
  
  public var isFirmwareUpgradeActive : Bool {
    get {
      let mask : UInt8 = 0x10
      return (_supportedProtocols[2] & mask) == mask
    }
    set(value) {
      let mask : UInt8 = 0x10
      _supportedProtocols[2] &= ~mask
      _supportedProtocols[2] |= value ? mask : 0x00
    }
  }

  public var isLocoNetGatewayProtocolSupported : Bool {
    get {
      let mask : UInt8 = 0x08
      return (_supportedProtocols[2] & mask) == mask
    }
    set(value) {
      let mask : UInt8 = 0x08
      _supportedProtocols[2] &= ~mask
      _supportedProtocols[2] |= value ? mask : 0x00
    }
  }

  public var supportedProtocolsInfo : [(protocol:String, supported:Bool)] {

    var result : [(protocol:String, supported:Bool)] = []

    result.append((String(localized:"Simple Protocol Subset"), isSimpleProtocolSubsetSupported))
    result.append((String(localized:"Datagram Protocol"), isDatagramProtocolSupported))
    result.append((String(localized:"Stream Protocol"), isStreamProtocolSupported))
    result.append((String(localized:"Memory Configuration Protocol"), isMemoryConfigurationProtocolSupported))
    result.append((String(localized:"Reservation Protocol"), isReservationProtocolSupported))
    result.append((String(localized:"Event Exchange Protocol"), isEventExchangeProtocolSupported))
    result.append((String(localized:"Identification Protocol"), isIdentificationSupported))
    result.append((String(localized:"Teaching/Learning Configuration Protocol"), isTeachingLearningConfigurationProtocolSupported))
    result.append((String(localized:"Remote Button Protocol"), isRemoteButtonProtocolSupported))
    result.append((String(localized:"Abbreviated Default CDI Protocol"), isAbbreviatedDefaultCDIProtocolSupported))
    result.append((String(localized:"Display Protocol"), isDisplayProtocolSupported))
    result.append((String(localized:"Simple Node Information Protocol"), isSimpleNodeInformationProtocolSupported))
    result.append((String(localized:"Configuration Description Information"), isConfigurationDescriptionInformationProtocolSupported))
    result.append((String(localized:"Traction Control Protocol"), isTractionControlProtocolSupported))
    result.append((String(localized:"Function Description Information"), isFunctionDescriptionInformationProtocolSupported))
    result.append((String(localized:"DCC Command Station Protocol"), isDCCCommandStationProtocolSupported))
    result.append((String(localized:"Simple Train Node Information Protocol"), isSimpleTrainNodeInformationProtocolSupported))
    result.append((String(localized:"Function Configuration"), isFunctionConfigurationProtocolSupported))
    result.append((String(localized:"Firmware Upgrade Protocol"), isFirmwareUpgradeProtocolSupported))
    result.append((String(localized:"Firmware Upgrade Active"), isFirmwareUpgradeActive))
    result.append((String(localized:"LocoNet Gateway Protocol"), isLocoNetGatewayProtocolSupported))
    
    return result

  }
  
  public var supportedProtocolsAsString : String {
    
    var result : String = ""
    
    for proto in supportedProtocolsInfo {
      if proto.supported {
        result += "\(proto.protocol)\n"
      }
    }
    
    return result

  }
  
  public var possibleAddressSpaces : [UInt8] {
    
    var possibles : Set<UInt8> = []
    
    if isConfigurationDescriptionInformationProtocolSupported {
      possibles.insert(OpenLCBNodeMemoryAddressSpace.cdi.rawValue)
      possibles.insert(OpenLCBNodeMemoryAddressSpace.configuration.rawValue)
    }
    if isAbbreviatedDefaultCDIProtocolSupported {
      possibles.insert(OpenLCBNodeMemoryAddressSpace.acdiManufacturer.rawValue)
      possibles.insert(OpenLCBNodeMemoryAddressSpace.acdiUser.rawValue)
    }
    if isFunctionDescriptionInformationProtocolSupported {
      possibles.insert(OpenLCBNodeMemoryAddressSpace.fdi.rawValue)
    }
    if isTractionControlProtocolSupported {
      possibles.insert(OpenLCBNodeMemoryAddressSpace.cv.rawValue)
    }
    
    let highest = Int(configurationOptions!.highestAddressSpace)
    
    var lowest = Int(configurationOptions!.lowestAddressSpace)
    
    while lowest <= highest {
      possibles.insert(UInt8(lowest & 0xff))
      lowest += 1
    }
    
    var result : [UInt8] = []
    
    for possible in possibles {
      result.append(possible)
    }
    
    result.sort { $0 >= $1 }
    
    return result
    
  }
  
  // MARK: Public Methods
  
  public func addAddressSpaceInformation(message:OpenLCBMessage) -> OpenLCBNodeAddressSpaceInformation? {
    
    var data = message.payload
    
    let addressSpace = data[2]
    
    var highestAddress : UInt32 = 0

    guard message.payload.count >= 8 else {
      return nil
    }
    
    if let address = UInt32(bigEndianData: [data[3], data[4], data[5], data[6]]) {
      highestAddress = address
    }
    
    var realHighestAddress = highestAddress
    
    if highestAddress == OpenLCBProgrammingMode.highestAddressModifier + 3 * 1024 - 1 {
      realHighestAddress = 3 * 1024 - 1
    }
    
    let readOnlyMask : UInt8 = 0b00000001
    
    let isReadOnly = (data[7] & readOnlyMask) == readOnlyMask
    
    var lowestAddress : UInt32 = 0
    
    let lowAddressPresentMask : UInt8 = 0b00000010
    
    let isLowestAddressPresent = (data[7] & lowAddressPresentMask) == lowAddressPresentMask
    
    var prefix = 8
    
    if isLowestAddressPresent, let address = UInt32(bigEndianData: [data[8], data[9], data[10], data[11]]) {
      lowestAddress = address
      prefix += 4
    }

    data.removeFirst(prefix)
    
    var description = ""
    
    if data.count > 0 {
      description = String(decoding: data, as: UTF8.self)
      description.removeLast()
    }
    
    let size = highestAddress - lowestAddress + 1
    
    let info : OpenLCBNodeAddressSpaceInformation = (addressSpace:addressSpace, lowestAddress: lowestAddress, highestAddress: highestAddress, realHighestAddress: realHighestAddress, size: size, isReadOnly: isReadOnly, description: description)
    
    addressSpaceInformation[addressSpace] = info
    
    return info
    
  }
  
}
