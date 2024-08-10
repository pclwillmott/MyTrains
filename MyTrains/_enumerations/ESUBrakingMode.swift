//
//  ESUBrakingMode.swift
//  MyTrains
//
//  Created by Paul Willmott on 10/08/2024.
//

import Foundation
import AppKit

public enum ESUBrakingMode : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case driveToBrakePoint = 0b00000000
  case stopImmediately   = 0b00000001

  // MARK: Constructors
  
  init?(title:String) {
    for temp in ESUBrakingMode.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    return ESUBrakingMode.titles[self]!
  }

  // MARK: Public Class Properties
  
  public static let titles : [ESUBrakingMode:String] = [
    .driveToBrakePoint : String(localized:"Drive to breakpoint then brake"),
    .stopImmediately   : String(localized:"Brake immediately"),
  ]

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in ESUBrakingMode.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

}
