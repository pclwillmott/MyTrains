//
//  TC64OutputType.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/12/2022.
//

import Foundation
import AppKit

public enum TC64OutputType : Int {
  
  case shortPulse = 0
  case longPulse = 1
  case shortBlink = 2
  case longBlink = 3
  case reserved1 = 4
  case reserved2 = 5
  case reserved3 = 6
  case reserved4 = 7

  public var title : String {
    get {
      return TC64OutputType.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Short Pulse",
    "Long Pulse",
    "Short Blink",
    "Long Blink",
    "Reserved #1",
    "Reserved #2",
    "Reserved #3",
    "Reserved #4",
  ]
  
  public static let defaultValue : TC64OutputType = .shortPulse

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: TC64OutputType) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> TC64OutputType {
    return TC64OutputType(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}

