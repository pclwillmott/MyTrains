//
//  SpeedConstraintType.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/02/2024.
//

import Foundation
import AppKit

public enum SpeedConstraintType : UInt16, CaseIterable {
  
  case noConstraintSelected     = 0
  case maximumSpeed             = 1
  case maximumShuntSpeed        = 2
  case maximumStopExpectedSpeed = 3
  case maximumRestrictedSpeed   = 4

  // MARK: Public Properties
  
  public var title : String {
    return SpeedConstraintType.titles[self]!
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [SpeedConstraintType:String] = [
    .noConstraintSelected:String(localized: "No constraint selected"),
    .maximumSpeed:String(localized: "Maximum speed at any time"),
    .maximumShuntSpeed:String(localized: "Maximum speed when shunting"),
    .maximumStopExpectedSpeed:String(localized: "Maximum speed when stop expected"),
    .maximumRestrictedSpeed:String(localized: "Maximum speed when restrictions apply"),
  ]
  
  private static var map : String {
    
    var items : [SpeedConstraintType] = []
    
    for (item, _) in titles {
      items.append(item)
    }

    items.sort {$0.title < $1.title}
    
    var map = "<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"
    
    return map
    
  }

  // MARK: Public Class Methods
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: CDI.SPEED_CONSTRAINT_TYPE, with: map)
  }

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    for item in SpeedConstraintType.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }
  
  public static func select(comboBox: NSComboBox, constraintType:SpeedConstraintType) {
    comboBox.selectItem(at: Int(constraintType.rawValue))
  }
  
  public static func selected(comboBox: NSComboBox) -> SpeedConstraintType? {
    return SpeedConstraintType(rawValue: UInt16(comboBox.indexOfSelectedItem))
  }
  

}
