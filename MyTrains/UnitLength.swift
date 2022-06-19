//
//  UnitLength.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2022.
//

import Foundation
import AppKit

public enum UnitLength : Int {
  
  case millimeters = 0
  case centimeters = 1
  case meters = 2
  case inches = 3
  case feet = 4
  
  public var title : String {
    get {
      return UnitLength.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "mm",
    "cm",
    "m",
    "in",
    "ft"
  ]
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: UnitLength) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static let defaultValue : UnitLength = .centimeters
  
  public static func selected(comboBox:NSComboBox) -> UnitLength {
    return UnitLength(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }

}
