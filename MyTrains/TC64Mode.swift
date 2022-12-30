//
//  TC64Mode.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/12/2022.
//

import Foundation
import AppKit

public enum TC64Mode : Int {
  
  case switchRequest = 0
  case SwitchFeedback = 1
  case SensorMessage = 2
  case Reserved = 3
  
  public var title : String {
    get {
      return TC64Mode.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Switch Request",
    "Switch Feedback",
    "Sensor Message",
    "Reserved",
  ]
  
  public static let defaultValue : TC64Mode = .switchRequest

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: TC64Mode) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> TC64Mode {
    return TC64Mode(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}

