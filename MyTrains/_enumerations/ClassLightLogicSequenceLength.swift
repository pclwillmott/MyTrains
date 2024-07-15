//
//  ClassLightLogicSequenceLength.swift
//  MyTrains
//
//  Created by Paul Willmott on 15/07/2024.
//

import Foundation
import AppKit

public enum ClassLightLogicSequenceLength : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case twoDifferentColorClassLights   = 0b00000001
  case threeDifferentColorClassLights = 0b00000010

  // MARK: Constructors
  
  init?(title:String) {
    for temp in ClassLightLogicSequenceLength.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [ClassLightLogicSequenceLength:String] = [
      .twoDifferentColorClassLights   : String(localized:"2 (Two different color class lights)"),
      .threeDifferentColorClassLights : String(localized:"3 (Three different color class lights)"),
    ]
    
    return titles[self]!
    
  }
  
  // MARK: Public Class Properties
  
  public static let mask : UInt8 = 0b00000011
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in ClassLightLogicSequenceLength.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

}
