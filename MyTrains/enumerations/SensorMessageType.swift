//
//  SensorMessageType.swift
//  MyTrains
//
//  Created by Paul Willmott on 14/01/2023.
//

import Foundation
import AppKit

public enum SensorMessageType : Int {
    
  case generalSensorReport = 0
  case turnoutSensorState = 1
  case turnoutOutputState = 2

  public var title : String {
    get {
      return SensorMessageType.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "General Sensor Report",
    "Turnout Sensor State",
    "Turnout Output State",
  ]
  
  private static let sequence : [SensorMessageType] = [.generalSensorReport, .turnoutSensorState, .turnoutOutputState]
  
  public static let defaultValue : SensorMessageType = .generalSensorReport

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }

  public static func populate(comboBox: NSComboBox, fromSet:Set<SensorMessageType>) {
    comboBox.removeAllItems()
    for item in fromSet {
      comboBox.addItem(withObjectValue: item.title)
    }
    comboBox.selectItem(at: 0)
  }

  public static func select(comboBox: NSComboBox, value: SensorMessageType) {
    var index = 0
    while index < comboBox.numberOfItems {
      if (comboBox.itemObjectValue(at: index) as! String) == value.title {
        comboBox.selectItem(at: index)
        return
      }
      index += 1
    }
  }
  
  public static func selected(comboBox: NSComboBox) -> SensorMessageType {
    for value in sequence {
      if comboBox.stringValue == value.title {
        return value
      }
    }
    return defaultValue
  }
  
}

