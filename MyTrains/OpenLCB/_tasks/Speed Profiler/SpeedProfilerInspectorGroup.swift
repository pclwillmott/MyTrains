//
//  SpeedProfilerInspectorGroup.swift
//  MyTrains
//
//  Created by Paul Willmott on 17/06/2024.
//

import Foundation
import AppKit

public enum SpeedProfilerInspectorGroup : Int, CaseIterable {
  
  // MARK: Enumeration
  
  case identity           = 1
  case quickHelp          = 2
  case locomotiveControl  = 3
  case sampling           = 4
  case analysis           = 5
  case route              = 6

  // MARK: Public Properties
  
  public var title : String {
    return SpeedProfilerInspectorGroup.groups[self]!.title
  }
  
  public var inspector : SpeedProfilerInspector {
    return SpeedProfilerInspectorGroup.groups[self]!.inspector
  }
  
  // MARK: Private Class Properties
  
  private static let groups : [SpeedProfilerInspectorGroup:(title:String, inspector:SpeedProfilerInspector)] = [
    .identity : (
      String(localized: "Identity", comment: "This is used for the title of the Identity section in the Speed Profiler."),
      .identity
    ),
    .quickHelp : (
      String(localized: "Quick Help", comment: "This is used for the title of the Quick Help section in the Speed Profiler."),
      .quickHelp
    ),
    .locomotiveControl : (
      String(localized: "Locomotive Control", comment: "This is used for the title of the Locomotive Control section in the Speed Profiler."),
      .settings
    ),
    .sampling : (
      String(localized: "Sampling Settings", comment: "This is used for the title of the Sampling Settings section in the Speed Profiler."),
      .settings
    ),
    .analysis : (
      String(localized: "Analysis Settings", comment: "This is used for the title of the Analysis Settings section in the Speed Profiler."),
      .settings
    ),
    .route: (
      String(localized: "Route", comment: "This is used for the title of the Route section in the Speed Profiler."),
      .route
    ),
  ]
  
  // MARK: Public Class Properties
  
  public static var inspectorGroupFields : [SpeedProfilerInspectorGroup:SpeedProfilerInspectorGroupField] {
    
    var constraints : [NSLayoutConstraint] = []

    var result : [SpeedProfilerInspectorGroup:SpeedProfilerInspectorGroupField] = [:]
    
    for item in SpeedProfilerInspectorGroup.allCases {
      
      var field : SpeedProfilerInspectorGroupField = (nil, nil, item)
      
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
  
  public static var inspectorGroupSeparators : [SpeedProfilerInspectorGroup:SpeedProfilerInspectorGroupField] {
    
    var constraints : [NSLayoutConstraint] = []

    var result : [SpeedProfilerInspectorGroup:SpeedProfilerInspectorGroupField] = [:]
    
    for item in SpeedProfilerInspectorGroup.allCases {
      
      var field : SpeedProfilerInspectorGroupField = (nil, nil, item)
      
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
