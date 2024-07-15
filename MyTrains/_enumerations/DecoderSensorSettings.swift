//
//  DecoderSensorSettings.swift
//  MyTrains
//
//  Created by Paul Willmott on 15/07/2024.
//

import Foundation
import AppKit

public enum DecoderSensorSettings : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case useDigitalWheelSensor = 0b00010000
  case useOutputAUX10        = 0b00000000

  // MARK: Constructors
  
  init?(title:String) {
    for temp in DecoderSensorSettings.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [DecoderSensorSettings:String] = [
      .useDigitalWheelSensor : String(localized:"Use digital wheel sensor"),
      .useOutputAUX10        : String(localized:"Use output AUX10"),
    ]
    
    return titles[self]!
    
  }
  
  // MARK: Public Class Properties
  
  public static let mask : UInt8 = 0b00010000
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in DecoderSensorSettings.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

}
