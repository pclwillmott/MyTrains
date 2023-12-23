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
  
  override internal func isValid(value:String) -> Bool {
    
    guard let elementSize else {
      return false
    }
    
    switch elementSize {
    case 1:
      if let uint8 = UInt8(textField.stringValue) {
        if let max = maxValue, let maxUInt8 = UInt8(max), uint8 > maxUInt8 {
          displayErrorMessage(message: "The value is greater than the maximum value of \(max).")
          return false
        }
        if let min = minValue, let minUInt8 = UInt8(min), uint8 < minUInt8 {
          displayErrorMessage(message: "The value is less than the minimum value of \(min).")
          return false
        }
      }
      else {
        displayErrorMessage(message: "Integer value expected.")
        return false
      }
    case 2:
      if let uint16 = UInt16(textField.stringValue) {
        if let max = maxValue, let maxUInt16 = UInt16(max), uint16 > maxUInt16 {
          displayErrorMessage(message: "The value is greater than the maximum value of \(max).")
          return false
        }
        if let min = minValue, let minUInt16 = UInt16(min), uint16 < minUInt16 {
          displayErrorMessage(message: "The value is less than the minimum value of \(min).")
          return false
        }
     }
      else {
        displayErrorMessage(message: "Integer value expected.")
        return false
      }
    case 4:
      if let uint32 = UInt32(textField.stringValue) {
        if let max = maxValue, let maxUInt32 = UInt32(max), uint32 > maxUInt32 {
          displayErrorMessage(message: "The value is greater than the maximum value of \(max).")
          return false
        }
        if let min = minValue, let minUInt32 = UInt32(min), uint32 < minUInt32 {
          displayErrorMessage(message: "The value is less than the minimum value of \(min).")
          return false
        }
      }
      else {
        displayErrorMessage(message: "Integer value expected.")
        return false
      }
    case 8:
      if let uint64 = UInt64(textField.stringValue) {
        if let max = maxValue, let maxUInt64 = UInt64(max), uint64 > maxUInt64 {
          displayErrorMessage(message: "The value is greater than the maximum value of \(max).")
          return false
        }
        if let min = minValue, let minUInt64 = UInt64(min), uint64 < minUInt64 {
          displayErrorMessage(message: "The value is less than the minimum value of \(min).")
          return false
        }
      }
      else {
        displayErrorMessage(message: "Integer value expected.")
        return false
      }
    default:
      print("CDIUIntView: unexpected integer size: \(elementSize)")
      return false
    }

    return true
    
  }
  
}

