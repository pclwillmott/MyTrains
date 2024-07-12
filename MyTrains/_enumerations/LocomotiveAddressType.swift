//
//  LocomotiveAddressType.swift
//  MyTrains
//
//  Created by Paul Willmott on 12/07/2024.
//

import Foundation
import AppKit

public enum LocomotiveAddressType : Int, CaseIterable {
  
  // MARK: Enumeration
  
  case primary = 0
  case extended = 1
  
  // MARK: Constructors
  
  init?(title:String) {
    for temp in LocomotiveAddressType.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [LocomotiveAddressType:String] = [
      .primary : String(localized:"Use primary (short) address"),
      .extended : String(localized:"Use extended (long) address"),
    ]
    
    return titles[self]!
    
  }
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in LocomotiveAddressType.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

  public static func select(comboBox:NSComboBox, value:LocomotiveAddressType) {
    comboBox.selectItem(withObjectValue: value.title)
  }
  
}
