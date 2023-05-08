//
//  TurnoutFeedbackType.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/07/2022.
//

import Foundation
import Cocoa

public enum TurnoutFeedbackType : Int {
  
  case none = 0
  case closed = 1
  case thrown = 2
  case both = 3
  case bothInverted = 4

  public var title : String {
    get {
      return TurnoutFeedbackType.titles[self.rawValue]
    }
  }
  
  private static let titles = [
   "None",
   "Closed",
   "Thrown",
   "Both",
   "Both (Inverted)",
  ]
  
  public static let defaultValue : TurnoutFeedbackType = .none
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    for item in titles {
      comboBox.addItem(withObjectValue: item)
    }
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: TurnoutFeedbackType) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> TurnoutFeedbackType {
    return TurnoutFeedbackType(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }

}
