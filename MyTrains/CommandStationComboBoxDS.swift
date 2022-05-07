//
//  CommandStationComboBoxDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2022.
//

import Foundation
import Cocoa

class CommmandStationComboBoxDS : NSObject, NSComboBoxDataSource {
  
  override init() {
    super.init()
  }
  
  deinit {
    _items.removeAll()
  }
  
  // Private Properties
  
  private var _dictionary : [Int:CommandStation] = [:]
  private var _items : [CommandStation] = []
  
  // Public Properties
  
  public var dictionary : [Int:CommandStation] {
    get {
      return _dictionary
    }
    set(value) {
      _dictionary = value
      _items.removeAll()
      for dictEntry in _dictionary {
        _items.append(dictEntry.value)
      }
 //     _items.sort {
   //     $0.commandStationName < $1.commandStationName
  //    }
    }
  }
  
  // Public Methods
  
  func commandStationAt(index: Int) -> CommandStation? {
    if index < 0 || index >= _items.count {
      return nil
    }
    return _items[index]
  }
  
  func indexWithKey(key: Int) -> Int? {
    var index : Int = 0
    while index < _items.count {
      let item = _items[index]
  //    if item.commandStationId == key {
    //    return index
      //}
      index += 1
    }
    return nil
  }
  
  // NSComboBoxDataSource Methods
  
  func numberOfItems(in comboBox: NSComboBox) -> Int {
    return _items.count
  }

  func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
    if index < 0 || index >= _items.count {
      return nil
    }
//    return _items[index].commandStationName
    return nil
  }

  func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
    var index = 0
    for item in _items {
//      if item.commandStationName == string {
  //      return index
    //  }
      index += 1
    }
    return -1
  }

  func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
    if string.count > 1 {
      for item in _items {
   //     if item.commandStationName.prefix(string.count) == string {
     //     return item.commandStationName
       // }
      }
    }
    return nil
  }

}
