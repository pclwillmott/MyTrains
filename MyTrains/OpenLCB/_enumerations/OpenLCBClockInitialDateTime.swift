//
//  OpenLCBClockInitialTimeDate.swift
//  MyTrains
//
//  Created by Paul Willmott on 10/06/2023.
//

import Foundation

public enum OpenLCBClockInitialDateTime : UInt8 {
  
  case computerDateTime = 0
  case defaultDateTime = 1
  
  // MARK: Public Properties
  
  public var title : String {
    return OpenLCBClockInitialDateTime.titles[Int(self.rawValue)]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Computer Data & Time", comment: "Used to indicate what is the initial date and time setting for a clock"),
    String(localized: "Default Data & Time", comment: "Used to indicate what is the initial date and time setting for a clock"),
  ]

  private static var map : String {
    
    var items : [OpenLCBClockInitialDateTime] = [
      .computerDateTime,
      .defaultDateTime,
    ]
    
    var map = ""
    
    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    return map
    
  }
  
  // MARK: Public Class Properties
  
  public static let defaultValue : TurnoutMotorType = .manual
  
  public static let mapPlaceholder = "%%CLOCK_INITIAL_DATE_TIME%%"

  // MARK: Public Class Methods
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
