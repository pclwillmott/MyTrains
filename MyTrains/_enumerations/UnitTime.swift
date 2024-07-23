//
//  UnitTime.swift
//  MyTrains
//
//  Created by Paul Willmott on 10/02/2024.
//

import Foundation
import AppKit

public enum UnitTime : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case milliseconds = 0
  case seconds      = 1
  case hours        = 2

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [UnitTime:String] = [
      .milliseconds : String(localized: "Milliseconds"),
      .seconds      : String(localized: "Seconds"),
      .hours        : String(localized: "Hours"),
    ]


    return titles[self]!
  }

  public var symbol : String {

    let symbols : [UnitTime:String] = [
      .milliseconds : String(localized: "ms", comment: "Used for the abbreviation of milliseconds"),
      .seconds : String(localized: "s", comment: "Used for the abbreviation of seconds"),
      .hours : String(localized: "h", comment: "Used for the abbreviation of hours"),
    ]

    return symbols[self]!
  }

  // MARK: Private Class Properties
  
  private static var map : String {
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in UnitTime.allCases {
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
