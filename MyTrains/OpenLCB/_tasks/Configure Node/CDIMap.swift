//
//  LCCCDIMap.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/04/2023.
//

import Foundation
import AppKit

public class CDIMap {
  
  // MARK: Constructors
  
  init(field:CDIElement) {
    self.field = field
  }
  
  deinit {
    field = nil
  }
  
  // MARK: Public Properties
  
  public weak var field : CDIElement?
  
  // MARK: Public Methods
  
  public func populate(comboBox:NSComboBox) {
    
    comboBox.removeAllItems()
    
    for item in field!.map {
      comboBox.addItem(withObjectValue: item.stringValue)
    }
    
    if let defaultValue = field?.defaultValue {
      selectItem(comboBox: comboBox, property: defaultValue)
    }
    
  }
  
  public func selectItem(comboBox:NSComboBox, property:String) {
    
    var index = 0
    
    comboBox.deselectItem(at: comboBox.indexOfSelectedItem)
    
    for item in field!.map {
      if property == item.property {
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
    return field!.map[comboBox.indexOfSelectedItem].property
  }

}
