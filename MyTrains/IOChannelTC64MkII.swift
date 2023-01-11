//
//  IOChannelTC64MkII.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2023.
//

import Foundation

public class IOChannelTC64MkII : IOChannel {
  
  // MARK: Public Properties
  
  public var baseCVNumber : Int {
    get {
      return 129 + (ioChannelNumber - 1) * 8
    }
  }
  
  public var lastCVNumber : Int {
    get {
      return baseCVNumber + 7
    }
  }
  
  public var ioPortName : String {
    get {
      let port = (ioChannelNumber - 1 ) / 8 + 1
      let line = (ioChannelNumber - 1 ) % 8 + 1
      let pins = [10, 9, 8, 7, 4, 3, 2, 1]
      return "I/O #\(port) Line #\(line) Pin #\(pins[line - 1])"
    }
  }
  
  public var paired : TC64Paired {
    get {
      let cv = baseCVNumber + 1
      let mask = 0b11000000
      let rawValue = (ioDevice.cvs[cv - 1].nextCVValue & mask) >> 6
      return TC64Paired(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = baseCVNumber + 1
      let mask = 0b11000000
      var rawValue = ioDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value.rawValue << 6)
      ioDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
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
  
  
  public var io : InputOutput {
    get {
      let cv = baseCVNumber + 2
      let rawValue = ioDevice.cvs[cv - 1].nextCVValue
      let mask = 0b01000000
      return (rawValue & mask) == mask ? .input : .output
    }
    set(value) {
      let cv = baseCVNumber + 2
      let mask = 0b01000000
      var rawValue = (ioDevice.cvs[cv - 1].nextCVValue & ~mask) & 0xff
      rawValue |= ((value == .input) ? mask : 0)
      ioDevice.cvs[cv - 1].nextCVValue = rawValue
    }
  }
  
  public var outputShortTiming : TC64ShortTiming {
    get {
      let cv = baseCVNumber + 3
      let rawValue = ioDevice.cvs[cv - 1].nextCVValue & 0x0f
      return TC64ShortTiming(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = baseCVNumber + 3
      var rawValue = ioDevice.cvs[cv - 1].nextCVValue & ~0x0f
      rawValue |= value.rawValue
      ioDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
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
      let rawValue = (ioDevice.cvs[cv - 1].nextCVValue & mask) >> 4
      return TC64OutputType(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = baseCVNumber + 3
      let mask = 0b01110000
      var rawValue = ioDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value.rawValue << 4)
      ioDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  public var isOutputInverted : Bool {
    get {
      let cv = baseCVNumber + 3
      let mask = 0b10000000
      let rawValue = ioDevice.cvs[cv - 1].nextCVValue
      return (rawValue & mask) == mask
    }
    set(value) {
      let cv = baseCVNumber + 3
      let mask = 0b10000000
      var rawValue = ioDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value ? mask : 0)
      ioDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }

}
