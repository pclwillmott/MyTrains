//
//  FunctionsConsistMode.swift
//  MyTrains
//
//  Created by Paul Willmott on 18/07/2024.
//

import Foundation

public enum FunctionConsistMode : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case frontLight = 127
  case rearLight = 128
  case f0 = 0
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
  case f16 = 16
  case f17 = 17
  case f18 = 18
  case f19 = 19
  case f20 = 20
  case f21 = 21
  case f22 = 22
  case f23 = 23
  case f24 = 24
  case f25 = 25
  case f26 = 26
  case f27 = 27
  case f28 = 28
  case f29 = 29
  case f30 = 30

  // MARK: Constructors
  
  init?(title:String) {
    for temp in FunctionConsistMode.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    return FunctionConsistMode.titles[self]!
  }

  // MARK: Public Methods
  
  public func cvMask(decoder:Decoder) -> (cv:CV, mask:UInt8)? {
    if decoder.decoderType.capabilities.contains(.lok5) {
      return FunctionConsistMode.masks_lok5[self]
    }
    else {
      return FunctionConsistMode.masks_lok4[self]
    }
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [FunctionConsistMode:String] = [
    .frontLight : String(localized:"Front Light"),
    .rearLight : String(localized:"Rear Light"),
    .f0 : String(localized:"F0"),
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
    .f16 : String(localized:"F16"),
    .f17 : String(localized:"F17"),
    .f18 : String(localized:"F18"),
    .f19 : String(localized:"F19"),
    .f20 : String(localized:"F20"),
    .f21 : String(localized:"F21"),
    .f22 : String(localized:"F22"),
    .f23 : String(localized:"F23"),
    .f24 : String(localized:"F24"),
    .f25 : String(localized:"F25"),
    .f26 : String(localized:"F26"),
    .f27 : String(localized:"F27"),
    .f28 : String(localized:"F28"),
    .f29 : String(localized:"F29"),
    .f30 : String(localized:"F30"),
  ]

  private static let masks_lok5 : [FunctionConsistMode:(cv:CV, mask:UInt8)] = [
    .frontLight : (.cv_000_000_022, ByteMask.d0),
    .rearLight  : (.cv_000_000_022, ByteMask.d1),
    .f1  : (.cv_000_000_021, ByteMask.d0),
    .f2  : (.cv_000_000_021, ByteMask.d1),
    .f3  : (.cv_000_000_021, ByteMask.d2),
    .f4  : (.cv_000_000_021, ByteMask.d3),
    .f5  : (.cv_000_000_021, ByteMask.d4),
    .f6  : (.cv_000_000_021, ByteMask.d5),
    .f7  : (.cv_000_000_021, ByteMask.d6),
    .f8  : (.cv_000_000_021, ByteMask.d7),
    .f9  : (.cv_000_000_022, ByteMask.d2),
    .f10 : (.cv_000_000_022, ByteMask.d3),
    .f11 : (.cv_000_000_022, ByteMask.d4),
    .f12 : (.cv_000_000_022, ByteMask.d5),
    .f13 : (.cv_000_000_022, ByteMask.d6),
    .f14 : (.cv_000_000_022, ByteMask.d7),
    .f15 : (.cv_000_000_109, ByteMask.d0),
    .f16 : (.cv_000_000_109, ByteMask.d1),
    .f17 : (.cv_000_000_109, ByteMask.d2),
    .f18 : (.cv_000_000_109, ByteMask.d3),
    .f19 : (.cv_000_000_109, ByteMask.d4),
    .f20 : (.cv_000_000_109, ByteMask.d5),
    .f21 : (.cv_000_000_109, ByteMask.d6),
    .f22 : (.cv_000_000_109, ByteMask.d7),
    .f23 : (.cv_000_000_110, ByteMask.d0),
    .f24 : (.cv_000_000_110, ByteMask.d1),
    .f25 : (.cv_000_000_110, ByteMask.d2),
    .f26 : (.cv_000_000_110, ByteMask.d3),
    .f27 : (.cv_000_000_110, ByteMask.d4),
    .f28 : (.cv_000_000_110, ByteMask.d5),
    .f29 : (.cv_000_000_110, ByteMask.d6),
    .f30 : (.cv_000_000_110, ByteMask.d7),
  ]

  private static let masks_lok4 : [FunctionConsistMode:(cv:CV, mask:UInt8)] = [
    .f1  : (.cv_000_000_021, ByteMask.d0),
    .f2  : (.cv_000_000_021, ByteMask.d1),
    .f3  : (.cv_000_000_021, ByteMask.d2),
    .f4  : (.cv_000_000_021, ByteMask.d3),
    .f5  : (.cv_000_000_021, ByteMask.d4),
    .f6  : (.cv_000_000_021, ByteMask.d5),
    .f7  : (.cv_000_000_021, ByteMask.d6),
    .f8  : (.cv_000_000_021, ByteMask.d7),
    .f0  : (.cv_000_000_022, ByteMask.d0),
    .f9  : (.cv_000_000_022, ByteMask.d1),
    .f10 : (.cv_000_000_022, ByteMask.d2),
    .f11 : (.cv_000_000_022, ByteMask.d3),
    .f12 : (.cv_000_000_022, ByteMask.d4),
    .f13 : (.cv_000_000_022, ByteMask.d5),
    .f14 : (.cv_000_000_022, ByteMask.d6),
    .f15 : (.cv_000_000_022, ByteMask.d7),
  ]

}
