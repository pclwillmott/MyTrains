//
//  TC64ActionPaired.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/12/2022.
//

import Foundation
import AppKit

public enum TC64ActionPaired : Int {
  
  case normal = 0
  case alt_na = 1
  case paired = 2
  case na_signal = 3
  
  public var title : String {
    get {
      return TC64ActionPaired.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Normal",
    "Alt. / N/A",
    "Paired",
    "N/A / Signal",
  ]
  
  public static let defaultValue : TC64ActionPaired = .normal

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: TC64ActionPaired) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> TC64ActionPaired {
    return TC64ActionPaired(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}

