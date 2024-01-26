//
//  EnableState.swift
//  MyTrains
//
//  Created by Paul Willmott on 14/01/2024.
//

import Foundation
import AppKit

public enum EnableState : UInt8 {
  
  case disabled = 0
  case enabled  = 1

  // MARK: Public Properties
  
  public var title : String {
    return EnableState.titles[Int(self.rawValue)]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Disabled", comment: "Used to indicate that something is disabled"),
    String(localized: "Enabled", comment: "Used to indicate that something is not disabled"),
  ]
  
  private static var map : String {
    
    var items : [EnableState] = [
      .disabled,
      .enabled,
    ]
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"
    
    return map
    
  }
  
  // MARK: Public Class Prooperties
  
  public static let defaultValue : EnableState = .disabled
  
  public static let mapPlaceholder = CDI.ENABLE_STATE

  // MARK: Public Class Methods
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
