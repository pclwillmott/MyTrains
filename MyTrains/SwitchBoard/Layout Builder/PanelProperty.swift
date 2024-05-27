//
//  PanelProperty.swift
//  MyTrains
//
//  Created by Paul Willmott on 23/05/2024.
//

import Foundation
import AppKit

public enum PanelProperty : Int {
  
  // MARK: Enumeration
  
  case layoutId = 1001
  case layoutName = 1002
  case panelId = 1003
  case panelName = 1004
  case panelDescription = 1005
  case numberOfRows = 1006
  case numberOfColumns = 1007
  
  // MARK: Public Properties
  
  // MARK: Public Methods
  
  public func isValid(string:String) -> Bool {
    
    switch self {
    case .panelName:
      return !string.isEmpty
    case .numberOfRows:
      return UInt16(string) != nil
    case .numberOfColumns:
      return UInt16(string) != nil
    default:
      return true
    }
    
  }
  
}


