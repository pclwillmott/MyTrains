//
//  UnitTime.swift
//  MyTrains
//
//  Created by Paul Willmott on 10/02/2024.
//

import Foundation

public enum UnitTime : UInt8 {
  
  case milliseconds = 0
  case seconds      = 1
  case hours        = 2

  // MARK: Public Properties
  
  public var title : String {
    return UnitTime.titles[Int(self.rawValue)]
  }

  public var symbol : String {
    return UnitTime.symbols[Int(self.rawValue)]
  }

  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Milliseconds"),
    String(localized: "Seconds"),
    String(localized: "Hours"),
  ]

  private static let symbols = [
    String(localized: "ms", comment: "Used for the abbreviation of milliseconds"),
    String(localized: "s", comment: "Used for the abbreviation of seconds"),
    String(localized: "h", comment: "Used for the abbreviation of hours"),
  ]

  private static var map : String {
    
    let items : [UnitTime] = [
      .milliseconds,
      .seconds,
      .hours,
    ]
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"
    
    return map
    
  }
  // MARK: Public Class Properties
  
  public static let defaultValue : UnitTime = .milliseconds

  public static let mapPlaceholder = CDI.UNIT_TIME

  // MARK: Public Class Methods
  
  // The factor to be applied to a time in units to get a time in seconds.
  public static func toS(units: UnitTime) -> Double {
    
    switch units {
    case .milliseconds:
      return 0.001
    case .seconds:
      return 1.0
    case .hours:
      return 3600.0
    }
    
  }
  
  // The factor to be applied to a time in seconds to get a time in units.
  public static func fromS(units: UnitTime) -> Double {
    return 1.0 / toS(units: units)
  }
  
  public static func convert(fromValue:Double, fromUnits:UnitTime, toUnits:UnitTime) -> Double {
    return fromValue * toS(units: fromUnits) * fromS(units: toUnits)
  }

  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
