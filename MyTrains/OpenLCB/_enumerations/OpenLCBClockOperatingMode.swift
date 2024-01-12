//
//  OpenLCBClockOperatingMode.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/06/2023.
//

import Foundation

public enum OpenLCBClockOperatingMode : UInt8 {
  
  case master = 0
  case slave  = 1

  // MARK: Public Properties
  
  public var title : String {
    return OpenLCBClockOperatingMode.titles[Int(self.rawValue)]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Master", comment: "Used to indicate a clock's operating mode"),
    String(localized: "Slave", comment: "Used to indicate a clock's operating mode"),
  ]

  private static var map : String {
    
    var items : [OpenLCBClockOperatingMode] = [
      .master,
      .slave,
    ]
    
    var map = ""
    
    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    return map
    
  }
  
  // MARK: Public Class Properties
  
  public static let defaultValue : TurnoutMotorType = .manual
  
  public static let mapPlaceholder = "%%CLOCK_OPERATING_MODE%%"

  // MARK: Public Class Methods
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
