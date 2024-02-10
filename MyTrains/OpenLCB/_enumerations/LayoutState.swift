//
//  LayoutState.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/01/2024.
//

import Foundation

public enum LayoutState : UInt8 {
  
  case activated   = 0
  case deactivated = 1

  // MARK: Public Properties
  
  public var title : String {
    return LayoutState.titles[Int(self.rawValue)]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Activated", comment: "Used to indicate a layout's state"),
    String(localized: "Deactivated", comment: "Used to indicate a layout's state"),
  ]

  private static var map : String {
    
    let items : [LayoutState] = [
      .activated,
      .deactivated,
    ]
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"

    return map
    
  }
  
  // MARK: Public Class Properties
  
  public static let defaultValue : LayoutState = .activated
  
  public static let mapPlaceholder = CDI.LAYOUT_STATE

  // MARK: Public Class Methods
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
