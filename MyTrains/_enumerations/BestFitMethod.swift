//
//  BestFitMethod.swift
//  MyTrains
//
//  Created by Paul Willmott on 03/08/2022.
//

import Foundation
import AppKit

public enum BestFitMethod : Int {
  
  case straightLine = 0
  case centralMovingAverage

  public var title : String {
    get {
      return BestFitMethod.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    String(localized: "Straight Line", comment: "Used by combobox to select curve fitting method)"),
    String(localized: "Moving Average", comment: "Used by combobox to select curve fitting method)"),
  ]
  
  public static let defaultValue : BestFitMethod = .straightLine
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: .defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:BestFitMethod) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> BestFitMethod {
    return BestFitMethod(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}
