//
//  ThrottleMode.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/08/2022.
//

import Foundation
import AppKit

public enum ThrottleMode : Int {
  
  case manual = 0
  case autoRoute = 1

  public var title : String {
    get {
      return ThrottleMode.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Manual",
    "Auto Route",
  ]
  
  public static let defaultValue : ThrottleMode = .manual
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: .defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:ThrottleMode) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> ThrottleMode {
    return ThrottleMode(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}
