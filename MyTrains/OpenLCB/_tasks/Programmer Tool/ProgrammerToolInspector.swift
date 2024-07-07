//
//  ProgrammerToolInspector.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/07/2024.
//

import Foundation
import AppKit

public enum ProgrammerToolInspector : Int, CaseIterable {
  
  // MARK: Enumeration
  
  case identity = 0
  case quickHelp = 1
  case settings = 2
  case rwCVs = 3
  case changedCVs = 4
  case sound = 5
  
  // MARK: Public Properties
  
  public var button : NSButton {
    
    let icons : [ProgrammerToolInspector:MyIcon] = [
      .identity   : .info,
      .quickHelp  : .help,
      .settings   : .gear,
      .rwCVs      : .wrench,
      .sound      : .speaker,
      .changedCVs : .sunglasses,
    ]
    
    let tooltip : [ProgrammerToolInspector:String] = [
      .identity   : String(localized: "Show Identity Inspector"),
      .quickHelp  : String(localized: "Show Quick Help Inspector"),
      .settings   : String(localized: "Show Settings Inspector"),
      .rwCVs      : String(localized: "Show Read/Write CVs Inspector"),
      .sound      : String(localized: "Show Sound Inspector"),
      .changedCVs : String(localized: "Show Changed CVs Inspector"),
    ]
    
    let button = icons[self]!.button(target: nil, action: nil)!
    button.toolTip = tooltip[self]!
    button.translatesAutoresizingMaskIntoConstraints = false
    button.isBordered = false
    button.tag = self.rawValue
    
    return button
    
  }
  
  public var backgroundColor : CGColor {
    
    let colors : [ProgrammerToolInspector:CGColor] = [
      .identity   : NSColor.blue.cgColor,
      .quickHelp  : NSColor.red.cgColor,
      .settings   : NSColor.yellow.cgColor,
      .rwCVs      : NSColor.green.cgColor,
      .sound      : NSColor.magenta.cgColor,
      .changedCVs : NSColor.orange.cgColor,
    ]
    
    return colors[self]!
    
  }
  
}
