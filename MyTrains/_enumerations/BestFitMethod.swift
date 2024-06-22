//
//  BestFitMethod.swift
//  MyTrains
//
//  Created by Paul Willmott on 03/08/2022.
//

import Foundation
import AppKit

public enum BestFitMethod : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case straightLine         = 0
  case centralMovingAverage = 1

  // MARK: Constructors
  
  init?(title:String) {
    for temp in BestFitMethod.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [BestFitMethod:String] = [
      .straightLine: String(localized: "Straight Line", comment: "Used by combobox to select curve fitting method)"),
      .centralMovingAverage: String(localized: "Moving Average", comment: "Used by combobox to select curve fitting method)"),
    ]
    
    return titles[self]!
    
  }
  
  public static let defaultValue : BestFitMethod = .straightLine
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in BestFitMethod.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
    select(comboBox: comboBox, value: .defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:BestFitMethod) {
    comboBox.selectItem(at: Int(value.rawValue))
  }
  
  public static func selected(comboBox: NSComboBox) -> BestFitMethod {
    return BestFitMethod(rawValue: UInt8(comboBox.indexOfSelectedItem)) ?? defaultValue
  }
  
}
