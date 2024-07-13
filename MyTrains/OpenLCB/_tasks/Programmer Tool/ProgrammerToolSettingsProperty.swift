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
  case enableQuantumEngineer = 16
  case ignoreAccelerationDecelerationInSoundSchedule = 17
  case useHighFrequencyPWMMotorControl = 18
  case analogVoltageHysteresisDescription = 19
  case analogMotorHysteresisVoltage = 20
  case analogFunctionDifferenceVoltage = 21

  // Brake Settings
  
  case enableABCBrakeMode = 22
  case brakeIfRightRailSignalPositive = 23
  case brakeIfLeftRailSignalPositive = 24
  case voltageDifferenceIndicatingABCBrakeSection = 25
  case abcReducedSpeed = 26
  case enableABCShuttleTrain = 27
  case waitingPeriodBeforeDirectionChange = 28
  case hluAllowZIMO = 29
  case hluSendZIMOZACKSignals = 30
  case hluSpeedLimit1 = 31
  case hluSpeedLimit2 = 32
  case hluSpeedLimit3 = 33
  case hluSpeedLimit4 = 34
  case hluSpeedLimit5 = 35
  case brakeOnForwardPolarity = 36
  case brakeOnReversePolarity = 37
  case selectrixBrakeOnForwardPolarity = 52
  case selectrixBrakeOnReversePolarity = 53
  case enableConstantBrakeDistance = 38
  case brakeDistanceLength = 39
  case differentBrakeDistanceBackwards = 40
  case brakeDistanceLengthBackwards = 41
  case driveUntilLocomotiveStopsInSpecifiedPeriod = 42
  case stoppingPeriod = 43
  case constantBrakeDistanceOnSpeedStep0 = 44
  case delayTimeBeforeExitingBrakeSection = 45
  case brakeFunction1BrakeTimeReduction = 46
  case maximumSpeedWhenBrakeFunction1Active = 47
  case brakeFunction2BrakeTimeReduction = 48
  case maximumSpeedWhenBrakeFunction2Active = 49
  case brakeFunction3BrakeTimeReduction = 50
  case maximumSpeedWhenBrakeFunction3Active = 51

  // DCC Settings
  
  case enableRailComFeedback = 54
  case enableRailComPlusAutomaticAnnouncement = 55
  case sendFollowingToCommandStation = 56
  case sendAddressViaBroadcastOnChannel1 = 57
  case allowDataTransmissionOnChannel2 = 58
  case detectSpeedStepModeAutomatically = 59
  case speedStepMode = 60
  
  // Identification
  
  case userId1 = 61
  case userId2 = 62
  
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
    .enableQuantumEngineer
    : (
      String(localized:"Enable Quantum Engineer Support%%CV%%"),
      String(localized:"Enable quantum engineer support."),
      String(localized:" [CV50.2]"),
      .quantumEngineer,
      .checkBox,
      []
    ),
    .ignoreAccelerationDecelerationInSoundSchedule
    : (
      String(localized:"Ignore Acceleration and Deceleration in the Sound Schedule%%CV%%"),
      String(localized:"Ignore acceleration and deceleration in the sound schedule."),
      String(localized:" [CV122.5]"),
      .soundControlBehaviour,
      .checkBox,
      []
    ),
    .useHighFrequencyPWMMotorControl
    : (
      String(localized:"High Frequency PWM Motor Control%%CV%%"),
      String(localized:"Use high frequency PWM motor control."),
      String(localized:" [CV122.6]"),
      .analogModeMotorControl,
      .checkBox,
      []
    ),
    .analogVoltageHysteresisDescription
    : (
      String(localized:""),
      String(localized:""),
      String(localized:""),
      .analogVoltageHysteresis,
      .description,
      []
    ),
    .analogMotorHysteresisVoltage
    : (
      String(localized:"Motor Hysteresis Voltage%%CV%%"),
      String(localized:"Motor hysteresis Voltage."),
      String(localized:" [CV130]"),
      .analogVoltageHysteresis,
      .textFieldWithInfo,
      []
    ),
    .analogFunctionDifferenceVoltage
    : (
      String(localized:"Function Difference Voltage%%CV%%"),
      String(localized:"Function difference voltage."),
      String(localized:" [CV129]"),
      .analogVoltageHysteresis,
      .textFieldWithInfo,
      []
    ),
    .enableABCBrakeMode
    : (
      String(localized:""),
      String(localized:""),
      String(localized:""),
      .abcBrakeSections,
      .description,
      []
    ),
    .brakeIfRightRailSignalPositive
    : (
      String(localized:"Brake if right rail signal in driving direction is more positive than the left rail%%CV%%"),
      String(localized:"Brake if right rail signal in driving direction is more positive than the left rail."),
      String(localized:" [CV27.0]"),
      .abcBrakeSections,
      .checkBox,
      []
    ),
    .brakeIfLeftRailSignalPositive
    : (
      String(localized:"Brake if left rail signal in driving direction is more positive than the right rail%%CV%%"),
      String(localized:"Brake if left rail signal in driving direction is more positive than the right rail."),
      String(localized:" [CV27.1]"),
      .abcBrakeSections,
      .checkBox,
      []
    ),
    .voltageDifferenceIndicatingABCBrakeSection
    : (
      String(localized:"Voltage difference indicating an ABC brake section%%CV%%"),
      String(localized:"Voltage difference indicating an ABC brake section."),
      String(localized:" [CV134]"),
      .abcBrakeSections,
      .textField,
      []
    ),
    .abcReducedSpeed
    : (
      String(localized:"ABC Reduced Speed%%CV%%"),
      String(localized:"ABC Reduced Speed."),
      String(localized:" [CV123]"),
      .abcBrakeSections,
      .textField,
      []
    ),
    .enableABCShuttleTrain
    : (
      String(localized:"Enable ABC Shuttle Train%%CV%%"),
      String(localized:"Enable ABC shuttle train."),
      String(localized:" [CV149]"),
      .abcBrakeSections,
      .checkBox,
      []
    ),
    .waitingPeriodBeforeDirectionChange
    : (
      String(localized:"Waiting time before direction change%%CV%%"),
      String(localized:"Waiting time before direction change."),
      String(localized:" [CV149]"),
      .abcBrakeSections,
      .textFieldWithInfo,
      []
    ),
    .hluAllowZIMO
    : (
      String(localized:"Allow ZIMO (HLU) Brake Sections%%CV%%"),
      String(localized:"Allow ZIMO (HLU) brake sections."),
      String(localized:" [CV27.2]"),
      .hluSettings,
      .checkBox,
      []
    ),
    .hluSendZIMOZACKSignals
    : (
      String(localized:"Send ZIMO ZACK Signals%%CV%%"),
      String(localized:"Send ZIMO ZACK signals."),
      String(localized:" [CV122.2]"),
      .hluSettings,
      .checkBox,
      []
    ),
    .hluSpeedLimit1
    : (
      String(localized:"HLU Speed Limit 1%%CV%%"),
      String(localized:"HLU speed limit 1."),
      String(localized:" [CV150]"),
      .hluSettings,
      .textField,
      []
    ),
    .hluSpeedLimit2
    : (
      String(localized:"HLU Speed Limit 2 (Ultra Low)%%CV%%"),
      String(localized:"HLU speed limit 2."),
      String(localized:" [CV151]"),
      .hluSettings,
      .textField,
      []
    ),
    .hluSpeedLimit3
    : (
      String(localized:"HLU Speed Limit 3%%CV%%"),
      String(localized:"HLU speed limit 3."),
      String(localized:" [CV152]"),
      .hluSettings,
      .textField,
      []
    ),
    .hluSpeedLimit4
    : (
      String(localized:"HLU Speed Limit 4 (Low Speed)%%CV%%"),
      String(localized:"HLU speed limit 4."),
      String(localized:" [CV153]"),
      .hluSettings,
      .textField,
      []
    ),
    .hluSpeedLimit5
    : (
      String(localized:"HLU Speed Limit 5%%CV%%"),
      String(localized:"HLU speed limit 5."),
      String(localized:" [CV154]"),
      .hluSettings,
      .textField,
      []
    ),
    .brakeOnForwardPolarity
    : (
      String(localized:"Brake on Forward DC Polarity%%CV%%"),
      String(localized:"Brake on forward DC polarity."),
      String(localized:" [CV27.4]"),
      .autoStopInPresenceOfDCPolarity,
      .checkBox,
      []
    ),
    .brakeOnReversePolarity
    : (
      String(localized:"Brake on Reverse DC Polarity%%CV%%"),
      String(localized:"Brake on reverse DC polarity."),
      String(localized:" [CV27.3]"),
      .autoStopInPresenceOfDCPolarity,
      .checkBox,
      []
    ),
    .selectrixBrakeOnForwardPolarity
    : (
      String(localized:"Brake on Forward Polarity of Brake Diode%%CV%%"),
      String(localized:"Brake on forward polarity of brake diode."),
      String(localized:" [CV27.6]"),
      .selectrixBrakeSections,
      .checkBox,
      []
    ),
    .selectrixBrakeOnReversePolarity
    : (
      String(localized:"Brake on Reverse Polarity of Brake Diode%%CV%%"),
      String(localized:"Brake on reverse polarity of brake diode."),
      String(localized:" [CV27.5]"),
      .selectrixBrakeSections,
      .checkBox,
      []
    ),
    .enableConstantBrakeDistance
    : (
      String(localized:"Enable Constant Brake Distance%%CV%%"),
      String(localized:"Enable constant brake distance."),
      String(localized:" [CV254]"),
      .constantBrakeDistance,
      .checkBox,
      []
    ),
    .brakeDistanceLength
    : (
      String(localized:"Brake Distance Length%%CV%%"),
      String(localized:"Brake distance length."),
      String(localized:" [CV254]"),
      .constantBrakeDistance,
      .textField,
      []
    ),
    .differentBrakeDistanceBackwards
    : (
      String(localized:"Different Brake Distance While Driving Backwards%%CV%%"),
      String(localized:"Different brake distance while driving backwards."),
      String(localized:" [CV255]"),
      .constantBrakeDistance,
      .checkBox,
      []
    ),
    .brakeDistanceLengthBackwards
    : (
      String(localized:"Brake Distance Length%%CV%%"),
      String(localized:"Brake distance length."),
      String(localized:" [CV255]"),
      .constantBrakeDistance,
      .textField,
      []
    ),
    .driveUntilLocomotiveStopsInSpecifiedPeriod
    : (
      String(localized:"Drive Until Locomotive Stops in Specified Period%%CV%%"),
      String(localized:"Drive until locomotive stops in specified period."),
      String(localized:" [CV253]"),
      .constantBrakeDistance,
      .checkBox,
      []
    ),
    .stoppingPeriod
    : (
      String(localized:"Stopping Period%%CV%%"),
      String(localized:"Stopping period."),
      String(localized:" [CV253]"),
      .constantBrakeDistance,
      .textFieldWithInfo,
      []
    ),
    .constantBrakeDistanceOnSpeedStep0
    : (
      String(localized:"Constant Brake Distance on Speed Step 0%%CV%%"),
      String(localized:"Constant brake distance on speed step 0."),
      String(localized:" [CV27.7]"),
      .constantBrakeDistance,
      .checkBox,
      []
    ),
    .delayTimeBeforeExitingBrakeSection
    : (
      String(localized:"Delay Time Before Exiting a Brake Section%%CV%%"),
      String(localized:"Delay time before exiting a brake section."),
      String(localized:" [CV102]"),
      .brakeSectionSettings,
      .textFieldWithInfo,
      []
    ),
    .brakeFunction1BrakeTimeReduction
    : (
      String(localized:"Brake Function 1 Reduces Brake Time by%%CV%%"),
      String(localized:"Brake function 1 reduces brake time by."),
      String(localized:" [CV179]"),
      .brakeFunctions,
      .textFieldWithInfo,
      []
    ),
    .maximumSpeedWhenBrakeFunction1Active
    : (
      String(localized:"Maximum Speed when Brake Function 1 is Active%%CV%%"),
      String(localized:"Maximum speed when brake function 1 is active."),
      String(localized:" [CV182]"),
      .brakeFunctions,
      .textField,
      []
    ),
    .brakeFunction2BrakeTimeReduction
    : (
      String(localized:"Brake Function 2 Reduces Brake Time by%%CV%%"),
      String(localized:"Brake function 2 reduces brake time by."),
      String(localized:" [CV180]"),
      .brakeFunctions,
      .textFieldWithInfo,
      []
    ),
    .maximumSpeedWhenBrakeFunction2Active
    : (
      String(localized:"Maximum Speed when Brake Function 2 is Active%%CV%%"),
      String(localized:"Maximum speed when brake function 2 is active."),
      String(localized:" [CV183]"),
      .brakeFunctions,
      .textField,
      []
    ),
    .brakeFunction3BrakeTimeReduction
    : (
      String(localized:"Brake Function 3 Reduces Brake Time by%%CV%%"),
      String(localized:"Brake function 3 reduces brake time by."),
      String(localized:" [CV181]"),
      .brakeFunctions,
      .textFieldWithInfo,
      []
    ),
    .maximumSpeedWhenBrakeFunction3Active
    : (
      String(localized:"Maximum Speed when Brake Function 3 is Active%%CV%%"),
      String(localized:"Maximum speed when brake function 3 is active."),
      String(localized:" [CV184]"),
      .brakeFunctions,
      .textField,
      []
    ),
    .enableRailComFeedback
    : (
      String(localized:"Enable RailCom Feedback%%CV%%"),
      String(localized:"Enable RailCom feedback."),
      String(localized:" [CV29.3]"),
      .railComSettings,
      .checkBox,
      []
    ),
    .enableRailComPlusAutomaticAnnouncement
    : (
      String(localized:"Enable RailComPlus Automatic Announcement%%CV%%"),
      String(localized:"Enable RailComPlus automatic announcement."),
      String(localized:" [CV28.7]"),
      .railComSettings,
      .checkBox,
      []
    ),
    .sendFollowingToCommandStation
    : (
      String(localized:""),
      String(localized:""),
      String(localized:""),
      .railComSettings,
      .description,
      []
    ),
    .sendAddressViaBroadcastOnChannel1
    : (
      String(localized:"Send Address via Broadcast on Channel 1%%CV%%"),
      String(localized:"Send address via broadcast on channel 1."),
      String(localized:" [CV28.0]"),
      .railComSettings,
      .checkBox,
      []
    ),
    .allowDataTransmissionOnChannel2
    : (
      String(localized:"Allow Data Transmission on Channel 2%%CV%%"),
      String(localized:"Allow data transmission on channel 2."),
      String(localized:" [CV28.1]"),
      .railComSettings,
      .checkBox,
      []
    ),
    .detectSpeedStepModeAutomatically
    : (
      String(localized:"Detect Speed Step Mode Automatically%%CV%%"),
      String(localized:"Detect speed step mode automatically."),
      String(localized:" [CV49.4]"),
      .speedStepMode,
      .checkBox,
      []
    ),
    .speedStepMode
    : (
      String(localized:"Speed Step Mode%%CV%%"),
      String(localized:"Speed step mode."),
      String(localized:" [CV29.1]"),
      .speedStepMode,
      .comboBox,
      []
    ),
    .userId1
    : (
      String(localized:"User ID #1%%CV%%"),
      String(localized:"User ID #1."),
      String(localized:" [CV105]"),
      .userIdentification,
      .textField,
      []
    ),
    .userId2
    : (
      String(localized:"User ID #2%%CV%%"),
      String(localized:"User ID #2."),
      String(localized:" [CV106]"),
      .userIdentification,
      .textField,
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
      case .label:
        let textField = NSTextField(labelWithString: "")
        field.control = textField
      case .description:
        let textField = NSTextField(labelWithString: "")
        textField.lineBreakMode = .byWordWrapping
        textField.maximumNumberOfLines = 0
        textField.preferredMaxLayoutWidth = 400.0
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
    case .speedStepMode:
      SpeedStepMode.populate(comboBox: comboBox)
    default:
      break
    }
    
  }
  
}
