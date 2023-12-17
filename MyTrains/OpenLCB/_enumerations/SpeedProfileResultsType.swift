//
//  SpeedProfileResultsType.swift
//  MyTrains
//
//  Created by Paul Willmott on 03/08/2022.
//

import Foundation
import AppKit

public enum SpeedProfileResultsType : Int {
  
  case actual = 0
  case bestFit = 1

  public var title : String {
    get {
      return SpeedProfileResultsType.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Actual Values",
    "Best Fit Values"
  ]
  
  public static let defaultValue : SpeedProfileResultsType = .actual
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: .defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:SpeedProfileResultsType) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> SpeedProfileResultsType {
    return SpeedProfileResultsType(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}
