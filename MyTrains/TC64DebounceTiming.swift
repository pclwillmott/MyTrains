//
//  TC64DebounceTiming.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/12/2022.
//

import Foundation
import AppKit

public enum TC64DebounceTiming : Int {
  
  case tdefault = 0x00
  case t100ms   = 0x01
  case t200ms   = 0x02
  case t350ms   = 0x03
  case t500ms   = 0x04
  case t650ms   = 0x05
  case t800ms   = 0x06
  case t1000ms  = 0x07
  case t1250ms  = 0x08
  case t1500ms  = 0x09
  case t2000ms  = 0x0a
  case t3000ms  = 0x0b
  case t4000ms  = 0x0c
  case t5000ms  = 0x0d
  case t6000ms  = 0x0e
  case t8000ms  = 0x0f

  public var title : String {
    get {
      return TC64DebounceTiming.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Default",
    "100ms",
    "200ms",
    "350ms",
    "500ms",
    "650ms",
    "800ms",
    "1000ms",
    "1250ms",
    "1500ms",
    "2s",
    "3s",
    "4s",
    "5s",
    "6s",
    "8s",
  ]
  
  public static let defaultValue : TC64DebounceTiming = .tdefault

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: TC64DebounceTiming) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> TC64DebounceTiming {
    return TC64DebounceTiming(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}

