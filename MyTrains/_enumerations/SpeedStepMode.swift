//
//  UseSpeedSteps.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/07/2024.
//

import Foundation
import AppKit

public enum SpeedStepMode : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case use28Or128Steps = 0b00000010
  case use14Steps      = 0b00000000

  // MARK: Constructors
  
  init?(title:String) {
    for temp in SpeedStepMode.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [SpeedStepMode:String] = [
      .use14Steps      : String(localized:"Use 14 Speed Steps"),
      .use28Or128Steps : String(localized:"Use 28 or 128 Speed Steps"),
    ]
    
    return titles[self]!
    
  }
  
  // MARK: Public Class Properties
  
  public static let mask : UInt8 = 0b00000010
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in SpeedStepMode.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

}
