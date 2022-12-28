//
//  LocoNetDeviceTC64Extensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 28/12/2022.
//

import Foundation

extension LocoNetDevice {
  
  // MARK: Public Properties
  
  public var isTC64 : Bool {
    if let info = locoNetProductInfo, info.id == .TowerControllerMarkII {
      return true
    }
    return false
  }
  
  public var firmwareVersion : Int {
    get {
      if isTC64 {
        return cvs[6].nextCVValue
      }
      return 0
    }
  }
  
  public var manufacturerId : Int {
    get {
      if isTC64 {
        return cvs[7].nextCVValue
      }
      return 0
    }
  }
  
  public var hardwareId : Int {
    get {
      if isTC64 {
        return cvs[8].nextCVValue
      }
      return 0
    }
  }
  
  public var isPortStateEnabled : Bool {
    get {
      if isTC64 {
        let cv112 = cvs[111]
        let mask : Int = 0b00000001
        return (cv112.nextCVValue & mask) == mask
      }
      return false
    }
    set(value) {
      if isTC64 {
        let cv112 = cvs[111]
        let mask : Int = 0b00000001
        cv112.nextCVValue = (cv112.nextCVValue & ~mask) | (value ? mask : 0)
      }
    }
  }
  
  public var isOpsModeEnabled : Bool {
    get {
      if isTC64 {
        let cv112 = cvs[111]
        let mask : Int = 0b00000010
        return (cv112.nextCVValue & mask) == mask
      }
      return false
    }
    set(value) {
      if isTC64 {
        let cv112 = cvs[111]
        let mask : Int = 0b00000010
        cv112.nextCVValue = (cv112.nextCVValue & ~mask) | (value ? mask : 0)
      }
    }
  }
  
  public var isInterrogatePwrOnEnabled : Bool {
    get {
      if isTC64 {
        let cv112 = cvs[111]
        let mask : Int = 0b00000100
        return (cv112.nextCVValue & mask) == mask
      }
      return false
    }
    set(value) {
      if isTC64 {
        let cv112 = cvs[111]
        let mask : Int = 0b00000100
        cv112.nextCVValue = (cv112.nextCVValue & ~mask) | (value ? mask : 0)
      }
    }
  }
  
  public var isInterrogateInputs : Bool {
    get {
      if isTC64 {
        let cv112 = cvs[111]
        let mask : Int = 0b00001000
        return (cv112.nextCVValue & mask) == mask
      }
      return false
    }
    set(value) {
      if isTC64 {
        let cv112 = cvs[111]
        let mask : Int = 0b00001000
        cv112.nextCVValue = (cv112.nextCVValue & ~mask) | (value ? mask : 0)
      }
    }
  }

  public var isInterrogateOutputs : Bool {
    get {
      if isTC64 {
        let cv112 = cvs[111]
        let mask : Int = 0b00010000
        return (cv112.nextCVValue & mask) == mask
      }
      return false
    }
    set(value) {
      if isTC64 {
        let cv112 = cvs[111]
        let mask : Int = 0b00010000
        cv112.nextCVValue = (cv112.nextCVValue & ~mask) | (value ? mask : 0)
      }
    }
  }
  
  public var isMasterModeEnabled : Bool {
    get {
      if isTC64 {
        let cv112 = cvs[111]
        let mask : Int = 0b10000000
        return (cv112.nextCVValue & mask) == mask
      }
      return false
    }
    set(value) {
      if isTC64 {
        let cv112 = cvs[111]
        let mask : Int = 0b10000000
        cv112.nextCVValue = (cv112.nextCVValue & ~mask) | (value ? mask : 0)
      }
    }
  }
  
  public var flashRewriteCount : Int {
    get {
      if isTC64 {
        let cv113 : Int = cvs[112].nextCVValue
        let cv114 : Int = cvs[113].nextCVValue
        let cv115 : Int = cvs[114].nextCVValue
        return cv113 | (cv114 << 8) | (cv115 << 16)
      }
      return 0
    }
  }

}

