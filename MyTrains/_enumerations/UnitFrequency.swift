//
//  UnitFrequency.swift
//  MyTrains
//
//  Created by Paul Willmott on 23/07/2024.
//

import Foundation

public enum UnitFrequency : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case hertz     = 0
  case kiloHertz = 1
  case megaHertz = 2

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [UnitFrequency:String] = [
      .hertz     : String(localized: "Hertz"),
      .kiloHertz : String(localized: "Kilohertz"),
      .megaHertz : String(localized: "Megahertz"),
    ]


    return titles[self]!
  }

  public var symbol : String {

    let symbols : [UnitFrequency:String] = [
      .hertz : String(localized: "Hz", comment: "Used for the abbreviation of Hertz"),
      .kiloHertz : String(localized: "kHz", comment: "Used for the abbreviation of Kilohertz"),
      .megaHertz : String(localized: "MHz", comment: "Used for the abbreviation of Megahertz"),
    ]

    return symbols[self]!
  }

  // MARK: Private Class Properties
  
  private static var map : String {
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in UnitFrequency.allCases {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"
    
    return map
    
  }
  // MARK: Public Class Properties
  
  public static let defaultValue : UnitFrequency = .hertz

  public static let mapPlaceholder = CDI.UNIT_FREQUENCY

  // MARK: Public Class Methods
  
  // The factor to be applied to a frequency in units to get a frequency in Hertz.
  public static func toHz(units: UnitFrequency) -> Double {
    
    switch units {
    case .hertz:
      return 1.0
    case .kiloHertz:
      return 1000.0
    case .megaHertz:
      return 1000000.0
    }
    
  }
  
  // The factor to be applied to a frequency in Hertz to get a frequency in units.
  public static func fromHz(units: UnitFrequency) -> Double {
    return 1.0 / toHz(units: units)
  }
  
  public static func convert(fromValue:Double, fromUnits:UnitFrequency, toUnits:UnitFrequency) -> Double {
    return fromValue * toHz(units: fromUnits) * fromHz(units: toUnits)
  }

  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
