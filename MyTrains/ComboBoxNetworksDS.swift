//
//  ComboBoxNetworksDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/12/2021.
//

import Foundation
import Cocoa

class ComboBoxNetworksDS : NSObject, NSComboBoxDataSource, NSComboBoxDelegate {
  
  private var _items : [Network]
  
  override init() {
    
    self._items = networkController.networks
    
    super.init()
    
  }
    
  // Returns the first item from the pop-up list that starts with the text the user has typed.

  public func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
    if string.count > 1 {
      for item in _items {
        if item.networkName.prefix(string.count) == string {
          return item.networkName
        }
      }
    }
    return nil
  }
  
  // Returns the index of the combo box item matching the specified string.

  public func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
    var index = 0
    for item in _items {
      if item.networkName == string {
        return index
      }
      index += 1
    }
    return -1
  }
 
  //  Returns the object that corresponds to the item at the specified index in the combo box.

  public func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
    if index < 0 || index >= _items.count {
      return nil
    }
    return _items[index]
  }

  //  Returns the row code that corresponds to the item at the specified index in the combo box.
  
  public func comboBox(_ comboBox: NSComboBox, codeForItemAt index: Int) -> Int? {
    if index < 0 || index >= _items.count {
      return nil
    }
    return _items[index].networkId
  }

  public func codeForItemAt(index: Int) -> Int? {
    if index < 0 || index >= _items.count {
      return nil
    }
    return _items[index].networkId
  }

  // Returns the number of items that the data source manages for the combo box.

  public func numberOfItems(in comboBox: NSComboBox) -> Int {
    return _items.count
  }
  
  // Returns the code of the combo box item matching the specified string.

   public func codeOfItemWithStringValue(string: String) -> Int {
     var index = 0
     for item in _items {
       if item.networkName == string {
         return item.networkId
       }
       index += 1
     }
     return -1
   }
  
}
