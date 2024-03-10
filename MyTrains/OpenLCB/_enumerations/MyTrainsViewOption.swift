//
//  MyTrainsViewOption.swift
//  MyTrains
//
//  Created by Paul Willmott on 10/03/2024.
//

import Foundation

public enum MyTrainsViewOption : UInt8 {
  
  case doNotOpen            = 0
  case open                 = 1
  case restorePreviousState = 2

  // MARK: Public Properties
  
  public var title : String {
    return MyTrainsViewOption.titles[self]!
  }
  
  // MARK: Private Class Methods
  
  private static let titles : [MyTrainsViewOption:String] = [
    .doNotOpen            : String(localized: "Do not open"),
    .open                 : String(localized: "Open"),
    .restorePreviousState : String(localized: "Restore previous state"),
  ]
  
  private static var map : String {
    
    let items : [MyTrainsViewOption] = [
      .doNotOpen,
      .open,
      .restorePreviousState,
    ]
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"

    return map
    
  }
  
  // MARK: Public Class Properties
  
  public static let defaultValue : MyTrainsViewOption = .doNotOpen
  
  // MARK: Public Class Methods
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: CDI.VIEW_OPTIONS, with: map)
  }

}
