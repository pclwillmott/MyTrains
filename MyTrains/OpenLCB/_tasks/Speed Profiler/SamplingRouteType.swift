//
//  SamplingRouteType.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2024.
//

import Foundation
import AppKit

public enum SamplingRouteType : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case loop     = 0
  case straight = 1
  
  // MARK: Constructors
  
  init?(title:String) {
    for temp in SamplingRouteType.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [SamplingRouteType:String] = [
      .loop : String(localized: "Loop"),
      .straight : String(localized: "Straight"),
    ]
    
    return titles[self]!
    
  }

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in SamplingRouteType.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }
  
  public static func select(comboBox:NSComboBox, item:SamplingRouteType) {
    comboBox.selectItem(withObjectValue: item.title)
  }
  
  public static func selected(comboBox:NSComboBox) -> SamplingRouteType? {
    guard comboBox.indexOfSelectedItem != -1 else {
      return nil
    }
    return SamplingRouteType(rawValue: UInt8(exactly: comboBox.indexOfSelectedItem)!)
  }

}
