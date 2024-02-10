//
//  UnitLength.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2022.
//

import Foundation
import AppKit

public enum UnitLength : UInt8 {
  
  case millimeters = 0
  case centimeters = 1
  case meters      = 2
  case kilometers  = 3
  case inches      = 4
  case feet        = 5
  case miles       = 6
  case mileschains = 7

  // MARK: Public Properties
  
  public var title : String {
    return UnitLength.titles[Int(self.rawValue)]
  }

  public var symbol : String {
    return UnitLength.symbols[Int(self.rawValue)]
  }

  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Millimeters"),
    String(localized: "Centimeters"),
    String(localized: "Meters"),
    String(localized: "Kilometers"),
    String(localized: "Inches"),
    String(localized: "Feet"),
    String(localized: "Miles"),
    String(localized: "Miles.Chains"),
  ]

  private static let symbols = [
    String(localized: "mm", comment: "Used for the abbreviation of millimeters"),
    String(localized: "cm", comment: "Used for the abbreviation of centimeters"),
    String(localized: "m", comment: "Used for the abbreviation of meters"),
    String(localized: "km", comment: "Used for the abbreviation of kilometers"),
    String(localized: "in.", comment: "Used for the abbreviation of inches"),
    String(localized: "ft.", comment: "Used for the abbreviation of feet (length)"),
    String(localized: "mi.", comment: "Used for the abbreviation of miles"),
    String(localized: "mi.ch", comment: "Used for the abbreviation of miles.chains"),
  ]

  private static var map : String {
    
    let items : [UnitLength] = [
      .millimeters,
      .centimeters,
      .meters,
      .kilometers,
      .inches,
      .feet,
      .miles,
      .mileschains,
    ]
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"
    
    return map
    
  }

  // MARK: Public Class Properties
  
  public static let defaultValue : UnitLength = .centimeters

  public static let defaultValueActualLength   : UnitLength = .centimeters
  public static let defaultValueScaleLength    : UnitLength = .meters
  public static let defaultValueActualDistance : UnitLength = .centimeters
  public static let defaultValueScaleDistance  : UnitLength = .kilometers

  public static let mapPlaceholder = CDI.UNIT_LENGTH

  // MARK: Public Class Methods
  
  // The factor to be applied to a length in units to get a length in cm.
  public static func toCM(units: UnitLength) -> Double? {
    
    switch units {
    case .millimeters:
      return 1.0 / 10.0
    case .centimeters:
      return 1.0
    case .meters:
      return 100.0
    case .kilometers:
      return 100000.0
    case .inches:
      return 2.54
    case .feet:
      return 30.48
    case .miles:
      return 160934.4
    case .mileschains:
      return nil
    }
    
  }
  
  // The factor to be applied to a length in cm to get a length in units.
  public static func fromCM(units: UnitLength) -> Double? {
    guard let multiplier = toCM(units: units) else {
      return nil
    }
    return 1.0 / multiplier
  }
  
  public static func convert(fromValue:Double, fromUnits:UnitLength, toUnits:UnitLength) -> Double {

    var temp = fromValue
    
    var from = fromUnits
    
    if fromUnits == .mileschains {
      let miles = temp.rounded(.towardZero)
      let chains = temp - miles
      temp = miles + chains / 80.0
      from = .miles
    }
    
    temp *= toCM(units: from)!
    
    temp *= fromCM(units: toUnits == .mileschains ? .miles : toUnits)!
    
    if toUnits == .mileschains {
      let miles = temp.rounded(.towardZero)
      let chains = (temp - miles) * 0.80
      temp = miles + chains
    }
    
    return temp

  }

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: UnitLength) {
    comboBox.selectItem(at: Int(value.rawValue))
  }
  
  public static func selected(comboBox:NSComboBox) -> UnitLength {
    return UnitLength(rawValue: UInt8(comboBox.indexOfSelectedItem)) ?? defaultValue
  }
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
