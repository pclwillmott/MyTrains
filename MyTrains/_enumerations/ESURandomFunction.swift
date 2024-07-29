//
//  ESURandomFunction.swift
//  MyTrains
//
//  Created by Paul Willmott on 28/07/2024.
//

import Foundation
import AppKit

public enum ESURandomFunction : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case random1 = 0
  case random2 = 1
  case random3 = 2
  case random4 = 3
  case random5 = 4
  case random6 = 5
  case random7 = 6
  case random8 = 7

  // MARK: Constructors
  
  init?(title:String) {
    for temp in ESURandomFunction.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    
    return ESURandomFunction.titles[self]!
    
  }
  
  // MARK: Public Methods
  
  public func cvIndexOffset(decoder:Decoder) -> Int {
    return Int(self.rawValue) * 8
  }
  
  // MARK: Public Class Properties
  
  public static let titles : [ESURandomFunction:String] = [
    .random1 : String(localized:"Random 1"),
    .random2 : String(localized:"Random 2"),
    .random3 : String(localized:"Random 3"),
    .random4 : String(localized:"Random 4"),
    .random5 : String(localized:"Random 5"),
    .random6 : String(localized:"Random 6"),
    .random7 : String(localized:"Random 7"),
    .random8 : String(localized:"Random 8"),
  ]

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    let target = comboBox.target
    let action = comboBox.action
    comboBox.target = nil
    comboBox.action = nil
    comboBox.removeAllItems()
    for item in ESURandomFunction.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
    comboBox.target = target
    comboBox.action = action
  }

}
