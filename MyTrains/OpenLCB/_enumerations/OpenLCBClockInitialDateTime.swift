//
//  OpenLCBClockInitialTimeDate.swift
//  MyTrains
//
//  Created by Paul Willmott on 10/06/2023.
//

import Foundation

public enum OpenLCBClockInitialDateTime : UInt8 {
  
  case computerDateTime = 0
  case defaultDateTime  = 1
  
  // MARK: Public Properties
  
  public var title : String {
    return OpenLCBClockInitialDateTime.titles[Int(self.rawValue)]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Computer Date and Time", comment: "Used to indicate what is the initial date and time setting for a clock"),
    String(localized: "Default Date and Time", comment: "Used to indicate what is the initial date and time setting for a clock"),
  ]

  private static var map : String {
    
    let items : [OpenLCBClockInitialDateTime] = [
      .computerDateTime,
      .defaultDateTime,
    ]
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"

    return map
    
  }
  
  // MARK: Public Class Properties
  
  public static let defaultValue : OpenLCBClockInitialDateTime = .computerDateTime
  
  public static let mapPlaceholder = CDI.CLOCK_INITIAL_DATE_TIME

  // MARK: Public Class Methods
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
