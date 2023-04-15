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
    
    self.nodeId = nodeId
    
    super.init()
    
  }
  
  // MARK: Private Properties
  
  private var _supportedProtocols : [UInt8] = [UInt8](repeating: 0x00, count: 64)
  
  // MARK: Public Properties
  
  public var nodeId : UInt64
  
  public var supportedProtocols : [UInt8] {
    get {
      return _supportedProtocols
    }
    set(value) {
      _supportedProtocols = [UInt8](repeating: 0x00, count: 64)
      for index in 0...min(value.count - 1, 63) {
        _supportedProtocols[index] = value[index]
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
  
}
