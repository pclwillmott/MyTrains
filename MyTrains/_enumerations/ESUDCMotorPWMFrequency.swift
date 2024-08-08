//
//  ESUDCMotorPWMFrequency.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/08/2024.
//

import Foundation
import AppKit

public enum ESUDCMotorPWMFrequency : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case kHz20 = 0b00000000
  case kHz40 = 0b00000010

  // MARK: Constructors
  
  init?(title:String) {
    for temp in ESUDCMotorPWMFrequency.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    return ESUDCMotorPWMFrequency.titles[self]!
  }

  // MARK: Public Class Properties
  
  public static let titles : [ESUDCMotorPWMFrequency:String] = [
    .kHz20 : String(localized:"20kHz motor pulse frequency"),
    .kHz40 : String(localized:"40kHz motor pulse frequency"),
  ]

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in ESUDCMotorPWMFrequency.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

}
