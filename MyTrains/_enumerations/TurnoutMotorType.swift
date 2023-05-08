//
//  TurnoutMotorType.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/06/2022.
//

import Foundation
import AppKit

public enum TurnoutMotorType : Int {
  
  case manual = 0
  case slowMotion = 1
  case solenoid = 2
  
  public var title : String {
    get {
      return TurnoutMotorType.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Manual",
    "Slow Motion",
    "Solenoid",
  ]

  private static let sequence : [TurnoutMotorType] = [.manual, .slowMotion, .solenoid]
  
  public static let defaultValue : TurnoutMotorType = .manual
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func populate(comboBox: NSComboBox, fromSet:Set<TurnoutMotorType>) {
    comboBox.removeAllItems()
    for item in fromSet {
      comboBox.addItem(withObjectValue: item.title)
    }
    comboBox.selectItem(at: 0)
  }

  public static func select(comboBox: NSComboBox, value: TurnoutMotorType) {
    var index = 0
    while index < comboBox.numberOfItems {
      if (comboBox.itemObjectValue(at: index) as! String) == value.title {
        comboBox.selectItem(at: index)
        return
      }
      index += 1
    }
  }
  
  public static func selected(comboBox: NSComboBox) -> TurnoutMotorType {
    for value in sequence {
      if comboBox.stringValue == value.title {
        return value
      }
    }
    return .manual
  }

}
