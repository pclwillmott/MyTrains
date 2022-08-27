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
  
  public static let defaultValue : TurnoutMotorType = .manual
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value:TurnoutMotorType) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> TurnoutMotorType {
    return TurnoutMotorType(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}
