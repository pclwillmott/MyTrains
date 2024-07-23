//
//  UnitLength.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2022.
//

import Foundation
import AppKit

public enum UnitLength : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
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
    
    let titles : [UnitLength:String] = [
      .millimeters : String(localized: "Millimeters"),
      .centimeters :  String(localized: "Centimeters"),
      .meters : String(localized: "Meters"),
      .kilometers :  String(localized: "Kilometers"),
      .inches : String(localized: "Inches"),
      .feet : String(localized: "Feet"),
      .miles : String(localized: "Miles"),
      .mileschains : String(localized: "Miles.Chains"),
    ]

    return titles[self]!
    
  }

  public var symbol : String {
    
    let symbols : [UnitLength:String] = [
      .millimeters : String(localized: "mm", comment: "Used for the abbreviation of millimeters"),
      .centimeters : String(localized: "cm", comment: "Used for the abbreviation of centimeters"),
      .meters : String(localized: "m", comment: "Used for the abbreviation of meters"),
      .kilometers : String(localized: "km", comment: "Used for the abbreviation of kilometers"),
      .inches : String(localized: "in.", comment: "Used for the abbreviation of inches"),
      .feet : String(localized: "ft.", comment: "Used for the abbreviation of feet (length)"),
      .miles : String(localized: "mi.", comment: "Used for the abbreviation of miles"),
      .mileschains : String(localized: "mi.ch", comment: "Used for the abbreviation of miles.chains"),
    ]

    return symbols[self]!
  }

  // MARK: Private Class Properties
  
  private static var map : String {
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in UnitLength.allCases {
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
    for item in UnitLength.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
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
