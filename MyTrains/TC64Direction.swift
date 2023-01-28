//
//  TC64Direction.swift
//  MyTrains
//
//  Created by Paul Willmott on 28/01/2023.
//

import Foundation
import AppKit

public enum TC64Direction : Int {
    
  case send = 0
  case respond = 1

  public var title : String {
    get {
      return TC64Direction.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Send",
    "Respond",
  ]
  
  private static let sequence : [TC64Direction] = [.send, .respond]
  
  public static let defaultValue : TC64Direction = .send

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }

  public static func populate(comboBox: NSComboBox, fromSet:Set<TC64Direction>) {
    comboBox.removeAllItems()
    for item in sequence {
      if fromSet.contains(item) {
        comboBox.addItem(withObjectValue: item.title)
      }
    }
    comboBox.selectItem(at: 0)
  }

  public static func select(comboBox: NSComboBox, value: TC64Direction) {
    var index = 0
    while index < comboBox.numberOfItems {
      if (comboBox.itemObjectValue(at: index) as! String) == value.title {
        comboBox.selectItem(at: index)
        return
      }
      index += 1
    }
  }
  
  public static func selected(comboBox: NSComboBox) -> TC64Direction {
    for value in sequence {
      if comboBox.stringValue == value.title {
        return value
      }
    }
    return .send
  }
  
}

