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
  case trackFault = 3
  case transponder = 4
  case turnoutState = 5
  case unconnected = 6

  public var title : String {
    get {
      return SensorType.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Digital Input",
    "Occupancy",
    "Position",
    "Track Fault",
    "Transponder",
    "Turnout State",
    "Unconnected",
  ]
  
  private static var sequence : [SensorType] {
    get {
      var result : [SensorType] = []
      for index in 0...titles.count - 1 {
        result.append(SensorType(rawValue: index)!)
      }
      return result
    }
  }
  
  public static let defaultValue : SensorType = .unconnected

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }

  public static func populate(comboBox: NSComboBox, fromSet:Set<SensorType>) {
    comboBox.removeAllItems()
    for item in sequence {
      if fromSet.contains(item) {
        comboBox.addItem(withObjectValue: item.title)
      }
    }
    comboBox.selectItem(at: 0)
  }

  public static func select(comboBox: NSComboBox, value: SensorType) {
    var index = 0
    while index < comboBox.numberOfItems {
      if (comboBox.itemObjectValue(at: index) as! String) == value.title {
        comboBox.selectItem(at: index)
        return
      }
      index += 1
    }
  }
  
  public static func selected(comboBox: NSComboBox) -> SensorType {
    for value in sequence {
      if comboBox.stringValue == value.title {
        return value
      }
    }
    return .defaultValue
  }

}
