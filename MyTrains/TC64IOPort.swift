//
//  TC64IOPort.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/12/2022.
//

import Foundation

public class TC64IOPort : NSObject {
  
  // MARK: Constructors
  
  public init(locoNetDevice:LocoNetDevice, ioPortNumber:Int) {
    self.locoNetDevice = locoNetDevice
    self.ioPortNumber = ioPortNumber
    super.init()
  }
  
  // MARK: Private Properties
  
  private var baseCVNumber : Int {
    get {
      return 129 + (ioPortNumber - 1) * 8
    }
  }
  
  // MARK: Public Properties
  
  public var locoNetDevice : LocoNetDevice
  
  public var ioPortNumber : Int // Numbered 1 to 64
  
  public var ioPortName : String {
    get {
      let port = (ioPortNumber - 1 ) / 8 + 1
      let line = (ioPortNumber - 1 ) % 8 + 1
      let pins = [10, 9, 8, 7, 4, 3, 2, 1]
      return "Port #\(port) I/O#\(line) Pin #\(pins[line - 1])"
    }
  }
  
  public var addressPrimary : Int {
    get {
      var cv = baseCVNumber + 0
      var address = locoNetDevice.cvs[cv - 1].nextCVValue
      cv += 1
      address |= (locoNetDevice.cvs[cv - 1].nextCVValue & 0x0f) << 8
      return address
    }
    set(value) {
      var cv = baseCVNumber + 0
      locoNetDevice.cvs[cv - 1].nextCVValue = value & 0xff
      cv += 1
      var rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & 0xf0
      rawValue |= ((value & 0x0f00) >> 8)
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }

  public var addressSecondary : Int {
    get {
      var cv = baseCVNumber + 4
      var address = locoNetDevice.cvs[cv - 1].nextCVValue
      cv += 1
      address |= (locoNetDevice.cvs[cv - 1].nextCVValue & 0x0f) << 8
      return address
    }
    set(value) {
      var cv = baseCVNumber + 4
      locoNetDevice.cvs[cv - 1].nextCVValue = value & 0xff
      cv += 1
      var rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & 0xf0
      rawValue |= ((value & 0x0f00) >> 8)
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }

  public var addressTertiary : Int {
    get {
      var cv = baseCVNumber + 6
      var address = locoNetDevice.cvs[cv - 1].nextCVValue
      cv += 1
      address |= (locoNetDevice.cvs[cv - 1].nextCVValue & 0x0f) << 8
      return address
    }
    set(value) {
      var cv = baseCVNumber + 6
      locoNetDevice.cvs[cv - 1].nextCVValue = value & 0xff
      cv += 1
      var rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & 0xf0
      rawValue |= ((value & 0x0f00) >> 8)
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  public var actionPaired : TC64ActionPaired {
    get {
      let cv = baseCVNumber + 1
      let mask = 0b11000000
      let rawValue = (locoNetDevice.cvs[cv - 1].nextCVValue & mask) >> 6
      return TC64ActionPaired(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = baseCVNumber + 1
      let mask = 0b11000000
      var rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value.rawValue << 6)
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  public var modePrimary : TC64Mode {
    get {
      let cv = baseCVNumber + 1
      let mask = 0b00110000
      let rawValue = (locoNetDevice.cvs[cv - 1].nextCVValue & mask) >> 4
      return TC64Mode(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = baseCVNumber + 1
      let mask = 0b00110000
      var rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value.rawValue << 4)
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  public var modeSecondary : TC64Mode {
    get {
      let cv = baseCVNumber + 5
      let mask = 0b00110000
      let rawValue = (locoNetDevice.cvs[cv - 1].nextCVValue & mask) >> 4
      return TC64Mode(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = baseCVNumber + 5
      let mask = 0b00110000
      var rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value.rawValue << 4)
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  public var modeTertiary : TC64Mode {
    get {
      let cv = baseCVNumber + 7
      let mask = 0b00110000
      let rawValue = (locoNetDevice.cvs[cv - 1].nextCVValue & mask) >> 4
      return TC64Mode(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = baseCVNumber + 7
      let mask = 0b00110000
      var rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value.rawValue << 4)
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  public var transitionControlPrimary : TC64TransitionControl {
    get {
      let cv = baseCVNumber + 2
      let mask = 0b00000011
      let rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & (mask << 0)
      return TC64TransitionControl(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = baseCVNumber + 2
      let mask = 0b00000011
      var rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & ~(mask << 0)
      rawValue |= (value.rawValue << 0)
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  public var transitionControlSecondary : TC64TransitionControl {
    get {
      let cv = baseCVNumber + 2
      let mask = 0b00000011
      let rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & (mask << 2)
      return TC64TransitionControl(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = baseCVNumber + 2
      let mask = 0b00000011
      var rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & ~(mask << 2)
      rawValue |= (value.rawValue << 0)
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  public var transitionControlTertiary : TC64TransitionControl {
    get {
      let cv = baseCVNumber + 2
      let mask = 0b00000011
      let rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & (mask << 4)
      return TC64TransitionControl(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = baseCVNumber + 2
      let mask = 0b00000011
      var rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & ~(mask << 4)
      rawValue |= (value.rawValue << 0)
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  public var io : InputOutput {
    get {
      let cv = baseCVNumber + 2
      let rawValue = locoNetDevice.cvs[cv - 1].nextCVValue
      let mask = 0b01000000
      return (rawValue & mask) == mask ? .input : .output
    }
    set(value) {
      let cv = baseCVNumber + 2
      let mask = 0b01000000
      var rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value == .input) ? mask : 0
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  public var timing : TC64Timing {
    get {
      let cv = baseCVNumber + 3
      let rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & 0x0f
      return TC64Timing(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = baseCVNumber + 3
      var rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & ~0x0f
      rawValue |= value.rawValue
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  public var ioType : TC64OutputType {
    get {
      let cv = baseCVNumber + 3
      let mask = 0b01110000
      let rawValue = (locoNetDevice.cvs[cv - 1].nextCVValue & mask) >> 4
      return TC64OutputType(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = baseCVNumber + 3
      let mask = 0b01110000
      var rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value.rawValue << 4)
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  public var isOutputInverted : Bool {
    get {
      let cv = baseCVNumber + 3
      let mask = 0b10000000
      let rawValue = locoNetDevice.cvs[cv - 1].nextCVValue
      return (rawValue & mask) == mask
    }
    set(value) {
      let cv = baseCVNumber + 3
      let mask = 0b10000000
      var rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value ? mask : 0)
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  public var polaritySecondary : TC64Polarity {
    get {
      let cv = baseCVNumber + 5
      let mask = 0b11000000
      let rawValue = (locoNetDevice.cvs[cv - 1].nextCVValue & mask) >> 6
      return TC64Polarity(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = baseCVNumber + 5
      let mask = 0b11000000
      var rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value.rawValue << 6)
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  public var polarityTertiary : TC64Polarity {
    get {
      let cv = baseCVNumber + 7
      let mask = 0b11000000
      let rawValue = (locoNetDevice.cvs[cv - 1].nextCVValue & mask) >> 6
      return TC64Polarity(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = baseCVNumber + 7
      let mask = 0b11000000
      var rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value.rawValue << 6)
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  // MARK: Public Methods
  
}
