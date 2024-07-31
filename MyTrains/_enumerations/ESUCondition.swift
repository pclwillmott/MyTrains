//
//  ESUCondition.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/07/2024.
//

import Foundation
import AppKit

public enum ESUCondition : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case ignore = 0b00000000
  case on     = 0b00000001
  case off    = 0b00000010

  // MARK: Constructors
  
  init?(title:String) {
    for temp in ESUCondition.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    return ESUCondition.titles[self]!
  }

  // MARK: Public Class Properties
  
  public static let titles : [ESUCondition:String] = [
    .ignore : String(localized:"Ignore"),
    .on     : String(localized:"On"),
    .off    : String(localized:"Off"),
  ]

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in ESUCondition.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

}
