//
//  UnitSpeed.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2022.
//

import Foundation
import AppKit

public enum UnitSpeed : Int {
  
  case kilometersPerHour = 0
  case milesPerHour = 1
  case metersPerSecond = 2
  case centimetersPerSecond = 3
  
  public var title : String {
    get {
      return UnitSpeed.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "km/h",
    "mph",
    "m/s",
    "cm/s"
  ]
  
  public static let defaultValue : UnitSpeed = .milesPerHour

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: UnitSpeed) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> UnitSpeed {
    return UnitSpeed(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}

