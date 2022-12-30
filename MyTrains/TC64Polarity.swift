//
//  TC64Polarity.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/12/2022.
//

import Foundation
import AppKit

public enum TC64Polarity : Int {
  
  case sendNormal = 0
  case sendInverted = 1
  case respondNormal = 2
  case respondInverted = 3

  public var title : String {
    get {
      return TC64Polarity.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Send Normal",
    "Send Inverted",
    "Respond Normal",
    "Respond Inverted",
  ]
  
  public static let defaultValue : TC64Polarity = .sendNormal

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: TC64Polarity) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> TC64Polarity {
    return TC64Polarity(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}

