//
//  ProgrammerToolSettingsProperty.swift
//  MyTrains
//
//  Created by Paul Willmott on 10/07/2024.
//

import Foundation
import AppKit

public enum ProgrammerToolSettingsProperty : Int, CaseIterable {

  // MARK: Enumeration
  
  // address
  
  case locomotiveAddressType = 1
  case locomotiveAddressShort = 2
  case locomotiveAddressLong = 3
//  case locomotiveAddressWarning = 4
  
  // MARK: Public Properties
  
  public var toolTip : String {
    return ProgrammerToolSettingsProperty.labels[self]!.toolTip
  }
  
  public var section : ProgrammerToolSettingsSection {
    return ProgrammerToolSettingsProperty.labels[self]!.section
  }
  
  public var controlType : ProgrammerToolControlType {
    return ProgrammerToolSettingsProperty.labels[self]!.controlType
  }
  
  // MARK: Public Methods
  
  public func label(showCV:Bool) -> String {
    guard let label = ProgrammerToolSettingsProperty.labels[self] else {
      return "error"
    }
    return label.labelTitle.replacingOccurrences(of: "%%CV%%", with: label.cv)
  }
  
  // MARK: Private Class Properties
  
  private static let labels : [ProgrammerToolSettingsProperty:(labelTitle:String, toolTip:String, cv:String, section:ProgrammerToolSettingsSection, controlType:ProgrammerToolControlType)] = [
    .locomotiveAddressType
    : (
      String(localized:"Locomotive Address Type%%CV%%"),
      String(localized:"Locomotive's address type."),
      String(localized:" [CV29.5]"),
      .locomotiveAddress,
      .comboBox
    ),
    .locomotiveAddressShort
    : (
      String(localized:"Locomotive Address%%CV%%"),
      String(localized:"Locomotive's primary or short address."),
      String(localized:" [CV1]"),
      .locomotiveAddress,
      .textField
    ),
    .locomotiveAddressLong
    : (
      String(localized:"Locomotive Address%%CV%%"),
      String(localized:"Locomotive's extended or long address."),
      String(localized:" [CV17, CV18]"),
      .locomotiveAddress,
      .textField
    ),
  ]

  // MARK: Public Class Properties
  
  public static var inspectorPropertyFields: [ProgrammerToolSettingsPropertyField] {
    
    var result : [ProgrammerToolSettingsPropertyField] = []
    
    let labelFontSize : CGFloat = 10.0
    let textFontSize  : CGFloat = 11.0
    
    for item in ProgrammerToolSettingsProperty.allCases {
      
      var field : ProgrammerToolSettingsPropertyField = (view:nil, label:nil, control:nil, item, customView:nil)
      
        
        field.label = NSTextField(labelWithString: item.label(showCV: true))
        
        let view = NSView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        switch item.controlType {
        case .checkBox:
          field.label!.stringValue = ""
          let checkBox = NSButton()
          checkBox.setButtonType(.switch)
          checkBox.title = item.label(showCV: true)
          field.control = checkBox
        case .comboBox:
          let comboBox = MyComboBox()
          comboBox.isEditable = false
          field.control = comboBox
   //       initComboBox(property: field.property, comboBox: comboBox)
          
        case .label, .description, .warning:
          let textField = NSTextField(labelWithString: "")
          field.control = textField
        case .textField:
          let textField = NSTextField()
          field.control = textField
        }
        
        field.control?.toolTip = item.toolTip
        field.control?.tag = item.rawValue
        
        /// https://manasaprema04.medium.com/autolayout-fundamental-522f0a6e5790
        
        field.label!.translatesAutoresizingMaskIntoConstraints = false
        field.label!.fontSize = labelFontSize
        field.label!.alignment = .right
        field.label!.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 250), for: .horizontal)
        //     field.label!.lineBreakMode = .byWordWrapping
        //     field.label!.maximumNumberOfLines = 0
        //     field.label!.preferredMaxLayoutWidth = 120.0
        
        view.addSubview(field.label!)
        
        field.control!.translatesAutoresizingMaskIntoConstraints = false
        field.control!.fontSize = textFontSize
        field.control!.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 1), for: .horizontal)
        
        view.addSubview(field.control!)
        //      view.backgroundColor = NSColor.yellow.cgColor
        
        field.view = view
        field.view!.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 500), for: .horizontal)
        
      result.append(field)
      
    }
    
    return result
    
  }

}
