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
  
  // Driving Characteristics
  
  case enableAcceleration = 63
  case accelerationRate = 64
  case accelerationAdjustment = 65
  case enableDeceleration = 66
  case decelerationRate = 67
  case decelerationAdjustment = 68
  case reverseMode = 69
  case enableForwardTrim = 70
  case forwardTrim = 71
  case enableReverseTrim = 72
  case reverseTrim = 73
  case enableShuntingModeTrim = 74
  case shuntingModeTrim = 75
  case loadAdjustmentOptionalLoad = 76
  case loadAdjustmentPrimaryLoad = 77
  case enableGearboxBacklashCompensation = 78
  case gearboxBacklashCompensation = 79
  case timeToBridgePowerInterruption = 80
  case preserveDirection = 81
  case enableStartingDelay = 82
  
  // Identification
  
  case userId1 = 61
  case userId2 = 62
  
  // Special Options
  
  case enableDCCProtocol = 83
  case enableMarklinMotorolaProtocol = 84
  case enableSelectrixProtocol = 85
  case enableM4Protocol = 86
  case memoryPersistentFunction = 87
  case memoryPersistentSpeed = 88
  case enableRailComPlusSynchronization = 89
  case m4MasterDecoderManufacturer = 90
  case m4MasterDecoderSerialNumber = 91
  
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
  
  public var minValue : Double {
    switch self {
    case .locomotiveAddressShort, .consistAddress, .waitingPeriodBeforeDirectionChange, .brakeDistanceLength, .brakeDistanceLengthBackwards, .stoppingPeriod, .accelerationRate, .decelerationRate, .forwardTrim, .reverseTrim, .gearboxBacklashCompensation, .shuntingModeTrim:
      return 1
    case .accelerationAdjustment, .decelerationAdjustment:
      return -127
    default:
      return 0
    }
  }
  
  public var maxValue : Double {
    switch self {
    case .maximumSpeedWhenBrakeFunction1Active, .maximumSpeedWhenBrakeFunction2Active, .maximumSpeedWhenBrakeFunction3Active:
      return 126
    case .locomotiveAddressShort, .consistAddress, .accelerationAdjustment, .decelerationAdjustment:
      return 127
    case .shuntingModeTrim:
      return 128
    default:
      return 255
    }
  }
  
  public var cvLabel : String {
    guard let label = ProgrammerToolSettingsProperty.labels[self] else {
      return "error"
    }
    return label.cv
  }
  
  // MARK: Public Methods
  
  public func label(showCV:Bool) -> String {
    guard let label = ProgrammerToolSettingsProperty.labels[self] else {
      return "error"
    }
    return label.labelTitle.replacingOccurrences(of: "%%CV%%", with: "")
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
      .textFieldWithInfoWithSlider,
      []
    ),
    .acAnalogModeMaximumSpeedVoltage
    : (
      String(localized:"Maximum Speed Voltage%%CV%%"),
      String(localized:"Maximum speed voltage."),
      String(localized:" [CV128]"),
      .acAnalogMode,
      .textFieldWithInfoWithSlider,
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
      .textFieldWithInfoWithSlider,
      []
    ),
    .dcAnalogModeMaximumSpeedVoltage
    : (
      String(localized:"Maximum Speed Voltage%%CV%%"),
      String(localized:"Maximum speed voltage."),
      String(localized:" [CV126]"),
      .dcAnalogMode,
      .textFieldWithInfoWithSlider,
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
      .textFieldWithInfoWithSlider,
      []
    ),
    .analogFunctionDifferenceVoltage
    : (
      String(localized:"Function Difference Voltage%%CV%%"),
      String(localized:"Function difference voltage."),
      String(localized:" [CV129]"),
      .analogVoltageHysteresis,
      .textFieldWithInfoWithSlider,
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
      .textFieldWithSlider,
      []
    ),
    .abcReducedSpeed
    : (
      String(localized:"ABC Reduced Speed%%CV%%"),
      String(localized:"ABC Reduced Speed."),
      String(localized:" [CV123]"),
      .abcBrakeSections,
      .textFieldWithSlider,
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
      .textFieldWithInfoWithSlider,
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
      .textFieldWithSlider,
      []
    ),
    .hluSpeedLimit2
    : (
      String(localized:"HLU Speed Limit 2 (Ultra Low)%%CV%%"),
      String(localized:"HLU speed limit 2."),
      String(localized:" [CV151]"),
      .hluSettings,
      .textFieldWithSlider,
      []
    ),
    .hluSpeedLimit3
    : (
      String(localized:"HLU Speed Limit 3%%CV%%"),
      String(localized:"HLU speed limit 3."),
      String(localized:" [CV152]"),
      .hluSettings,
      .textFieldWithSlider,
      []
    ),
    .hluSpeedLimit4
    : (
      String(localized:"HLU Speed Limit 4 (Low Speed)%%CV%%"),
      String(localized:"HLU speed limit 4."),
      String(localized:" [CV153]"),
      .hluSettings,
      .textFieldWithSlider,
      []
    ),
    .hluSpeedLimit5
    : (
      String(localized:"HLU Speed Limit 5%%CV%%"),
      String(localized:"HLU speed limit 5."),
      String(localized:" [CV154]"),
      .hluSettings,
      .textFieldWithSlider,
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
      .textFieldWithSlider,
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
      .textFieldWithSlider,
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
      .textFieldWithInfoWithSlider,
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
      .textFieldWithInfoWithSlider,
      []
    ),
    .brakeFunction1BrakeTimeReduction
    : (
      String(localized:"Brake Function 1 Reduces Brake Time by%%CV%%"),
      String(localized:"Brake function 1 reduces brake time by."),
      String(localized:" [CV179]"),
      .brakeFunctions,
      .textFieldWithInfoWithSlider,
      []
    ),
    .maximumSpeedWhenBrakeFunction1Active
    : (
      String(localized:"Maximum Speed when Brake Function 1 is Active%%CV%%"),
      String(localized:"Maximum speed when brake function 1 is active."),
      String(localized:" [CV182]"),
      .brakeFunctions,
      .textFieldWithSlider,
      []
    ),
    .brakeFunction2BrakeTimeReduction
    : (
      String(localized:"Brake Function 2 Reduces Brake Time by%%CV%%"),
      String(localized:"Brake function 2 reduces brake time by."),
      String(localized:" [CV180]"),
      .brakeFunctions,
      .textFieldWithInfoWithSlider,
      []
    ),
    .maximumSpeedWhenBrakeFunction2Active
    : (
      String(localized:"Maximum Speed when Brake Function 2 is Active%%CV%%"),
      String(localized:"Maximum speed when brake function 2 is active."),
      String(localized:" [CV183]"),
      .brakeFunctions,
      .textFieldWithSlider,
      []
    ),
    .brakeFunction3BrakeTimeReduction
    : (
      String(localized:"Brake Function 3 Reduces Brake Time by%%CV%%"),
      String(localized:"Brake function 3 reduces brake time by."),
      String(localized:" [CV181]"),
      .brakeFunctions,
      .textFieldWithInfoWithSlider,
      []
    ),
    .maximumSpeedWhenBrakeFunction3Active
    : (
      String(localized:"Maximum Speed when Brake Function 3 is Active%%CV%%"),
      String(localized:"Maximum speed when brake function 3 is active."),
      String(localized:" [CV184]"),
      .brakeFunctions,
      .textFieldWithSlider,
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
    .enableAcceleration
    : (
      String(localized:"Enable Acceleration Time%%CV%%"),
      String(localized:"Enable acceleration time."),
      String(localized:" [CV3]"),
      .accelerationAndDeceleration,
      .checkBox,
      []
    ),
    .accelerationRate
    : (
      String(localized:"Time from Stop to Maximum Speed%%CV%%"),
      String(localized:"Time from stop to maximum speed."),
      String(localized:" [CV3]"),
      .accelerationAndDeceleration,
      .textFieldWithInfoWithSlider,
      []
    ),
    .accelerationAdjustment
    : (
      String(localized:"Acceleration Adjustment%%CV%%"),
      String(localized:"Acceleration Adjustment."),
      String(localized:" [CV23]"),
      .accelerationAndDeceleration,
      .textFieldWithInfoWithSlider,
      []
    ),
    .enableDeceleration
    : (
      String(localized:"Enable Deceleration Time%%CV%%"),
      String(localized:"Enable deceleration time."),
      String(localized:" [CV4]"),
      .accelerationAndDeceleration,
      .checkBox,
      []
    ),
    .decelerationRate
    : (
      String(localized:"Time from Maximum Speed to Stop%%CV%%"),
      String(localized:"Time from maximum speed to stop."),
      String(localized:" [CV4]"),
      .accelerationAndDeceleration,
      .textFieldWithInfoWithSlider,
      []
    ),
    .decelerationAdjustment
    : (
      String(localized:"Deceleration Adjustment%%CV%%"),
      String(localized:"Deceleration Adjustment."),
      String(localized:" [CV24]"),
      .accelerationAndDeceleration,
      .textFieldWithInfoWithSlider,
      []
    ),
    .reverseMode
    : (
      String(localized:"Reverse Direction (Forward becomes Reverse)%%CV%%"),
      String(localized:"Reverse direction."),
      String(localized:" [CV29.0]"),
      .reverseMode,
      .checkBox,
      []
    ),
    .enableForwardTrim
    : (
      String(localized:"Enable Forward Trimming%%CV%%"),
      String(localized:"Enable forward trimming."),
      String(localized:" [CV66]"),
      .trimming,
      .checkBox,
      []
    ),
    .forwardTrim
    : (
      String(localized:"Forward Trimming%%CV%%"),
      String(localized:"Forward trimming."),
      String(localized:" [CV66]"),
      .trimming,
      .textFieldWithInfoWithSlider,
      []
    ),
    .enableReverseTrim
    : (
      String(localized:"Enable Reverse Trimming%%CV%%"),
      String(localized:"Enable Reverse trimming."),
      String(localized:" [CV95]"),
      .trimming,
      .checkBox,
      []
    ),
    .reverseTrim
    : (
      String(localized:"Reverse Trimming%%CV%%"),
      String(localized:"Reverse trimming."),
      String(localized:" [CV95]"),
      .trimming,
      .textFieldWithInfoWithSlider,
      []
    ),
    .enableShuntingModeTrim
    : (
      String(localized:"Enable Shunting Mode Trimming%%CV%%"),
      String(localized:"Enable shunting mode trimming."),
      String(localized:" [CV101]"),
      .trimming,
      .checkBox,
      []
    ),
    .shuntingModeTrim
    : (
      String(localized:"Shunting Mode Trimming%%CV%%"),
      String(localized:"Shunting mode trimming."),
      String(localized:" [CV101]"),
      .trimming,
      .textFieldWithInfoWithSlider,
      []
    ),
    .loadAdjustmentOptionalLoad
    : (
      String(localized:"Load Adjustment when \"Optional Load\" is Enabled%%CV%%"),
      String(localized:"Load adjustment when \"Optional Load\" is enabled."),
      String(localized:" [CV103]"),
      .loadAdjustment,
      .textFieldWithInfoWithSlider,
      []
    ),
    .loadAdjustmentPrimaryLoad
    : (
      String(localized:"Load Adjustment when \"Primary Load\" is Enabled%%CV%%"),
      String(localized:"Load adjustment when \"Primary Load\" is enabled."),
      String(localized:" [CV104]"),
      .loadAdjustment,
      .textFieldWithInfoWithSlider,
      []
    ),
    .enableGearboxBacklashCompensation
    : (
      String(localized:"Enable Gearbox Backlash Compensation%%CV%%"),
      String(localized:"Enable gearbox backlash compensation."),
      String(localized:" [CV111]"),
      .gearboxBacklash,
      .checkBox,
      []
    ),
    .gearboxBacklashCompensation
    : (
      String(localized:"Slow motion time until Acceleration Starts%%CV%%"),
      String(localized:"Slow motion time until acceleration starts."),
      String(localized:" [CV111]"),
      .gearboxBacklash,
      .textFieldWithInfoWithSlider,
      []
    ),
    .timeToBridgePowerInterruption
    : (
      String(localized:"Time to Bridge Power Interruption (PowerPack required)%%CV%%"),
      String(localized:"Time to bridge power interruption."),
      String(localized:" [CV113]"),
      .powerPack,
      .textFieldWithInfoWithSlider,
      []
    ),
    .preserveDirection
    : (
      String(localized:"Preserve Direction when changing from Analog to Digital%%CV%%"),
      String(localized:"Preserve direction when changing from analog to digital."),
      String(localized:" [CV124.0]"),
      .preserveDirection,
      .checkBox,
      []
    ),
    .enableStartingDelay
    : (
      String(localized:"Delay Starting if Drive Sound is Enabled%%CV%%"),
      String(localized:"Delay starting if drive sound is enabled."),
      String(localized:" [CV124.2]"),
      .startingDelay,
      .checkBox,
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
    .enableDCCProtocol
    : (
      String(localized:"DCC Protocol%%CV%%"),
      String(localized:"Enable DCC protocol."),
      String(localized:" [CV47.0]"),
      .enabledProtocols,
      .checkBox,
      []
    ),
    .enableMarklinMotorolaProtocol
    : (
      String(localized:"Märklin Motorola Protocol%%CV%%"),
      String(localized:"Enable Märklin Motorola protocol."),
      String(localized:" [CV47.2]"),
      .enabledProtocols,
      .checkBox,
      []
    ),
    .enableSelectrixProtocol
    : (
      String(localized:"Selectrix%%CV%%"),
      String(localized:"Enable Selectrix protocol."),
      String(localized:" [CV47.3]"),
      .enabledProtocols,
      .checkBox,
      []
    ),
    .enableM4Protocol
    : (
      String(localized:"M4 Protocol%%CV%%"),
      String(localized:"Enable M4 protocol."),
      String(localized:" [CV47.1]"),
      .enabledProtocols,
      .checkBox,
      []
    ),
    .memoryPersistentFunction
    : (
      String(localized:"Persistent Function%%CV%%"),
      String(localized:"Enable persistent function."),
      String(localized:" [CV122.0]"),
      .memorySettings,
      .checkBox,
      []
    ),
    .memoryPersistentSpeed
    : (
      String(localized:"Persistent Speed%%CV%%"),
      String(localized:"Enable persistent speed."),
      String(localized:" [CV122.1]"),
      .memorySettings,
      .checkBox,
      []
    ),
    .enableRailComPlusSynchronization
    : (
      String(localized:"This decoder synchronizes RailComPlus / M4 address with a Master decoder%%CV%%"),
      String(localized:"This decoder synchronizes RailComPlus / M4 address with a Master decoder."),
      String(localized:" [CV191]"),
      .railComDecoderSync,
      .checkBox,
      []
    ),
    .m4MasterDecoderManufacturer
    : (
      String(localized:"Decoder Manufacturer%%CV%%"),
      String(localized:"Decoder manufacturer."),
      String(localized:" [CV191]"),
      .railComDecoderSync,
      .comboBox,
      []
    ),
    .m4MasterDecoderSerialNumber
    : (
      String(localized:"Decoder Serial Number%%CV%%"),
      String(localized:"Decoder serial number."),
      String(localized:" [CV195, CV194, CV193, CV192]"),
      .railComDecoderSync,
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
      
      var field : ProgrammerToolSettingsPropertyField = (view:nil, label:nil, control:nil, item, customView:nil, cvLabel:nil, slider:nil)
      
      field.label = NSTextField(labelWithString: item.label(showCV: true))

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
        field.customView = NSImageView(image: MyIcon.warning.image!)
        field.control = NSTextField(labelWithString: "")
      case .label:
        field.control = NSTextField(labelWithString: "")
      case .description:
        let textField = NSTextField(labelWithString: "")
        textField.lineBreakMode = .byWordWrapping
        textField.maximumNumberOfLines = 0
        textField.preferredMaxLayoutWidth = 400.0
        field.control = textField
      case .textField:
        field.control = NSTextField()
      case .textFieldWithInfo:
        field.control = NSTextField()
        let info = NSTextField(labelWithString: "")
        info.fontSize = textFontSize
        field.customView = info
      case .textFieldWithSlider:
        field.control = NSTextField()
        field.slider = NSSlider()
      case .textFieldWithInfoWithSlider:
        field.control = NSTextField()
        let info = NSTextField(labelWithString: "")
        info.fontSize = textFontSize
        field.customView = info
        field.slider = NSSlider()
      }
      
      /// https://manasaprema04.medium.com/autolayout-fundamental-522f0a6e5790
      
      let view = NSView()
      view.translatesAutoresizingMaskIntoConstraints = false
      view.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 500), for: .horizontal)
      field.view = view

      if let label = field.label {
        label.translatesAutoresizingMaskIntoConstraints = false
        label.fontSize = labelFontSize
        label.alignment = .right
        label.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 250), for: .horizontal)
        view.addSubview(label)
      }
      
      if let slider = field.slider {
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.altIncrementValue = 1
        slider.minValue = item.minValue
        slider.maxValue = item.maxValue
        slider.tag = item.rawValue
        view.addSubview(slider)
      }
      
      if let control = field.control {
        control.translatesAutoresizingMaskIntoConstraints = false
        control.fontSize = textFontSize
        control.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 1), for: .horizontal)
        control.toolTip = item.toolTip
        control.tag = item.rawValue
        view.addSubview(control)
      }
      
      if let customView = field.customView {
        customView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customView)
      }

      field.cvLabel = NSTextField(labelWithString: "")

      if let cvLabel = field.cvLabel {
        cvLabel.translatesAutoresizingMaskIntoConstraints = false
        cvLabel.fontSize = labelFontSize
        cvLabel.alignment = .right
        view.addSubview(cvLabel)
      }
      
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
    case .m4MasterDecoderManufacturer:
      ManufacturerCode.populate(comboBox: comboBox)
    case .speedStepMode:
      SpeedStepMode.populate(comboBox: comboBox)
    default:
      break
    }
    
  }
  
}
