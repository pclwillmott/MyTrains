//
//  SamplePeriod.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/08/2022.
//

import Foundation
import AppKit

public enum SamplePeriod : Int {
  
  case sec5 = 0
  case sec10 = 1
  case sec15 = 2
  case sec20 = 3
  case sec25 = 4
  case sec30 = 5
  case sec35 = 6
  case sec40 = 7
  case sec45 = 8
  case sec50 = 9
  case sec55 = 10
  case sec60 = 11

  public var title : String {
    get {
      return SamplePeriod.titles[self.rawValue]
    }
  }
  
  public var samplePeriod : TimeInterval {
    get {
      return Double(self.rawValue + 1) * 5.0
    }
  }
  
  private static let titles = [
    "5 seconds",
    "10 seconds",
    "15 seconds",
    "20 seconds",
    "25 seconds",
    "30 seconds",
    "35 seconds",
    "40 seconds",
    "45 seconds",
    "50 seconds",
    "55 seconds",
    "1 minute",
  ]
  
  public static let defaultValue : SamplePeriod = .sec15
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: .defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:SamplePeriod) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> SamplePeriod {
    return SamplePeriod(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}
