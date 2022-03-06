//
//  ProgrammerComboBoxDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/03/2022.
//

import Foundation
import Cocoa

class ProgrammerComboBoxDS : NSObject, NSComboBoxDataSource {
  
  override init() {
    super.init()
  }
  
  // MARK: Public Properties
  
  public var items : [Programmer] = []
  
  // MARK: Public Methods
  
  func programmerAt(index: Int) -> Programmer? {
    if index < 0 || index >= items.count {
      return nil
    }
    return items[index]
  }
  
  // MARK: NSComboBoxDataSource Methods
  
  func numberOfItems(in comboBox: NSComboBox) -> Int {
    return items.count
  }

  func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
    if index < 0 || index >= items.count {
      return nil
    }
    return items[index].name
  }

  func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
    var index = 0
    for item in items {
      if item.name == string {
        return index
      }
      index += 1
    }
    return -1
  }

  func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
    if string.count > 1 {
      for item in items {
        if item.name.prefix(string.count) == string {
          return item.name
        }
      }
    }
    return nil
  }

}
