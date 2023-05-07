//
//  TrackGauge.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2022.
//

import Foundation
import AppKit

public enum TrackGauge : Int {
  
  case em         = 0
  case n          = 1
  case o          = 2
  case o14        = 3
  case ooho       = 4
  case ooo        = 5
  case p4         = 6
  case s          = 7
  case scaleSeven = 8
  case tt         = 9
  case tt3        = 10

  public var title : String {
    get {
      return TrackGauge.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "EM",
    "N",
    "O",
    "O14",
    "OO/HO",
    "OOO",
    "P4",
    "S",
    "Scale 7",
    "TT",
    "TT3",
  ]
  
  public static let defaultValue : TrackGauge = .ooho

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: TrackGauge) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> TrackGauge {
    return TrackGauge(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}

