//
//  UnitCurrent.swift
//  MyTrains
//
//  Created by Paul Willmott on 23/07/2024.
//

import Foundation

public enum UnitCurrent : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case milliAmps = 0
  case amps      = 1

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [UnitCurrent:String] = [
      .milliAmps : String(localized: "Milliampere"),
      .amps      : String(localized: "Ampere"),
    ]


    return titles[self]!
  }

  public var symbol : String {

    let symbols : [UnitCurrent:String] = [
      .milliAmps : String(localized: "mA", comment: "Used for the abbreviation of milliampere"),
      .amps : String(localized: "A", comment: "Used for the abbreviation of Ampere"),
    ]

    return symbols[self]!
  }

  // MARK: Private Class Properties
  
  private static var map : String {
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in UnitCurrent.allCases {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"
    
    return map
    
  }
  // MARK: Public Class Properties
  
  public static let defaultValue : UnitCurrent = .amps

  public static let mapPlaceholder = CDI.UNIT_CURRENT

  // MARK: Public Class Methods
  
  // The factor to be applied to a current in units to get a current in amps.
  public static func toAmps(units: UnitCurrent) -> Double {
    
    switch units {
    case .milliAmps:
      return 1000.0
    case .amps:
      return 1.0
    }
    
  }
  
  // The factor to be applied to a current in amps to get a current in units.
  public static func fromAmps(units: UnitCurrent) -> Double {
    return 1.0 / toAmps(units: units)
  }
  
  public static func convert(fromValue:Double, fromUnits:UnitCurrent, toUnits:UnitCurrent) -> Double {
    return fromValue * toAmps(units: fromUnits) * fromAmps(units: toUnits)
  }

  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
