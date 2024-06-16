//
//  SpeedProfilerValueType.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/06/2024.
//

import Foundation
import AppKit

public enum SpeedProfilerValueType : Int, CaseIterable {

  // MARK: Enumeration
  
  case actualSamples = 0
  case bestFitValues = 1
  
  // MARK: Public Properties
  
  public var title : String {
    return SpeedProfilerValueType.titles[self]!
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [SpeedProfilerValueType:String] = [
    .actualSamples : String(localized:"Actual Samples"),
    .bestFitValues : String(localized:"Best Fit Values"),
  ]
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in SpeedProfilerValueType.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }
  
  public static func select(comboBox:NSComboBox, valueType:SpeedProfilerValueType) {
    comboBox.selectItem(withObjectValue: valueType.title)
  }
  
  public static func selected(comboBox:NSComboBox) -> SpeedProfilerValueType? {
    if let title = comboBox.objectValueOfSelectedItem as? String {
      for item in SpeedProfilerValueType.allCases {
        if item.title == title {
          return item
        }
      }
    }
    return nil
  }
  
}

