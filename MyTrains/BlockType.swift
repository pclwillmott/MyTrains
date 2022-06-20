//
//  BlockType.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/06/2022.
//

import Foundation
import AppKit

public enum BlockType : Int {
  
  case freeTrack = 0
  case station = 1
  case shunt = 2
  case siding = 3
  case turnout = 4

  public var title : String {
    get {
      return BlockType.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Free Track",
    "Station",
    "Shunt",
    "Siding",
    "Turnout",
  ]
  
  public static let defaultValue : BlockType = .freeTrack
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:BlockType) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox:NSComboBox) -> BlockType {
    return BlockType(rawValue: comboBox.indexOfSelectedItem) ?? .defaultValue
  }
  
}
