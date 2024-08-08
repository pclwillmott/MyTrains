//
//  ESUFunctionMapping.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/07/2024.
//

import Foundation
import AppKit

public enum ESUFunctionMapping : Int, CaseIterable {
  
  // MARK: Enumeration
  
  case mapping1 = 0
  case mapping2 = 1
  case mapping3 = 2
  case mapping4 = 3
  case mapping5 = 4
  case mapping6 = 5
  case mapping7 = 6
  case mapping8 = 7
  case mapping9 = 8
  case mapping10 = 9
  case mapping11 = 10
  case mapping12 = 11
  case mapping13 = 12
  case mapping14 = 13
  case mapping15 = 14
  case mapping16 = 15
  case mapping17 = 16
  case mapping18 = 17
  case mapping19 = 18
  case mapping20 = 19
  case mapping21 = 20
  case mapping22 = 21
  case mapping23 = 22
  case mapping24 = 23
  case mapping25 = 24
  case mapping26 = 25
  case mapping27 = 26
  case mapping28 = 27
  case mapping29 = 28
  case mapping30 = 29
  case mapping31 = 30
  case mapping32 = 31
  case mapping33 = 32
  case mapping34 = 33
  case mapping35 = 34
  case mapping36 = 35
  case mapping37 = 36
  case mapping38 = 37
  case mapping39 = 38
  case mapping40 = 39
  case mapping41 = 40
  case mapping42 = 41
  case mapping43 = 42
  case mapping44 = 43
  case mapping45 = 44
  case mapping46 = 45
  case mapping47 = 46
  case mapping48 = 47
  case mapping49 = 48
  case mapping50 = 49
  case mapping51 = 50
  case mapping52 = 51
  case mapping53 = 52
  case mapping54 = 53
  case mapping55 = 54
  case mapping56 = 55
  case mapping57 = 56
  case mapping58 = 57
  case mapping59 = 58
  case mapping60 = 59
  case mapping61 = 60
  case mapping62 = 61
  case mapping63 = 62
  case mapping64 = 63
  case mapping65 = 64
  case mapping66 = 65
  case mapping67 = 66
  case mapping68 = 67
  case mapping69 = 68
  case mapping70 = 69
  case mapping71 = 70
  case mapping72 = 71

  // MARK: Constructors
  
  init?(title:String) {
    for temp in ESUFunctionMapping.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    return ESUFunctionMapping.titles[self]!
  }
  
  public func cvIndexOffset(decoder:Decoder) -> Int {
    return self.rawValue * 16
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [ESUFunctionMapping:String] = [
    
    .mapping1 : String(localized:"Function Mapping 1"),
    .mapping2 : String(localized:"Function Mapping 2"),
    .mapping3 : String(localized:"Function Mapping 3"),
    .mapping4 : String(localized:"Function Mapping 4"),
    .mapping5 : String(localized:"Function Mapping 5"),
    .mapping6 : String(localized:"Function Mapping 6"),
    .mapping7 : String(localized:"Function Mapping 7"),
    .mapping8 : String(localized:"Function Mapping 8"),
    .mapping9 : String(localized:"Function Mapping 9"),
    .mapping10 : String(localized:"Function Mapping 10"),
    .mapping11 : String(localized:"Function Mapping 11"),
    .mapping12 : String(localized:"Function Mapping 12"),
    .mapping13 : String(localized:"Function Mapping 13"),
    .mapping14 : String(localized:"Function Mapping 14"),
    .mapping15 : String(localized:"Function Mapping 15"),
    .mapping16 : String(localized:"Function Mapping 16"),
    .mapping17 : String(localized:"Function Mapping 17"),
    .mapping18 : String(localized:"Function Mapping 18"),
    .mapping19 : String(localized:"Function Mapping 19"),
    .mapping20 : String(localized:"Function Mapping 20"),
    .mapping21 : String(localized:"Function Mapping 21"),
    .mapping22 : String(localized:"Function Mapping 22"),
    .mapping23 : String(localized:"Function Mapping 23"),
    .mapping24 : String(localized:"Function Mapping 24"),
    .mapping25 : String(localized:"Function Mapping 25"),
    .mapping26 : String(localized:"Function Mapping 26"),
    .mapping27 : String(localized:"Function Mapping 27"),
    .mapping28 : String(localized:"Function Mapping 28"),
    .mapping29 : String(localized:"Function Mapping 29"),
    .mapping30 : String(localized:"Function Mapping 30"),
    .mapping31 : String(localized:"Function Mapping 31"),
    .mapping32 : String(localized:"Function Mapping 32"),
    .mapping33 : String(localized:"Function Mapping 33"),
    .mapping34 : String(localized:"Function Mapping 34"),
    .mapping35 : String(localized:"Function Mapping 35"),
    .mapping36 : String(localized:"Function Mapping 36"),
    .mapping37 : String(localized:"Function Mapping 37"),
    .mapping38 : String(localized:"Function Mapping 38"),
    .mapping39 : String(localized:"Function Mapping 39"),
    .mapping40 : String(localized:"Function Mapping 40"),
    .mapping41 : String(localized:"Function Mapping 41"),
    .mapping42 : String(localized:"Function Mapping 42"),
    .mapping43 : String(localized:"Function Mapping 43"),
    .mapping44 : String(localized:"Function Mapping 44"),
    .mapping45 : String(localized:"Function Mapping 45"),
    .mapping46 : String(localized:"Function Mapping 46"),
    .mapping47 : String(localized:"Function Mapping 47"),
    .mapping48 : String(localized:"Function Mapping 48"),
    .mapping49 : String(localized:"Function Mapping 49"),
    .mapping50 : String(localized:"Function Mapping 50"),
    .mapping51 : String(localized:"Function Mapping 51"),
    .mapping52 : String(localized:"Function Mapping 52"),
    .mapping53 : String(localized:"Function Mapping 53"),
    .mapping54 : String(localized:"Function Mapping 54"),
    .mapping55 : String(localized:"Function Mapping 55"),
    .mapping56 : String(localized:"Function Mapping 56"),
    .mapping57 : String(localized:"Function Mapping 57"),
    .mapping58 : String(localized:"Function Mapping 58"),
    .mapping59 : String(localized:"Function Mapping 59"),
    .mapping60 : String(localized:"Function Mapping 60"),
    .mapping61 : String(localized:"Function Mapping 61"),
    .mapping62 : String(localized:"Function Mapping 62"),
    .mapping63 : String(localized:"Function Mapping 63"),
    .mapping64 : String(localized:"Function Mapping 64"),
    .mapping65 : String(localized:"Function Mapping 65"),
    .mapping66 : String(localized:"Function Mapping 66"),
    .mapping67 : String(localized:"Function Mapping 67"),
    .mapping68 : String(localized:"Function Mapping 68"),
    .mapping69 : String(localized:"Function Mapping 69"),
    .mapping70 : String(localized:"Function Mapping 70"),
    .mapping71 : String(localized:"Function Mapping 71"),
    .mapping72 : String(localized:"Function Mapping 72"),

  ]
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox, decoder:Decoder) {
    
    let maxFunction = decoder.decoderType.capabilities.contains(.lok5) ? ESUFunctionMapping.mapping72 : ESUFunctionMapping.mapping40
    
    comboBox.removeAllItems()
    for item in ESUFunctionMapping.allCases {
      if item.rawValue <= maxFunction.rawValue {
        comboBox.addItem(withObjectValue: item.title)
      }
    }
  }

}
