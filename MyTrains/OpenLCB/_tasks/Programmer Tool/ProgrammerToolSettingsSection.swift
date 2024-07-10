//
//  ProgrammerToolSettingsSection.swift
//  MyTrains
//
//  Created by Paul Willmott on 10/07/2024.
//

import Foundation
import AppKit

public enum ProgrammerToolSettingsSection : Int, CaseIterable {
  
  // MARK: Enumeration
  
  case locomotiveAddress = 1
 
  // MARK: Public Properties
  
  public var inspector : ProgrammerToolSettingsGroup {
    return ProgrammerToolSettingsSection.groups[self]!.inspector
  }

  public var title : String {
    return ProgrammerToolSettingsSection.groups[self]!.title
  }

  // MARK: Private Class Properties
  
  private static let groups : [ProgrammerToolSettingsSection:(title:String, inspector:ProgrammerToolSettingsGroup)] = [
    .locomotiveAddress : (
      String(localized: "Locomotive Address"),
      .address
    ),
  ]
  
  // MARK: Public Class Properties
  
  public static var inspectorSectionFields : [ProgrammerToolSettingsSection:ProgrammerToolSettingsSectionField] {
    
    var constraints : [NSLayoutConstraint] = []

    var result : [ProgrammerToolSettingsSection:ProgrammerToolSettingsSectionField] = [:]
    
    for item in ProgrammerToolSettingsSection.allCases {
      
      var field : ProgrammerToolSettingsSectionField = (nil, nil, item)
      
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
  
  public static var inspectorSectionSeparators : [ProgrammerToolSettingsSection:ProgrammerToolSettingsSectionField] {
    
    var constraints : [NSLayoutConstraint] = []

    var result : [ProgrammerToolSettingsSection:ProgrammerToolSettingsSectionField] = [:]
    
    for item in ProgrammerToolSettingsSection.allCases {
      
      var field : ProgrammerToolSettingsSectionField = (nil, nil, item)
      
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
