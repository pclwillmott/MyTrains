//
//  RouteDirection.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/08/2022.
//

import Foundation
import AppKit

public enum RouteDirection : UInt8, CaseIterable {
  
  case next     = 0
  case previous = 1

  init?(title:String) {
    for temp in RouteDirection.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    return RouteDirection.titles[Int(self.rawValue)]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Next", comment: "Used to describe the direction of the next block in respect of a train route"),
    String(localized: "Previous", comment: "Used to describe the direction of the previous block in respect of a train route"),
  ]
  
  private static var map : String {
    
    let items : [RouteDirection] = [
      .next,
      .previous,
    ]
    
    var map = "<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"

    return map
    
  }

  // MARK: Public Class Properties
  
  public static let defaultValue : RouteDirection = .next
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    comboBox.addItems(withObjectValues: titles)
    select(comboBox: comboBox, value: .defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:RouteDirection) {
    comboBox.selectItem(at: Int(value.rawValue))
  }
  
  public static func selected(comboBox: NSComboBox) -> RouteDirection {
    return RouteDirection(rawValue: UInt8(comboBox.indexOfSelectedItem)) ?? defaultValue
  }
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: CDI.ROUTE_DIRECTION, with: map)
  }

}
