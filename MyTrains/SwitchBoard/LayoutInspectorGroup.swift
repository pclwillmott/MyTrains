//
//  LayoutInspectorGroup.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/04/2024.
//

import Foundation
import AppKit

public enum LayoutInspectorGroup : Int, CaseIterable {
  
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
  case turnoutEvents      = 10
  case sensorEvents       = 11
  case speedConstraintsDP = 12
  case speedConstraintsDN = 13

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
      .information
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
      String(localized: "Block Event IDs", comment: "This is used for the title of the Block Event IDs section in the Layout Builder."),
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
      String(localized: "Turnout Control", comment: "This is used for the title of the Turnout Control section in the Layout Builder."),
      .attributes
    ),
    .signalEvents : (
      String(localized: "Signal Event IDs", comment: "This is used for the title of the Signal Event IDs section in the Layout Builder."),
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
    .turnoutEvents : (
      String(localized: "Turnout Event IDs", comment: "This is used for the title of the Turnout Event IDs section in the Layout Builder."),
      .events
    ),
    .sensorEvents : (
      String(localized: "Sensor Event IDs", comment: "This is used for the title of the Sensor Event IDs section in the Layout Builder."),
      .events
    ),
  ]
  
  // MARK: Public Class Properties
  
  public static var inspectorGroupFields : [LayoutInspectorGroup:LayoutInspectorGroupField] {
    
    var constraints : [NSLayoutConstraint] = []

    var result : [LayoutInspectorGroup:LayoutInspectorGroupField] = [:]
    
    for item in LayoutInspectorGroup.allCases {
      
      var field : LayoutInspectorGroupField = (nil, nil, item)
      
      let view = NSView()
      view.translatesAutoresizingMaskIntoConstraints = false
      
      let label = NSTextField(labelWithString: item.title)
      label.translatesAutoresizingMaskIntoConstraints = false
      label.font = NSFont.systemFont(ofSize: 12, weight: .bold)
      label.textColor = NSColor.systemGray
      label.alignment = .left
      
      view.addSubview(label)
      constraints.append(label.leadingAnchor.constraint(equalTo: view.leadingAnchor))
      constraints.append(view.heightAnchor.constraint(equalTo: label.heightAnchor))
      
      field.view = view
      field.label = label
      
      result[item] = field
      
    }
    
    NSLayoutConstraint.activate(constraints)

    return result
    
  }
  
  public static var inspectorGroupSeparators : [LayoutInspectorGroup:LayoutInspectorGroupField] {
    
    var constraints : [NSLayoutConstraint] = []

    var result : [LayoutInspectorGroup:LayoutInspectorGroupField] = [:]
    
    for item in LayoutInspectorGroup.allCases {
      
      var field : LayoutInspectorGroupField = (nil, nil, item)
      
      let separator = SeparatorView()
      separator.translatesAutoresizingMaskIntoConstraints = false
      constraints.append(separator.heightAnchor.constraint(equalToConstant: 20))

      field.view = separator
      
      result[item] = field
      
    }
    
    NSLayoutConstraint.activate(constraints)

    return result
    
  }

}
