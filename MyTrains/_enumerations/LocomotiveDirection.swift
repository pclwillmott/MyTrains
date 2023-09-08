//
//  LocomotiveDirection.swift
//  MyTrains
//
//  Created by Paul Willmott on 04/08/2022.
//

import Foundation
import AppKit

public enum LocomotiveDirection : Int {
  
  case forward = 0
  case reverse = 1
  
  public var title : String {
    get {
      return LocomotiveDirection.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Forward",
    "Reverse",
  ]
  
  public static let defaultValue : LocomotiveDirection = .forward
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: .defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:LocomotiveDirection) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> LocomotiveDirection {
    return LocomotiveDirection(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}
