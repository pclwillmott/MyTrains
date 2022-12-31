//
//  TC64ActionPaired.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/12/2022.
//

import Foundation
import AppKit

public enum TC64Action : Int {
  
  case normal = 0
  case alt = 1
  case paired = 2
  case na = 3
  
  public var title : String {
    get {
      return TC64Action.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Normal",
    "Alt.",
    "Paired",
    "N/A",
  ]
  
  public static let defaultValue : TC64Action = .normal

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: TC64Action) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> TC64Action {
    return TC64Action(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}

