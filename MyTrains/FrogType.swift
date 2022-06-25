//
//  FrogType.swift
//  MyTrains
//
//  Created by Paul Willmott on 25/06/2022.
//

import Foundation
import AppKit

public enum FrogType : Int {
  
  case electroFrog = 0
  case insulFrog = 1
  case uniFrog = 2
  
  public var title : String {
    get {
      return FrogType.titles[self.rawValue]
    }
  }
  
  private static let titles : [String] = [
    "ElectroFrog",
    "InsulFrog",
    "UniFrog",
  ]
  
  public static var defaultValue : FrogType {
    get {
      return .insulFrog
    }
  }
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:FrogType) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox:NSComboBox) -> FrogType {
    return FrogType(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}
