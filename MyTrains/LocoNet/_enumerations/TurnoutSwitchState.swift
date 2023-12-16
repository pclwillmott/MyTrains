//
//  TurnoutSwitchState.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/07/2022.
//

import Foundation
import Cocoa
import AppKit

public enum TurnoutSwitchState : Int {
  
  case thrown  = 0
  case closed  = 1
  case unknown = 2

  public var title : String {
    get {
      return TurnoutSwitchState.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Thrown",
    "Closed",
    "Unknown",
  ]
  
  public static let defaultValue : TurnoutSwitchState = .unknown

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: TurnoutSwitchState) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> TurnoutSwitchState {
    return TurnoutSwitchState(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }

}
