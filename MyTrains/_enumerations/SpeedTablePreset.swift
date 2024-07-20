//
//  SpeedTablePreset.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/07/2024.
//

import Foundation
import AppKit

public enum SpeedTablePreset : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case exponential1 = 1
  case exponential2 = 2
  case doNothing = 0
  case linear = 3
  case linearUntilFirstMaximumValue = 4
  case logarithmic1 = 5
  case logarithmic2 = 6
  case lokSound43Point = 7

  // MARK: Constructors
  
  init?(title:String) {
    for temp in SpeedTablePreset.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }
  
  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [SpeedTablePreset:String] = [
      .doNothing                    : String(localized:"Identity"),
      .linearUntilFirstMaximumValue : String(localized:"Linear until first maximum value"),
      .exponential1                 : String(localized:"Exponential 1"),
      .exponential2                 : String(localized:"Exponential 2"),
      .linear                       : String(localized:"Linear"),
      .logarithmic1                 : String(localized:"Logarithmic 1"),
      .logarithmic2                 : String(localized:"Logarithmic 2"),
      .lokSound43Point              : String(localized:"LokSound 4 3 Point"),
    ]
    
    return titles[self]!
    
  }
  
  public var speedTableValues : [UInt8] {
    
    let values : [SpeedTablePreset:[UInt8]] = [
      .doNothing : [],
      .linearUntilFirstMaximumValue : [],
      .exponential1 : [
        1,
        2,
        4,
        7,
        10,
        14,
        18,
        23,
        28,
        34,
        40,
        47,
        54,
        62,
        70,
        79,
        88,
        98,
        108,
        120,
        133,
        147,
        162,
        178,
        195,
        213,
        233,
        255,
      ],
      .exponential2 : [
        1,
        1,
        2,
        3,
        3,
        4,
        4,
        5,
        5,
        6,
        6,
        7,
        10,
        14,
        18,
        24,
        31,
        40,
        50,
        63,
        77,
        93,
        112,
        134,
        159,
        187,
        219,
        255,
      ],
      .linear : [
        1,
        9,
        18,
        28,
        37,
        47,
        56,
        66,
        75,
        85,
        94,
        103,
        113,
        122,
        132,
        141,
        151,
        160,
        170,
        179,
        188,
        198,
        207,
        217,
        226,
        236,
        245,
        255,
      ],
      .logarithmic1 : [
        1,
         35,
         54,
         69,
         81,
         93,
         104,
         114,
         123,
         132,
         141,
         149,
         157,
         165,
         173,
         180,
         187,
         194,
         201,
         207,
         214,
         220,
         226,
         233,
         239,
         244,
         250,
         255,
      ],
      .logarithmic2 : [
        1,
        65,
        86,
        108,
        123,
        136,
        146,
        155,
        163,
        171,
        177,
        184,
        190,
        195,
        200,
        205,
        210,
        215,
        219,
        223,
        227,
        231,
        235,
        238,
        242,
        245,
        249,
        255,
      ],
      .lokSound43Point : [
        1,
        7,
        12,
        17,
        22,
        28,
        34,
        40,
        47,
        55,
        62,
        71,
        79,
        88,
        98,
        108,
        118,
        129,
        140,
        151,
        163,
        175,
        188,
        200,
        213,
        227,
        241,
        255,
      ]
    ]
    
    return values[self]!
    
  }
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in SpeedTablePreset.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }
  
}

