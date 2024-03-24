//
//  SoftUIntX.swift
//  MyTrains
//
//  Created by Paul Willmott on 24/03/2024.
//

import Foundation

public struct SoftUIntX {
  
  // MARK: Constructors & Destructors
  
  init?(size:Int, bigEndianData:[UInt8] = []) {
    
    guard size >= bigEndianData.count else {
      return nil
    }
    
    self.size = size
    
    var temp = bigEndianData
    
    while !temp.isEmpty {
      digits.append(temp.removeLast())
    }
    
    let extraDigits = size - digits.count
    
    if extraDigits > 0 {
      digits.append(contentsOf: [UInt8](repeating: 0, count: extraDigits))
    }
    
  }
  
  init(_ value:UInt64) {
    self = SoftUIntX(size: 8, bigEndianData: value.bigEndianData)!
  }
  
  init(_ value:UInt32) {
    self = SoftUIntX(size: 4, bigEndianData: value.bigEndianData)!
  }
  
  init(_ value:UInt16) {
    self = SoftUIntX(size: 2, bigEndianData: value.bigEndianData)!
  }
  
  init(_ value:UInt8) {
    self = SoftUIntX(size: 1, bigEndianData: value.bigEndianData)!
  }
  
  init(_ value:Int64) {
    self = SoftUIntX(UInt64(bitPattern: value))
  }

  init(_ value:Int32) {
    self = SoftUIntX(UInt32(bitPattern: value))
  }

  init(_ value:Int16) {
    self = SoftUIntX(UInt16(bitPattern: value))
  }

  init(_ value:Int8) {
    self = SoftUIntX(UInt8(bitPattern: value))
  }
  
  init?(_ value:String) {
    
    var temp = value.trimmingCharacters(in: .whitespacesAndNewlines)
    
    var result = SoftUIntX(UInt8(0))
    
    var ten = SoftUIntX(UInt8(10))
    
    while !temp.isEmpty {
      let char = temp.removeFirst()
      if !char.isNumber {
        return nil
      }
      result = result * ten 
      result.digits.append(0)
      result.size += 1
      result = (result + SoftUIntX(char.asciiValue! - Character("0").asciiValue!)).normalized
    }
    
    self = result
    
  }

  // MARK: Private Properties
  
  private var digits : [UInt8] = []
  
  // MARK: Public Properties
  
  public var size : Int
  
  public var isZero : Bool {
    for byte in digits {
      if byte != 0 {
        return false
      }
    }
    return true
  }
  
  public var bigEndianData : [UInt8] {
    var result : [UInt8] = []
    var temp = digits
    while !temp.isEmpty {
      result.append(temp.removeLast())
    }
    return result
  }
  
  public var stringValue : String {
    
    var result : [UInt8] = [0]
    
    var temp = self.normalized
    
    let ten = SoftUIntX(UInt8(10))
    
    let offset = Character("0").asciiValue!
    
    repeat {
      
      let maxSize = max(temp.size, ten.size)
      
      let numerator   = SoftUIntX(size: maxSize, bigEndianData: temp.bigEndianData)!
      let denominator = SoftUIntX(size: maxSize, bigEndianData: ten.bigEndianData)!
      var quotient    = SoftUIntX(size: maxSize)!
      var remainder   = SoftUIntX(size: maxSize)!
      
      SoftUIntX.divide(numerator: numerator, denominator: denominator, quotient: &quotient, remainder: &remainder)

      result.insert((remainder).digits[0] + offset, at: 0)
      
      temp = quotient
      
    } while !temp.isZero
    
    return String(cString: result)
    
  }
  
  public var normalized : SoftUIntX {
    
    var result = self
    
    while result.digits.count > 0 && result.digits.last! == 0 {
      result.digits.removeLast()
      result.size -= 1
    }
    
    return result
    
  }
  
  // MARK: Public Methods
  
  public func bigEndianData(maxSize:Int) -> [UInt8]? {
    let temp = normalized
    if temp.size > maxSize {
      return nil
    }
    return temp.bigEndianData
  }
  
  public func getBit(_ bitNumber:Int) -> Bool {
    
    let byte = bitNumber / 8
    let bit  = bitNumber % 8
    
    if byte >= digits.count {
      fatalError("Invalid bit number")
    }
    
    return (digits[byte] & (1 << bit)) != 0
    
  }
  
  public mutating func setBit(_ bitNumber:Int, value:Bool) {

    let byte = bitNumber / 8
    let bit  = bitNumber % 8
    
    if byte >= digits.count {
      fatalError("Invalid bit number")
    }
    
    let mask : UInt8 = 1 << bit
    
    digits[byte] &= ~mask
    digits[byte] |= value ? mask : 0
    
  }
  
  // MARK: Private Class Methods
  
  private static func divide(numerator:SoftUIntX, denominator:SoftUIntX, quotient: inout SoftUIntX, remainder:inout SoftUIntX) {
    
    for index in (0 ...  numerator.size * 8 - 1).reversed() {
      remainder = remainder << 1
      remainder.setBit(0, value: numerator.getBit(index))
      if remainder >= denominator {
        remainder = remainder - denominator
        quotient.setBit(index, value: true)
      }
    }

  }
  
  // MARK: Public Class Methods
  
  public static func << (lhs:SoftUIntX, rhs:UInt) -> SoftUIntX {
    
    var temp = lhs.digits
    
    if rhs > 0 {
      
      var carry : UInt16 = 0
      
      for _ in 1 ... rhs {
        for index in 0 ... temp.count - 1 {
          carry = (UInt16(temp[index]) << 1) | carry
          temp[index] = UInt8(carry & 0xff)
          carry >>= 8
        }
      }
      
    }
    
    var result = SoftUIntX(size: temp.count)!
    
    result.digits = temp
    
    return result
    
  }

  public static func >> (lhs:SoftUIntX, rhs:UInt) -> SoftUIntX {
    
    var temp = lhs.bigEndianData
    
    if rhs > 0 {
      
      var borrow : UInt8 = 0
      
      for _ in 1 ... rhs {
        for index in 0 ... temp.count - 1 {
          let newBorrow = (temp[index] & 0x01) == 0x01 ? UInt8(0x80) : UInt8(0x00)
          temp[index] = (temp[index] >> 1) | borrow
          borrow = newBorrow
        }
      }
      
    }
    
    return SoftUIntX(size: temp.count, bigEndianData: temp)!
    
  }
  
  public static func == (lhs:SoftUIntX, rhs:SoftUIntX) -> Bool {
    
    let maxSize = max(lhs.size, rhs.size)
    
    let left   = SoftUIntX(size: maxSize, bigEndianData: lhs.bigEndianData)!
    let right  = SoftUIntX(size: maxSize, bigEndianData: rhs.bigEndianData)!
    
    for index in 0 ... maxSize - 1 {
      if left.digits[index] != right.digits[index] {
        return false
      }
    }
    
    return true
    
  }
  
  public static func > (lhs:SoftUIntX, rhs:SoftUIntX) -> Bool {
    let test = lhs - rhs
    return !test.isZero && !test.getBit(test.size * 8 - 1)
  }
  
  public static func < (lhs:SoftUIntX, rhs:SoftUIntX) -> Bool {
    let test = lhs - rhs
    return test.getBit(test.size * 8 - 1)
  }
  
  public static func >= (lhs:SoftUIntX, rhs:SoftUIntX) -> Bool {
    let test = lhs - rhs
    return !test.getBit(test.size * 8 - 1)
  }
  
  public static func <= (lhs:SoftUIntX, rhs:SoftUIntX) -> Bool {
    let test = lhs - rhs
    return test.isZero || test.getBit(test.size * 8 - 1)
  }
  
  public static func / (lhs:SoftUIntX, rhs:SoftUIntX) -> SoftUIntX {
    
    if rhs.isZero {
      fatalError("division by zero")
    }

    let maxSize = max(lhs.size, rhs.size)
    
    let numerator   = SoftUIntX(size: maxSize, bigEndianData: lhs.bigEndianData)!
    let denominator = SoftUIntX(size: maxSize, bigEndianData: rhs.bigEndianData)!
    var quotient    = SoftUIntX(size: maxSize)!
    var remainder   = SoftUIntX(size: maxSize)!
    
    divide(numerator: numerator, denominator: denominator, quotient: &quotient, remainder: &remainder)
    
    return quotient
    
  }

  public static func % (lhs:SoftUIntX, rhs:SoftUIntX) -> SoftUIntX {
    
    if rhs.isZero {
      fatalError("division by zero")
    }

    let maxSize = max(lhs.size, rhs.size)
    
    let numerator   = SoftUIntX(size: maxSize, bigEndianData: lhs.bigEndianData)!
    let denominator = SoftUIntX(size: maxSize, bigEndianData: rhs.bigEndianData)!
    var quotient    = SoftUIntX(size: maxSize)!
    var remainder   = SoftUIntX(size: maxSize)!
    
    divide(numerator: numerator, denominator: denominator, quotient: &quotient, remainder: &remainder)
    
    return remainder
    
  }

  public static func * (lhs:SoftUIntX, rhs:SoftUIntX) -> SoftUIntX {
    
    let maxSize = max(lhs.size, rhs.size)
    
    var left   = SoftUIntX(size: maxSize * 2, bigEndianData: lhs.bigEndianData)!
    var right  = SoftUIntX(size: maxSize * 2, bigEndianData: rhs.bigEndianData)!
    var result = SoftUIntX(size: maxSize * 2)!
    
    var numberOfBits = 8 * maxSize
    
    while numberOfBits > 0 {
      if (right.digits[0] & 0x01) == 0x01 {
        result = result + left
      }
      left = left << 1
      right = right >> 1
      numberOfBits -= 1
    }
    
    return result.normalized

  }

  public static prefix func ~ (lhs:SoftUIntX) -> SoftUIntX {
    
    var result = lhs
    
    for index in 0 ... result.digits.count - 1 {
      result.digits[index] = ~result.digits[index]
    }
    
    return result
    
  }
  
  public static func - (lhs:SoftUIntX, rhs:SoftUIntX) -> SoftUIntX {
    return lhs + ~rhs + SoftUIntX(UInt8(1))
  }

  public static func + (lhs:SoftUIntX, rhs:SoftUIntX) -> SoftUIntX {
    
    let maxSize = max(lhs.size, rhs.size)
    
    let left   = SoftUIntX(size: maxSize, bigEndianData: lhs.bigEndianData)!
    let right  = SoftUIntX(size: maxSize, bigEndianData: rhs.bigEndianData)!
    var result = SoftUIntX(size: maxSize)!
    
    var carry : UInt16 = 0
    
    for index in 0 ... maxSize - 1 {
      carry = UInt16(left.digits[index]) + UInt16(right.digits[index]) + carry
      result.digits[index] = UInt8(carry & 0xff)
      carry >>= 8
    }
    
    return result
    
  }

}


