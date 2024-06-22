//
//  TrackProtocol.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2024.
//

import Foundation
import AppKit

public enum TrackProtocol : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case dcc128     = 0
  case dcc28      = 1
  case dcc14      = 2
  case mfx_m4     = 3
  case motorolaI  = 4
  case motorolaII = 5
  case openLCB    = 6
  
  // MARK: Constructors
  
  init?(title:String) {
    for temp in TrackProtocol.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }
  
  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [TrackProtocol:String] = [
      .dcc128     : String(localized: "DCC 128 Speed Steps"),
      .dcc28      : String(localized: "DCC 28 Speed Steps"),
      .dcc14      : String(localized: "DCC 14 Speed Steps"),
      .mfx_m4     : String(localized: "MFX/M4 Track Protocol"),
      .motorolaI  : String(localized: "Marklin-Motorola I"),
      .motorolaII : String(localized: "Marklin-Motorola II"),
      .openLCB    : String(localized: "Native OpenLCB"),
    ]
    
    return titles[self]!
    
  }
  
  public var numberOfSamples : UInt16 {
    
    let samples : [TrackProtocol:UInt16] = [
      .dcc128:     127,
      .dcc28:       27,
      .dcc14:       13,
      .mfx_m4:     128,
      .motorolaI:  128,
      .motorolaII: 128,
      .openLCB:    512,
    ]
    
    return samples[self]!
    
  }
  
  public var isNumberOfSamplesFixed : Bool {
    
    let fixed : Set<TrackProtocol> = [
      .dcc128,
      .dcc28,
      .dcc14,
      .mfx_m4,
      .motorolaI,
      .motorolaII,
    ]
    
    return fixed.contains(self)
    
  }

  public var isMaximumSpeedFixed : Bool {
    
    let fixed : Set<TrackProtocol> = [
      .dcc128,
      .dcc28,
      .dcc14,
    ]
    
    return fixed.contains(self)
    
  }

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in TrackProtocol.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }
  
  public static func select(comboBox:NSComboBox, item:TrackProtocol) {
    comboBox.selectItem(withObjectValue: item.title)
  }
  
  public static func selected(comboBox:NSComboBox) -> TrackProtocol? {
    guard comboBox.indexOfSelectedItem != -1 else {
      return nil
    }
    return TrackProtocol(rawValue: UInt8(exactly: comboBox.indexOfSelectedItem)!)
  }
  
}
