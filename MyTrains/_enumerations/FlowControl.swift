//
//  FlowControl.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/05/2022.
//

import Foundation
import AppKit

public enum FlowControl : UInt8 {
  
  case noFlowControl = 0
  case rtsCts        = 1
  
  // MARK: Public Properties
  
  public var title : String {
    return FlowControl.titles[Int(self.rawValue)]
  }
  
  // MARK: Public Class Properties
  
  public static let defaultValue : FlowControl = .noFlowControl
  
  public static let mapPlaceholder = CDI.FLOW_CONTROL
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "No Flow Control", comment: "Used to indicate that serial port does not use hardware flow control"),
    String(localized: "RTS/CTS", comment: "Used to indicate that serial port uses the RTS/CTS lines for hardware flow control"),
  ]

  private static var map : String {
    
    let items : [FlowControl] = [
      .noFlowControl,
      .rtsCts,
    ]
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }
    
    map += "</map>\n"

    return map
    
  }

  // MARK: Public Class Methods
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: defaultValue)
  }
  
  public static func select(comboBox: NSComboBox, value: FlowControl) {
    comboBox.selectItem(at: Int(value.rawValue))
  }
  
  public static func selected(comboBox: NSComboBox) -> FlowControl {
    return FlowControl(rawValue: UInt8(comboBox.indexOfSelectedItem)) ?? defaultValue
  }

  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }
  
}


