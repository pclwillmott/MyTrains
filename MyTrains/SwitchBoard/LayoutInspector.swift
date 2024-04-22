//
//  LayoutInspector.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/04/2024.
//

import Foundation

public enum LayoutInspector : Int {
  
  // MARK: Enumeration
  
  case information      = 0
  case quickHelp        = 1
  case attributes       = 2
  case events           = 3
  case speedConstraints = 4
  case turnouts         = 5
  
  // MARK: Public Properties
  
  public var title : String {
    return LayoutInspector.titles[self]!
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [LayoutInspector:String] = [
    .information      : String(localized: "Information", comment: ""),
    .quickHelp        : String(localized: "Quick Help", comment: ""),
    .attributes       : String(localized: "Attributes", comment: ""),
    .events           : String(localized: "Events", comment: ""),
    .speedConstraints : String(localized: "Speed Constraints", comment: ""),
    .turnouts         : String(localized: "Turnouts", comment: ""),
  ]
}
