//
//  TC64InputPolarityPrimary.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/12/2022.
//

import Foundation
import AppKit

public enum TC64InputPolarityPrimary : Int {
  
  case sendNormal = 0
  case sendInverted = 1

  public var title : String {
    get {
      return TC64InputPolarityPrimary.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Send Normal",
    "Send Inverted",
  ]
  
  public static let defaultValue : TC64InputPolarityPrimary = .sendNormal

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: TC64InputPolarityPrimary) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> TC64InputPolarityPrimary {
    return TC64InputPolarityPrimary(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}

