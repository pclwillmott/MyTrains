//
//  SoundControlBasis.swift
//  MyTrains
//
//  Created by Paul Willmott on 17/07/2024.
//

import Foundation
import AppKit

public enum SoundControlBasis : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case accelerationAndBrakeTime = 0
  case accelerationAndBrakeTimeAndTrainLoad = 1

  // MARK: Constructors
  
  init?(title:String) {
    for temp in SoundControlBasis.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [SoundControlBasis:String] = [
      .accelerationAndBrakeTime : String(localized:"Acceleration and brake time"),
      .accelerationAndBrakeTimeAndTrainLoad : String(localized:"Acceleration, brake time, and train load"),
    ]
    
    return titles[self]!
    
  }
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in SoundControlBasis.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

}
