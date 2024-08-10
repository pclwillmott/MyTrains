//
//  ESUDCMotorPWMFrequencyLok3.swift
//  MyTrains
//
//  Created by Paul Willmott on 10/08/2024.
//

import Foundation
import AppKit

public enum ESUDCMotorPWMFrequencyLok3 : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case kHz15 = 0b00000000
  case kHz31 = 0b00000010

  // MARK: Constructors
  
  init?(title:String) {
    for temp in ESUDCMotorPWMFrequencyLok3.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    return ESUDCMotorPWMFrequencyLok3.titles[self]!
  }

  // MARK: Public Class Properties
  
  public static let titles : [ESUDCMotorPWMFrequencyLok3:String] = [
    .kHz15 : String(localized:"15kHz motor pulse frequency"),
    .kHz31 : String(localized:"31kHz motor pulse frequency"),
  ]

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in ESUDCMotorPWMFrequencyLok3.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

}
