//
//  ESUConditionDirection.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/07/2024.
//

import Foundation
import AppKit

public enum ESUConditionDirection : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case ignore  = 0b00000000
  case forward = 0b00000001
  case reverse = 0b00000010

  // MARK: Constructors
  
  init?(title:String) {
    for temp in ESUConditionDirection.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    return ESUConditionDirection.titles[self]!
  }

  // MARK: Public Class Properties
  
  public static let titles : [ESUConditionDirection:String] = [
    .ignore  : String(localized:"Ignore"),
    .forward : String(localized:"Forward"),
    .reverse : String(localized:"Reverse"),
  ]

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in ESUConditionDirection.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

}
