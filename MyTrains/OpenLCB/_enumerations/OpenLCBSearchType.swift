//
//  OpenLCBSerachType.swift
//  MyTrains
//
//  Created by Paul Willmott on 25/06/2023.
//

import Foundation
import Cocoa

public enum OpenLCBSearchType : UInt8 {
  
  case forceAllocate       = 0x80
  case searchExistingNodes = 0x00

  // MARK: Static Properties
  
  private static let titles : [OpenLCBSearchType:String] = [
    forceAllocate       : "Force Allocate Legacy Node",
    searchExistingNodes : "Search Existing Nodes Only"
  ]
  
  // MARK: Static Methods
  
  public static let defaultValue : OpenLCBSearchType = .searchExistingNodes
  
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
  
  public static func select(comboBox:NSComboBox, value:OpenLCBSearchType) {
    let key = titles[value]!
    for index in 0 ... comboBox.numberOfItems - 1 {
      if comboBox.itemObjectValue(at: index) as! String == key {
        comboBox.selectItem(at: index)
        return
      }
    }
    comboBox.selectItem(at: Int(value.rawValue))
  }

  public static func selected(comboBox: NSComboBox) -> OpenLCBSearchType {
    let temp = comboBox.itemObjectValue(at: comboBox.indexOfSelectedItem) as! String
    for (key, item) in titles {
      if temp == item {
        return key
      }
    }
    return defaultValue
  }

}
