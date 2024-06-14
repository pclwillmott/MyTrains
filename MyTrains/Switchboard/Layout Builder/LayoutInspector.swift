//
//  LayoutInspector.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/04/2024.
//

import Foundation

public enum LayoutInspector : Int, CaseIterable {
  
  // MARK: Enumeration
  
  case identity         = 0
  case quickHelp        = 1
  case attributes       = 2
  case events           = 3
  case speedConstraints = 4
  
  // MARK: Public Properties
  
  public var title : String {
    return LayoutInspector.titles[self]!
  }
  
  public var tooltip : String {
    return LayoutInspector.tooltips[self]!
  }
  
  public var icon : MyIcon {
    return LayoutInspector.icons[self]!
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [LayoutInspector:String] = [
    .identity         : String(localized: "Identity", comment: ""),
    .quickHelp        : String(localized: "Quick Help", comment: ""),
    .attributes       : String(localized: "Attributes", comment: ""),
    .events           : String(localized: "Events", comment: ""),
    .speedConstraints : String(localized: "Speed Constraints", comment: ""),
  ]

  private static let tooltips : [LayoutInspector:String] = [
    .identity         : String(localized: "Show Identity Inspector", comment: ""),
    .quickHelp        : String(localized: "Show Quick Help Inspector", comment: ""),
    .attributes       : String(localized: "Show Attributes Inspector", comment: ""),
    .events           : String(localized: "Show Events Inspector", comment: ""),
    .speedConstraints : String(localized: "Show Speed Constraints Inspector", comment: ""),
  ]

  private static let icons : [LayoutInspector:MyIcon] = [
    .identity         : .info,
    .quickHelp        : .help,
    .attributes       : .gear,
    .events           : .bolt,
    .speedConstraints : .speedometer,
  ]

}
