//
//  FunctionsAnalogMode.swift
//  MyTrains
//
//  Created by Paul Willmott on 18/07/2024.
//

import Foundation

public enum FunctionAnalogMode : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case light = 0
  case f1 = 1
  case f2 = 2
  case f3 = 3
  case f4 = 4
  case f5 = 5
  case f6 = 6
  case f7 = 7
  case f8 = 8
  case f9 = 9
  case f10 = 10
  case f11 = 11
  case f12 = 12
  case f13 = 13
  case f14 = 14
  case f15 = 15

  // MARK: Constructors
  
  init?(title:String) {
    for temp in FunctionAnalogMode.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [FunctionAnalogMode:String] = [
      .light : String(localized:"Light"),
      .f1 : String(localized:"F1"),
      .f2 : String(localized:"F2"),
      .f3 : String(localized:"F3"),
      .f4 : String(localized:"F4"),
      .f5 : String(localized:"F5"),
      .f6 : String(localized:"F6"),
      .f7 : String(localized:"F7"),
      .f8 : String(localized:"F8"),
      .f9 : String(localized:"F9"),
      .f10 : String(localized:"F10"),
      .f11 : String(localized:"F11"),
      .f12 : String(localized:"F12"),
      .f13 : String(localized:"F13"),
      .f14 : String(localized:"F14"),
      .f15 : String(localized:"F15"),
    ]
    
    return titles[self]!
    
  }

  public var cvMask : (cv:CV, mask:UInt8) {
    
    let masks : [FunctionAnalogMode:(cv:CV, mask:UInt8)] = [
      .f1    : (.cv_000_000_013, ByteMask.d0),
      .f2    : (.cv_000_000_013, ByteMask.d1),
      .f3    : (.cv_000_000_013, ByteMask.d2),
      .f4    : (.cv_000_000_013, ByteMask.d3),
      .f5    : (.cv_000_000_013, ByteMask.d4),
      .f6    : (.cv_000_000_013, ByteMask.d5),
      .f7    : (.cv_000_000_013, ByteMask.d6),
      .f8    : (.cv_000_000_013, ByteMask.d7),
      .light : (.cv_000_000_014, ByteMask.d0),
      .f9    : (.cv_000_000_014, ByteMask.d1),
      .f10   : (.cv_000_000_014, ByteMask.d2),
      .f11   : (.cv_000_000_014, ByteMask.d3),
      .f12   : (.cv_000_000_014, ByteMask.d4),
      .f13   : (.cv_000_000_014, ByteMask.d5),
      .f14   : (.cv_000_000_014, ByteMask.d6),
      .f15   : (.cv_000_000_014, ByteMask.d7),
    ]
    
    return masks[self]!
    
  }

}
