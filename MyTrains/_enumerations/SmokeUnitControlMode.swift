//
//  SmokeUnitControlMode.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/07/2024.
//

import Foundation
import AppKit

public enum SmokeUnitControlMode : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case heatingControl = 0
  case fanControl     = 1

  // MARK: Constructors
  
  init?(title:String) {
    for temp in SmokeUnitControlMode.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [SmokeUnitControlMode:String] = [
      .heatingControl : String(localized:"Heating control"),
      .fanControl     : String(localized:"Fan control"),
    ]
    
    return titles[self]!
    
  }
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in SmokeUnitControlMode.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

}
