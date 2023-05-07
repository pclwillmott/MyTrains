//
//  CVNumberBase.swift
//  MyTrains
//
//  Created by Paul Willmott on 28/12/2022.
//

import Foundation
import AppKit

public enum CVNumberBase : Int {
  
  case decimal = 0
  case hexadecimal = 1
  case binary = 2
  case octal = 3
  
  // MARK: Public Properties
  
  public var title : String {
    get {
      return CVNumberBase.titles[self.rawValue]
    }
  }
  
  // MARK: Public Methods
  
  public func toString(value:Int) -> String {
    
    var item : String = ""
    
    switch self {
      
    case .decimal:
      
      item = "\(String(format: "%d", value))"
      
    case .hexadecimal:
      
      item = "0x\(String(format: "%02x", value))"
      
    case .binary:
      
      var padded = String(value, radix: 2)
      for _ in 0..<(8 - padded.count) {
        padded = "0" + padded
      }
      item = "0b" + padded

    case .octal:
      
      item = "\(String(format: "%03o", value))"
      if item.prefix(1) != "0" {
        item = "0\(item)"
      }
      
    }
    
    return item

  }

  // MARK: Class Private Properties
  
  private static let titles = [
    "Decimal",
    "Hexadecimal",
    "Binary",
    "Octal",
  ]
  
  // MARK: Class Public Methods
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: CVNumberBase) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static let defaultValue : CVNumberBase = .decimal
  
  public static func selected(comboBox:NSComboBox) -> CVNumberBase {
    return CVNumberBase(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }

}

