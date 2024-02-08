//
//  UnitType.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/02/2024.
//

import Foundation

public enum BaseUnitConversionType : UInt8 {

  case none           = 0x00
  case actualLength   = 0x10
  case scaleLength    = 0x20
  case actualDistance = 0x30
  case scaleDistance  = 0x40
  case actualSpeed    = 0x50
  case scaleSpeed     = 0x60
}

public enum UnitConversionType : UInt8 {
  
  case none            = 0x00
  case actualLength2   = 0x12
  case actualLength4   = 0x14
  case actualLength8   = 0x18
  case scaleLength2    = 0x22
  case scaleLength4    = 0x24
  case scaleLength8    = 0x28
  case actualDistance2 = 0x32
  case actualDistance4 = 0x34
  case actualDistance8 = 0x38
  case scaleDistance2  = 0x42
  case scaleDistance4  = 0x44
  case scaleDistance8  = 0x48
  case actualSpeed2    = 0x52
  case actualSpeed4    = 0x54
  case actualSpeed8    = 0x58
  case scaleSpeed2     = 0x62
  case scaleSpeed4     = 0x64
  case scaleSpeed8     = 0x68

  // MARK: Public Properties
  
  public var baseType : BaseUnitConversionType {
    return BaseUnitConversionType(rawValue: self.rawValue & 0xf0)!
  }
  
  public var numberOfBytes : Int {
    return Int(self.rawValue & 0x0f)
  }
  
}
