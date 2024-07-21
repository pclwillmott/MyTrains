//
//  ExternalSmokeUnitType.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/07/2024.
//

import Foundation
import AppKit

public enum ExternalSmokeUnitType : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case km1_BR41_BR44 = 0
  case km1_Other     = 1
  case kiss          = 2
  case esuSmokeUnit  = 3

  // MARK: Constructors
  
  init?(title:String) {
    for temp in ExternalSmokeUnitType.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [ExternalSmokeUnitType:String] = [
      .km1_BR41_BR44 : String(localized:"KM1 BR 41 / BR 44"),
      .km1_Other     : String(localized:"KM1 (other)"),
      .kiss          : String(localized:"KISS"),
      .esuSmokeUnit  : String(localized:"ESU Smoke Unit"),
    ]
    
    return titles[self]!
    
  }
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in ExternalSmokeUnitType.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

}
