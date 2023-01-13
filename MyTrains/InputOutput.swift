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
  
  private static let sequence : [InputOutput] = [output, input]
  
  public static let defaultValue : InputOutput = .input

  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }

  public static func populate(comboBox: NSComboBox, fromSet:Set<InputOutput>) {
    comboBox.removeAllItems()
    for item in fromSet {
      comboBox.addItem(withObjectValue: item.title)
    }
    comboBox.selectItem(at: 0)
  }

  public static func select(comboBox: NSComboBox, value: InputOutput) {
    var index = 0
    while index < comboBox.numberOfItems {
      if (comboBox.itemObjectValue(at: index) as! String) == value.title {
        comboBox.selectItem(at: index)
        return
      }
      index += 1
    }
  }
  
  public static func selected(comboBox: NSComboBox) -> InputOutput {
    for value in sequence {
      if comboBox.stringValue == value.title {
        return value
      }
    }
    return .input
  }
  
}

