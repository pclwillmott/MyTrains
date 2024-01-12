//
//  OpenLCBSearchMatchType.swift
//  MyTrains
//
//  Created by Paul Willmott on 25/06/2023.
//

import Foundation
import AppKit

public enum OpenLCBSearchMatchType : UInt8 {
  
  case exactMatch = 0x40
  case allMatches = 0x00

  // MARK: Static Properties
  
  private static let titles : [OpenLCBSearchMatchType:String] = [
    exactMatch : "Exact Match Only",
    allMatches : "All Matches (including partial match)"
  ]
  
  // MARK: Static Methods
  
  public static let defaultValue : OpenLCBSearchMatchType = .allMatches
  
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
  
  public static func select(comboBox:NSComboBox, value:OpenLCBSearchMatchType) {
    let key = titles[value]!
    for index in 0 ... comboBox.numberOfItems - 1 {
      if comboBox.itemObjectValue(at: index) as! String == key {
        comboBox.selectItem(at: index)
        return
      }
    }
    comboBox.selectItem(at: Int(value.rawValue))
  }

  public static func selected(comboBox: NSComboBox) -> OpenLCBSearchMatchType {
    let temp = comboBox.itemObjectValue(at: comboBox.indexOfSelectedItem) as! String
    for (key, item) in titles {
      if temp == item {
        return key
      }
    }
    return defaultValue
  }

}
