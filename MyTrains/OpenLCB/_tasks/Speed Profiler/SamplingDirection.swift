//
//  SamplingDirection.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2024.
//

import Foundation
import AppKit

public enum SamplingDirection : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case bothDirections
  case forward
  case reverse
  
  // MARK: Constructors
  
  init?(title:String) {
    for temp in SamplingDirection.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [SamplingDirection:String] = [
      .bothDirections : String(localized: "Forward & Reverse"),
      .forward        : String(localized: "Forward Only"),
      .reverse        : String(localized: "Reverese Only"),
    ]
    
    return titles[self]!
    
  }
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in SamplingDirection.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }
  
  public static func select(comboBox:NSComboBox, item:SamplingDirection) {
    comboBox.selectItem(withObjectValue: item.title)
  }
  
  public static func selected(comboBox:NSComboBox) -> SamplingDirection? {
    guard comboBox.indexOfSelectedItem != -1 else {
      return nil
    }
    return SamplingDirection(rawValue: UInt8(exactly: comboBox.indexOfSelectedItem)!)
  }

}
