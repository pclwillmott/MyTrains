//
//  OpenLCBSearchMatchTarget.swift
//  MyTrains
//
//  Created by Paul Willmott on 25/06/2023.
//

import Foundation
import AppKit

public enum OpenLCBSearchMatchTarget : UInt8 {
  
  case matchAddressOnly = 0x20
  case matchAnywhere    = 0x00

  // MARK: Static Properties
  
  private static let titles : [OpenLCBSearchMatchTarget:String] = [
    matchAddressOnly : "Match in Address Only",
    matchAnywhere    : "Match in Address or Name"
  ]
  
  // MARK: Static Methods
  
  public static let defaultValue : OpenLCBSearchMatchTarget = .matchAnywhere
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    var temp : [String] = []
    for (_, title) in titles {
      temp.append(title)
    }
    temp.sort {$0 < $1}
    comboBox.addItems(withObjectValues: temp)
    select(comboBox: comboBox, value: .defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:OpenLCBSearchMatchTarget) {
    let key = titles[value]!
    for index in 0 ... comboBox.numberOfItems - 1 {
      if comboBox.itemObjectValue(at: index) as! String == key {
        comboBox.selectItem(at: index)
        return
      }
    }
    comboBox.selectItem(at: Int(value.rawValue))
  }

  public static func selected(comboBox: NSComboBox) -> OpenLCBSearchMatchTarget {
    let temp = comboBox.itemObjectValue(at: comboBox.indexOfSelectedItem) as! String
    for (key, item) in titles {
      if temp == item {
        return key
      }
    }
    return defaultValue
  }

}
