//
//  SensorType.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/11/2022.
//

import Foundation
import AppKit

public enum SensorType : Int {
  
  case digitalInput = 0
  case occupancy = 1
  case position = 2
  case turnoutState = 3
  case unconnected = 4

  public var title : String {
    get {
      return SensorType.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Digital Input",
    "Occupancy",
    "Position",
    "Turnout State",
    "Unconnected",
  ]
  
  public static let defaultValue : SensorType = .unconnected
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:SensorType) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox:NSComboBox) -> SensorType {
    return SensorType(rawValue: comboBox.indexOfSelectedItem) ?? .defaultValue
  }
  
}
