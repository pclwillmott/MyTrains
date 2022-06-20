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
  
  // The factor to be applied to a speed in units to get a speed in cm/s.
  // This factor does not take into account the layout scale.
  public static func toCMS(units: UnitSpeed) -> Double {
    
    let secondsPerHour : Double = 60.0 * 60.0
    let km2m           : Double = 1000.0
    let m2cm           : Double = 100.0
    let km2cm          : Double = km2m * m2cm
    let miles2cm       : Double = 1.609344 * km2cm
    
    switch units {
    case .kilometersPerHour:
      return 1.0 / secondsPerHour * km2cm
    case .milesPerHour:
      return 1.0 / secondsPerHour * miles2cm
    case .metersPerSecond:
      return m2cm
    case .centimetersPerSecond:
      return 1.0
    }
    
  }
  
  // The factor to be applied to a speed in cm/s to get a speed in units.
  // This factor does not take into account the layout scale.
  public static func fromCMS(units: UnitSpeed) -> Double {
    return 1.0 / toCMS(units: units)
  }
  
}

