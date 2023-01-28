//
//  IOFunctionTC64MkII.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2023.
//

import Foundation
import AppKit

public class IOFunctionTC64MkII : IOFunction {

  // MARK: Private Properties
  
  private var tc64IOChannel : IOChannelTC64MkII {
    get {
      return ioChannel as! IOChannelTC64MkII
    }
  }
  
  private var addressPrimary : Int {
    get {
      var cv = tc64IOChannel.baseCVNumber + 0
      var address = ioDevice.cvs[cv - 1].nextCVValue
      cv += 1
      address |= (ioDevice.cvs[cv - 1].nextCVValue & 0x0f) << 8
      return address + 1
    }
    set(value) {
      let address = value - 1
      var cv = tc64IOChannel.baseCVNumber + 0
      ioDevice.cvs[cv - 1].nextCVValue = address & 0xff
      cv += 1
      var rawValue = ioDevice.cvs[cv - 1].nextCVValue & 0xf0
      rawValue |= ((address & 0x0f00) >> 8)
      ioDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }

  private var addressSecondary : Int {
    get {
      var cv = tc64IOChannel.baseCVNumber + 4
      var address = ioDevice.cvs[cv - 1].nextCVValue
      cv += 1
      address |= (ioDevice.cvs[cv - 1].nextCVValue & 0x0f) << 8
      return address + 1
    }
    set(value) {
      let address = value - 1
      var cv = tc64IOChannel.baseCVNumber + 4
      ioDevice.cvs[cv - 1].nextCVValue = address & 0xff
      cv += 1
      var rawValue = ioDevice.cvs[cv - 1].nextCVValue & 0xf0
      rawValue |= ((address & 0x0f00) >> 8)
      ioDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }

  private var addressTertiary : Int {
    get {
      var cv = tc64IOChannel.baseCVNumber + 6
      var address = ioDevice.cvs[cv - 1].nextCVValue
      cv += 1
      address |= (ioDevice.cvs[cv - 1].nextCVValue & 0x0f) << 8
      return address + 1
    }
    set(value) {
      let address = value - 1
      var cv = tc64IOChannel.baseCVNumber + 6
      ioDevice.cvs[cv - 1].nextCVValue = address & 0xff
      cv += 1
      var rawValue = ioDevice.cvs[cv - 1].nextCVValue & 0xf0
      rawValue |= ((address & 0x0f00) >> 8)
      ioDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }

  private var modePrimary : TC64Mode {
    get {
      let cv = tc64IOChannel.baseCVNumber + 1
      let mask = 0b00110000
      let rawValue = (ioDevice.cvs[cv - 1].nextCVValue & mask) >> 4
      return TC64Mode(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = tc64IOChannel.baseCVNumber + 1
      let mask = 0b00110000
      var rawValue = ioDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value.rawValue << 4)
      ioDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  private var modeSecondary : TC64Mode {
    get {
      let cv = tc64IOChannel.baseCVNumber + 5
      let mask = 0b00110000
      let rawValue = (ioDevice.cvs[cv - 1].nextCVValue & mask) >> 4
      return TC64Mode(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = tc64IOChannel.baseCVNumber + 5
      let mask = 0b00110000
      var rawValue = ioDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value.rawValue << 4)
      ioDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  private var modeTertiary : TC64Mode {
    get {
      let cv = tc64IOChannel.baseCVNumber + 7
      let mask = 0b00110000
      let rawValue = (ioDevice.cvs[cv - 1].nextCVValue & mask) >> 4
      return TC64Mode(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = tc64IOChannel.baseCVNumber + 7
      let mask = 0b00110000
      var rawValue = ioDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value.rawValue << 4)
      ioDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  private var transitionControlPrimary : TC64TransitionControl {
    get {
      let cv = tc64IOChannel.baseCVNumber + 2
      let mask = 0b00000011
      let rawValue = ioDevice.cvs[cv - 1].nextCVValue & mask
      return TC64TransitionControl(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = tc64IOChannel.baseCVNumber + 2
      let mask = 0b00000011
      var rawValue = (ioDevice.cvs[cv - 1].nextCVValue & ~mask) & 0xff
      rawValue |= value.rawValue
      ioDevice.cvs[cv - 1].nextCVValue = rawValue
    }
  }
  
  private var transitionControlSecondary : TC64TransitionControl {
    get {
      let cv = tc64IOChannel.baseCVNumber + 2
      let mask = 0b00001100
      let rawValue = (ioDevice.cvs[cv - 1].nextCVValue & mask) >> 2
      return TC64TransitionControl(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = tc64IOChannel.baseCVNumber + 2
      let mask = 0b00001100
      var rawValue = (ioDevice.cvs[cv - 1].nextCVValue & ~mask) & 0xff
      rawValue |= (value.rawValue << 2)
      ioDevice.cvs[cv - 1].nextCVValue = rawValue
    }
  }
  
  private var transitionControlTertiary : TC64TransitionControl {
    get {
      let cv = tc64IOChannel.baseCVNumber + 2
      let mask = 0b00110000
      let rawValue = (ioDevice.cvs[cv - 1].nextCVValue & mask) >> 4
      return TC64TransitionControl(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = tc64IOChannel.baseCVNumber + 2
      let mask = 0b00110000
      var rawValue = (ioDevice.cvs[cv - 1].nextCVValue & ~mask) & 0xff
      rawValue |= (value.rawValue << 4)
      ioDevice.cvs[cv - 1].nextCVValue = rawValue
    }
  }
  
  private var invertedPrimary : Bool {
    get {
      let cv = tc64IOChannel.baseCVNumber + 2
      let mask = 0b10000000
      return (ioDevice.cvs[cv - 1].nextCVValue & mask) == mask
    }
    set(value) {
      let cv = tc64IOChannel.baseCVNumber + 2
      let mask = 0b10000000
      var rawValue = ioDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value ? mask : 0)
      ioDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }

  private var invertedSecondary : Bool {
    get {
      let cv = tc64IOChannel.baseCVNumber + 5
      let mask = 0b01000000
      return (ioDevice.cvs[cv - 1].nextCVValue & mask) == mask
    }
    set(value) {
      let cv = tc64IOChannel.baseCVNumber + 5
      let mask = 0b01000000
      var rawValue = ioDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value ? mask : 0)
      ioDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }

  private var invertedTertiary : Bool {
    get {
      let cv = tc64IOChannel.baseCVNumber + 7
      let mask = 0b01000000
      return (ioDevice.cvs[cv - 1].nextCVValue & mask) == mask
    }
    set(value) {
      let cv = tc64IOChannel.baseCVNumber + 7
      let mask = 0b01000000
      var rawValue = ioDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value ? mask : 0)
      ioDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }

  private var directionPrimary : TC64Direction {
    get {
      return ioChannel.channelType == .input ? .send : .respond
    }
    set(value) {
      let _ = value
    }
  }
  
  private var directionSecondary : TC64Direction {
    get {
      let cv = tc64IOChannel.baseCVNumber + 5
      let mask = 0b10000000
      let rawValue = (ioDevice.cvs[cv - 1].nextCVValue & mask) >> 6
      return TC64Direction(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = tc64IOChannel.baseCVNumber + 5
      let mask = 0b10000000
      var rawValue = ioDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value.rawValue << 6)
      ioDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }
  
  private var directionTertiary : TC64Direction {
    get {
      let cv = tc64IOChannel.baseCVNumber + 7
      let mask = 0b10000000
      let rawValue = (ioDevice.cvs[cv - 1].nextCVValue & mask) >> 6
      return TC64Direction(rawValue: rawValue) ?? .defaultValue
    }
    set(value) {
      let cv = tc64IOChannel.baseCVNumber + 7
      let mask = 0b10000000
      var rawValue = ioDevice.cvs[cv - 1].nextCVValue & ~mask
      rawValue |= (value.rawValue << 6)
      ioDevice.cvs[cv - 1].nextCVValue = rawValue & 0xff
    }
  }

  // MARK: Public Properties
  
  public var allowedDirection : Set<TC64Direction> {
    get {
      if ioFunctionNumber == 1 {
        return ioChannel.channelType == .input ? [.send] : [.respond]
      }
      return [.send, .respond]
    }
  }

  override public var address : Int {
    get {
      switch ioFunctionNumber {
      case 1:
        return addressPrimary
      case 2:
        return addressSecondary
      case 3:
        return addressTertiary
      default:
        return -1
      }
    }
    set(value) {
      switch ioFunctionNumber {
      case 1:
        addressPrimary = value
      case 2:
        addressSecondary = value
      case 3:
        addressTertiary = value
      default:
        break
      }
    }
  }
  
  public var direction : TC64Direction {
    get {
      switch ioFunctionNumber {
      case 1:
        return directionPrimary
      case 2:
        return directionSecondary
      case 3:
        return directionTertiary
      default:
        return .defaultValue
      }
    }
    set(value) {
      switch ioFunctionNumber {
      case 1:
        directionPrimary = value
      case 2:
        directionSecondary = value
      case 3:
        directionTertiary = value
      default:
        break
      }
    }
  }
  
  public var isInverted : Bool {
    get {
      switch ioFunctionNumber {
      case 1:
        return invertedPrimary
      case 2:
        return invertedSecondary
      case 3:
        return invertedTertiary
      default:
        return false
      }
    }
    set(value) {
      switch ioFunctionNumber {
      case 1:
        invertedPrimary = value
      case 2:
        invertedSecondary = value
      case 3:
        invertedTertiary = value
      default:
        break
      }
    }
  }
  
  public var mode : TC64Mode {
    get {
      switch ioFunctionNumber {
      case 1:
        return modePrimary
      case 2:
        return modeSecondary
      case 3:
        return modeTertiary
      default:
        return .defaultValue
      }
    }
    set(value) {
      switch ioFunctionNumber {
      case 1:
        modePrimary = value
      case 2:
        modeSecondary = value
      case 3:
        modeTertiary = value
      default:
        break
      }
    }
  }
  
  public var transitionControl : TC64TransitionControl {
    get {
      switch ioFunctionNumber {
      case 1:
        return transitionControlPrimary
      case 2:
        return transitionControlSecondary
      case 3:
        return transitionControlTertiary
      default:
        return .defaultValue
      }
    }
    set(value) {
      switch ioFunctionNumber {
      case 1:
        transitionControlPrimary = value
      case 2:
        transitionControlSecondary = value
      case 3:
        transitionControlTertiary = value
      default:
        break
      }
    }
  }
  
  override public var hasPropertySheet: Bool {
    get {
      return true
    }
  }
  
  // MARK: Public Methods
  
  override public func propertySheet() {
    
    if ioChannel.channelType == .input {
      let x = ModalWindow.IOFunctionTC64MkIIInputPropertySheet
      let wc = x.windowController
      let vc = x.viewController(windowController: wc) as! IOFunctionTC64MkIIInputPropertySheetVC
      vc.ioFunction = self
      propertySheetDelegate = vc
      if let window = wc.window {
        NSApplication.shared.runModal(for: window)
        window.close()
      }
    }
    else {
      let x = ModalWindow.IOFunctionTC64MkIIOutputPropertySheet
      let wc = x.windowController
      let vc = x.viewController(windowController: wc) as! IOFunctionTC64MkIIOutputPropertySheetVC
      vc.ioFunction = self
      propertySheetDelegate = vc
      if let window = wc.window {
        NSApplication.shared.runModal(for: window)
        window.close()
      }
    }
    
  }

}
