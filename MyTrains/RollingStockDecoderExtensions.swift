//
//  RollingStockDecoderExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 12/06/2022.
//

import Foundation

extension RollingStock {
  
  // MARK: Public Properties
  
  public var functionSettings : Int {
    get {
      var result = 0
      var mask = 1
      for locoFunc in functions {
        result |= locoFunc.stateToSend ? mask : 0
        mask <<= 1
      }
      return result
    }
  }
  
  public var decoderManufacturerName : String {
    get {
      return "" // NMRA.manufacturerName(code: getCV(cvNumber: 8).cvValue)
    }
  }
  
  public var consistAddress : Int {
    get {
      if let cv19 = getCV(cvNumber: 19) {
        return cv19.cvValue & 0x7f
      }
      return 0
    }
    set(value) {
      if let cv19 = getCV(cvNumber: 19) {
        var newCV19 = cv19.cvValue & 0b10000000
        newCV19 |= value & 0x7f
        cv19.cvValue = newCV19
      }
    }
  }
  
  public var isAdvancedConsist : Bool {
    get {
      return consistAddress != 0
    }
  }
  
  public var consistRelativeDirection : LocomotiveDirection {
    get {
      if let cv19 = getCV(cvNumber: 19) {
        let mask = 0b10000000
        return (cv19.cvValue & mask) == mask ? .reverse : .forward
      }
      return .forward
    }
    set(value) {
      if let cv19 = getCV(cvNumber: 19) {
        let mask = 0b10000000
        var newCV19 = cv19.cvValue & ~mask
        newCV19 |= value == .reverse ? mask : 0
        cv19.cvValue = newCV19
      }
    }
  }
  
  public var consistAddressActiveF1 : Bool {
    get {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00000001
        return cv21.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00000001
        var newCV21 = cv21.cvValue & ~mask
        newCV21 |= value ? mask : 0
        cv21.cvValue = newCV21
      }
    }
  }
  
  public var consistAddressActiveF2 : Bool {
    get {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00000010
        return cv21.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00000010
        var newCV21 = cv21.cvValue & ~mask
        newCV21 |= value ? mask : 0
        cv21.cvValue = newCV21
      }
    }
  }
  
  public var consistAddressActiveF3 : Bool {
    get {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00000100
        return cv21.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00000100
        var newCV21 = cv21.cvValue & ~mask
        newCV21 |= value ? mask : 0
        cv21.cvValue = newCV21
      }
    }
  }
  
  public var consistAddressActiveF4 : Bool {
    get {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00001000
        return cv21.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00001000
        var newCV21 = cv21.cvValue & ~mask
        newCV21 |= value ? mask : 0
        cv21.cvValue = newCV21
      }
    }
  }
  
  public var consistAddressActiveF5 : Bool {
    get {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00010000
        return cv21.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00010000
        var newCV21 = cv21.cvValue & ~mask
        newCV21 |= value ? mask : 0
        cv21.cvValue = newCV21
      }
    }
  }
  
  public var consistAddressActiveF6 : Bool {
    get {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00100000
        return cv21.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00100000
        var newCV21 = cv21.cvValue & ~mask
        newCV21 |= value ? mask : 0
        cv21.cvValue = newCV21
      }
    }
  }
  
  public var consistAddressActiveF7 : Bool {
    get {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b01000000
        return cv21.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b01000000
        var newCV21 = cv21.cvValue & ~mask
        newCV21 |= value ? mask : 0
        cv21.cvValue = newCV21
      }
    }
  }
  
  public var consistAddressActiveF8 : Bool {
    get {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b10000000
        return cv21.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b10000000
        var newCV21 = cv21.cvValue & ~mask
        newCV21 |= value ? mask : 0
        cv21.cvValue = newCV21
      }
    }
  }
  
  public var consistAddressActiveF9 : Bool {
    get {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00000100
        return cv22.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00000100
        var newCV22 = cv22.cvValue & ~mask
        newCV22 |= value ? mask : 0
        cv22.cvValue = newCV22
      }
    }
  }
  
  public var consistAddressActiveF10 : Bool {
    get {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00001000
        return cv22.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00001000
        var newCV22 = cv22.cvValue & ~mask
        newCV22 |= value ? mask : 0
        cv22.cvValue = newCV22
      }
    }
  }
  
  public var consistAddressActiveF11 : Bool {
    get {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00010000
        return cv22.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00010000
        var newCV22 = cv22.cvValue & ~mask
        newCV22 |= value ? mask : 0
        cv22.cvValue = newCV22
      }
    }
  }
  
  public var consistAddressActiveF12 : Bool {
    get {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00100000
        return cv22.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00100000
        var newCV22 = cv22.cvValue & ~mask
        newCV22 |= value ? mask : 0
        cv22.cvValue = newCV22
      }
    }
  }
  
  public var consistAddressActiveF0Forward : Bool {
    get {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00000001
        return cv22.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00000001
        var newCV22 = cv22.cvValue & ~mask
        newCV22 |= value ? mask : 0
        cv22.cvValue = newCV22
      }
    }
  }
  
  public var consistAddressActiveF0Reverse : Bool {
    get {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00000010
        return cv22.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00000010
        var newCV22 = cv22.cvValue & ~mask
        newCV22 |= value ? mask : 0
        cv22.cvValue = newCV22
      }
    }
  }
  
  public var isShortAddress : Bool {
    get {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00100000
        return (cv29.cvValue & mask) == 0
      }
      return true
    }
    set(value) {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00100000
        var newCV29 = cv29.cvValue & ~mask
        newCV29 |= value ? 0 : mask
        cv29.cvValue = newCV29
      }
    }
  }
  
  public var isSpeedTableCV2CV5CV6 : Bool {
    get {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00010000
        return (cv29.cvValue & mask) == 0
      }
      return false
    }
    set(value) {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00010000
        var newCV29 = cv29.cvValue & ~mask
        newCV29 |= value ? 0 : mask
        cv29.cvValue = newCV29
      }
    }
  }
  
  public var isRailComEnabled : Bool {
    get {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00001000
        return (cv29.cvValue & mask) == mask
      }
      return true
    }
    set(value) {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00001000
        var newCV29 = cv29.cvValue & ~mask
        newCV29 |= value ? mask : 0
        cv29.cvValue = newCV29
      }
    }
  }
  
  public var isAnalogOperationEnabled : Bool {
    get {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00000100
        return (cv29.cvValue & mask) == mask
      }
      return true
    }
    set(value) {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00000100
        var newCV29 = cv29.cvValue & ~mask
        newCV29 |= value ? mask : 0
        cv29.cvValue = newCV29
      }
    }
  }
  
  public var is14Steps : Bool {
    get {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00000010
        return (cv29.cvValue & mask) == 0
      }
      return false
    }
    set(value) {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00000010
        var newCV29 = cv29.cvValue & ~mask
        newCV29 |= value ? 0 : mask
        cv29.cvValue = newCV29
      }
    }
  }
  
  public var isNormalDirectionOfTravelForward : Bool {
    get {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00000001
        return (cv29.cvValue & mask) == 0
      }
      return true
    }
    set(value) {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00000001
        var newCV29 = cv29.cvValue & ~mask
        newCV29 |= value ? 0 : mask
        cv29.cvValue = newCV29
      }
    }
  }

  // MARK: Class Public Methods
  
  public static func decoderAddress(cv17: Int, cv18: Int) -> Int {
    return (cv17 << 8 | cv18) - 49152
  }
  
  public static func cv17(address: Int) -> Int {
    let temp = address + 49152
    return temp >> 8
  }
  
  public static func cv18(address: Int) -> Int {
    let temp = address + 49152
    return temp & 0xff
  }
  
}
