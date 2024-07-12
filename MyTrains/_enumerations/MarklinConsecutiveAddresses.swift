//
//  MarklinConsecutiveAddresses.swift
//  MyTrains
//
//  Created by Paul Willmott on 12/07/2024.
//

import Foundation
import AppKit

public enum MarklinConsecutiveAddresses : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case noAdditionalAddresses = 0b00000000
  case use2Addresses         = 0b00001000
  case use3Addresses         = 0b10000000
  case use4Addresses         = 0b10001000

  // MARK: Constructors
  
  init?(title:String) {
    for temp in MarklinConsecutiveAddresses.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [MarklinConsecutiveAddresses:String] = [
      .noAdditionalAddresses : String(localized:"No Additional Addresses"),
      .use2Addresses : String(localized:"Second Address for Motorola and Selectrix"),
      .use3Addresses : String(localized:"Use 3 Addresses (Motorola only)"),
      .use4Addresses : String(localized:"Use 4 Addresses (Motorola only)"),
    ]
    
    return titles[self]!
    
  }
  
  // MARK: Public Class Properties
  
  public static let mask : UInt8 = 0b10001000
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in MarklinConsecutiveAddresses.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

  public static func select(comboBox:NSComboBox, value:MarklinConsecutiveAddresses) {
    comboBox.selectItem(withObjectValue: value.title)
  }
  
}
