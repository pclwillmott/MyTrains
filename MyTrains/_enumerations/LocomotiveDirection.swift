//
//  LocomotiveDirection.swift
//  MyTrains
//
//  Created by Paul Willmott on 04/08/2022.
//

import Foundation
import AppKit

public enum LocomotiveDirection : Int {
  
  case forward = 0
  case reverse = 1
  
  // MARK: Public Properties
  
  public var title : String {
    return LocomotiveDirection.titles[self.rawValue]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Forward", comment: "Used to indicate that the train is moving in the forward direction"),
    String(localized: "Reverse", comment: "Used to indicate that the train is moving in the reverse direction"),
  ]

  private static var map : String {
    
    var items : [LocomotiveDirection] = [
      .forward,
      .reverse,
    ]
    
    var map = ""
    
    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    return map
    
  }

  // MARK: Public Class Properties
  
  public static let defaultValue : LocomotiveDirection = .forward
  
  public static let mapPlaceholder = "%%LOCOMOTIVE_DIRECTION%%"

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: .defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:LocomotiveDirection) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> LocomotiveDirection {
    return LocomotiveDirection(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
