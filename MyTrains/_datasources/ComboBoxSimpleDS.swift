//
//  ComboBoxSimpleDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 25/06/2023.
//

import Foundation
import Cocoa

class ComboBoxSimpleDS : NSObject, NSComboBoxDataSource {
  
  // MARK: Constructors
  
  deinit {
    _dictionary.removeAll()
    _items.removeAll()
  }
  
  // MARK: Private Properties
  
  private var _dictionary : [UInt64:String] = [:]
  
  private var _items : [String] = []
  
  // MARK: Public Properties
  
  public var dictionary : [UInt64:String] {
    get {
      return _dictionary
    }
    set(value) {
      _dictionary = value
      _items.removeAll()
      for (_, value) in _dictionary {
        _items.append(value)
      }
      _items.sort { $0 < $1 }
    }
  }
  
  // MARK: Public Methods
  
  public func itemAt(index: Int) -> String? {
    if index < 0 || index >= _items.count {
      return nil
    }
    return _items[index]
  }
  
  public func keyForItemAt(index: Int) -> UInt64? {
    if index < 0 || index >= _items.count {
      return nil
    }
    let item = _items[index]
    for (key, value) in _dictionary {
      if value == item {
        return key
      }
    }
    return nil
  }
  
  public func indexWithKey(key: UInt64) -> Int? {
    
    if let value = _dictionary[key] {
      
      var index = 0
      for item in _items {
        if item == value {
          return index
        }
        index += 1
      }
      
    }
    
    return nil
    
  }
  
  // MARK: NSComboBoxDataSource Methods
  
  func numberOfItems(in comboBox: NSComboBox) -> Int {
    return _items.count
  }

  func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
    if index < 0 || index >= _items.count {
      return nil
    }
    return _items[index]
  }

  func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
    var index = 0
    for item in _items {
      if item == string {
        return index
      }
      index += 1
    }
    return -1
  }

  func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
    if string.count > 1 {
      for item in _items {
        if item.prefix(string.count) == string {
          return item
        }
      }
    }
    return nil
  }

}
