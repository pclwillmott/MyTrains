//
//  ProgrammerToolInspectorProperty.swift
//  MyTrains
//
//  Created by Paul Willmott on 07/07/2024.
//

import Foundation
import AppKit

public enum ProgrammerToolInspectorProperty : Int, CaseIterable {
  
  // MARK: Enumeration
  
  // Decoder Information
  
  case projectName = 1
  case manufacturer = 2
  case model = 3
  case esuflash = 4
  case manufacturerId = 5
  case esuProductId = 6
  case esuSerialNumber = 7
  case esuSoundLock = 8
  case esuFirmwareVersion = 9
  case esuFirmwareType = 10
  case esuBootcodeVersion = 11
  case esuProductionInfo = 12
  case esuProductionDate = 13
  case cv7 = 14
  case cv8 = 15
  case esuDecoderOperatingTime = 16
  case esuSmokeUnitOperatingTime = 17
  
  // Read and Write CVs
  
  case programmingMode = 18
  case decoderType = 19
  case decoderAddress = 20
  case cv = 21
  case value = 22
  case bits = 23
  case useIndexCVs = 24
  case cv31 = 25
  case cv32 = 26
  
  // Quick Help

  /// This will cause a runtime error if the lookup is not defined - this is the intent!
  public var label : String {

    guard let appNode else {
      return ""
    }
    var result = ProgrammerToolInspectorProperty.labels[self]!.labelTitle
    result = result.replacingOccurrences(of: "%%UNITS_ACTUAL_LENGTH%%", with: appNode.unitsActualLength.symbol)
    result = result.replacingOccurrences(of: "%%UNITS_SCALE_LENGTH%%", with: appNode.unitsScaleLength.symbol)
    result = result.replacingOccurrences(of: "%%UNITS_ACTUAL_DISTANCE%%", with: appNode.unitsActualDistance.symbol)
    result = result.replacingOccurrences(of: "%%UNITS_SCALE_DISTANCE%%", with: appNode.unitsScaleDistance.symbol)
    result = result.replacingOccurrences(of: "%%UNITS_ACTUAL_SPEED%%", with: appNode.unitsActualSpeed.symbol)
    result = result.replacingOccurrences(of: "%%UNITS_SCALE_SPEED%%", with: appNode.unitsScaleSpeed.symbol)
    result = result.replacingOccurrences(of: "%%UNITS_TIME%%", with: appNode.unitsTime.symbol)
    return result
  }
  
  /// This will cause a runtime error if the lookup is not defined - this is the intent!
  public var toolTip : String {
    return ProgrammerToolInspectorProperty.labels[self]!.toolTip
  }

  /// This will cause a runtime error if the lookup is not defined - this is the intent!
  public var inspector : ProgrammerToolInspector {
    return ProgrammerToolInspectorProperty.labels[self]!.inspector
  }

  /// This will cause a runtime error if the lookup is not defined - this is the intent!
  public var controlType : InspectorControlType {
    return ProgrammerToolInspectorProperty.labels[self]!.controlType
  }
  
  public var requiredCapabilities : Set<DecoderCapability> {
    return ProgrammerToolInspectorProperty.labels[self]?.requiredCapabilities ?? []
  }


  // MARK: Private Class Properties
  
  private static let labels : [ProgrammerToolInspectorProperty:(labelTitle:String, toolTip:String, inspector:ProgrammerToolInspector, controlType:InspectorControlType, requiredCapabilities:Set<DecoderCapability>)] = [
    .projectName
    : (
      String(localized:"Project Name", comment:"This is used for the title of a text field."),
      String(localized:"The name of this decoder project.", comment:"This is used for a tooltip."),
      .identity,
      .textField,
      []
    ),
    .manufacturer
    : (
      String(localized:"Manufacturer"),
      String(localized:"The manufacturer of this decoder.", comment:"This is used for a tooltip."),
      .identity,
      .label,
      []
    ),
    .model
    : (
      String(localized:"Model"),
      String(localized:"The model of this decoder.", comment:"This is used for a tooltip."),
      .identity,
      .label,
      []
    ),
    .esuflash
    : (
      String(localized:"Flash"),
      String(localized:"", comment:"This is used for a tooltip."),
      .identity,
      .label,
      []
    ),
    .manufacturerId
    : (
      String(localized:"Manufacturer ID"),
      String(localized:"The NMRA ID for the manufacturer of this decoder.", comment:"This is used for a tooltip."),
      .identity,
      .label,
      []
    ),
    .esuProductId
    : (
      String(localized:"Product ID"),
      String(localized:"The product ID.", comment:"This is used for a tooltip."),
      .identity,
      .label,
      []
    ),
    .esuSerialNumber
    : (
      String(localized:"Serial Number"),
      String(localized:"The serial number of this decoder.", comment:"This is used for a tooltip."),
      .identity,
      .label,
      []
    ),
    .esuSoundLock
    : (
      String(localized:"Sound Lock"),
      String(localized:"", comment:"This is used for a tooltip."),
      .identity,
      .label,
      []
    ),
    .esuFirmwareVersion
    : (
      String(localized:"Firmware Version"),
      String(localized:"The firmware version of this decoder.", comment:"This is used for a tooltip."),
      .identity,
      .label,
      []
    ),
    .esuFirmwareType
    : (
      String(localized:"Firmware Type"),
      String(localized:"The firmware type of this decoder.", comment:"This is used for a tooltip."),
      .identity,
      .label,
      []
    ),
    .esuBootcodeVersion
    : (
      String(localized:"Bootcode Version"),
      String(localized:"The bootcode version of this decoder.", comment:"This is used for a tooltip."),
      .identity,
      .label,
      []
    ),
    .esuProductionInfo
    : (
      String(localized:"Production Info"),
      String(localized:"", comment:"This is used for a tooltip."),
      .identity,
      .label,
      []
    ),
    .esuProductionDate
    : (
      String(localized:"Production Date"),
      String(localized:"The production date of this decoder.", comment:"This is used for a tooltip."),
      .identity,
      .label,
      []
    ),
    .cv7
    : (
      String(localized:"CV7"),
      String(localized:"CV7 setting.", comment:"This is used for a tooltip."),
      .identity,
      .label,
      []
    ),
    .cv8
    : (
      String(localized:"CV8"),
      String(localized:"CV8 Ssetting.", comment:"This is used for a tooltip."),
      .identity,
      .label,
      []
    ),
    .esuDecoderOperatingTime
    : (
      String(localized:"Decoder Operating Time"),
      String(localized:"The operating time of this decoder.", comment:"This is used for a tooltip."),
      .identity,
      .label,
      []
    ),
    .esuSmokeUnitOperatingTime
    : (
      String(localized:"Smoke Unit Operating Time"),
      String(localized:"The operating time of the smoke unit.", comment:"This is used for a tooltip."),
      .identity,
      .label,
      []
    ),
    .programmingMode
    : (
      String(localized:"Programming Track"),
      String(localized:"Programming track.", comment:"This is used for a tooltip."),
      .rwCVs,
      .comboBox,
      []
    ),
    .decoderType
    : (
      String(localized:"Decoder Type"),
      String(localized:"Decoder type.", comment:"This is used for a tooltip."),
      .rwCVs,
      .comboBox,
      []
    ),
    .decoderAddress
    : (
      String(localized:"Decoder Address"),
      String(localized:"Decoder address.", comment:"This is used for a tooltip."),
      .rwCVs,
      .textField,
      []
    ),
    .cv
    : (
      String(localized:"CV"),
      String(localized:"The number of the CV that you wish to change.", comment:"This is used for a tooltip."),
      .rwCVs,
      .readCV,
      []
    ),
    .value
    : (
      String(localized:"Value"),
      String(localized:"The value of the CV in decimal.", comment:"This is used for a tooltip."),
      .rwCVs,
      .writeCV,
      []
    ),
    .bits
    : (
      String(localized:"Bit [7..0]"),
      String(localized:"The value of the CV in binary.", comment:"This is used for a tooltip."),
      .rwCVs,
      .bits8,
      []
    ),
    .useIndexCVs
    : (
      String(localized:"Use Index CVs (CV31, CV32)"),
      String(localized:"Check this box to use index CVs.", comment:"This is used for a tooltip."),
      .rwCVs,
      .checkBox,
      []
    ),
    .cv31
    : (
      String(localized:"CV31"),
      String(localized:"The value of CV31 in decimal.", comment:"This is used for a tooltip."),
      .rwCVs,
      .textField,
      []
    ),
    .cv32
    : (
      String(localized:"CV32"),
      String(localized:"The value of CV32 in decimal.", comment:"This is used for a tooltip."),
      .rwCVs,
      .textField,
      []
    ),
  ]
  
  // MARK: Public Class Properties
  
  public static var inspectorPropertyFields: [ProgrammerToolInspectorPropertyField] {
    
    var result : [ProgrammerToolInspectorPropertyField] = []
    
    let labelFontSize : CGFloat = 10.0
    let textFontSize  : CGFloat = 11.0
    
    for item in ProgrammerToolInspectorProperty.allCases {
      
      var field : ProgrammerToolInspectorPropertyField = (view:nil, label:nil, control:nil, item, readButton:nil, writeButton:nil, bits:nil)
      
      field.label = NSTextField(labelWithString: item.label)
      
      let view = NSView()
      
      view.translatesAutoresizingMaskIntoConstraints = false
      
      switch item.controlType {
      case .checkBox:
        field.label!.stringValue = ""
        let checkBox = NSButton()
        checkBox.setButtonType(.switch)
        checkBox.title = item.label
        field.control = checkBox
      case .comboBox:
        let comboBox = MyComboBox()
        comboBox.isEditable = false
        field.control = comboBox
  //      initComboBox(property: field.property, comboBox: comboBox)
      case .writeCV:
        let textField = NSTextField()
        field.control = textField
        let writeButton = NSButton()
        writeButton.title = String(localized: "Write")
 //       writeButton.fontSize = labelFontSize
        writeButton.translatesAutoresizingMaskIntoConstraints = false
        writeButton.tag = item.rawValue
        view.addSubview(writeButton)
        field.writeButton = writeButton
        
      case .readCV:
        let textField = NSTextField()
        field.control = textField
        let readButton = NSButton()
        readButton.title = String(localized: "Read")
  //      readButton.fontSize = labelFontSize
        readButton.translatesAutoresizingMaskIntoConstraints = false
        readButton.tag = item.rawValue
        view.addSubview(readButton)
        field.writeButton = readButton

      case .label:
        let textField = NSTextField(labelWithString: "")
        field.control = textField
      case .textField:
        let textField = NSTextField()
        field.control = textField
      case .panelView:
        break
      case .bits8:
        var bits : [NSButton] = []
        for bit in 0 ... 7 {
          let checkBox = NSButton()
          checkBox.translatesAutoresizingMaskIntoConstraints = false
          bits.append(checkBox)
          checkBox.setButtonType(.switch)
          checkBox.title = ""
          view.addSubview(checkBox)
        }
        field.bits = bits
      case .eventId:
        break
      }
      
      field.control?.toolTip = item.toolTip
      field.control?.tag = item.rawValue
      
      /// https://manasaprema04.medium.com/autolayout-fundamental-522f0a6e5790
      
      field.label!.translatesAutoresizingMaskIntoConstraints = false
 //     field.label!.fontSize = labelFontSize
      field.label!.alignment = .right
      field.label!.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 250), for: .horizontal)
      //     field.label!.lineBreakMode = .byWordWrapping
      //     field.label!.maximumNumberOfLines = 0
      //     field.label!.preferredMaxLayoutWidth = 120.0
      
      view.addSubview(field.label!)
      
      field.control?.translatesAutoresizingMaskIntoConstraints = false
 //     field.control?.fontSize = textFontSize
      field.control?.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 1), for: .horizontal)
      
      if let control = field.control {
        view.addSubview(control)
        //      view.backgroundColor = NSColor.yellow.cgColor
      }
      field.view = view
      field.view!.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 500), for: .horizontal)

      result.append(field)
      
    }
    
    return result
    
  }

}
