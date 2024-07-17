//
//  SteamChuffMode.swift
//  MyTrains
//
//  Created by Paul Willmott on 17/07/2024.
//

import Foundation
import AppKit

public enum SteamChuffMode : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case useExternalWheelSensor = 0
  case playSteamChuffsAccordingToSpeed = 1

  // MARK: Constructors
  
  init?(title:String) {
    for temp in SteamChuffMode.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [SteamChuffMode:String] = [
      .useExternalWheelSensor : String(localized:"Use external wheel sensor"),
      .playSteamChuffsAccordingToSpeed : String(localized:"Play steam chuffs according to speed"),
    ]
    
    return titles[self]!
    
  }
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in SteamChuffMode.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

}
