//
//  OpenLCBClockState.swift
//  MyTrains
//
//  Created by Paul Willmott on 26/05/2023.
//

import Foundation

public enum OpenLCBClockState : UInt8 {
  
  case stopped = 0
  case running = 1

  // MARK: Public Properties
  
  public var title : String {
    return OpenLCBClockState.titles[Int(self.rawValue)]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Stopped", comment: "Used to indicate a clock is stopped"),
    String(localized: "Running", comment: "Used to indicate a clock is running"),
  ]

  private static var map : String {
    
    let items : [OpenLCBClockState] = [
      .stopped,
      .running,
    ]
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"

    return map
    
  }
  
  // MARK: Public Class Properties
  
  public static let defaultValue : OpenLCBClockState = .running
  
  public static let mapPlaceholder = CDI.CLOCK_STATE

  // MARK: Public Class Methods
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
