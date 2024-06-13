//
//  ComboBoxNodeDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/06/2024.
//

import Foundation
import AppKit

class ComboBoxNodeDS : NSObject, NSComboBoxDataSource {
  
  // MARK: Constructors
  
  #if DEBUG
  override init() {
    super.init()
    addInit()
  }
  #endif
  
  deinit {
    _dictionary.removeAll()
    _items.removeAll()
    #if DEBUG
    addDeinit()
    #endif
  }
  
  // MARK: Private Properties
  
  private var _dictionary : [UInt64:OpenLCBNodeVirtual] = [:]
  
  private var _items : [OpenLCBNodeVirtual] = []
  
  // MARK: Public Properties
  
  public var dictionary : [UInt64:OpenLCBNodeVirtual] {
    get {
      return _dictionary
    }
    set(value) {
      _dictionary = value
      _items.removeAll()
      for (_, node) in _dictionary {
        _items.append(node)
      }
      _items.sort { $0.userNodeName.sortValue < $1.userNodeName.sortValue }
    }
  }
  
  // MARK: Public Methods
  
  public func itemAt(index: Int) -> String? {
    if index < 0 || index >= _items.count {
      return nil
    }
    return _items[index].userNodeName
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
    return _items[index].userNodeName
  }

  func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
    var index = 0
    for item in _items {
      if item.userNodeName == string {
        return index
      }
      index += 1
    }
    return -1
  }

  func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
    if string.count > 1 {
      for item in _items {
        if item.userNodeName.prefix(string.count) == string {
          return item.userNodeName
        }
      }
    }
    return nil
  }

}
