//
//  TrackCode.swift
//  MyTrains
//
//  Created by Paul Willmott on 25/06/2022.
//

import Foundation
import AppKit

public enum TrackCode : Int {

  case code55 = 0
  case code60 = 1
  case code70 = 2
  case code75 = 3
  case code80 = 4
  case code83 = 5
  case code100 = 6
  case code124 = 7
  case code143 = 8
  case code200 = 9
  case code250 = 10

  public var title : String {
    get {
      return TrackCode.titles[self.rawValue]
    }
  }
  
  private static let titles : [String] = [
    "Code 55",
    "Code 60",
    "Code 70",
    "Code 75",
    "Code 80",
    "Code 83",
    "Code 100",
    "Code 124",
    "Code 143",
    "Code 200",
    "Code 250",
  ]
  
  public static var defaultValue : TrackCode = .code100
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:TrackCode) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selection(comboBox:NSComboBox) -> TrackCode {
    return TrackCode(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}

