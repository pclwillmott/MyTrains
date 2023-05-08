//
//  DayOfWeek.swift
//  MyTrains
//
//  Created by Paul Willmott on 04/12/2022.
//

import Foundation
import AppKit

public enum DayOfWeek : Int {
  
  case monday = 0
  case tuesday = 1
  case wednesday = 2
  case thursday = 3
  case friday = 4
  case saturday = 5
  case sunday = 6

  public var title : String {
    get {
      return DayOfWeek.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
  ]
  
  public static let defaultValue : DayOfWeek = .monday
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:DayOfWeek) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox:NSComboBox) -> DayOfWeek {
    return DayOfWeek(rawValue: comboBox.indexOfSelectedItem) ?? .defaultValue
  }
  
}
