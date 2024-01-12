//
//  SpeedSteps.swift
//  MyTrains
//
//  Created by Paul Willmott on 14/08/2022.
//

import Foundation
import Cocoa
import AppKit

public enum SpeedSteps : UInt8 {
  
  case dcc28      = 0b000 // 0
  case trinary    = 0b001 // 1
  case dcc14      = 0b010 // 2
  case dcc128     = 0b011 // 3
  case dcc28FX    = 0b100 // 4
  case trinaryFX  = 0b101 // 5
  case dcc14FX    = 0b110 // 6
  case dcc128FX   = 0b111 // 7

  // MARK: Public Properties
  
  public static var protectMask : UInt8 {
    return 0b11111000
  }
  
  public var setMask : UInt8 {
    return self.rawValue
  }
  
  public func opsw(locoNetDeviceId:LocoNetDeviceId) -> Int {
    
    let fx = self.rawValue & 0b100
    
    var dt = self.rawValue & 0b011
    
    if !SpeedSteps.newStyleCommandStations.contains(locoNetDeviceId) {
      dt = (~dt) & 0b011
    }
    
    return Int(fx | dt)
    
  }

  public var title : String {
    return SpeedSteps.titles[Int(self.rawValue)]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "DCC 28", comment: "Used for LocoNet train control protocol selection"),
    String(localized: "Motorola Trinary", comment: "Used for LocoNet train control protocol selection"),
    String(localized: "DCC 14", comment: "Used for LocoNet train control protocol selection"),
    String(localized: "DCC 128", comment: "Used for LocoNet train control protocol selection"),
    String(localized: "DCC 28 FX", comment: "Used for LocoNet train control protocol selection"),
    String(localized: "Reserved 1", comment: "Used for LocoNet train control protocol selection"),
    String(localized: "Reserved 2", comment: "Used for LocoNet train control protocol selection"),
    String(localized: "DCC 128 FX", comment: "Used for LocoNet train control protocol selection"),
  ]
  
  // MARK: Public Class Properties
  
  public static let defaultValue : SpeedSteps = .dcc128
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: .defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:SpeedSteps) {
    comboBox.selectItem(at: Int(value.rawValue))
  }

  public static func select(comboBox:NSComboBox, opsw:Int, locoNetDeviceId:LocoNetDeviceId) {
    
    let value = SpeedSteps.speedStepFromOpSw(opsw: opsw, locoNetDeviceId: locoNetDeviceId)
    
    select(comboBox: comboBox, value: value)
    
  }

  public static func selected(comboBox: NSComboBox) -> SpeedSteps {
    return SpeedSteps(rawValue: UInt8(comboBox.indexOfSelectedItem)) ?? defaultValue
  }
  
  public static var newStyleCommandStations : Set<LocoNetDeviceId> {
    get {
      return [.DCS210, .DCS240, .DCS210PLUS, .DCS240PLUS, .DCS52]
    }
  }
  
  public static func speedStepFromOpSw(opsw:Int, locoNetDeviceId: LocoNetDeviceId) -> SpeedSteps {
    
    let fx = UInt8(opsw) & 0b100
    
    var dt = UInt8(opsw) & 0b011
    
    if !SpeedSteps.newStyleCommandStations.contains(locoNetDeviceId) {
      dt = (~dt) & 0b011
    }

    return SpeedSteps(rawValue: fx | dt) ?? .defaultValue
    
  }

}
