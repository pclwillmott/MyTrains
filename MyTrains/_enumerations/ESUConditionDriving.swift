//
//  ESUConditionDriving.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/07/2024.
//

import Foundation
import AppKit

public enum ESUConditionDriving : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case ignore = 0b00000000
  case yes    = 0b00000001
  case no     = 0b00000010

  // MARK: Constructors
  
  init?(title:String) {
    for temp in ESUConditionDriving.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    return ESUConditionDriving.titles[self]!
  }

  // MARK: Public Class Properties
  
  public static let titles : [ESUConditionDriving:String] = [
    .ignore : String(localized:"Ignore"),
    .yes    : String(localized:"Yes"),
    .no     : String(localized:"No"),
  ]

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in ESUConditionDriving.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

}
