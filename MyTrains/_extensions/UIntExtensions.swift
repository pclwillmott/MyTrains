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
  
  public func toHexDotFormat(numberOfBytes:Int) -> String {

    guard numberOfBytes >= 0 && numberOfBytes <= 8 else {
      return "error"
    }

    var hex = self.toHex(numberOfDigits: numberOfBytes * 2)
    
    var result = ""
    
    while !hex.isEmpty {
      result += hex.prefix(2)
      hex.removeFirst(2)
      if !hex.isEmpty {
        result += "."
      }
    }
    
    return result
    
  }
  
  init?(dotHex:String) {
    
    let split = dotHex.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: ".", omittingEmptySubsequences: true)
    
    if split.count != 8 {
      return nil
    }
    
    var value : UInt64 = 0
    
    for digits in split {
      if let byte = UInt8(digits, radix: 16) {
        value <<= 8
        value |= UInt64(byte)
      }
      else {
        return nil
      }
    }
    
    self.init()
    
    self = value
    
  }
  
  init(hex:String) {
    
    self.init()
    
    self = UInt64(hex, radix: 16) ?? 0
    
  }

  init(hex:String.SubSequence) {
    
    self.init()
    
    self = UInt64(hex, radix: 16) ?? 0
    
  }
  
  init?(bigEndianData: [UInt8]) {
    
    guard bigEndianData.count <= 8 else {
      return nil
    }
    
    self.init()
    
    self = 0
    for byte in bigEndianData {
      self <<= 8
      self |= UInt64(byte)
    }
    
  }
  
  public var bigEndianData : [UInt8] {
    var intValue = self
    var data : [UInt8] = []
    for _ in 1...MemoryLayout<UInt64>.size {
      let byte = UInt8(intValue & 0xff)
      data.insert(byte, at: 0)
      intValue >>= 8
    }
    return data
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

  init?(bigEndianData: [UInt8]) {
    
    guard bigEndianData.count <= 4 else {
      return nil
    }
    
    self.init()
    
    self = 0
    for byte in bigEndianData {
      self <<= 8
      self |= UInt32(byte)
    }
    
  }

  public var bigEndianData : [UInt8] {
    var intValue = self
    var data : [UInt8] = []
    for _ in 1...MemoryLayout<UInt32>.size {
      let byte = UInt8(intValue & 0xff)
      data.insert(byte, at: 0)
      intValue >>= 8
    }
    return data
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

  init?(bigEndianData: [UInt8]) {
    
    guard bigEndianData.count <= 2 else {
      return nil
    }
    
    self.init()
    
    self = 0
    for byte in bigEndianData {
      self <<= 8
      self |= UInt16(byte)
    }
    
  }
  
  public var bigEndianData : [UInt8] {
    var intValue = self
    var data : [UInt8] = []
    for _ in 1...MemoryLayout<UInt16>.size {
      let byte = UInt8(intValue & 0xff)
      data.insert(byte, at: 0)
      intValue >>= 8
    }
    return data
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

  init?(bigEndianData: [UInt8]) {
    
    guard bigEndianData.count == 1 else {
      return nil
    }
    
    self.init()
    
    self = bigEndianData[0]
    
  }
  
  public var bigEndianData : [UInt8] {
    return [self]
  }

}

