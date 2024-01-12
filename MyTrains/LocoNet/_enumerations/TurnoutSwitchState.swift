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

  // MARK: Public Properties
  
  public var title : String {
    return TurnoutSwitchState.titles[self.rawValue]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Thrown", comment: "Used to indicate the state of a turnout"),
    String(localized: "Closed", comment: "Used to indicate the state of a turnout"),
    String(localized: "Unknown", comment: "Used to indicate the state of a turnout"),
  ]
  
  // MARK: Public Class Properties
  
  public static let defaultValue : TurnoutSwitchState = .unknown

  // MARK: Public Class Methods
  
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
