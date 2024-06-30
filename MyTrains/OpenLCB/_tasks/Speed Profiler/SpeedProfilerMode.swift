//
//  SpeedProfilerMode.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/06/2024.
//

import Foundation
import AppKit

public enum SpeedProfilerMode : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case sampleAllSpeeds   = 0
  case sampleSingleSpeed = 1
  
  // MARK: Constructors
  
  init?(title:String) {
    for temp in SpeedProfilerMode.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }
  
  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [SpeedProfilerMode:String] = [
      .sampleAllSpeeds   : String(localized: "Sample All Speeds"),
      .sampleSingleSpeed : String(localized: "Sample Single Speed"),
    ]
    
    return titles[self]!
    
  }
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in SpeedProfilerMode.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }
  
  public static func select(comboBox:NSComboBox, item:SpeedProfilerMode) {
    comboBox.selectItem(withObjectValue: item.title)
  }
  
  public static func selected(comboBox:NSComboBox) -> SpeedProfilerMode? {
    guard comboBox.indexOfSelectedItem != -1 else {
      return nil
    }
    return SpeedProfilerMode(rawValue: UInt8(exactly: comboBox.indexOfSelectedItem)!)
  }
  
}
