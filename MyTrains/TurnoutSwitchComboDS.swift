//
//  TurnoutSwitchComboDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/11/2022.
//

import Foundation
import Cocoa

class TurnoutSwitchComboDS : NSObject, NSComboBoxDataSource {
  
  // MARK: Constructors
  
  override init() {
    super.init()
  }
  
  deinit {
    items.removeAll()
  }
  
  // MARK: Private Properties
  
  // MARK: Public Properties
  
  public var items : [TurnoutSwitch] = []
  
  // MARK: Public Methods
  
  public func objectAt(index: Int) -> TurnoutSwitch? {
    if index < 0 || index >= items.count {
      return nil
    }
    return items[index]
  }
  
  public func indexWithKey(deviceId:Int, channelNumber: Int) -> Int? {
    var index : Int = 0
    while index < items.count {
      let item = items[index]
      if item.locoNetDeviceId == deviceId && item.channelNumber == channelNumber {
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
    return items[index].comboSwitchName
  }

  func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
    var index = 0
    for item in items {
      if item.comboSwitchName == string {
        return index
      }
      index += 1
    }
    return -1
  }

  func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
    if string.count > 1 {
      for item in items {
        if item.comboSwitchName.prefix(string.count) == string {
          return item.comboSwitchName
        }
      }
    }
    return nil
  }

}
