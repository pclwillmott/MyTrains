//
//  IOChannelType.swift
//  MyTrains
//
//  Created by Paul Willmott on 12/01/2023.
//

import Foundation
import AppKit

public enum IOChannelType : Int {
  
  case input = 0
  case output = 1
  case ioTC64MkII = 2

  public var title : String {
    get {
      return IOChannelType.titles[self.rawValue]
    }
  }
  
  private static let titles : [String] = [
    "Input",
    "Output",
    "Input/Output",
  ]
  
  public static var defaultValue : IOChannelType {
    get {
      return .input
    }
  }
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:IOChannelType) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox:NSComboBox) -> IOChannelType {
    return IOChannelType(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }

}

