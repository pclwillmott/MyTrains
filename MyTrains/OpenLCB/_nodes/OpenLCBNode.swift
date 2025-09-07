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
    
    self._nodeId = nodeId
    
    super.init()
    
  }
  
  deinit {
    addressSpaceInformation.removeAll()
    configurationOptions = nil
  }
  
  // MARK: Private Properties
  
  // THESE VARIABLES ARE ONLY USED FOR THE RAW OpenLCBNode. THEY FAKE THE ACDI.
  
  private var _acdiManufacturerSpaceVersion : UInt8 = 4
  private var _manufacturerName             = ""
  private var _nodeModelName                = ""
  private var _nodeHardwareVersion          = ""
  private var _nodeSoftwareVersion          = ""
  private var _acdiUserSpaceVersion         : UInt8 = 2
  private var _userNodeName                 = ""
  private var _userNodeDescription          = ""
  @objc private var _nodeId : UInt64
           
  // MARK: Public Properties
  
  @objc public var nodeId : UInt64 {
    get {
      return _nodeId
    }
    set(value) {
      _nodeId = value
    }
  }
  
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
        debugLog("invalid acdiManufacturerSpaceVersion: 0x\(acdiManufacturerSpaceVersion.hex()) \(nodeId.dotHex(numberOfBytes: 6)!)")
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
        debugLog("invalid acdiUserSpaceVersion: 0x\(acdiUserSpaceVersion.hex())")
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
        debugLog("invalid acdiManufacturerSpaceVersion: 0x\(acdiManufacturerSpaceVersion.hex()) id: \(nodeId.dotHex(numberOfBytes: 6)!)")
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
        debugLog("invalid acdiUserSpaceVersion: 0x(\(acdiUserSpaceVersion.hex())")
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
  
  public var supportedProtocols : Set<OpenLCBSupportedProtocol> = []

  public var supportedProtocolsAsString : String {
    
    var items : [String] = []
    
    for item in supportedProtocols {
      items.append(item.title)
    }
    
    items.sort {$0 < $1}
    
    var result = ""
    
    for item in items {
      if !result.isEmpty {
        result += "\n"
      }
      result += "\(item)"
    }
    
    return result

  }
  
  public var rawSupportedProtocols : [UInt8] {
    get {
      var temp : UInt64 = 0
      for item in supportedProtocols {
        temp |= item.rawValue
      }
      var data = temp.bigEndianData
      while data.last == 0 {
        data.removeLast()
      }
      return data
    }
    set(value) {
      supportedProtocols.removeAll()
      let temp = UInt64(bigEndianData: [UInt8]((value + [UInt8](repeating: 0, count: 8)).prefix(8)))!
      for item in OpenLCBSupportedProtocol.allCases {
        if temp & item.rawValue == item.rawValue {
          supportedProtocols.insert(item)
        }
      }
    }
  }
  
  public var isSimpleProtocolSubsetSupported : Bool {
    get {
      return supportedProtocols.contains(.simpleProtocolSubset)
    }
    set(value) {
      if value {
        supportedProtocols.insert(.simpleProtocolSubset)
      }
      else {
        supportedProtocols.remove(.simpleProtocolSubset)
      }
    }
  }
  
  public var isDatagramProtocolSupported : Bool {
    get {
      return supportedProtocols.contains(.datagramProtocol)
    }
    set(value) {
      if value {
        supportedProtocols.insert(.datagramProtocol)
      }
      else {
        supportedProtocols.remove(.datagramProtocol)
      }
    }
  }
  
  public var isStreamProtocolSupported : Bool {
    get {
      return supportedProtocols.contains(.streamProtocol)
    }
    set(value) {
      if value {
        supportedProtocols.insert(.streamProtocol)
      }
      else {
        supportedProtocols.remove(.streamProtocol)
      }
    }
  }
  
  public var isMemoryConfigurationProtocolSupported : Bool {
    get {
      return supportedProtocols.contains(.memoryConfigurationProtocol)
    }
    set(value) {
      if value {
        supportedProtocols.insert(.memoryConfigurationProtocol)
      }
      else {
        supportedProtocols.remove(.memoryConfigurationProtocol)
      }
    }
  }
  
  public var isReservationProtocolSupported : Bool {
    get {
      return supportedProtocols.contains(.reservationProtocol)
    }
    set(value) {
      if value {
        supportedProtocols.insert(.reservationProtocol)
      }
      else {
        supportedProtocols.remove(.reservationProtocol)
      }
    }
  }
  
  public var isEventExchangeProtocolSupported : Bool {
    get {
      return supportedProtocols.contains(.eventExchangeProtocol)
    }
    set(value) {
      if value {
        supportedProtocols.insert(.eventExchangeProtocol)
      }
      else {
        supportedProtocols.remove(.eventExchangeProtocol)
      }
    }
  }
  
  public var isIdentificationSupported : Bool {
    get {
      return supportedProtocols.contains(.identificationProtocol)
    }
    set(value) {
      if value {
        supportedProtocols.insert(.identificationProtocol)
      }
      else {
        supportedProtocols.remove(.identificationProtocol)
      }
    }
  }
  
  public var isTeachingLearningConfigurationProtocolSupported : Bool {
    get {
      return supportedProtocols.contains(.teachingLearningConfigurationProtocol)
    }
    set(value) {
      if value {
        supportedProtocols.insert(.teachingLearningConfigurationProtocol)
      }
      else {
        supportedProtocols.remove(.teachingLearningConfigurationProtocol)
      }
    }
  }
  
  public var isRemoteButtonProtocolSupported : Bool {
    get {
      return supportedProtocols.contains(.remoteButtonProtocol)
    }
    set(value) {
      if value {
        supportedProtocols.insert(.remoteButtonProtocol)
      }
      else {
        supportedProtocols.remove(.remoteButtonProtocol)
      }
    }
  }
  
  public var isAbbreviatedDefaultCDIProtocolSupported : Bool {
    get {
      return supportedProtocols.contains(.abbreviatedDefaultCDIProtocol)
    }
    set(value) {
      if value {
        supportedProtocols.insert(.abbreviatedDefaultCDIProtocol)
      }
      else {
        supportedProtocols.remove(.abbreviatedDefaultCDIProtocol)
      }
    }
  }
  
  public var isDisplayProtocolSupported : Bool {
    get {
      return supportedProtocols.contains(.displayProtocol)
    }
    set(value) {
      if value {
        supportedProtocols.insert(.displayProtocol)
      }
      else {
        supportedProtocols.remove(.displayProtocol)
      }
    }
  }
  
  public var isSimpleNodeInformationProtocolSupported : Bool {
    get {
      return supportedProtocols.contains(.simpleNodeInformationProtocol)
    }
    set(value) {
      if value {
        supportedProtocols.insert(.simpleNodeInformationProtocol)
      }
      else {
        supportedProtocols.remove(.simpleNodeInformationProtocol)
      }
    }
  }
  
  public var isConfigurationDescriptionInformationSupported : Bool {
    get {
      return supportedProtocols.contains(.configurationDescriptionInformation)
    }
    set(value) {
      if value {
        supportedProtocols.insert(.configurationDescriptionInformation)
      }
      else {
        supportedProtocols.remove(.configurationDescriptionInformation)
      }
    }
  }
  
  public var isTrainControlProtocolSupported : Bool {
    get {
      return supportedProtocols.contains(.trainControlProtocol)
    }
    set(value) {
      if value {
        supportedProtocols.insert(.trainControlProtocol)
      }
      else {
        supportedProtocols.remove(.trainControlProtocol)
      }
    }
  }
  
  public var isFunctionDescriptionInformationSupported : Bool {
    get {
      return supportedProtocols.contains(.functionDescriptionInformation)
    }
    set(value) {
      if value {
        supportedProtocols.insert(.functionDescriptionInformation)
      }
      else {
        supportedProtocols.remove(.functionDescriptionInformation)
      }
    }
  }
  
  public var isFunctionConfigurationSupported : Bool {
    get {
      return supportedProtocols.contains(.functionConfiguration)
    }
    set(value) {
      if value {
        supportedProtocols.insert(.functionConfiguration)
      }
      else {
        supportedProtocols.remove(.functionConfiguration)
      }
    }
  }
  
  public var isFirmwareUpgradeProtocolSupported : Bool {
    get {
      return supportedProtocols.contains(.firmwareUpgradeProtocol)
    }
    set(value) {
      if value {
        supportedProtocols.insert(.firmwareUpgradeProtocol)
      }
      else {
        supportedProtocols.remove(.firmwareUpgradeProtocol)
      }
    }
  }
  
  public var isFirmwareUpgradeActive : Bool {
    get {
      return supportedProtocols.contains(.firmwareUpgradeActive)
    }
    set(value) {
      if value {
        supportedProtocols.insert(.firmwareUpgradeActive)
      }
      else {
        supportedProtocols.remove(.firmwareUpgradeActive)
      }
    }
  }

  public var possibleAddressSpaces : [UInt8] {
    
    var possibles : Set<UInt8> = []
    
    if isConfigurationDescriptionInformationSupported {
      possibles.insert(OpenLCBNodeMemoryAddressSpace.cdi.rawValue)
      possibles.insert(OpenLCBNodeMemoryAddressSpace.configuration.rawValue)
    }
    if isAbbreviatedDefaultCDIProtocolSupported {
      possibles.insert(OpenLCBNodeMemoryAddressSpace.acdiManufacturer.rawValue)
      possibles.insert(OpenLCBNodeMemoryAddressSpace.acdiUser.rawValue)
    }
    if isFunctionDescriptionInformationSupported {
      possibles.insert(OpenLCBNodeMemoryAddressSpace.fdi.rawValue)
    }
    if isTrainControlProtocolSupported {
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
