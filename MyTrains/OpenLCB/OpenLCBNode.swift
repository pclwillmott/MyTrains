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
    
    _supportedProtocols = [UInt8](repeating: 0x00, count: UNDERSTOOD_BYTES)
    
    self.nodeId = nodeId
    
    super.init()
    
  }
  
  // MARK: Private Properties
  
  private let UNDERSTOOD_BYTES : Int
  
  private var _supportedProtocols : [UInt8]
  
  // MARK: Public Properties
  
  public var nodeId : UInt64
  
  public var manufacturerName : String = ""
  
  public var nodeModelName : String = ""
  
  public var nodeHardwareVersion : String = ""
  
  public var nodeSoftwareVersion : String = ""
  
  public var userNodeName : String = ""
  
  public var userNodeDescription : String = ""
  
  public var addressSpaceInformation : [UInt8:OpenLCBNodeAddressSpaceInformation] = [:]
  
  public var encodedNodeInformation : [UInt8] {
    get {
      return [UInt8](("\u{04}\(manufacturerName)\0\(nodeModelName)\0\(nodeHardwareVersion)\0\(nodeSoftwareVersion)\0\u{02}\(userNodeName)\0\(userNodeDescription)\0").utf8)
    }
    set(value) {
      
      let temp = String(bytes: value, encoding: .utf8)!.split(separator: "\0", omittingEmptySubsequences: false)
      
      let version = value[0]
      
      if version == 1 || version == 4 {
        
        manufacturerName = String(temp[0])
        
        manufacturerName.removeFirst()
        
        nodeModelName = String(temp[1])
        
        nodeHardwareVersion = String(temp[2])
        
        nodeSoftwareVersion = String(temp[3])
        
        userNodeName = String(temp[4])
        userNodeName.removeFirst()
        
        userNodeDescription = String(temp[5])
        
      }

    }
  }
  
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
  
  public func addAddressSpaceInformation(message:OpenLCBMessage) -> OpenLCBNodeAddressSpaceInformation {
    
    var data = message.payload
    
    let addressSpace = data[2]
    
    var highestAddress : UInt32 = 0
    
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
    
    let info : OpenLCBNodeAddressSpaceInformation = (addressSpace:addressSpace, lowestAddress: Int(lowestAddress), highestAddress: Int(highestAddress), isReadOnly: isReadOnly, description: description)
    
    addressSpaceInformation[addressSpace] = info
    
    return info
    
  }
  
}
