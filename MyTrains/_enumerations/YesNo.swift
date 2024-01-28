//
//  YesNo.swift
//  MyTrains
//
//  Created by Paul Willmott on 28/01/2024.
//

import Foundation
import AppKit

public enum YesNo : UInt8 {
  
  case no  = 0
  case yes = 1

  // MARK: Public Properties
  
  public var title : String {
    return YesNo.titles[Int(self.rawValue)]
  }
  
  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "No", comment: "Used to indicate a yes/no state"),
    String(localized: "Yes", comment: "Used to indicate a yes/no state"),
  ]
  
  private static var map : String {
    
    let items : [YesNo] = [
      .no,
      .yes,
    ]
    
    var map = "<default>\(defaultValue.rawValue)</default>\n<map>\n"

    for item in items {
      map += "<relation><property>\(item.rawValue)</property><value>\(item.title)</value></relation>\n"
    }

    map += "</map>\n"

    return map
    
  }
  
  // MARK: Public Class Prooperties
  
  public static let defaultValue : YesNo = .no
  
  public static let mapPlaceholder = CDI.YES_NO

  // MARK: Public Class Methods
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: mapPlaceholder, with: map)
  }

}
