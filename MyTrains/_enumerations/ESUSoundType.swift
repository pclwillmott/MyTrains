//
//  ESUSoundType.swift
//  MyTrains
//
//  Created by Paul Willmott on 10/08/2024.
//

import Foundation
import AppKit

public enum ESUSoundType : Int, CaseIterable {
  
  // MARK: Enumeration
  
  case dieselHydraulical                    = 0
  case dieselMechanical                     = 1
  case electricOrDieselElectric             = 2
  case steamLocomotiveWithoutExternalSensor = 3
  case steamLocomotiveWithExternalSensor    = 4
  
  // MARK: Constructors
  
  init?(title:String) {
    for temp in ESUSoundType.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  init(cv57:UInt8, cv58:UInt8) {
    if cv57 == 0 && cv58 == 0 {
      self = .dieselHydraulical
    }
    else if cv57 == 1 && cv58 == 0 {
      self = .dieselMechanical
    }
    else if cv57 != 0 && cv58 != 0 {
      self = .steamLocomotiveWithoutExternalSensor
    }
    else { // There are two cases that match this so pick the first
      self = .electricOrDieselElectric
    }
  }

  // MARK: Public Properties
  
  public var title : String {
    return ESUSoundType.titles[self]!
  }

  // MARK: Public Class Properties
  
  public static let titles : [ESUSoundType:String] = [
    .dieselHydraulical                    : String(localized:"Diesel Hydraulical"),
    .dieselMechanical                     : String(localized:"Diesel Mechanical"),
    .electricOrDieselElectric             : String(localized:"Electric or Diesel Electric"),
    .steamLocomotiveWithoutExternalSensor : String(localized:"Steam Locomotive without External Sensor"),
    .steamLocomotiveWithExternalSensor    : String(localized:"Steam Locomotive with External Sensor"),
  ]

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in ESUSoundType.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

}
