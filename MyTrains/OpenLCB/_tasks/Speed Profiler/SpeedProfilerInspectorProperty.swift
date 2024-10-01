//
//  SpeedProfilerInspectorProperty.swift
//  MyTrains
//
//  Created by Paul Willmott on 17/06/2024.
//

import Foundation
import AppKit
import SGAppKit

public enum SpeedProfilerInspectorProperty : Int, CaseIterable {
  
  // MARK: Enumeration
  
  // Identity
  
  case locomotiveId = 1    //
  case locomotiveName = 2 //
  
  // Locomotive Control
  
  case trackProtocol = 3   //
  case locomotiveControlBasis = 4 //
  case locomotiveFacingDirection = 5 //
  case maximumSpeed = 24 //
  case maximumSpeedLabel = 25

  // Sampling

  case profilerMode = 30
  case commandedSampleNumber = 31
  case locomotiveTravelDirectionToSample = 6 //
  case numberOfSamples = 7 //
  case numberOfSamplesLabel = 8 //
  case minimumSamplePeriod = 9 //
  case startSampleNumber = 10 //
  case stopSampleNumber = 11 //
  case useLightSensors = 12 //
  case useReedSwitches = 13 //
  case useRFIDReaders = 14 //
  case useOccupancyDetectors = 15 //

  // Analysis

  case directionToChart = 27
  case bestFitMethod = 16 //
  case showTrendline = 17 //
  case showSamples = 26
  case colourForward = 28
  case colourReverse = 29

  // Route
  
  case routeType = 18       //
  case startBlockId = 19   //
  case endBlockId = 20     //
  case route = 21            //
  case totalRouteLength = 23 //
  case routeSegments = 22

  // MARK: Public Properties
  
  /// This will cause a runtime error if the lookup is not defined - this is the intent!
  public var label : String {

    guard let appNode else {
      return ""
    }
    var result = SpeedProfilerInspectorProperty.labels[self]!.labelTitle
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
    return SpeedProfilerInspectorProperty.labels[self]!.toolTip
  }

  /// This will cause a runtime error if the lookup is not defined - this is the intent!
  public var group : SpeedProfilerInspectorGroup {
    return SpeedProfilerInspectorProperty.labels[self]!.group
  }

  /// This will cause a runtime error if the lookup is not defined - this is the intent!
  public var inspector : SpeedProfilerInspector {
    return SpeedProfilerInspectorProperty.labels[self]!.group.inspector
  }

  /// This will cause a runtime error if the lookup is not defined - this is the intent!
  public var controlType : InspectorControlType {
    return SpeedProfilerInspectorProperty.labels[self]!.controlType
  }
  
  // MARK: Public Methods
  
  // MARK: Private Class Properties
  
  private static let labels : [SpeedProfilerInspectorProperty:(labelTitle:String, toolTip:String, group:SpeedProfilerInspectorGroup, controlType:InspectorControlType)] = [
    .locomotiveId
    : (
      String(localized:"Locomotive ID", comment:"This is used for the title of label which displays the locomotive's node Id."),
      String(localized:"Locomotive's node ID.", comment:"This is used for a tooltip."),
      .identity,
      .label
    ),
    .locomotiveName
    : (
      String(localized:"Locomotive Name", comment:"This is used for the title of label which displays the locomotive's name."),
      String(localized:"Locomotive's name.", comment:"This is used for a tooltip."),
      .identity,
      .label
    ),
    .trackProtocol
    : (
      String(localized:"Track Protocol", comment:"This is used for the title of combobox."),
      String(localized:"Track Protocol.", comment:"This is used for a tooltip."),
      .locomotiveControl,
      .comboBox
    ),
    .locomotiveControlBasis
    : (
      String(localized:"Control Basis", comment:"This is used for the title of combobox."),
      String(localized:"This determines how MyTrains controls this locomotive in automatic mode.", comment:"This is used for a tooltip."),
      .locomotiveControl,
      .comboBox
    ),
    .locomotiveFacingDirection
    : (
      String(localized:"Facing Direction", comment:"This is used for the title of combobox."),
      String(localized:"This is the track direction that the front of the locomotive is facing.", comment:"This is used for a tooltip."),
      .locomotiveControl,
      .comboBox
    ),
    .maximumSpeed
    : (
      String(localized:"Maximum Speed (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of a text field."),
      String(localized:"The maximum speed that the locomotive can be commanded to travel at.", comment:"This is used for a tooltip."),
      .locomotiveControl,
      .textField
    ),
    .maximumSpeedLabel
    : (
      String(localized:"Maximum Speed (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of a label."),
      String(localized:"The maximum speed that the locomotive can be commanded to travel at.", comment:"This is used for a tooltip."),
      .locomotiveControl,
      .label
    ),
    .locomotiveTravelDirectionToSample
    : (
      String(localized:"Direction to profile", comment:"This is used for the title of a combobox."),
      String(localized:"Train direction or directions to profile.", comment:"This is used for a tooltip."),
      .sampling,
      .comboBox
    ),
    .numberOfSamples
    : (
      String(localized:"Number of Samples", comment:"This is used for the title of text field."),
      String(localized:"Number of sampling points.", comment:"This is used for a tooltip."),
      .sampling,
      .textField
    ),
    .numberOfSamplesLabel
    : (
      String(localized:"Number of Samples", comment:"This is used for the title of a label."),
      String(localized:"Number of sampling points.", comment:"This is used for a tooltip."),
      .sampling,
      .label
    ),
    .minimumSamplePeriod
    : (
      String(localized:"Minimum Sample Period", comment:"This is used for the title of combobox."),
      String(localized:"Minimum period to profile one speed step.", comment:"This is used for a tooltip."),
      .sampling,
      .comboBox
    ),
    .profilerMode
    : (
      String(localized:"Profiler Mode", comment:"This is used for the title of combobox."),
      String(localized:"Determines the speed profiler mode of operation.", comment:"This is used for a tooltip."),
      .sampling,
      .comboBox
    ),
    .commandedSampleNumber
    : (
      String(localized:"Commanded Speed (%%UNITS_SCALE_SPEED%%)", comment:"This is used for the title of combobox."),
      String(localized:"The speed to command the locomotive to run at.", comment:"This is used for a tooltip."),
      .sampling,
      .comboBox
    ),
    .startSampleNumber
    : (
      String(localized:"Start Sample Number", comment:"This is used for the title of a text field."),
      String(localized:"Number of the sample to start profiling at.", comment:"This is used for a tooltip."),
      .sampling,
      .textField
    ),
    .stopSampleNumber
    : (
      String(localized:"Stop Sample Number", comment:"This is used for the title of a text field."),
      String(localized:"Number of the sample to stop profiling at.", comment:"This is used for a tooltip."),
      .sampling,
      .textField
    ),
    .useLightSensors
    : (
      String(localized:"Use Light Sensors", comment:"This is used for the title of a check box."),
      String(localized:"Use light sensors for profiling.", comment:"This is used for a tooltip."),
      .sampling,
      .checkBox
    ),
    .useReedSwitches
    : (
      String(localized:"Use Reed Switches", comment:"This is used for the title of a check box."),
      String(localized:"Use reed switches for profiling.", comment:"This is used for a tooltip."),
      .sampling,
      .checkBox
    ),
    .useRFIDReaders
    : (
      String(localized:"Use RFID Readers", comment:"This is used for the title of a check box."),
      String(localized:"Use RFID readers for profiling.", comment:"This is used for a tooltip."),
      .sampling,
      .checkBox
    ),
    .useOccupancyDetectors
    : (
      String(localized:"Use Occupancy Detectors", comment:"This is used for the title of a check box."),
      String(localized:"Use occupancy detectors for profiling.", comment:"This is used for a tooltip."),
      .sampling,
      .checkBox
    ),
    .bestFitMethod
    : (
      String(localized:"Best Fit Method", comment:"This is used for the title of a combobox."),
      String(localized:"Curve fit methodology.", comment:"This is used for a tooltip."),
      .analysis,
      .comboBox
    ),
    .directionToChart
    : (
      String(localized:"Direction to Chart", comment:"This is used for the title of a combobox."),
      String(localized:"The locomotive direction or directions to plot on the chart.", comment:"This is used for a tooltip."),
      .analysis,
      .comboBox
    ),
    .showTrendline
    : (
      String(localized:"Show Trendline", comment:"This is used for the title of a check box."),
      String(localized:"Show trendline on chart.", comment:"This is used for a tooltip."),
      .analysis,
      .checkBox
    ),
    .showSamples
    : (
      String(localized:"Show Samples", comment:"This is used for the title of a check box."),
      String(localized:"Show samples on chart.", comment:"This is used for a tooltip."),
      .analysis,
      .checkBox
    ),
    .colourForward
    : (
      String(localized:"Forward Color", comment:"This is used for the title of a check box."),
      String(localized:"Color of the forward samples and trendline.", comment:"This is used for a tooltip."),
      .analysis,
      .comboBox
    ),
    .colourReverse
    : (
      String(localized:"Reverse Color", comment:"This is used for the title of a check box."),
      String(localized:"Color of the reverse samples and trendline.", comment:"This is used for a tooltip."),
      .analysis,
      .comboBox
    ),
    .routeType
    : (
      String(localized:"Route Type", comment:"This is used for the title of a combobox."),
      String(localized:"Route Type.", comment:"This is used for a tooltip."),
      .route,
      .comboBox
    ),
    .startBlockId
    : (
      String(localized:"Start Block", comment:"This is used for the title of a combobox."),
      String(localized:"Select the starting block for the route.", comment:"This is used for a tooltip."),
      .route,
      .comboBox
    ),
    .endBlockId
    : (
      String(localized:"End Block", comment:"This is used for the title of a combobox."),
      String(localized:"Select the end block for the route.", comment:"This is used for a tooltip."),
      .route,
      .comboBox
    ),
    .route
    : (
      String(localized:"Route", comment:"This is used for the title of a combobox."),
      String(localized:"Select the required route.", comment:"This is used for a tooltip."),
      .route,
      .comboBox
    ),
    .totalRouteLength
    : (
      String(localized:"Route Length (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of a label."),
      String(localized:"This is the total length of the selected route.", comment:"This is used for a tooltip."),
      .route,
      .label
    ),
    .routeSegments
    : (
      String(localized:"Route Length (%%UNITS_ACTUAL_LENGTH%%)", comment:"This is used for the title of a label."),
      String(localized:"This is the total length of the selected route.", comment:"This is used for a tooltip."),
      .route,
      .panelView
    ),
  ]
  
  // MARK: Public Class Properties
  
  public static var inspectorPropertyFields: [SpeedProfilerInspectorPropertyField] {
    
    var result : [SpeedProfilerInspectorPropertyField] = []
    
    let labelFontSize : CGFloat = 10.0
    let textFontSize  : CGFloat = 11.0
    
    for item in SpeedProfilerInspectorProperty.allCases {
      
      var field : SpeedProfilerInspectorPropertyField = (view:nil, label:nil, control:nil, item, new:nil, copy:nil, paste:nil)
      
      if item.controlType == .panelView {
        
        let view = NSStackView()
        view.orientation = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        
        field.view = view
        
        result.append(field)
        
        for (_, item) in appNode!.panelList {
          if item.switchboardItems!.count > 0 {
            let panel = SwitchboardSpeedProfilerView()
            panel.translatesAutoresizingMaskIntoConstraints = false
            panel.switchboardPanel = item
            view.addArrangedSubview(panel)
          }
        }
        
      }
      else {
        
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
          let comboBox = SGComboBox()
          comboBox.isEditable = false
          field.control = comboBox
          initComboBox(property: field.property, comboBox: comboBox)
        case .eventId:
          let textField = NSTextField()
          textField.placeholderString = "00.00.00.00.00.00.00.00"
          field.control = textField
          let newButton = NSButton()
          newButton.title = String(localized: "New")
          newButton.fontSize = labelFontSize
          newButton.translatesAutoresizingMaskIntoConstraints = false
          newButton.tag = item.rawValue
          view.addSubview(newButton)
          field.new = newButton
          let copyButton = NSButton()
          copyButton.title = String(localized: "Copy")
          copyButton.fontSize = labelFontSize
          copyButton.translatesAutoresizingMaskIntoConstraints = false
          copyButton.tag = item.rawValue
          
          view.addSubview(copyButton)
          field.copy = copyButton
          let pasteButton = NSButton()
          pasteButton.title = String(localized: "Paste")
          pasteButton.fontSize = labelFontSize
          pasteButton.translatesAutoresizingMaskIntoConstraints = false
          pasteButton.tag = item.rawValue
          view.addSubview(pasteButton)
          field.paste = pasteButton
          
        case .label:
          let textField = NSTextField(labelWithString: "")
          field.control = textField
        case .textField:
          let textField = NSTextField()
          field.control = textField
        case .panelView:
          break
        case .readCV:
          break
        case .writeCV:
          break
        case .bits8:
          break
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
        
      }
      
      result.append(field)
      
    }
    
    return result
    
  }

  // MARK: Private Class Methods
  
  private static func initComboBox(property:SpeedProfilerInspectorProperty, comboBox:SGComboBox) {
    
    switch property {
    case trackProtocol:
      TrackProtocol.populate(comboBox: comboBox)
    case locomotiveControlBasis:
      LocomotiveControlBasis.populate(comboBox: comboBox)
    case locomotiveFacingDirection:
      RouteDirection.populate(comboBox: comboBox)
    case locomotiveTravelDirectionToSample, directionToChart:
      SamplingDirection.populate(comboBox: comboBox)
    case minimumSamplePeriod:
      SamplePeriod.populate(comboBox: comboBox)
    case bestFitMethod:
      BestFitMethod.populate(comboBox: comboBox)
    case routeType:
      SamplingRouteType.populate(comboBox: comboBox)
    case startBlockId:
      appNode?.populateSpeedProfilerBlocks(comboBox: comboBox)
    case endBlockId:
      appNode?.populateSpeedProfilerBlocks(comboBox: comboBox)
    case colourForward, colourReverse:
      Colour.populate(comboBox: comboBox)
    case profilerMode:
      SpeedProfilerMode.populate(comboBox: comboBox)
    default:
      break
    }
  }

}
