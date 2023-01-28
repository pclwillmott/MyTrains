//
//  TC64Direction.swift
//  MyTrains
//
//  Created by Paul Willmott on 28/01/2023.
//

import Foundation
import AppKit

public enum TC64ActionPaired : Int {
    
  case normal = 0
  case alternate = 1
  case paired = 2
  case signal = 3

  public var title : String {
    get {
      return TC64ActionPaired.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Normal",
    "Alternate",
    "Paired",
    "Signal",
  ]
  
  private static let sequence : [TC64ActionPaired] = [.normal, .alternate, .paired, .signal]
  
  public static let defaultValue : TC64ActionPaired = .normal

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }

  public static func populate(comboBox: NSComboBox, fromSet:Set<TC64ActionPaired>) {
    comboBox.removeAllItems()
    for item in sequence {
      if fromSet.contains(item) {
        comboBox.addItem(withObjectValue: item.title)
      }
    }
    comboBox.selectItem(at: 0)
  }

  public static func select(comboBox: NSComboBox, value: TC64ActionPaired) {
    var index = 0
    while index < comboBox.numberOfItems {
      if (comboBox.itemObjectValue(at: index) as! String) == value.title {
        comboBox.selectItem(at: index)
        return
      }
      index += 1
    }
  }
  
  public static func selected(comboBox: NSComboBox) -> TC64ActionPaired {
    for value in sequence {
      if comboBox.stringValue == value.title {
        return value
      }
    }
    return .normal
  }
  
}

