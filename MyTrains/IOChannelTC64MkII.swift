//
//  IOChannelTC64MkII.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2023.
//

import Foundation
import AppKit

public class IOChannelTC64MkII : IOChannel {
  
  // MARK: Public Properties
  
  override public var allowedChannelTypes : Set<InputOutput> {
    get {
      return [.output, .input]
    }
  }

  public var allowedActionPaired : Set<TC64ActionPaired> {
    get {
      if channelType == .input {
        return [.normal, .alternate, .paired]
      }
      return [.normal, .paired, .signal]
    }
  }

  override public var channelType: InputOutput {
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
  
  public var actionPaired : TC64ActionPaired {
    get {
      let cv = baseCVNumber + 1
      let mask = 0b11000000
      let rawValue = (ioDevice.cvs[cv - 1].nextCVValue & mask) >> 6
      return TC64ActionPaired(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = baseCVNumber + 1
      let mask = 0b11000000
      var rawValue = ioDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value.rawValue << 6)
      ioDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
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
  
  override public var hasPropertySheet: Bool {
    get {
      return true
    }
  }
  
  // MARK: Public Methods
  
  override public func propertySheet() {
    
    if channelType == .input {
      let x = ModalWindow.IOChannelTC64MkIIInputPropertySheet
      let wc = x.windowController
      let vc = x.viewController(windowController: wc) as! IOChannelTC64MkIIInputPropertySheetVC
      vc.ioChannel = self
      propertySheetDelegate = vc
      if let window = wc.window {
        NSApplication.shared.runModal(for: window)
        window.close()
      }
    }
    else {
      let x = ModalWindow.IOChannelTC64MkIIOutputPropertySheet
      let wc = x.windowController
      let vc = x.viewController(windowController: wc) as! IOChannelTC64MkIIOutputPropertySheetVC
      vc.ioChannel = self
      propertySheetDelegate = vc
      if let window = wc.window {
        NSApplication.shared.runModal(for: window)
        window.close()
      }
    }
    
  }

}
