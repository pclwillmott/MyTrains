//
//  TC64Paired.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/12/2022.
//

import Foundation
import AppKit

public enum TC64Paired : Int {
  
  case normal = 0
  case na = 1
  case paired = 2
  case signal = 3
  
  public var title : String {
    get {
      return TC64Paired.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Normal",
    "N/A",
    "Paired",
    "Signal",
  ]
  
  public static let defaultValue : TC64Paired = .normal

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: TC64Paired) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> TC64Paired {
    return TC64Paired(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}

