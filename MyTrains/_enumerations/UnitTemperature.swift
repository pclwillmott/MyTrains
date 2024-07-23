//
//  UnitTemperature.swift
//  MyTrains
//
//  Created by Paul Willmott on 23/07/2024.
//

import Foundation

public enum UnitTemperature : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case celsius    = 0
  case fahrenheit = 1
  case kelvin     = 2

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [UnitTemperature:String] = [
      .celsius    : String(localized: "Celsius"),
      .fahrenheit : String(localized: "Fahrenheit"),
      .kelvin     : String(localized: "Kelvin"),
    ]


    return titles[self]!
  }

  public var symbol : String {

    let symbols : [UnitTemperature:String] = [
      .celsius : String(localized: "°C", comment: "Used for the abbreviation of Degrees Celsius"),
      .fahrenheit : String(localized: "°F", comment: "Used for the abbreviation of Degrees Fahrenheit"),
      .kelvin : String(localized: "K", comment: "Used for the abbreviation of Kelvin"),
    ]

    return symbols[self]!
  }

  // MARK: Private Class Properties
  
  private static var map : String {
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in UnitTemperature.allCases {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"
    
    return map
    
  }
  // MARK: Public Class Properties
  
  public static let defaultValue : UnitTemperature = .celsius

  public static let mapPlaceholder = CDI.UNIT_TEMPERATURE

  // MARK: Public Class Methods
    
  public static func convert(fromValue:Double, fromUnits:UnitTemperature, toUnits:UnitTemperature) -> Double {
    
    var celsius : Double
    
    switch fromUnits {
    case .celsius:
      celsius = fromValue
    case .fahrenheit:
      celsius = (fromValue - 32.0) * 5.0 / 9.0
    case .kelvin:
      celsius = fromValue - 273.15
    }
    
    var result : Double
    
    switch toUnits {
    case .celsius:
      result = celsius
    case .fahrenheit:
      result = celsius * 9.0 / 5.0 + 32.0
    case .kelvin:
      result = celsius + 273.15
    }
    
    return result
    
  }

  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
