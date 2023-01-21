//
//  DetectionSensitivity.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/01/2023.
//

import Foundation
import AppKit

public enum DetectionSensitivity : Int {
  
  case regular = 0
  case high = 1

  public var title : String {
    get {
      return DetectionSensitivity.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Regular Detection Sensitivity",
    "High Detection Sensitivity",
  ]
  
  public static let defaultValue : DetectionSensitivity = .regular
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:DetectionSensitivity) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox:NSComboBox) -> DetectionSensitivity {
    return DetectionSensitivity(rawValue: comboBox.indexOfSelectedItem) ?? .defaultValue
  }
  
}
