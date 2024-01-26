//
//  UnitLength.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2022.
//

import Foundation
import AppKit

public enum UnitLength : Int {
  
  case millimeters = 0
  case centimeters = 1
  case meters = 2
  case kilometers = 3
  case inches = 4
  case feet = 5
  case miles = 6
  case mileschains = 7

  // MARK: Public Properties
  
  public var title : String {
    return UnitLength.titles[self.rawValue]
  }
  
  public var toCM : Double {
    return UnitLength.toCM(units: self)
  }
  
  public var fromCM : Double {
    return UnitLength.fromCM(units: self)
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
  
  public static let mapPlaceholder = CDI.UNIT_LENGTH

  // MARK: Public Class Methods
  
  // The factor to be applied to a length in units to get a length in cm.
  // This factor does not take into account the layout scale.
  public static func toCM(units: UnitLength) -> Double {
    
    switch units {
    case .millimeters:
      return 1.0 / 10.0
    case .centimeters:
      return 1.0
    case .feet:
      return 12.0 * 2.54
    case .meters:
      return 100.0
    case .inches:
      return 2.54
    default:
      return 1.0
    }
    
  }
  
  // The factor to be applied to a length in cm/s to get a length in units.
  // This factor does not take into account the layout scale.
  public static func fromCM(units: UnitLength) -> Double {
    return 1.0 / toCM(units: units)
  }

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: UnitLength) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox:NSComboBox) -> UnitLength {
    return UnitLength(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
