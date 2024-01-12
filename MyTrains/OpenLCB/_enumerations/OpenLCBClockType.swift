//
//  OpenLCBClockType.swift
//  MyTrains
//
//  Created by Paul Willmott on 26/05/2023.
//

import Foundation

public enum OpenLCBClockType : UInt8 {
  
  case fastClock       = 0
  case realTimeClock   = 1
  case alternateClock1 = 2
  case alternateClock2 = 3
  case customClock     = 4

  // MARK: Public Properties
  
  public var title : String {
    return OpenLCBClockType.titles[Int(self.rawValue)]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Fast Clock", comment: "Used to indicate a clock's type"),
    String(localized: "Real Time Clock", comment: "Used to indicate a clock's type"),
    String(localized: "Alternate Clock 1", comment: "Used to indicate a clock's type"),
    String(localized: "Alternate Clock 2", comment: "Used to indicate a clock's type"),
    String(localized: "Custom Clock", comment: "Used to indicate a clock's type"),
  ]

  private static var map : String {
    
    var items : [OpenLCBClockType] = [
      .fastClock,
      .realTimeClock,
      .alternateClock1,
      .alternateClock2,
      .customClock,
    ]
    
    var map = ""
    
    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    return map
    
  }
  
  // MARK: Public Class Properties
  
  public static let defaultValue : TurnoutMotorType = .manual
  
  public static let mapPlaceholder = "%%CLOCK_TYPE%%"

  // MARK: Public Class Methods
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
