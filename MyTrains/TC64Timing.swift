//
//  TC64Timing.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/12/2022.
//

import Foundation
import AppKit

public enum TC64Timing : Int {
  
  case steady_10s   = 0x00
  case t100ms_15s   = 0x01
  case t200ms_20s   = 0x02
  case t350ms_30s   = 0x03
  case t500ms_40s   = 0x04
  case t650ms_50s   = 0x05
  case t800ms_60s   = 0x06
  case t1000ms_90s  = 0x07
  case t1250ms_120s = 0x08
  case t1500ms_180s = 0x09
  case t2000ms_240s = 0x0a
  case t3000ms_300s = 0x0b
  case t4000ms_360s = 0x0c
  case t5000ms_420s = 0x0d
  case t6000ms_480s = 0x0e
  case t8000ms_600s = 0x0f

  public var title : String {
    get {
      return TC64Timing.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Steady/10s",
    "100ms/15s",
    "200ms/20s",
    "350ms/30s",
    "500ms/40s",
    "650ms/50s",
    "800ms/60s",
    "1000ms/90s",
    "1250ms/120s",
    "1500ms/180s",
    "2s/240s",
    "3s/300s",
    "4s/360s",
    "5s/420s",
    "6s/480s",
    "8s/600s",
  ]
  
  public static let defaultValue : TC64Timing = .steady_10s

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: TC64Timing) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> TC64Timing {
    return TC64Timing(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}

