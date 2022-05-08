//
//  FlowControl.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/05/2022.
//

import Foundation
import Cocoa

public enum FlowControl : Int {
  
  case noFlowControl = 0
  case rtsCts = 1
  
  public var title : String {
    get {
      switch self {
      case .noFlowControl:
        return "No Flow Control"
      case .rtsCts:
        return "RTS/CTS"
      }
    }
  }
  
  public static func populate(comboBox: NSComboBox) {
    comboBox.removeAllItems()
    for index in 0...1 {
      if let setting = FlowControl(rawValue: index) {
        comboBox.addItem(withObjectValue: setting.title)
      }
    }
  }
  
}


