//
//  RouteDirection.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/08/2022.
//

import Foundation
import AppKit

public enum RouteDirection : Int {
  
  case next = 0
  case previous = 1

  public var title : String {
    get {
      return RouteDirection.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Next",
    "Previous",
  ]
  
  public static let defaultValue : RouteDirection = .next
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: .defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:RouteDirection) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> RouteDirection {
    return RouteDirection(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}
