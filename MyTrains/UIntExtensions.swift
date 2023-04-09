//
//  UIntExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 09/04/2023.
//

import Foundation

extension UInt64 {
  
  public func toHex(numberOfDigits:Int) -> String {
    
    guard numberOfDigits >= 0 && numberOfDigits <= 16 else {
      return "error"
    }
    
    let highWord = UInt32(self >> 32)
    let lowWord = UInt32(self & 0xffffffff)
    let hexStr = String(format: "%08X%08X", highWord, lowWord)

    return String(hexStr.suffix(numberOfDigits))
    
  }
  
  init(hex:String) {
    
    self.init()
    
    self = UInt64(hex, radix: 16) ?? 0
    
  }

  init(hex:String.SubSequence) {
    
    self.init()
    
    self = UInt64(hex, radix: 16) ?? 0
    
  }

}

extension UInt32 {
  
  public func toHex(numberOfDigits:Int) -> String {
    
    guard numberOfDigits >= 0 && numberOfDigits <= 8 else {
      return "error"
    }
    
    let hexStr = String(format: "%08X", self)

    return String(hexStr.suffix(numberOfDigits))
    
  }
  
  init(hex:String) {
    
    self.init()
    
    self = UInt32(hex, radix: 16) ?? 0
    
  }

  init(hex:String.SubSequence) {
    
    self.init()
    
    self = UInt32(hex, radix: 16) ?? 0
    
  }

}

extension UInt16 {
  
  public func toHex(numberOfDigits:Int) -> String {
    
    guard numberOfDigits >= 0 && numberOfDigits <= 4 else {
      return "error"
    }
    
    let hexStr = String(format: "%04X", self)

    return String(hexStr.suffix(numberOfDigits))
    
  }
  
  init(hex:String) {
    
    self.init()
    
    self = UInt16(hex, radix: 16) ?? 0
    
  }

  init(hex:String.SubSequence) {
    
    self.init()
    
    self = UInt16(hex, radix: 16) ?? 0
    
  }

}

extension UInt8 {
  
  public func toHex(numberOfDigits:Int) -> String {
    
    guard numberOfDigits >= 0 && numberOfDigits <= 2 else {
      return "error"
    }
    
    let hexStr = String(format: "%02X", self)

    return String(hexStr.suffix(numberOfDigits))
    
  }
 
  init(hex:String) {
    
    self.init()
    
    self = UInt8(hex, radix: 16) ?? 0
    
  }

  init(hex:String.SubSequence) {
    
    self.init()
    
    self = UInt8(hex, radix: 16) ?? 0
    
  }

}

