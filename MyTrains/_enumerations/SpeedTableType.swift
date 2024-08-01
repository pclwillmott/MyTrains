//
//  SpeedTableType.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/08/2024.
//

import Foundation
import AppKit

public enum SpeedTableType : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case cv67to94        = 0b00010000
  case vStartvMidvHigh = 0b00000000

  // MARK: Constructors
  
  init?(title:String) {
    for temp in SpeedTableType.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }
  
  // MARK: Public Properties
  
  public var title : String {
    return SpeedTableType.titles[self]!
  }

  // MARK: Private Class Properties
  
  private static let titles : [SpeedTableType:String] = [
    .cv67to94        : String(localized:"Use speed curve"),
    .vStartvMidvHigh : String(localized:"Use three values (VStart, VMid, VHigh)"),
  ]

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in SpeedTableType.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

}
