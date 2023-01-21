//
//  ShortCircuitDetectionType.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/01/2023.
//

import Foundation
import AppKit

public enum ShortCircuitDetectionType : Int {
  
  case normal = 0
  case slower = 1

  public var title : String {
    get {
      return ShortCircuitDetectionType.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Normal Short Circuit Detection",
    "Slower Short Circuit Detection",
  ]
  
  public static let defaultValue : ShortCircuitDetectionType = .normal
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:ShortCircuitDetectionType) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox:NSComboBox) -> ShortCircuitDetectionType {
    return ShortCircuitDetectionType(rawValue: comboBox.indexOfSelectedItem) ?? .defaultValue
  }
  
}
