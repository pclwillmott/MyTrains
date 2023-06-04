//
//  OpenLCBNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 15/04/2023.
//

import Foundation

public class OpenLCBNode : NSObject {
  
  // MARK: Constructors
  
  public init(nodeId:UInt64) {
    
    UNDERSTOOD_BYTES = 3
    
    _supportedProtocols = [UInt8](repeating: 0, count: UNDERSTOOD_BYTES)
    
    self.nodeId = nodeId
    
    acdiManufacturerSpace = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.acdiManufacturer.rawValue, defaultMemorySize: 125, isReadOnly: true, description: "")

    acdiUserSpace = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.acdiUser.rawValue, defaultMemorySize: 128, isReadOnly: false, description: "")
    
    super.init()
    
    self.memorySpaces[acdiManufacturerSpace.space] = acdiManufacturerSpace

    self.memorySpaces[acdiUserSpace.space] = acdiUserSpace
    
    self.acdiManufacturerSpaceVersion = 4
    
    self.acdiUserSpaceVersion = 2
    
  }
  
  // MARK: Private Properties
  
  private let UNDERSTOOD_BYTES : Int
  
  private var _supportedProtocols : [UInt8]
  
  internal var memorySpaces : [UInt8:OpenLCBMemorySpace] = [:]
  
  // MARK: Public Properties
  
  public var nodeId : UInt64
  
  public var acdiManufacturerSpace : OpenLCBMemorySpace
  
  public var acdiUserSpace : OpenLCBMemorySpace
  
  public var acdiManufacturerSpaceVersion : UInt8 {
    get {
      var result = acdiManufacturerSpace.getUInt8(address: 0)!
      return result == 0 ? 4 : result
    }
    set(value) {
      acdiManufacturerSpace.setUInt(address: 0, value: value == 1 ? 4 : value)
    }
  }
  
  public var manufacturerName : String {
    get {
      return acdiManufacturerSpace.getString(address: 1, count: 41)!
    }
    set(value) {
      acdiManufacturerSpace.setString(address: 1, value: String(value.prefix(40)), fieldSize: 41)
    }
  }
  
  public var nodeModelName : String {
    get {
      return acdiManufacturerSpace.getString(address: 42, count: 41)!
    }
    set(value) {
      acdiManufacturerSpace.setString(address: 42, value: String(value.prefix(40)), fieldSize: 41)
    }
  }
  
  public var nodeHardwareVersion : String {
    get {
      return acdiManufacturerSpace.getString(address: 83, count: 21)!
    }
    set(value) {
      acdiManufacturerSpace.setString(address: 83, value: String(value.prefix(20)), fieldSize: 21)
    }
  }
  
  public var nodeSoftwareVersion : String {
    get {
      return acdiManufacturerSpace.getString(address: 104, count: 21)!
    }
    set(value) {
      acdiManufacturerSpace.setString(address: 104, value: String(value.prefix(20)), fieldSize: 21)
    }

  }
  
  public var acdiUserSpaceVersion : UInt8 {
    get {
      var result = acdiUserSpace.getUInt8(address: 0)!
      return result == 0 ? 2 : result
    }
    set(value) {
      acdiUserSpace.setUInt(address: 0, value: value == 1 ? 2 : value)
    }
  }

  public var userNodeName : String {
    get {
      return acdiUserSpace.getString(address: 1, count: 63)!
    }
    set(value) {
      acdiUserSpace.setString(address: 1, value: String(value.prefix(62)), fieldSize: 63)
    }
  }
  
  public var userNodeDescription : String {
    get {
      return acdiUserSpace.getString(address: 64, count: 64)!
    }
    set(value) {
      acdiUserSpace.setString(address: 64, value: String(value.prefix(63)), fieldSize: 64)
    }
  }
  
  public var addressSpaceInformation : [UInt8:OpenLCBNodeAddressSpaceInformation] = [:]
  
  public var encodedNodeInformation : [UInt8] {
    
    get {
      
      var data : [UInt8] = []
      
      data.append(acdiManufacturerSpaceVersion)
      
      for stringNumber in 1 ... acdiManufacturerSpaceVersion {
        var string : String = ""
        switch stringNumber {
        case 1:
          string = manufacturerName
        case 2:
          string = nodeModelName
        case 3:
          string = nodeHardwareVersion
        case 4:
          string = nodeSoftwareVersion
        default:
          break
        }
        for byte in string.utf8 {
          data.append(byte)
        }
        data.append(0)
      }
      
      data.append(acdiUserSpaceVersion)
      
      for stringNumber in 1 ... acdiUserSpaceVersion {
        var string : String = ""
        switch stringNumber {
        case 1:
          string = userNodeName
        case 2:
          string = userNodeDescription
        default:
          break
        }
        for byte in string.utf8 {
          data.append(byte)
        }
        data.append(0)
      }
      
      return data
      
    }
    
    set(value) {
      
      var index : Int = 0

      acdiManufacturerSpaceVersion = value[index]
      
      index += 1
      
      var stringNumber = 0
            
      while stringNumber < acdiManufacturerSpaceVersion && index < value.count {
        
        var current : [UInt8] = []
        
        while value[index] != UInt8(0) {
          current.append(value[index])
          index += 1
        }
        
        current.append(value[index])
        index += 1
        
        let string = String(cString: current)
        stringNumber += 1
        switch stringNumber {
        case 1:
          manufacturerName = string
        case 2:
          nodeModelName = string
        case 3:
          nodeHardwareVersion = string
        case 4:
          nodeSoftwareVersion = string
        default:
          break
        }

      }
      
      acdiUserSpaceVersion = value[index]
      
      index += 1

      stringNumber = 0
            
      while stringNumber < acdiUserSpaceVersion && index < value.count {
        var current : [UInt8] = []
        while value[index] != 0 {
          current.append(value[index])
          index += 1
        }
        current.append(value[index])
        index += 1
        let string = String(cString: current)
        stringNumber += 1
        switch stringNumber {
        case 1:
          userNodeName = string
        case 2:
          userNodeDescription = string
        default:
          break
        }
      }

    }
    
  }
  
  public var configurationOptions : OpenLCBNodeConfigurationOptions = OpenLCBNodeConfigurationOptions()
  
  public var supportedProtocols : [UInt8] {
    get {
      return _supportedProtocols
    }
    set(value) {
      _supportedProtocols = value
      while _supportedProtocols.count < UNDERSTOOD_BYTES {
        _supportedProtocols.append(0x00)
      }
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
  
  public var isFirmwareUpgradeActiveProtocolSupported : Bool {
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
  
  public var supportedProtocolsInfo : [(protocol:String, supported:Bool)] {
    get {
      
      var result : [(protocol:String, supported:Bool)] = []
      
      result.append(("Simple Protocol Subset", isSimpleProtocolSubsetSupported))
      result.append(("Datagram Protocol", isDatagramProtocolSupported))
      result.append(("Stream Protocol", isStreamProtocolSupported))
      result.append(("Memory Configuration Protocol", isMemoryConfigurationProtocolSupported))
      result.append(("Reservation Protocol", isReservationProtocolSupported))
      result.append(("Event Exchange Protocol", isEventExchangeProtocolSupported))
      result.append(("Identification Protocol", isIdentificationSupported))
      result.append(("Teaching/Learning Configuration Protocol", isTeachingLearningConfigurationProtocolSupported))
      result.append(("Remote Button Protocol", isRemoteButtonProtocolSupported))
      result.append(("Abbreviated Default CDI Protocol", isAbbreviatedDefaultCDIProtocolSupported))
      result.append(("Display Protocol", isDisplayProtocolSupported))
      result.append(("Simple Node Information Protocol", isSimpleNodeInformationProtocolSupported))
      result.append(("Configuration Description Information", isConfigurationDescriptionInformationProtocolSupported))
      result.append(("Traction Control Protocol", isTractionControlProtocolSupported))
      result.append(("Function Description Information", isFunctionDescriptionInformationProtocolSupported))
      result.append(("DCC Command Station Protocol", isDCCCommandStationProtocolSupported))
      result.append(("Simple Train Node Information Protocol", isSimpleTrainNodeInformationProtocolSupported))
      result.append(("Function Configuration", isFunctionConfigurationProtocolSupported))
      result.append(("Firmware Upgrade Protocol", isFirmwareUpgradeProtocolSupported))
      result.append(("Firmware Upgrade Active", isFirmwareUpgradeActiveProtocolSupported))
      return result
      
    }
  }
  
  public var supportedProtocolsAsString : String {
    
    get {
      var result : String = ""
      for proto in supportedProtocolsInfo {
        if proto.supported {
          result += "\(proto.protocol)\n"
        }
      }
      return result
    }
    
  }
  
  // MARK: Public Methods
  
  public func addAddressSpaceInformation(message:OpenLCBMessage) -> OpenLCBNodeAddressSpaceInformation? {
    
    var data = message.payload
    
    let addressSpace = data[2]
    
    var highestAddress : UInt32 = 0

    /*
    print("\(message.sourceNodeId!.toHexDotFormat(numberOfBytes: 6)) -> ", terminator: "")
    for byte in message.payload {
      print("\(byte.toHex(numberOfDigits: 2)), ", terminator: "")
    }
    print()
    */
    
    guard message.payload.count >= 8 else {
  //    print("addAddressSpaceInformation: payload too short.")
      return nil
    }
    
    if let address = UInt32(bigEndianData: [data[3], data[4], data[5], data[6]]) {
      highestAddress = address
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
    
    let info : OpenLCBNodeAddressSpaceInformation = (addressSpace:addressSpace, lowestAddress: lowestAddress, highestAddress: highestAddress, size: size, isReadOnly: isReadOnly, description: description)
    
    addressSpaceInformation[addressSpace] = info
    
    return info
    
  }
  
}
