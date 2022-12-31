//
//  TC64LongTiming.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/12/2022.
//

import Foundation
import AppKit

public enum TC64LongTiming : Int {
  
  case t10s  = 0x00
  case t15s  = 0x01
  case t20s  = 0x02
  case t30s  = 0x03
  case t40s  = 0x04
  case t50s  = 0x05
  case t60s  = 0x06
  case t90s  = 0x07
  case t120s = 0x08
  case t180s = 0x09
  case t240s = 0x0a
  case t300s = 0x0b
  case t360s = 0x0c
  case t420s = 0x0d
  case t480s = 0x0e
  case t600s = 0x0f

  public var title : String {
    get {
      return TC64LongTiming.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "10s",
    "15s",
    "20s",
    "30s",
    "40s",
    "50s",
    "60s",
    "90s",
    "120s",
    "180s",
    "240s",
    "300s",
    "360s",
    "420s",
    "480s",
    "600s",
  ]
  
  public static let defaultValue : TC64LongTiming = .t10s

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: TC64LongTiming) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> TC64LongTiming {
    return TC64LongTiming(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}

