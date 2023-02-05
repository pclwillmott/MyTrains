//
//  SensorComboDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/11/2022.
//

import Foundation
import AppKit

class SensorComboDS : NSObject, NSComboBoxDataSource {
  
  // MARK: Constructors
  
  override init() {
    super.init()
  }
  
  deinit {
    items.removeAll()
  }
  
  // MARK: Private Properties
  
  // MARK: Public Properties
  
  public var items : [IOFunction] = []
  
  // MARK: Public Methods
  
  public func objectAt(index: Int) -> IOFunction? {
    if index < 0 || index >= items.count {
      return nil
    }
    return items[index]
  }
  
  public func indexWithKey(ioFunctionId: Int) -> Int? {
    var index : Int = 0
    while index < items.count {
      let item = items[index]
      if item.primaryKey == ioFunctionId {
        return index
      }
      index += 1
    }
    return nil
  }
  
  // MARK: NSComboBoxDataSource Methods
  
  func numberOfItems(in comboBox: NSComboBox) -> Int {
    return items.count
  }

  func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
    if index < 0 || index >= items.count {
      return nil
    }
    return items[index].comboSensorName()
  }

  func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
    var index = 0
    for item in items {
      if item.comboSensorName() == string {
        return index
      }
      index += 1
    }
    return -1
  }

  func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
    if string.count > 1 {
      for item in items {
        if item.comboSensorName().prefix(string.count) == string {
          return item.comboSensorName()
        }
      }
    }
    return nil
  }

}
