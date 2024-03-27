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
    
    units = [UInt64](repeating: 0, count: SoftUIntX.numberOfStorageUnitsRequired(numberOfBytes: size))
    
    var temp = bigEndianData
    
    var index = 0
    while !temp.isEmpty {
      let temp2 = [UInt8](temp.suffix(8))
      units[index] = UInt64(bigEndianData: temp2)!
      temp.removeLast(temp2.count)
      index += 1
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
    
    let ten = SoftUIntX(UInt8(10))
    
    while !temp.isEmpty {
      let char = temp.removeFirst()
      if !char.isNumber {
        return nil
      }
      result = result * ten 
      result.units.append(0)
      result = (result + SoftUIntX(char.asciiValue! - Character("0").asciiValue!)).normalized
    }
    
    self = result
    
  }

  // MARK: Private Properties
  
  public var units : [UInt64] = []
  
  // MARK: Public Properties
  
  public var numberOfStorageUnitsUsed : Int {
    return units.count
  }
  
  // This is the number of bytes required
  public var size : Int
  
  public var isZero : Bool {
    for unit in units {
      if unit != 0 {
        return false
      }
    }
    return true
  }
  
  public var bigEndianData : [UInt8] {
    var result : [UInt8] = []
    for unit in units.reversed() {
      result.append(contentsOf: unit.bigEndianData)
    }
    result.removeFirst(result.count - size)
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
      
      let temp2 = SoftUIntX.divide(numerator: numerator, denominator: denominator)

      result.insert(UInt8((temp2.remainder).units[0] & 0xff) + offset, at: 0)
      
      temp = temp2.quotient
      
    } while !temp.isZero
    
    return String(cString: result)
    
  }
  
  public var normalized : SoftUIntX {
    
    var result = self
    
    while result.numberOfStorageUnitsUsed > 1 && result.units.last! == 0 {
      result.units.removeLast()
    }
    
    let temp = result.units.last!
    
    if result.numberOfStorageUnitsUsed == 1 && temp == 0 {
      result.size = 1
      return result
    }
    
    result.size = result.numberOfStorageUnitsUsed * 8
    
    var mask : UInt64 = 0xff00000000000000
    
    for _ in 1 ... 8 {
      if (temp & mask) != 0 {
        break
      }
      result.size -= 1
      mask >>= 8
    }
    
    return result
    
  }
  
  public var isHighBitSet : Bool {
    return (units.last! & 0x8000000000000000) != 0
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
    
    let unit = bitNumber / 64
    let bit  = bitNumber % 64
    
    if unit >= numberOfStorageUnitsUsed {
      fatalError("Invalid bit number")
    }
    
    return (units[unit] & (1 << bit)) != 0
    
  }
  
  public mutating func setBit(_ bitNumber:Int, value:Bool) {

    let unit = bitNumber / 64
    let bit  = bitNumber % 64
    
    if unit >= numberOfStorageUnitsUsed {
      fatalError("Invalid bit number")
    }
    
    let mask : UInt64 = 1 << bit
    
    units[unit] &= ~mask
    units[unit] |= value ? mask : 0
    
  }
  
  // MARK: Private Class Methods
  
  private static func divide(numerator:SoftUIntX, denominator:SoftUIntX) -> (quotient: SoftUIntX, remainder:SoftUIntX) {
    
    let maxSize = max(numerator.size, denominator.size)
    var remainder = SoftUIntX(size: maxSize)!
    var quotient = SoftUIntX(size: maxSize)!
    
    if maxSize <= 8 {
      let (q, r) = numerator.units[0].quotientAndRemainder(dividingBy: denominator.units[0])
      quotient.units[0] = q
      remainder.units[0] = r
    }
    else {
      for index in (0 ... numerator.numberOfStorageUnitsUsed * 64 - 1).reversed() {
        remainder = remainder << 1
        remainder.setBit(0, value: numerator.getBit(index))
        if remainder >= denominator {
          remainder = remainder - denominator
          quotient.setBit(index, value: true)
        }
      }
    }
    
    return (quotient: quotient, remainder: remainder)

  }
  
  // MARK: Public Class Methods
  
  public static func numberOfStorageUnitsRequired(numberOfBytes:Int) -> Int {
    return (numberOfBytes - 1) / 8 + 1
  }
  
  public static func << (lhs:SoftUIntX, rhs:UInt) -> SoftUIntX {
    
    var temp = lhs.units
    
    if rhs > 0 {
      
      var carry : UInt64 = 0
      
      for _ in 1 ... rhs {
        for index in 0 ... temp.count - 1 {
          let nextCarry = (temp[index] & 0x8000000000000000) != 0
          temp[index] = (temp[index] << 1) | carry
          carry = nextCarry ? 0x0000000000000001 : 0
        }
      }
      
    }
    
    var result = SoftUIntX(size: lhs.size)!
    
    result.units = temp
    
    return result
    
  }

  public static func >> (lhs:SoftUIntX, rhs:UInt) -> SoftUIntX {
    
    var temp = lhs.units
    
    if rhs > 0 {
      
      var borrow : UInt64 = 0
      
      for _ in 1 ... rhs {
        for index in (0 ... temp.count - 1).reversed() {
          let nextBorrow = (temp[index] & 0x0000000000000001) != 0
          temp[index] = (temp[index] >> 1) | borrow
          borrow = nextBorrow ? 0x8000000000000000 : 0
        }
      }
      
    }
    
    var result = SoftUIntX(size: lhs.size)!
    
    result.units = temp
    
    return result

  }
  
  public static func == (lhs:SoftUIntX, rhs:SoftUIntX) -> Bool {
    
    let maxSize = max(lhs.size, rhs.size)
    
    let left   = SoftUIntX(size: maxSize, bigEndianData: lhs.bigEndianData)!
    let right  = SoftUIntX(size: maxSize, bigEndianData: rhs.bigEndianData)!
    
    for index in 0 ... left.numberOfStorageUnitsUsed - 1 {
      if left.units[index] != right.units[index] {
        return false
      }
    }
    
    return true
    
  }
  
  public static func > (lhs:SoftUIntX, rhs:SoftUIntX) -> Bool {
    let test = lhs - rhs
    return !test.isZero && !test.isHighBitSet
  }
  
  public static func < (lhs:SoftUIntX, rhs:SoftUIntX) -> Bool {
    return (lhs - rhs).isHighBitSet
  }
  
  public static func >= (lhs:SoftUIntX, rhs:SoftUIntX) -> Bool {
    return !(lhs - rhs).isHighBitSet
  }
  
  public static func <= (lhs:SoftUIntX, rhs:SoftUIntX) -> Bool {
    let test = lhs - rhs
    return test.isZero || test.isHighBitSet
  }
  
  public static func / (lhs:SoftUIntX, rhs:SoftUIntX) -> SoftUIntX {
    
    if rhs.isZero {
      fatalError("division by zero")
    }

    let maxSize = max(lhs.size, rhs.size)
    
    let numerator   = SoftUIntX(size: maxSize, bigEndianData: lhs.bigEndianData)!
    let denominator = SoftUIntX(size: maxSize, bigEndianData: rhs.bigEndianData)!
    
    let temp = divide(numerator: numerator, denominator: denominator)
    
    return temp.quotient
    
  }

  public static func % (lhs:SoftUIntX, rhs:SoftUIntX) -> SoftUIntX {
    
    if rhs.isZero {
      fatalError("division by zero")
    }

    let maxSize = max(lhs.size, rhs.size)
    
    let numerator   = SoftUIntX(size: maxSize, bigEndianData: lhs.bigEndianData)!
    let denominator = SoftUIntX(size: maxSize, bigEndianData: rhs.bigEndianData)!
    
    let temp = divide(numerator: numerator, denominator: denominator)
    
    return temp.remainder
    
  }

  public static func * (lhs:SoftUIntX, rhs:SoftUIntX) -> SoftUIntX {
    
    let maxSize = max(lhs.size, rhs.size)
    
    var left   = SoftUIntX(size: maxSize * 2, bigEndianData: lhs.bigEndianData)!
    var right  = SoftUIntX(size: maxSize * 2, bigEndianData: rhs.bigEndianData)!
    var result = SoftUIntX(size: maxSize * 2)!
    
    for _ in 1 ... result.numberOfStorageUnitsUsed * 64 {
      if (right.units[0] & 0x01) != 0 {
        result = result + left
      }
      left = left << 1
      right = right >> 1
    }
    
    return result.normalized

  }

  public static prefix func ~ (lhs:SoftUIntX) -> SoftUIntX {
    
    var result = lhs
    
    for index in 0 ... result.numberOfStorageUnitsUsed - 1 {
      print(result.units[index].toHex(numberOfDigits: 16))
      result.units[index] = ~result.units[index]
      print(result.units[index].toHex(numberOfDigits: 16))
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
    
    var carry = false
    
    for index in 0 ... result.numberOfStorageUnitsUsed - 1 {
      let temp1 = left.units[index].addingReportingOverflow(carry ? 1 : 0)
      carry = temp1.overflow
      let temp2 = temp1.partialValue.addingReportingOverflow(right.units[index])
      carry = carry || temp2.overflow
      result.units[index] = temp2.partialValue
    }
    
    return result
    
  }

}


