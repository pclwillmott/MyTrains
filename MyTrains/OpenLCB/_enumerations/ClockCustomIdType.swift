//
//  ClockCustomIdType.swift
//  MyTrains
//
//  Created by Paul Willmott on 14/01/2024.
//

import Foundation

public enum ClockCustomIdType : UInt8 {
  
  case clockNodeId   = 0
  case userSpecified = 1
  
  // MARK: Public Properties
  
  public var title : String {
    return ClockCustomIdType.titles[Int(self.rawValue)]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Clock Node ID", comment: "Used to indicate that a custom clock should use the clock node Id"),
    String(localized: "User Specified", comment: "Used to indicate that a custom clock should use the user specified node Id"),
  ]

  private static var map : String {
    
    var items : [ClockCustomIdType] = [
      .clockNodeId,
      .userSpecified,
    ]
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"

    return map
    
  }
  
  // MARK: Public Class Properties
  
  public static let defaultValue : ClockCustomIdType = .clockNodeId
  
  public static let mapPlaceholder = CDI.CLOCK_CUSTOM_ID_TYPE

  // MARK: Public Class Methods
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
