//
//  LayoutInspectorGroup.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/04/2024.
//

import Foundation

public enum LayoutInspectorGroup : Int {
  
  // MARK: Enumeration
  
  case identity           = 1
  case generalSettings    = 2
  case blockSettings      = 3
  case trackConfiguration = 4
  case blockEvents        = 5
  case sensorSettings     = 6
  case signalSettings     = 7
  case turnoutControl     = 8
  case signalEvents       = 9
  case speedConstraintsDP = 10
  case speedConstraintsDN = 11

  // MARK: Public Properties
  
  public var title : String {
    return LayoutInspectorGroup.groups[self]!.title
  }
  
  public var inspector : LayoutInspector {
    return LayoutInspectorGroup.groups[self]!.inspector
  }
  
  // MARK: Private Class Properties
  
  private static let groups : [LayoutInspectorGroup:(title:String, inspector:LayoutInspector)] = [
    .identity : (
      String(localized: "Identity", comment: "This is used for the title of the Identity section in the Layout Builder."),
      .attributes
    ),
    .generalSettings : (
      String(localized: "General Settings", comment: "This is used for the title of the General Settings section in the Layout Builder."),
      .attributes
    ),
    .blockSettings : (
      String(localized: "Block Settings", comment: "This is used for the title of the Block Settings section in the Layout Builder."),
      .attributes
    ),
    .trackConfiguration : (
      String(localized: "Track Configuration", comment: "This is used for the title of the Track Configuration section in the Layout Builder."),
      .attributes
    ),
    .blockEvents : (
      String(localized: "Block Events", comment: "This is used for the title of the Block Events section in the Layout Builder."),
      .events
    ),
    .sensorSettings : (
      String(localized: "Sensor Settings", comment: "This is used for the title of the Sensor Settings section in the Layout Builder."),
      .attributes
    ),
    .signalSettings : (
      String(localized: "Signal Settings", comment: "This is used for the title of the Signal Settings section in the Layout Builder."),
      .attributes
    ),
    .turnoutControl : (
      String(localized: "Identity", comment: "This is used for the title of the Turnout Control section in the Layout Builder."),
      .turnouts
    ),
    .signalEvents : (
      String(localized: "Signal Events", comment: "This is used for the title of the Signal Events section in the Layout Builder."),
      .events
    ),
    .speedConstraintsDP : (
      String(localized: "Direction Previous", comment: "This is used for the title of the Speed Constraints Direction Previous section in the Layout Builder."),
      .speedConstraints
    ),
    .speedConstraintsDN : (
      String(localized: "Direction Next", comment: "This is used for the title of the Speed Constraints Direction Next section in the Layout Builder."),
      .speedConstraints
    ),
  ]
  
}
