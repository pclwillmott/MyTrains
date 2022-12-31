//
//  TC64OutputPolarityPrimary.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/12/2022.
//

import Foundation
import AppKit

public enum TC64OutputPolarityPrimary : Int {
  
  case respondNormal = 0
  case respondInverted = 1

  public var title : String {
    get {
      return TC64OutputPolarityPrimary.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Respond Normal",
    "Respond Inverted",
  ]
  
  public static let defaultValue : TC64OutputPolarityPrimary = .respondNormal

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: TC64OutputPolarityPrimary) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> TC64OutputPolarityPrimary {
    return TC64OutputPolarityPrimary(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}

