//
//  FlowControl.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/05/2022.
//

import Foundation
import AppKit

public enum FlowControl : Int {
  
  case noFlowControl = 0
  case rtsCts        = 1
  
  // MARK: Public Properties
  
  public var title : String {
    return FlowControl.titles[self.rawValue]
  }
  
  // MARK: Public Class Properties
  
  public static let defaultValue : FlowControl = .noFlowControl
  
  public static let mapPlaceholder = "%%FLOW_CONTROL%%"
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "No Flow Control", comment: "Used to indicate that serial port does not use hardware flow control"),
    String(localized: "RTS/CTS", comment: "Used to indicate that serial port uses the RTS/CTS lines for hardware flow control"),
  ]

  private static var map : String {
    
    var items : [FlowControl] = [
      .noFlowControl,
      .rtsCts,
    ]
    
    var map = ""
    
    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    return map
    
  }

  // MARK: Public Class Methods
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: FlowControl) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> FlowControl {
    return FlowControl(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }

  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }
  
}


