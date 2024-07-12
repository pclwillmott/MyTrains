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
  case marklinConsecutiveAddresses = 5
  case locomotiveAddressWarning = 6
  
  // DCC Consist Address
  
  case enableDCCConsistAddress = 7
  case consistAddress = 8
  case consistReverseDirection = 9
  
  // Analog Settings
  
  case enableACAnalogMode = 10
  case acAnalogModeStartVoltage = 11
  case acAnalogModeMaximumSpeedVoltage = 12
  case enableDCAnalogMode = 13
  case dcAnalogModeStartVoltage = 14
  case dcAnalogModeMaximumSpeedVoltage = 15

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
  
  public var requiredCapabilities : Set<DecoderCapability> {
    return ProgrammerToolSettingsProperty.labels[self]?.requiredCapabilities ?? []
  }
  
  // MARK: Public Methods
  
  public func label(showCV:Bool) -> String {
    guard let label = ProgrammerToolSettingsProperty.labels[self] else {
      return "error"
    }
    return label.labelTitle.replacingOccurrences(of: "%%CV%%", with: label.cv)
  }
  
  // MARK: Private Class Properties
  
  private static let labels : [ProgrammerToolSettingsProperty:(labelTitle:String, toolTip:String, cv:String, section:ProgrammerToolSettingsSection, controlType:ProgrammerToolControlType, requiredCapabilities:Set<DecoderCapability>)] = [
    .locomotiveAddressType
    : (
      String(localized:"Locomotive Address Type%%CV%%"),
      String(localized:"Locomotive's address type."),
      String(localized:" [CV29.5]"),
      .locomotiveAddress,
      .comboBox,
      []
    ),
    .locomotiveAddressShort
    : (
      String(localized:"Locomotive Address%%CV%%"),
      String(localized:"Locomotive's primary or short address."),
      String(localized:" [CV1]"),
      .locomotiveAddress,
      .textField,
      []
    ),
    .locomotiveAddressLong
    : (
      String(localized:"Locomotive Address%%CV%%"),
      String(localized:"Locomotive's extended or long address."),
      String(localized:" [CV17, CV18]"),
      .locomotiveAddress,
      .textField,
      []
    ),
    .marklinConsecutiveAddresses
    : (
      String(localized:"Additional Addresses%%CV%%"),
      String(localized:"Additional addresses."),
      String(localized:" [CV49.7, CV49.3]"),
      .locomotiveAddress,
      .comboBox,
      []
    ),
    .locomotiveAddressWarning
    : (
      String(localized:""),
      String(localized:""),
      String(localized:""),
      .locomotiveAddress,
      .warning,
      []
    ),
    .enableDCCConsistAddress
    : (
      String(localized:"Enable DCC Consist Address%%CV%%"),
      String(localized:"Enable DCC consist address."),
      String(localized:" [CV19.6:0]"),
      .dccConsistAddress,
      .checkBox,
      []
    ),
    .consistAddress
    : (
      String(localized:"Address for Consist Operation%%CV%%"),
      String(localized:"Address for consist operation."),
      String(localized:" [CV19.6:0]"),
      .dccConsistAddress,
      .textField,
      []
    ),
    .consistReverseDirection
    : (
      String(localized:"Reverse Direction%%CV%%"),
      String(localized:"Reverse direction."),
      String(localized:" [CV19.7]"),
      .dccConsistAddress,
      .checkBox,
      []
    ),
    .enableACAnalogMode
    : (
      String(localized:"Enable AC Analog Mode%%CV%%"),
      String(localized:"Enable AC analog mode."),
      String(localized:" [CV29.2, CV50.0]"),
      .acAnalogMode,
      .checkBox,
      []
    ),
    .acAnalogModeStartVoltage
    : (
      String(localized:"Start Voltage (minimum speed)%%CV%%"),
      String(localized:"Start voltage (minimum speed)."),
      String(localized:" [CV127]"),
      .acAnalogMode,
      .textFieldWithInfo,
      []
    ),
    .acAnalogModeMaximumSpeedVoltage
    : (
      String(localized:"Maximum Speed Voltage%%CV%%"),
      String(localized:"Maximum speed voltage."),
      String(localized:" [CV128]"),
      .acAnalogMode,
      .textFieldWithInfo,
      []
    ),
    .enableDCAnalogMode
    : (
      String(localized:"Enable DC Analog Mode%%CV%%"),
      String(localized:"Enable DC analog mode."),
      String(localized:" [CV29.2, CV50.1]"),
      .dcAnalogMode,
      .checkBox,
      []
    ),
    .dcAnalogModeStartVoltage
    : (
      String(localized:"Start Voltage (minimum speed)%%CV%%"),
      String(localized:"Start voltage (minimum speed)."),
      String(localized:" [CV125]"),
      .dcAnalogMode,
      .textFieldWithInfo,
      []
    ),
    .dcAnalogModeMaximumSpeedVoltage
    : (
      String(localized:"Maximum Speed Voltage%%CV%%"),
      String(localized:"Maximum speed voltage."),
      String(localized:" [CV126]"),
      .dcAnalogMode,
      .textFieldWithInfo,
      []
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
        initComboBox(property: field.property, comboBox: comboBox)
        
      case .warning:
        let image = NSImageView(image: MyIcon.warning.image!)
  //      image.contentTintColor = .yellow
        field.customView = image
        field.control = NSTextField(labelWithString: "")
      case .label, .description:
        let textField = NSTextField(labelWithString: "")
        field.control = textField
      case .textField:
        let textField = NSTextField()
        field.control = textField
      case .textFieldWithInfo:
        let textField = NSTextField()
        field.control = textField
        var info = NSTextField(labelWithString: "")
        info.fontSize = textFontSize
        info.backgroundColor = .brown
        field.customView = info
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
      
      if let customView = field.customView {
        customView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customView)
      }
      
      view.addSubview(field.control!)
      //      view.backgroundColor = NSColor.yellow.cgColor
      
      field.view = view
      field.view!.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 500), for: .horizontal)
      
      result.append(field)
      
    }
    
    return result
    
  }

  // MARK: Private Class Methods
  
  private static func initComboBox(property:ProgrammerToolSettingsProperty, comboBox:MyComboBox) {
    
    switch property {
    case .locomotiveAddressType:
      LocomotiveAddressType.populate(comboBox: comboBox)
    case .marklinConsecutiveAddresses:
      MarklinConsecutiveAddresses.populate(comboBox: comboBox)
    default:
      break
    }
    
  }
  
}
