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
  
  // MARK: Public Properties
  
  public var baseCVNumber : Int {
    get {
      return 129 + (ioPortNumber - 1) * 8
    }
  }
  
  public var lastCVNumber : Int {
    get {
      return baseCVNumber + 7
    }
  }
  
  public var locoNetDevice : LocoNetDevice
  
  public var ioPortNumber : Int // Numbered 1 to 64
  
  public var ioPortName : String {
    get {
      let port = (ioPortNumber - 1 ) / 8 + 1
      let line = (ioPortNumber - 1 ) % 8 + 1
      let pins = [10, 9, 8, 7, 4, 3, 2, 1]
      return "I/O #\(port) Line #\(line) Pin #\(pins[line - 1])"
    }
  }
  
  public var addressPrimary : Int {
    get {
      var cv = baseCVNumber + 0
      var address = locoNetDevice.cvs[cv - 1].nextCVValue
      cv += 1
      address |= (locoNetDevice.cvs[cv - 1].nextCVValue & 0x0f) << 8
      return address + 1
    }
    set(value) {
      let address = value - 1
      var cv = baseCVNumber + 0
      locoNetDevice.cvs[cv - 1].nextCVValue = address & 0xff
      cv += 1
      var rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & 0xf0
      rawValue |= ((address & 0x0f00) >> 8)
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }

  public var addressSecondary : Int {
    get {
      var cv = baseCVNumber + 4
      var address = locoNetDevice.cvs[cv - 1].nextCVValue
      cv += 1
      address |= (locoNetDevice.cvs[cv - 1].nextCVValue & 0x0f) << 8
      return address + 1
    }
    set(value) {
      let address = value - 1
      var cv = baseCVNumber + 4
      locoNetDevice.cvs[cv - 1].nextCVValue = address & 0xff
      cv += 1
      var rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & 0xf0
      rawValue |= ((address & 0x0f00) >> 8)
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }

  public var addressTertiary : Int {
    get {
      var cv = baseCVNumber + 6
      var address = locoNetDevice.cvs[cv - 1].nextCVValue
      cv += 1
      address |= (locoNetDevice.cvs[cv - 1].nextCVValue & 0x0f) << 8
      return address + 1
    }
    set(value) {
      let address = value - 1
      var cv = baseCVNumber + 6
      locoNetDevice.cvs[cv - 1].nextCVValue = address & 0xff
      cv += 1
      var rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & 0xf0
      rawValue |= ((address & 0x0f00) >> 8)
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  public var paired : TC64Paired {
    get {
      let cv = baseCVNumber + 1
      let mask = 0b11000000
      let rawValue = (locoNetDevice.cvs[cv - 1].nextCVValue & mask) >> 6
      return TC64Paired(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = baseCVNumber + 1
      let mask = 0b11000000
      var rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value.rawValue << 6)
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  public var action : TC64Action {
    get {
      return TC64Action(rawValue: paired.rawValue) ?? .defaultValue
    }
    set(value) {
      paired = TC64Paired(rawValue: value.rawValue) ?? .defaultValue
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
      let rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & mask
      return TC64TransitionControl(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = baseCVNumber + 2
      let mask = 0b00000011
      var rawValue = (locoNetDevice.cvs[cv - 1].nextCVValue & ~mask) & 0xff
      rawValue |= value.rawValue
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue
    }
  }
  
  public var transitionControlSecondary : TC64TransitionControl {
    get {
      let cv = baseCVNumber + 2
      let mask = 0b00001100
      let rawValue = (locoNetDevice.cvs[cv - 1].nextCVValue & mask) >> 2
      return TC64TransitionControl(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = baseCVNumber + 2
      let mask = 0b00001100
      var rawValue = (locoNetDevice.cvs[cv - 1].nextCVValue & ~mask) & 0xff
      rawValue |= (value.rawValue << 2)
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue
    }
  }
  
  public var transitionControlTertiary : TC64TransitionControl {
    get {
      let cv = baseCVNumber + 2
      let mask = 0b00110000
      let rawValue = (locoNetDevice.cvs[cv - 1].nextCVValue & mask) >> 4
      return TC64TransitionControl(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = baseCVNumber + 2
      let mask = 0b00110000
      var rawValue = (locoNetDevice.cvs[cv - 1].nextCVValue & ~mask) & 0xff
      rawValue |= (value.rawValue << 4)
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue
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
      var rawValue = (locoNetDevice.cvs[cv - 1].nextCVValue & ~mask) & 0xff
      rawValue |= ((value == .input) ? mask : 0)
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue
    }
  }
  
  public var outputShortTiming : TC64ShortTiming {
    get {
      let cv = baseCVNumber + 3
      let rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & 0x0f
      return TC64ShortTiming(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = baseCVNumber + 3
      var rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & ~0x0f
      rawValue |= value.rawValue
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  public var outputLongTiming : TC64LongTiming {
    get {
      return TC64LongTiming(rawValue: outputShortTiming.rawValue) ?? .defaultValue
    }
    set(value) {
      outputShortTiming = TC64ShortTiming(rawValue: value.rawValue) ?? .defaultValue
    }
  }
  
  public var debounceTiming : TC64DebounceTiming {
    get {
      return TC64DebounceTiming(rawValue: outputShortTiming.rawValue) ?? .defaultValue
    }
    set(value) {
      outputShortTiming = TC64ShortTiming(rawValue: value.rawValue) ?? .defaultValue
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

  public var outputPolarityPrimary : TC64OutputPolarityPrimary {
    get {
      let cv = baseCVNumber + 2
      let mask = 0b10000000
      let rawValue = (locoNetDevice.cvs[cv - 1].nextCVValue & mask) >> 7
      return TC64OutputPolarityPrimary(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = baseCVNumber + 2
      let mask = 0b10000000
      var rawValue = locoNetDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value.rawValue << 7)
      locoNetDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  public var inputPolarityPrimary : TC64InputPolarityPrimary {
    get {
      return TC64InputPolarityPrimary(rawValue: outputPolarityPrimary.rawValue) ?? .defaultValue
    }
    set(value) {
      outputPolarityPrimary = TC64OutputPolarityPrimary(rawValue: value.rawValue) ?? .defaultValue
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
