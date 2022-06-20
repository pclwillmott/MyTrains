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
  case ho         = 1
  case n          = 2
  case o          = 3
  case o14        = 4
  case oo         = 5
  case ooo        = 6
  case p4         = 7
  case s          = 8
  case scaleSeven = 9
  case tt         = 10
  case tt3        = 11

  public var title : String {
    get {
      return TrackGauge.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "EM",
    "HO",
    "N",
    "O",
    "O14",
    "00",
    "000",
    "P4",
    "S",
    "Scale 7",
    "TT",
    "TT3",
  ]
  
  public static let defaultValue : TrackGauge = .oo

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

