//
//  CDIUIntView.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/12/2023.
//

import Foundation
import AppKit

class CDIUIntView: CDITextView {
  
  // MARK: Private & Internal Properties
  
  private var mask : UInt64? {
    
    switch elementSize {
    case 1:
      return 0xff
    case 2:
      return 0xffff
    case 4:
      return 0xffffffff
    case 8:
      return 0xffffffffffffffff
    default:
      return nil
    }

  }
  
  // MARK: Public Properties

  public var unsignedIntegerValue : UInt64 {
    get {
      return UInt64(textField.stringValue)!
    }
    set(value) {
      addTextField()
      if let mask {
        textField.stringValue = "\(value & mask)"
      }
      else {
        textField.stringValue = "bad element size"
      }
    }
  }

  // MARK: Private & Internal Methods
  
  override internal func viewType() -> OpenLCBCDIViewType? {
    return .string
  }

  // MARK: NSTextFieldDelegate, NSControlTextEditingDelegate Methods

  @objc func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
    
    guard let elementSize else {
      return true
    }
    
    switch elementSize {
    case 1:
      if let uint8 = UInt8(control.stringValue) {
        if let max = maxValue, let maxUInt8 = UInt8(max), uint8 > maxUInt8 {
          return false
        }
        if let min = minValue, let minUInt8 = UInt8(min), uint8 < minUInt8 {
          return false
        }
      }
      else {
        return false
      }
    case 2:
      if let uint16 = UInt16(control.stringValue) {
        if let max = maxValue, let maxUInt16 = UInt16(max), uint16 > maxUInt16 {
          return false
        }
        if let min = minValue, let minUInt16 = UInt16(min), uint16 < minUInt16 {
          return false
        }
     }
      else {
        return false
      }
    case 4:
      if let uint32 = UInt32(control.stringValue) {
        if let max = maxValue, let maxUInt32 = UInt32(max), uint32 > maxUInt32 {
          return false
        }
        if let min = minValue, let minUInt32 = UInt32(min), uint32 < minUInt32 {
          return false
        }
      }
      else {
        return false
      }
    case 8:
      if let uint64 = UInt64(control.stringValue) {
        if let max = maxValue, let maxUInt64 = UInt64(max), uint64 > maxUInt64 {
          return false
        }
        if let min = minValue, let minUInt64 = UInt64(min), uint64 < minUInt64 {
          return false
        }
      }
      else {
        return false
      }
    default:
      print("CDIUIntView: unexpected integer size: \(elementSize)")
      return false
    }

    return true
    
  }
  
}

