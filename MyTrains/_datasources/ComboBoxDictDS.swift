//
//  ComboBoxDictDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/12/2021.
//

import Foundation
import Cocoa

class ComboBoxDictDS : NSObject, NSComboBoxDataSource {
  
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
  
  private var _dictionary : [Int:Any] = [:]
  
  private var _items : [EditorObject] = []
  
  // MARK: Public Properties
  
  public var dictionary : [Int:Any] {
    get {
      return _dictionary
    }
    set(value) {
      _dictionary = value
      _items.removeAll()
      for dictEntry in _dictionary {
        if let editItem = dictEntry.value as? EditorObject {
          editItem.primaryKey = dictEntry.key
          _items.append(editItem)
        }
      }
      _items.sort {
        $0.sortString() < $1.sortString()
      }
    }
  }
  
  // MARK: Public Methods
  
  public func editorObjectAt(index: Int) -> EditorObject? {
    if index < 0 || index >= _items.count {
      return nil
    }
    return _items[index]
  }
  
  public func indexWithKey(key: Int) -> Int? {
    var index : Int = 0
    while index < _items.count {
      let item = _items[index]
      if item.primaryKey == key {
        return index
      }
      index += 1
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
    return _items[index].displayString()
  }

  func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
    var index = 0
    for item in _items {
      if item.displayString() == string {
        return index
      }
      index += 1
    }
    return -1
  }

  func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
    if string.count > 1 {
      for item in _items {
        if item.displayString().prefix(string.count) == string {
          return item.displayString()
        }
      }
    }
    return nil
  }

}
