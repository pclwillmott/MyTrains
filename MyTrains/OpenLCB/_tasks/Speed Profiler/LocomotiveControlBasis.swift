//
//  LocomotiveControlBasis.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2024.
//

import Foundation
import AppKit

public enum LocomotiveControlBasis : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case defaultValues = 0
  case bestFitValues = 1
  case actualValues  = 2
  
  // MARK: Constructors
  
  init?(title:String) {
    for temp in LocomotiveControlBasis.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [LocomotiveControlBasis:String] = [
      .defaultValues : String(localized: "Default Values"),
      .actualValues  : String(localized: "Actual Values"),
      .bestFitValues : String(localized: "Best Fit Values"),
    ]
    
    return titles[self]!
    
  }

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in LocomotiveControlBasis.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }
  
  public static func select(comboBox:NSComboBox, item:LocomotiveControlBasis) {
    comboBox.selectItem(withObjectValue: item.title)
  }
  
  public static func selected(comboBox:NSComboBox) -> LocomotiveControlBasis? {
    guard comboBox.indexOfSelectedItem != -1 else {
      return nil
    }
    return LocomotiveControlBasis(rawValue: UInt8(exactly: comboBox.indexOfSelectedItem)!)
  }

}
