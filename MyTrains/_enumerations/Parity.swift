//
//  Parity.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/07/2023.
//

import Foundation
import AppKit

public enum Parity : Int32 {
  
  case none = 0
  case even = 1
  case odd  = 2

  // MARK: Public Properties
  
  public var title : String {
    return Parity.titles[Int(self.rawValue)]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "No Parity", comment: "Used to indicate that the serial port is configured for no parity bit"),
    String(localized: "Even Parity", comment: "Used to indicate that the serial port is configured for even parity"),
    String(localized: "Odd Parity", comment: "Used to indicate that the serial port is configured for odd parity"),
  ]
  
  private static var map : String {
    
    var items : [Parity] = [
      .none,
      .even,
      .odd,
    ]
    
    var map = ""
    
    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    return map
    
  }
  
  // MARK: Public Class Prooperties
  
  public static let defaultValue : Parity = .none
  
  public static let mapPlaceholder = "%%PARITY%%"

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: .defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:Parity) {
    comboBox.selectItem(at: Int(value.rawValue))
  }
  
  public static func selected(comboBox: NSComboBox) -> Parity {
    return Parity(rawValue: Int32(comboBox.indexOfSelectedItem)) ?? defaultValue
  }
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
