//
//  Orientation.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2022.
//

import Foundation
import AppKit

public enum Orientation : Int {
  
  case deg0   = 0
  case deg45  = 1
  case deg90  = 2
  case deg135 = 3
  case deg180 = 4
  case deg225 = 5
  case deg270 = 6
  case deg315 = 7

  public var title : String {
    get {
      return Orientation.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "0°",
    "45°",
    "90°",
    "135°",
    "180°",
    "225°",
    "270°",
    "315°",
  ]
  
  public static let defaultValue : Orientation = .deg0
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in titles {
      comboBox.addItem(withObjectValue: item)
    }
    select(comboBox: comboBox, value: .deg0)
  }
  
  public static func select(comboBox:NSComboBox, value:Orientation) {
    comboBox.selectItem(at: value.rawValue)
  }
  
}
