//
//  LocoNetFastClockScaleFactor.swift
//  MyTrains
//
//  Created by Paul Willmott on 04/12/2022.
//

import Foundation
import AppKit

public enum LocoNetFastClockScaleFactor : Int {
  
  case off = 0
  case scale1 = 1
  case scale2 = 2
  case scale3 = 3
  case scale4 = 4
  case scale5 = 5
  case scale6 = 6
  case scale7 = 7
  case scale8 = 8
  case scale9 = 9
  case scale10 = 10
  case scale11 = 11
  case scale12 = 12
  case scale13 = 13
  case scale14 = 14
  case scale15 = 15
  case scale16 = 16


  public var title : String {
    get {
      return LocoNetFastClockScaleFactor.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Off",
    "1:1",
    "1:2",
    "1:3",
    "1:4",
    "1:5",
    "1:6",
    "1:7",
    "1:8",
    "1:9",
    "1:10",
    "1:11",
    "1:12",
    "1:13",
    "1:14",
    "1:15",
    "1:16",
  ]
  
  public static let defaultValue : LocoNetFastClockScaleFactor = .off
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:LocoNetFastClockScaleFactor) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox:NSComboBox) -> LocoNetFastClockScaleFactor {
    return LocoNetFastClockScaleFactor(rawValue: comboBox.indexOfSelectedItem) ?? .defaultValue
  }
  
}
