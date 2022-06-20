//
//  TurnoutMotorType.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/06/2022.
//

import Foundation
import AppKit

public enum TurnoutMotorType : Int {
  
  case slowMotion = 0
  case solenoid = 1
  
  public var title : String {
    get {
      return TurnoutMotorType.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Slow Motion",
    "Solenoid",
  ]
  
  public static let defaultValue : TurnoutMotorType = .solenoid
  
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

