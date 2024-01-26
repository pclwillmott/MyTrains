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

  public static let mapPlaceholder = CDI.UNIT_SPEED

  // MARK: Public Class Methods
  
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
    default:
      return 1.0
    }
    
  }
  
  // The factor to be applied to a speed in cm/s to get a speed in units.
  // This factor does not take into account the layout scale.
  public static func fromCMS(units: UnitSpeed) -> Double {
    return 1.0 / toCMS(units: units)
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

