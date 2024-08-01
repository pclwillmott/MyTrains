//
//  ThreeValueSpeedTablePreset.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/08/2024.
//

import Foundation
import AppKit

public enum ThreeValueSpeedTablePreset : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case standard = 1
  case switcher = 2
  case ice = 3
  case identity = 0

  // MARK: Constructors
  
  init?(title:String) {
    for temp in ThreeValueSpeedTablePreset.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }
  
  // MARK: Public Properties
  
  public var title : String {
    return ThreeValueSpeedTablePreset.titles[self]!
  }
  
  public var speedTableValues : [UInt8] {
    return ThreeValueSpeedTablePreset.values[self]!
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [ThreeValueSpeedTablePreset:String] = [
    .identity : String(localized:"Identity"),
    .standard : String(localized:"Default"),
    .switcher : String(localized:"Switcher"),
    .ice      : String(localized:"ICE"),
  ]
  
  private static let values : [ThreeValueSpeedTablePreset:[UInt8]] = [
    .identity : [],
    .standard : [3, 88, 255],
    .switcher : [1, 60, 255],
    .ice      : [1, 140, 255],
  ]

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in ThreeValueSpeedTablePreset.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }
  
}

