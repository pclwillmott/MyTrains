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
  case inches = 3
  case feet = 4
  
  public var title : String {
    get {
      return UnitLength.titles[self.rawValue]
    }
  }
  
  public var toCM : Double {
    get {
      return UnitLength.toCM(units: self)
    }
  }
  
  public var fromCM : Double {
    get {
      return UnitLength.fromCM(units: self)
    }
  }
  
  private static let titles = [
    "mm",
    "cm",
    "m",
    "in",
    "ft"
  ]
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: UnitLength) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static let defaultValue : UnitLength = .centimeters
  
  public static func selected(comboBox:NSComboBox) -> UnitLength {
    return UnitLength(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
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
    }
    
  }
  
  // The factor to be applied to a length in cm/s to get a length in units.
  // This factor does not take into account the layout scale.
  public static func fromCM(units: UnitLength) -> Double {
    return 1.0 / toCM(units: units)
  }

}
