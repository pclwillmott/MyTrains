//
//  UnitSpeed.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2022.
//

import Foundation
import AppKit

public enum UnitSpeed : Int {
  
  case centimetersPerSecond = 0
  case metersPerSecond = 1
  case kilometersPerHour = 2
  case inchesPerSecond = 3
  case feetPerSecond = 4
  case milesPerHour = 5

  // MARK: Public Properties
  
  public var title : String {
    return UnitSpeed.titles[self.rawValue]
  }

  public var symbol : String {
    return UnitSpeed.symbols[self.rawValue]
  }

  public var toCMS : Double {
    var temp = UnitSpeed.toCMS(units: self)
    if self == .kilometersPerHour || self == .milesPerHour {
      if let layout = myTrainsController.layout {
        temp /= layout.scale
      }
    }
    return temp
  }
  
  public var fromCMS : Double {
    var temp = UnitSpeed.fromCMS(units: self)
    if self == .kilometersPerHour || self == .milesPerHour {
      if let layout = myTrainsController.layout {
        temp *= layout.scale
      }
    }
    return temp
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Centimeters/Second"),
    String(localized: "Meters/Second"),
    String(localized: "Kilometers/Hour"),
    String(localized: "Inches/Second"),
    String(localized: "Feet/Second"),
    String(localized: "Miles/Hour"),
  ]

  private static let symbols = [
    String(localized: "cm/s", comment: "Used for the abbreviation of centimeters per second"),
    String(localized: "m/s", comment: "Used for the abbreviation of meters per second"),
    String(localized: "km/h", comment: "Used for the abbreviation of kilometers per hour"),
    String(localized: "ips", comment: "Used for the abbreviation of inches per second"),
    String(localized: "ft/s", comment: "Used for the abbreviation of feet (length) per second"),
    String(localized: "mph", comment: "Used for the abbreviation of miles per hour"),
  ]

  private static var map : String {
    
    let items : [UnitSpeed] = [
      .centimetersPerSecond,
      .metersPerSecond,
      .kilometersPerHour,
      .inchesPerSecond,
      .feetPerSecond,
      .milesPerHour,
    ]
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"
    
    return map
    
  }
  // MARK: Public Class Properties
  
  public static let defaultValue : UnitSpeed = .milesPerHour

  public static let defaultValueActualSpeed : UnitSpeed = .centimetersPerSecond
  public static let defaultValueScaleSpeed  : UnitSpeed = .kilometersPerHour

  public static let mapPlaceholder = CDI.UNIT_SPEED

  // MARK: Public Class Methods
  
  // The factor to be applied to a speed in units to get a speed in cm/s.
  // This factor does not take into account the layout scale.
  public static func toCMS(units: UnitSpeed) -> Double {
    
    let secondsPerHour : Double = 60.0 * 60.0
    let km2cm : Double = 1000.0 * 100.0
    
    switch units {
    case .centimetersPerSecond:
      return 1.0
    case .metersPerSecond:
      return 100.0
    case .kilometersPerHour:
      return km2cm / secondsPerHour
    case .inchesPerSecond:
      return 2.54
    case .feetPerSecond:
      return 12.0 * 2.54
    case .milesPerHour:
      return (1.609344 * km2cm) / secondsPerHour
    }
    
  }
  
  // The factor to be applied to a speed in cm/s to get a speed in units.
  // This factor does not take into account the layout scale.
  public static func fromCMS(units: UnitSpeed) -> Double {
    return 1.0 / toCMS(units: units)
  }
  
  public static func convert(fromValue:Double, fromUnits:UnitSpeed, toUnits:UnitSpeed) -> Double {
    return fromValue * toCMS(units: fromUnits) * fromCMS(units: toUnits)
  }

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
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}

