//
//  UnitSpeed.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2022.
//

import Foundation
import AppKit

public enum UnitSpeed : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case centimetersPerSecond = 0
  case metersPerSecond = 1
  case kilometersPerHour = 2
  case inchesPerSecond = 3
  case feetPerSecond = 4
  case milesPerHour = 5

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [UnitSpeed:String] = [
      .centimetersPerSecond : String(localized: "Centimeters/Second"),
      .metersPerSecond : String(localized: "Meters/Second"),
      .kilometersPerHour : String(localized: "Kilometers/Hour"),
      .inchesPerSecond : String(localized: "Inches/Second"),
      .feetPerSecond : String(localized: "Feet/Second"),
      .milesPerHour : String(localized: "Miles/Hour"),
    ]

    return titles[self]!
  }

  public var symbol : String {
    
    let symbols : [UnitSpeed:String] = [
      .centimetersPerSecond : String(localized: "cm/s", comment: "Used for the abbreviation of centimeters per second"),
      .metersPerSecond : String(localized: "m/s", comment: "Used for the abbreviation of meters per second"),
      .kilometersPerHour : String(localized: "km/h", comment: "Used for the abbreviation of kilometers per hour"),
      .inchesPerSecond : String(localized: "ips", comment: "Used for the abbreviation of inches per second"),
      .feetPerSecond : String(localized: "ft/s", comment: "Used for the abbreviation of feet (length) per second"),
      .milesPerHour : String(localized: "mph", comment: "Used for the abbreviation of miles per hour"),
    ]

    return symbols[self]!
  }

  // MARK: Private Class Properties

  private static var map : String {
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in UnitSpeed.allCases {
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
    for item in UnitSpeed.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: UnitSpeed) {
    comboBox.selectItem(at: Int(value.rawValue))
  }
  
  public static func selected(comboBox: NSComboBox) -> UnitSpeed {
    return UnitSpeed(rawValue: UInt8(comboBox.indexOfSelectedItem)) ?? defaultValue
  }
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}

