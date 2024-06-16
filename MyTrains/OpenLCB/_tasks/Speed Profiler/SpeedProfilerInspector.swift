//
//  SpeedProfilerInspector.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/06/2024.
//

import Foundation
import AppKit

public enum SpeedProfilerInspector : Int, CaseIterable {
  
  // MARK: Enumeration
  
  case identity = 0
  case quickHelp = 1
  case settings = 2
  case route = 3
  
  // MARK: Public Properties
  
  public var button : NSButton {
    
    let icons : [SpeedProfilerInspector:MyIcon] = [
      .identity   : .info,
      .quickHelp  : .help,
      .settings   : .gear,
      .route      : .map,
    ]
    
    let tooltip : [SpeedProfilerInspector:String] = [
      .identity   : String(localized: "Show Identity Inspector"),
      .quickHelp  : String(localized: "Show Quick Help Inspector"),
      .settings   : String(localized: "Show Settings Inspector"),
      .route      : String(localized: "Show Route Inspector"),
    ]
    
    let button = icons[self]!.button(target: nil, action: nil)!
    button.toolTip = tooltip[self]!
    button.translatesAutoresizingMaskIntoConstraints = false
    button.isBordered = false
    button.tag = self.rawValue
    
    return button
    
  }
  
}
