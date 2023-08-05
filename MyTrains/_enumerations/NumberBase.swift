//
//  CVNumberBase.swift
//  MyTrains
//
//  Created by Paul Willmott on 28/12/2022.
//

import Foundation
import AppKit

public enum NumberBase : Int {
  
  case decimal = 0
  case hexadecimal = 1
  case binary = 2
  case octal = 3
  
  // MARK: Public Properties
  
  public var title : String {
    get {
      return NumberBase.titles[self.rawValue]
    }
  }
  
  // MARK: Public Methods
  
  public func toString(value:UInt8) -> String {
    
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
    "Hex",
    "Binary",
    "Octal",
  ]
  
  // MARK: Class Public Methods
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: NumberBase) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static let defaultValue : NumberBase = .decimal
  
  public static func selected(comboBox:NSComboBox) -> NumberBase {
    return NumberBase(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
  public static func toUInt8(string:String) -> UInt8? {
    
    let part = string.trimmingCharacters(in: .whitespacesAndNewlines)
    
    if part.prefix(2) == "0x" {
      if let nn = UInt8(part.suffix(part.count-2), radix: 16) {
        return nn
      }
    }
    else if part.prefix(2) == "0b" {
      if let nn = UInt8(part.suffix(part.count-2), radix: 2) {
        return nn
     }
    }
    else if part.prefix(1) == "0" {
      if let nn = UInt8(part.suffix(part.count), radix: 8) {
        return nn
      }
    }
    else {
      if let nn = UInt8(part.suffix(part.count), radix: 10) {
        return nn
      }
    }

    return nil
    
  }
  
}
