//
//  UnitVoltage.swift
//  MyTrains
//
//  Created by Paul Willmott on 23/07/2024.
//

import Foundation

public enum UnitVoltage : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case milliVolts = 0
  case volts      = 1

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [UnitVoltage:String] = [
      .milliVolts : String(localized: "Millivolts"),
      .volts      : String(localized: "Volts"),
    ]


    return titles[self]!
  }

  public var symbol : String {

    let symbols : [UnitVoltage:String] = [
      .milliVolts : String(localized: "mV", comment: "Used for the abbreviation of millivolt"),
      .volts : String(localized: "V", comment: "Used for the abbreviation of volt"),
    ]

    return symbols[self]!
  }

  // MARK: Private Class Properties
  
  private static var map : String {
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in UnitVoltage.allCases {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"
    
    return map
    
  }
  // MARK: Public Class Properties
  
  public static let defaultValue : UnitVoltage = .volts

  public static let mapPlaceholder = CDI.UNIT_VOLTAGE

  // MARK: Public Class Methods
  
  // The factor to be applied to a voltage in units to get a voltage in volts.
  public static func toVolts(units: UnitVoltage) -> Double {
    
    switch units {
    case .milliVolts:
      return 1000.0
    case .volts:
      return 1.0
    }
    
  }
  
  // The factor to be applied to a voltage in volts to get a voltage in units.
  public static func fromVolts(units: UnitVoltage) -> Double {
    return 1.0 / toVolts(units: units)
  }
  
  public static func convert(fromValue:Double, fromUnits:UnitVoltage, toUnits:UnitVoltage) -> Double {
    return fromValue * toVolts(units: fromUnits) * fromVolts(units: toUnits)
  }

  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
