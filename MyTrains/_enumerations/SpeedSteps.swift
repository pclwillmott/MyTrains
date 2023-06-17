//
//  SpeedSteps.swift
//  MyTrains
//
//  Created by Paul Willmott on 14/08/2022.
//

import Foundation
import Cocoa

public enum SpeedSteps : Int {
  
  case dcc28      = 0b000
  case trinary    = 0b001
  case dcc14      = 0b010
  case dcc128     = 0b011
  case dcc28FX    = 0b100
  case trinaryFX  = 0b101
  case dcc14FX    = 0b110
  case dcc128FX   = 0b111
  
  public func protectMask() -> UInt8 {
    return 0b11111000
  }
  
  public func setMask() -> UInt8 {
    return UInt8(self.rawValue)
  }
  
  public func opsw(locoNetProductId:DeviceId) -> Int {
    
    let fx = self.rawValue & 0b100
    
    var dt = self.rawValue & 0b011
    
    if !SpeedSteps.newStyleCommandStations.contains(locoNetProductId) {
      dt = (~dt) & 0b011
    }
    
    return fx | dt
    
  }

  public var title : String {
    get {
      return SpeedSteps.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "DCC 28",
    "Motorola Trinary",
    "DCC 14",
    "DCC 128",
    "DCC 28 FX",
    "Reserved 1",
    "Reserved 2",
    "DCC 128 FX",
  ]
  
  public static let defaultValue : SpeedSteps = .dcc128
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: .defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:SpeedSteps) {
    comboBox.selectItem(at: value.rawValue)
  }

  public static func select(comboBox:NSComboBox, opsw:Int, locoNetProductId:DeviceId) {
    
    let value = SpeedSteps.speedStepFromOpSw(opsw: opsw, locoNetProductId: locoNetProductId)
    
    select(comboBox: comboBox, value: value)
    
  }

  public static func selected(comboBox: NSComboBox) -> SpeedSteps {
    return SpeedSteps(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
  public static var newStyleCommandStations : Set<DeviceId> {
    get {
      return [.DCS210, .DCS240, .DCS210PLUS, .DCS240PLUS, .DCS52]
    }
  }
  
  public static func speedStepFromOpSw(opsw:Int, locoNetProductId: DeviceId) -> SpeedSteps {
    
    let fx = opsw & 0b100
    
    var dt = opsw & 0b011
    
    if !SpeedSteps.newStyleCommandStations.contains(locoNetProductId) {
      dt = (~dt) & 0b011
    }

    return SpeedSteps(rawValue: fx | dt) ?? .defaultValue
    
  }

}
