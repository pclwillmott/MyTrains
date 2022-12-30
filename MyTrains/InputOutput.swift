//
//  InputOutput.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/12/2022.
//

import Foundation
import AppKit

public enum InputOutput : Int {
  
  case output = 0
  case input = 1

  public var title : String {
    get {
      return InputOutput.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Output",
    "Input",
  ]
  
  public static let defaultValue : InputOutput = .input

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: InputOutput) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> InputOutput {
    return InputOutput(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
}

