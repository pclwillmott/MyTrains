//
//  TC64TransitionControl.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/12/2022.
//

import Foundation
import AppKit

public enum TC64TransitionControl : Int {
  
  case noMessage         = 0
  case onPositiveEdge    = 1
  case onNegativeEdge    = 2
  case onBothTransitions = 3

  public var title : String {
    get {
      return TC64TransitionControl.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "No Message",
    "On Positive Edge",
    "On Negative Edge",
    "On Both Transitions",
  ]
  
  public static let defaultValue : TC64TransitionControl = .noMessage

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: TC64TransitionControl) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> TC64TransitionControl {
    return TC64TransitionControl(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}

