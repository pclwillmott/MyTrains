//
//  RouteDirection.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/08/2022.
//

import Foundation
import AppKit

public enum RouteDirection : Int {
  
  case next     = 0
  case previous = 1

  // MARK: Public Properties
  
  public var title : String {
    return RouteDirection.titles[self.rawValue]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Next", comment: "Used to describe the direction of the next block in respect of a train route"),
    String(localized: "Previous", comment: "Used to describe the direction of the previous block in respect of a train route"),
  ]
  
  private static var map : String {
    
    var items : [RouteDirection] = [
      .next,
      .previous,
    ]
    
    var map = ""
    
    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    return map
    
  }

  // MARK: Public Class Properties
  
  public static let defaultValue : RouteDirection = .next
  
  public static let mapPlaceholder = "%%ROUTE_DIRECTION%%"

  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: .defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:RouteDirection) {
    comboBox.selectItem(at: value.rawValue)
  }
  
  public static func selected(comboBox: NSComboBox) -> RouteDirection {
    return RouteDirection(rawValue: comboBox.indexOfSelectedItem) ?? defaultValue
  }
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
