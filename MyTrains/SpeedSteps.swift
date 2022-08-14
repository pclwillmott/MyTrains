//
//  SpeedSteps.swift
//  MyTrains
//
//  Created by Paul Willmott on 14/08/2022.
//

import Foundation
import Cocoa

public enum SpeedSteps : Int {
  
  case analog = 0
  case dcc14 = 1
  case dcc28 = 2
  case dcc28A = 3
  case dcc28T = 4
  case dcc128 = 5
  case dcc128A = 6
  
  public func protectMask() -> UInt8 {
    return 0b11111000
  }
  
  public func setMask() -> UInt8 {
    
    var mask : UInt8 = 0
    
    switch self {
    case .dcc28:
      mask = 0b000
    case .dcc28T:
      mask = 0b001
    case .dcc14:
      mask = 0b010
    case .dcc128:
      mask = 0b011
    case .dcc28A:
      mask = 0b100
    case .dcc128A:
      mask = 0b111
    default:
      break
    }
    
    return mask
    
  }

  public var title : String {
    get {
      return SpeedSteps.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Analog",
    "DCC 14",
    "DCC 28",
    "DCC 28A",
    "Trinary",
    "DCC 128",
    "DCC 128A",
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
  
  public static func selected(comboBox: NSComboBox) -> SpeedSteps {
    return SpeedSteps(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }

}
