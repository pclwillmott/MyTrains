//
//  BlockDirection.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2022.
//

import Foundation
import AppKit

public enum BlockDirection : Int {

  case bidirectional = 0
  case unidirectional = 1

  public var title : String {
    get {
      return BlockDirection.titles[self.rawValue]
    }
  }
  
  private static let titles = [
   "Bidirectional",
   "Unidirectional",
  ]
  
  public static let defaultValue : BlockDirection = .bidirectional
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    for item in titles {
      comboBox.addItem(withObjectValue: item)
    }
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: BlockDirection) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> BlockDirection {
    return BlockDirection(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}
