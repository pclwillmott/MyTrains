//
//  LCCCDIMap.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/04/2023.
//

import Foundation
import Cocoa

public class LCCCDIMap {
  
  // MARK: Constructors
  
  init(field:LCCCDIElement) {
    self.field = field
  }
  
  // MARK: Public Properties
  
  public var field : LCCCDIElement
  
  // MARK: Public Methods
  
  public func populate(comboBox:NSComboBox) {
    
    comboBox.removeAllItems()
    
    for item in field.map {
      comboBox.addItem(withObjectValue: item.stringValue)
    }
    
    if let defaultValue = field.defaultValue {
      selectItem(comboBox: comboBox, property: defaultValue)
    }
    
  }
  
  public func selectItem(comboBox:NSComboBox, property:String) {
    
    var index = 0
    
    for item in field.map {
      if property == item.property{
        comboBox.selectItem(at: index)
        return
      }
      index += 1
    }
    
  }
  
  public func selectedItem(comboBox:NSComboBox) -> String? {
    if comboBox.indexOfSelectedItem == -1 {
      return nil
    }
    return field.map[comboBox.indexOfSelectedItem].property
  }

}