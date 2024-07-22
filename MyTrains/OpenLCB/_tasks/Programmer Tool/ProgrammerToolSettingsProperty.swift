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
  case consistFunctions = 163
  
  // Analog Settings
  
  case analogModeActiveFunctions = 164
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
  
  // Function Outputs
  
  case physicalOutput = 165
  case physicalOutputPowerOnDelay = 166
  case physicalOutputPowerOffDelay = 167
  case physicalOutputEnableFunctionTimeout = 168
  case physicalOutputTimeUntilAutomaticPowerOff = 169
  case physicalOutputOutputMode = 170
  case physicalOutputBrightness = 171
  case physicalOutputUseClassLightLogic = 198
  case physicalOutputSequencePosition = 199
  case physicalOutputPhaseShift = 172
  case physicalOutputStartupTime = 173
  case physicalOutputStartupTimeInfo = 206
  case physicalOutputStartupDescription = 197
  case physicalOutputLevel = 174
  case physicalOutputSmokeUnitControlMode = 175
  case physicalOutputSpeed = 176
  case physicalOutputAccelerationRate = 177
  case physicalOutputDecelerationRate = 178
  case physicalOutputHeatWhileLocomotiveStands = 179
  case physicalOutputMinimumHeatWhileLocomotiveDriving = 180
  case physicalOutputMaximumHeatWhileLocomotiveDriving = 181
  case physicalOutputChuffPower = 182
  case physicalOutputFanPower = 183
  case physicalOutputTimeout = 184
  case physicalOutputServoDurationA = 185
  case physicalOutputServoDurationB = 186
  case physicalOutputServoPositionA = 187
  case physicalOutputServoDoNotDisableServoPulseAtPositionA = 188
  case physicalOutputServoPositionB = 189
  case physicalOutputServoDoNotDisableServoPulseAtPositionB = 190
  case physicalOutputCouplerForce = 191
  case physicalOutputExternalSmokeUnitType = 204
  case physicalOutputSpecialFunctions = 205
  case physicalOutputGradeCrossing = 196
  case physicalOutputRule17Forward = 192
  case physicalOutputRule17Reverse = 193
  case physicalOutputDimmer = 194
  case physicalOutputLEDMode = 195

  
  // Function Settings
  
  case frequencyForBlinkingEffects = 92
  case gradeCrossingHoldingTime = 93
  case fadeInTimeOfLightEffects = 94
  case fadeOutTimeOfLightEffects = 95
  case logicalFunctionDimmerBrightnessReduction = 96
  case classLightLogicSequenceLength = 97
  case enforceSlaveCommunicationOnAUX3AndAUX4 = 98
  case decoderSensorSettings = 99
  case enableAutomaticUncoupling = 100
  case automaticUncouplingSpeed = 101
  case automaticUncouplingPushTime = 102
  case automaticUncouplingWaitTime = 103
  case automaticUncouplingMoveTime = 104
  
  // Identification
  
  case userId1 = 61
  case userId2 = 62
  
  // Compatibility
  
  case enableSerialFunctionModeF1toF8ForLGBMTS = 158
  case enableSupportForBroadwayLimitedSteamEngineControl = 159
  case enableSUSIMaster = 160
  case susiWarning = 161
  case enableSUSISlave = 162
  
  // Motor Settings
  
  case esuSpeedTable = 200
  case speedTableIndex = 201
  case speedTableEntryValue = 202
  case speedTablePreset = 203
  case minimumSpeed = 112
  case maximumSpeed = 113
  case emfBasicSettings = 130
  case enableLoadControlBackEMF = 114
  case regulationReference = 115
  case regulationParameterK = 116
  case regulationParameterI = 117
  case emfSlowSpeedSettings = 131
  case regulationParameterKSlow = 118
  case largestInternalSpeedStepThatUsesKSlow = 129
  case regulationInfluenceDuringSlowSpeed = 119
  case emfBackEMFSettings = 132
  case slowSpeedBackEMFSamplingPeriod = 120
  case fullSpeedBackEMFSamplingPeriod = 121
  case slowSpeedLengthOfMeasurementGap = 122
  case fullSpeedLengthOfMeasurementGap = 123
  case enableMotorOverloadProtection = 124
  case enableMotorCurrentLimiter = 125
  case motorCurrentLimiterLimit = 126
  case motorPulseFrequency = 127
  case enableAutomaticParkingBrake = 128
  
  // Smoke Unit
  
  case smokeUnitTimeUntilPowerOff = 105
  case smokeUnitFanSpeedTrim = 106
  case smokeUnitTemperatureTrim = 107
  case smokeUnitPreheatingTemperatureForSecondarySmokeUnits = 108
  case smokeChuffsDurationRelativeToTriggerDistance = 109
  case smokeChuffsMinimumDuration = 110
  case smokeChuffsMaximumDuration = 111
  
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
  
  // Sound Settings
  
  case steamChuffMode = 133
  case distanceOfSteamChuffsAtSpeedStep1 = 134
  case triggerImpulsesPerSteamChuff = 140
  case divideTriggerImpulsesInTwoIfShuntingModeEnabled = 141
  case steamChuffAdjustmentAtHigherSpeedSteps = 135
  case enableSecondaryTrigger = 136
  case secondaryTriggerDistanceReduction = 137
  case enableMinimumDistanceOfSteamChuffs = 138
  case minimumDistanceofSteamChuffs = 139
  case masterVolume = 142
  case fadeSoundVolumeReduction = 143
  case soundFadeOutFadeInTime = 144
  case soundBass = 145
  case soundTreble = 146
  case brakeSoundSwitchingOnThreshold = 147
  case brakeSoundSwitchingOffThreshold = 148
  case soundControlBasis = 149
  case trainLoadAtLowSpeed = 150
  case trainLoadAtHighSpeed = 151
  case enableLoadOperationThreshold = 152
  case loadOperationThreshold = 153
  case loadOperationTriggeredFunction = 154
  case enableIdleOperationThreshold = 155
  case idleOperationThreshold = 156
  case idleOperationTriggeredFunction = 157

  
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
    case .locomotiveAddressShort, .consistAddress, .waitingPeriodBeforeDirectionChange, .brakeDistanceLength, .brakeDistanceLengthBackwards, .stoppingPeriod, .accelerationRate, .decelerationRate, .forwardTrim, .reverseTrim, .gearboxBacklashCompensation, .shuntingModeTrim, .automaticUncouplingSpeed, .frequencyForBlinkingEffects, .minimumSpeed, .maximumSpeed, .motorCurrentLimiterLimit, .distanceOfSteamChuffsAtSpeedStep1, .steamChuffAdjustmentAtHigherSpeedSteps, .secondaryTriggerDistanceReduction, .minimumDistanceofSteamChuffs, .triggerImpulsesPerSteamChuff, .soundFadeOutFadeInTime, .trainLoadAtLowSpeed, .loadOperationThreshold, .idleOperationThreshold, .speedTableIndex, .speedTableEntryValue, .physicalOutputTimeUntilAutomaticPowerOff, .physicalOutputSequencePosition:
      return 1
    case .slowSpeedBackEMFSamplingPeriod, .fullSpeedBackEMFSamplingPeriod:
      return 25
    case .accelerationAdjustment, .decelerationAdjustment:
      return -127
    case .slowSpeedLengthOfMeasurementGap, .fullSpeedLengthOfMeasurementGap:
      return 3
    case .motorPulseFrequency:
      return 10
    default:
      return 0
    }
  }
  
  public var maxValue : Double {
    switch self {
    case .maximumSpeedWhenBrakeFunction1Active, .maximumSpeedWhenBrakeFunction2Active, .maximumSpeedWhenBrakeFunction3Active:
      return 126
    case .locomotiveAddressShort, .consistAddress, .accelerationAdjustment, .decelerationAdjustment, .fadeInTimeOfLightEffects, .fadeOutTimeOfLightEffects, .physicalOutputLevel:
      return 127
    case .shuntingModeTrim, .logicalFunctionDimmerBrightnessReduction, .fadeSoundVolumeReduction:
      return 128
    case .slowSpeedBackEMFSamplingPeriod, .fullSpeedBackEMFSamplingPeriod:
      return 200
    case .slowSpeedLengthOfMeasurementGap, .fullSpeedLengthOfMeasurementGap:
      return 40
    case .motorPulseFrequency:
      return 50
    case .masterVolume:
      return 192
    case .soundFadeOutFadeInTime:
      return 64
    case .soundBass, .soundTreble:
      return 32
    case .speedTableIndex:
      return 28
    case .physicalOutputPowerOnDelay, .physicalOutputPowerOffDelay:
      return 15
    case .physicalOutputCouplerForce, .physicalOutputBrightness, .physicalOutputSpeed, .physicalOutputAccelerationRate, .physicalOutputDecelerationRate, .physicalOutputHeatWhileLocomotiveStands, .physicalOutputMinimumHeatWhileLocomotiveDriving, .physicalOutputMaximumHeatWhileLocomotiveDriving, .physicalOutputChuffPower, .physicalOutputFanPower:
      return 31
    case .physicalOutputSequencePosition:
      return 3
    case .physicalOutputPhaseShift, .physicalOutputServoDurationA, .physicalOutputServoDurationB, .physicalOutputServoPositionA, .physicalOutputServoPositionB:
      return 63
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
  
  public var label : String {
    guard let label = ProgrammerToolSettingsProperty.labels[self] else {
      return "error"
    }
    return label.labelTitle
  }
  

  
  // MARK: Public Methods
  
  // MARK: Private Class Properties
  
  private static let labels : [ProgrammerToolSettingsProperty:(labelTitle:String, toolTip:String, cv:String, section:ProgrammerToolSettingsSection, controlType:ProgrammerToolControlType, requiredCapabilities:Set<DecoderCapability>)] = [
    .locomotiveAddressType
    : (
      String(localized:"Locomotive Address Type"),
      String(localized:"Locomotive's address type."),
      String(localized:" [CV29.5]"),
      .locomotiveAddress,
      .comboBox,
      []
    ),
    .physicalOutputStartupDescription
    : (
      String(localized:""),
      String(localized:""),
      String(localized:""),
      .physicalOutputConfiguration,
      .description,
      []
    ),
    .locomotiveAddressShort
    : (
      String(localized:"Locomotive Address"),
      String(localized:"Locomotive's primary or short address."),
      String(localized:" [CV1]"),
      .locomotiveAddress,
      .textField,
      []
    ),
    .locomotiveAddressLong
    : (
      String(localized:"Locomotive Address"),
      String(localized:"Locomotive's extended or long address."),
      String(localized:" [CV17, CV18]"),
      .locomotiveAddress,
      .textField,
      []
    ),
    .marklinConsecutiveAddresses
    : (
      String(localized:"Additional Addresses"),
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
      String(localized:"Enable DCC Consist Address"),
      String(localized:"Enable DCC consist address."),
      String(localized:" [CV19.6:0]"),
      .dccConsistAddress,
      .checkBox,
      []
    ),
    .consistAddress
    : (
      String(localized:"Address for Consist Operation"),
      String(localized:"Address for consist operation."),
      String(localized:" [CV19.6:0]"),
      .dccConsistAddress,
      .textField,
      []
    ),
    .consistReverseDirection
    : (
      String(localized:"Reverse Direction"),
      String(localized:"Reverse direction."),
      String(localized:" [CV19.7]"),
      .dccConsistAddress,
      .checkBox,
      []
    ),
    .consistFunctions
    : (
      String(localized:"Select the functions that should respond to the consist address"),
      String(localized:"Select the functions that should respond to the consist address."),
      String(localized:" [CV21, CV22, CV109, CV110]"),
      .activateFunctionsInConsistMode,
      .functionsConsistMode,
      []
    ),
    .analogModeActiveFunctions
    : (
      String(localized:"Activate the following functions while driving in analog mode"),
      String(localized:"Activate the following functions while driving in analog mode."),
      String(localized:" [CV13, CV14]"),
      .activeFunctionsInAnalogMode,
      .functionsAnalogMode,
      []
    ),
    .enableACAnalogMode
    : (
      String(localized:"Enable AC Analog Mode"),
      String(localized:"Enable AC analog mode."),
      String(localized:" [CV29.2, CV50.0]"),
      .acAnalogMode,
      .checkBox,
      []
    ),
    .acAnalogModeStartVoltage
    : (
      String(localized:"Start Voltage (minimum speed)"),
      String(localized:"Start voltage (minimum speed)."),
      String(localized:" [CV127]"),
      .acAnalogMode,
      .textFieldWithInfoWithSlider,
      []
    ),
    .acAnalogModeMaximumSpeedVoltage
    : (
      String(localized:"Maximum Speed Voltage"),
      String(localized:"Maximum speed voltage."),
      String(localized:" [CV128]"),
      .acAnalogMode,
      .textFieldWithInfoWithSlider,
      []
    ),
    .enableDCAnalogMode
    : (
      String(localized:"Enable DC Analog Mode"),
      String(localized:"Enable DC analog mode."),
      String(localized:" [CV29.2, CV50.1]"),
      .dcAnalogMode,
      .checkBox,
      []
    ),
    .dcAnalogModeStartVoltage
    : (
      String(localized:"Start Voltage (minimum speed)"),
      String(localized:"Start voltage (minimum speed)."),
      String(localized:" [CV125]"),
      .dcAnalogMode,
      .textFieldWithInfoWithSlider,
      []
    ),
    .dcAnalogModeMaximumSpeedVoltage
    : (
      String(localized:"Maximum Speed Voltage"),
      String(localized:"Maximum speed voltage."),
      String(localized:" [CV126]"),
      .dcAnalogMode,
      .textFieldWithInfoWithSlider,
      []
    ),
    .enableQuantumEngineer
    : (
      String(localized:"Enable Quantum Engineer Support"),
      String(localized:"Enable quantum engineer support."),
      String(localized:" [CV50.2]"),
      .quantumEngineer,
      .checkBox,
      []
    ),
    .ignoreAccelerationDecelerationInSoundSchedule
    : (
      String(localized:"Ignore Acceleration and Deceleration in the Sound Schedule"),
      String(localized:"Ignore acceleration and deceleration in the sound schedule."),
      String(localized:" [CV122.5]"),
      .soundControlBehaviour,
      .checkBox,
      []
    ),
    .useHighFrequencyPWMMotorControl
    : (
      String(localized:"High Frequency PWM Motor Control"),
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
      String(localized:"Motor Hysteresis Voltage"),
      String(localized:"Motor hysteresis Voltage."),
      String(localized:" [CV130]"),
      .analogVoltageHysteresis,
      .textFieldWithInfoWithSlider,
      []
    ),
    .analogFunctionDifferenceVoltage
    : (
      String(localized:"Function Difference Voltage"),
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
      String(localized:"Brake if right rail signal in driving direction is more positive than the left rail"),
      String(localized:"Brake if right rail signal in driving direction is more positive than the left rail."),
      String(localized:" [CV27.0]"),
      .abcBrakeSections,
      .checkBox,
      []
    ),
    .brakeIfLeftRailSignalPositive
    : (
      String(localized:"Brake if left rail signal in driving direction is more positive than the right rail"),
      String(localized:"Brake if left rail signal in driving direction is more positive than the right rail."),
      String(localized:" [CV27.1]"),
      .abcBrakeSections,
      .checkBox,
      []
    ),
    .voltageDifferenceIndicatingABCBrakeSection
    : (
      String(localized:"Voltage difference indicating an ABC brake section"),
      String(localized:"Voltage difference indicating an ABC brake section."),
      String(localized:" [CV134]"),
      .abcBrakeSections,
      .textFieldWithSlider,
      []
    ),
    .abcReducedSpeed
    : (
      String(localized:"ABC Reduced Speed"),
      String(localized:"ABC Reduced Speed."),
      String(localized:" [CV123]"),
      .abcBrakeSections,
      .textFieldWithSlider,
      []
    ),
    .enableABCShuttleTrain
    : (
      String(localized:"Enable ABC Shuttle Train"),
      String(localized:"Enable ABC shuttle train."),
      String(localized:" [CV149]"),
      .abcBrakeSections,
      .checkBox,
      []
    ),
    .waitingPeriodBeforeDirectionChange
    : (
      String(localized:"Waiting time before direction change"),
      String(localized:"Waiting time before direction change."),
      String(localized:" [CV149]"),
      .abcBrakeSections,
      .textFieldWithInfoWithSlider,
      []
    ),
    .hluAllowZIMO
    : (
      String(localized:"Allow ZIMO (HLU) Brake Sections"),
      String(localized:"Allow ZIMO (HLU) brake sections."),
      String(localized:" [CV27.2]"),
      .hluSettings,
      .checkBox,
      []
    ),
    .hluSendZIMOZACKSignals
    : (
      String(localized:"Send ZIMO ZACK Signals"),
      String(localized:"Send ZIMO ZACK signals."),
      String(localized:" [CV122.2]"),
      .hluSettings,
      .checkBox,
      []
    ),
    .hluSpeedLimit1
    : (
      String(localized:"HLU Speed Limit 1"),
      String(localized:"HLU speed limit 1."),
      String(localized:" [CV150]"),
      .hluSettings,
      .textFieldWithSlider,
      []
    ),
    .hluSpeedLimit2
    : (
      String(localized:"HLU Speed Limit 2 (Ultra Low)"),
      String(localized:"HLU speed limit 2."),
      String(localized:" [CV151]"),
      .hluSettings,
      .textFieldWithSlider,
      []
    ),
    .hluSpeedLimit3
    : (
      String(localized:"HLU Speed Limit 3"),
      String(localized:"HLU speed limit 3."),
      String(localized:" [CV152]"),
      .hluSettings,
      .textFieldWithSlider,
      []
    ),
    .hluSpeedLimit4
    : (
      String(localized:"HLU Speed Limit 4 (Low Speed)"),
      String(localized:"HLU speed limit 4."),
      String(localized:" [CV153]"),
      .hluSettings,
      .textFieldWithSlider,
      []
    ),
    .hluSpeedLimit5
    : (
      String(localized:"HLU Speed Limit 5"),
      String(localized:"HLU speed limit 5."),
      String(localized:" [CV154]"),
      .hluSettings,
      .textFieldWithSlider,
      []
    ),
    .brakeOnForwardPolarity
    : (
      String(localized:"Brake on Forward DC Polarity"),
      String(localized:"Brake on forward DC polarity."),
      String(localized:" [CV27.4]"),
      .autoStopInPresenceOfDCPolarity,
      .checkBox,
      []
    ),
    .brakeOnReversePolarity
    : (
      String(localized:"Brake on Reverse DC Polarity"),
      String(localized:"Brake on reverse DC polarity."),
      String(localized:" [CV27.3]"),
      .autoStopInPresenceOfDCPolarity,
      .checkBox,
      []
    ),
    .selectrixBrakeOnForwardPolarity
    : (
      String(localized:"Brake on Forward Polarity of Brake Diode"),
      String(localized:"Brake on forward polarity of brake diode."),
      String(localized:" [CV27.6]"),
      .selectrixBrakeSections,
      .checkBox,
      []
    ),
    .selectrixBrakeOnReversePolarity
    : (
      String(localized:"Brake on Reverse Polarity of Brake Diode"),
      String(localized:"Brake on reverse polarity of brake diode."),
      String(localized:" [CV27.5]"),
      .selectrixBrakeSections,
      .checkBox,
      []
    ),
    .enableConstantBrakeDistance
    : (
      String(localized:"Enable Constant Brake Distance"),
      String(localized:"Enable constant brake distance."),
      String(localized:" [CV254]"),
      .constantBrakeDistance,
      .checkBox,
      []
    ),
    .brakeDistanceLength
    : (
      String(localized:"Brake Distance Length"),
      String(localized:"Brake distance length."),
      String(localized:" [CV254]"),
      .constantBrakeDistance,
      .textFieldWithSlider,
      []
    ),
    .differentBrakeDistanceBackwards
    : (
      String(localized:"Different Brake Distance While Driving Backwards"),
      String(localized:"Different brake distance while driving backwards."),
      String(localized:" [CV255]"),
      .constantBrakeDistance,
      .checkBox,
      []
    ),
    .brakeDistanceLengthBackwards
    : (
      String(localized:"Brake Distance Length"),
      String(localized:"Brake distance length."),
      String(localized:" [CV255]"),
      .constantBrakeDistance,
      .textFieldWithSlider,
      []
    ),
    .driveUntilLocomotiveStopsInSpecifiedPeriod
    : (
      String(localized:"Drive Until Locomotive Stops in Specified Period"),
      String(localized:"Drive until locomotive stops in specified period."),
      String(localized:" [CV253]"),
      .constantBrakeDistance,
      .checkBox,
      []
    ),
    .stoppingPeriod
    : (
      String(localized:"Stopping Period"),
      String(localized:"Stopping period."),
      String(localized:" [CV253]"),
      .constantBrakeDistance,
      .textFieldWithInfoWithSlider,
      []
    ),
    .constantBrakeDistanceOnSpeedStep0
    : (
      String(localized:"Constant Brake Distance on Speed Step 0"),
      String(localized:"Constant brake distance on speed step 0."),
      String(localized:" [CV27.7]"),
      .constantBrakeDistance,
      .checkBox,
      []
    ),
    .delayTimeBeforeExitingBrakeSection
    : (
      String(localized:"Delay Time Before Exiting a Brake Section"),
      String(localized:"Delay time before exiting a brake section."),
      String(localized:" [CV102]"),
      .brakeSectionSettings,
      .textFieldWithInfoWithSlider,
      []
    ),
    .brakeFunction1BrakeTimeReduction
    : (
      String(localized:"Brake Function 1 Reduces Brake Time by"),
      String(localized:"Brake function 1 reduces brake time by."),
      String(localized:" [CV179]"),
      .brakeFunctions,
      .textFieldWithInfoWithSlider,
      []
    ),
    .maximumSpeedWhenBrakeFunction1Active
    : (
      String(localized:"Maximum Speed when Brake Function 1 is Active"),
      String(localized:"Maximum speed when brake function 1 is active."),
      String(localized:" [CV182]"),
      .brakeFunctions,
      .textFieldWithSlider,
      []
    ),
    .brakeFunction2BrakeTimeReduction
    : (
      String(localized:"Brake Function 2 Reduces Brake Time by"),
      String(localized:"Brake function 2 reduces brake time by."),
      String(localized:" [CV180]"),
      .brakeFunctions,
      .textFieldWithInfoWithSlider,
      []
    ),
    .maximumSpeedWhenBrakeFunction2Active
    : (
      String(localized:"Maximum Speed when Brake Function 2 is Active"),
      String(localized:"Maximum speed when brake function 2 is active."),
      String(localized:" [CV183]"),
      .brakeFunctions,
      .textFieldWithSlider,
      []
    ),
    .brakeFunction3BrakeTimeReduction
    : (
      String(localized:"Brake Function 3 Reduces Brake Time by"),
      String(localized:"Brake function 3 reduces brake time by."),
      String(localized:" [CV181]"),
      .brakeFunctions,
      .textFieldWithInfoWithSlider,
      []
    ),
    .maximumSpeedWhenBrakeFunction3Active
    : (
      String(localized:"Maximum Speed when Brake Function 3 is Active"),
      String(localized:"Maximum speed when brake function 3 is active."),
      String(localized:" [CV184]"),
      .brakeFunctions,
      .textFieldWithSlider,
      []
    ),
    .enableRailComFeedback
    : (
      String(localized:"Enable RailCom Feedback"),
      String(localized:"Enable RailCom feedback."),
      String(localized:" [CV29.3]"),
      .railComSettings,
      .checkBox,
      []
    ),
    .enableRailComPlusAutomaticAnnouncement
    : (
      String(localized:"Enable RailComPlus Automatic Announcement"),
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
      String(localized:"Send Address via Broadcast on Channel 1"),
      String(localized:"Send address via broadcast on channel 1."),
      String(localized:" [CV28.0]"),
      .railComSettings,
      .checkBox,
      []
    ),
    .allowDataTransmissionOnChannel2
    : (
      String(localized:"Allow Data Transmission on Channel 2"),
      String(localized:"Allow data transmission on channel 2."),
      String(localized:" [CV28.1]"),
      .railComSettings,
      .checkBox,
      []
    ),
    .detectSpeedStepModeAutomatically
    : (
      String(localized:"Detect Speed Step Mode Automatically"),
      String(localized:"Detect speed step mode automatically."),
      String(localized:" [CV49.4]"),
      .speedStepMode,
      .checkBox,
      []
    ),
    .speedStepMode
    : (
      String(localized:"Speed Step Mode"),
      String(localized:"Speed step mode."),
      String(localized:" [CV29.1]"),
      .speedStepMode,
      .comboBox,
      []
    ),
    .enableAcceleration
    : (
      String(localized:"Enable Acceleration Time"),
      String(localized:"Enable acceleration time."),
      String(localized:" [CV3]"),
      .accelerationAndDeceleration,
      .checkBox,
      []
    ),
    .accelerationRate
    : (
      String(localized:"Time from Stop to Maximum Speed"),
      String(localized:"Time from stop to maximum speed."),
      String(localized:" [CV3]"),
      .accelerationAndDeceleration,
      .textFieldWithInfoWithSlider,
      []
    ),
    .accelerationAdjustment
    : (
      String(localized:"Acceleration Adjustment"),
      String(localized:"Acceleration Adjustment."),
      String(localized:" [CV23]"),
      .accelerationAndDeceleration,
      .textFieldWithInfoWithSlider,
      []
    ),
    .enableDeceleration
    : (
      String(localized:"Enable Deceleration Time"),
      String(localized:"Enable deceleration time."),
      String(localized:" [CV4]"),
      .accelerationAndDeceleration,
      .checkBox,
      []
    ),
    .decelerationRate
    : (
      String(localized:"Time from Maximum Speed to Stop"),
      String(localized:"Time from maximum speed to stop."),
      String(localized:" [CV4]"),
      .accelerationAndDeceleration,
      .textFieldWithInfoWithSlider,
      []
    ),
    .decelerationAdjustment
    : (
      String(localized:"Deceleration Adjustment"),
      String(localized:"Deceleration Adjustment."),
      String(localized:" [CV24]"),
      .accelerationAndDeceleration,
      .textFieldWithInfoWithSlider,
      []
    ),
    .reverseMode
    : (
      String(localized:"Reverse Direction (Forward becomes Reverse)"),
      String(localized:"Reverse direction."),
      String(localized:" [CV29.0]"),
      .reverseMode,
      .checkBox,
      []
    ),
    .enableForwardTrim
    : (
      String(localized:"Enable Forward Trimming"),
      String(localized:"Enable forward trimming."),
      String(localized:" [CV66]"),
      .trimming,
      .checkBox,
      []
    ),
    .forwardTrim
    : (
      String(localized:"Forward Trimming"),
      String(localized:"Forward trimming."),
      String(localized:" [CV66]"),
      .trimming,
      .textFieldWithInfoWithSlider,
      []
    ),
    .enableReverseTrim
    : (
      String(localized:"Enable Reverse Trimming"),
      String(localized:"Enable Reverse trimming."),
      String(localized:" [CV95]"),
      .trimming,
      .checkBox,
      []
    ),
    .reverseTrim
    : (
      String(localized:"Reverse Trimming"),
      String(localized:"Reverse trimming."),
      String(localized:" [CV95]"),
      .trimming,
      .textFieldWithInfoWithSlider,
      []
    ),
    .enableShuntingModeTrim
    : (
      String(localized:"Enable Shunting Mode Trimming"),
      String(localized:"Enable shunting mode trimming."),
      String(localized:" [CV101]"),
      .trimming,
      .checkBox,
      []
    ),
    .shuntingModeTrim
    : (
      String(localized:"Shunting Mode Trimming"),
      String(localized:"Shunting mode trimming."),
      String(localized:" [CV101]"),
      .trimming,
      .textFieldWithInfoWithSlider,
      []
    ),
    .loadAdjustmentOptionalLoad
    : (
      String(localized:"Load Adjustment when \"Optional Load\" is Enabled"),
      String(localized:"Load adjustment when \"Optional Load\" is enabled."),
      String(localized:" [CV103]"),
      .loadAdjustment,
      .textFieldWithInfoWithSlider,
      []
    ),
    .loadAdjustmentPrimaryLoad
    : (
      String(localized:"Load Adjustment when \"Primary Load\" is Enabled"),
      String(localized:"Load adjustment when \"Primary Load\" is enabled."),
      String(localized:" [CV104]"),
      .loadAdjustment,
      .textFieldWithInfoWithSlider,
      []
    ),
    .enableGearboxBacklashCompensation
    : (
      String(localized:"Enable Gearbox Backlash Compensation"),
      String(localized:"Enable gearbox backlash compensation."),
      String(localized:" [CV111]"),
      .gearboxBacklash,
      .checkBox,
      []
    ),
    .gearboxBacklashCompensation
    : (
      String(localized:"Slow motion time until Acceleration Starts"),
      String(localized:"Slow motion time until acceleration starts."),
      String(localized:" [CV111]"),
      .gearboxBacklash,
      .textFieldWithInfoWithSlider,
      []
    ),
    .timeToBridgePowerInterruption
    : (
      String(localized:"Time to Bridge Power Interruption (PowerPack required)"),
      String(localized:"Time to bridge power interruption."),
      String(localized:" [CV113]"),
      .powerPack,
      .textFieldWithInfoWithSlider,
      []
    ),
    .preserveDirection
    : (
      String(localized:"Preserve Direction when changing from Analog to Digital"),
      String(localized:"Preserve direction when changing from analog to digital."),
      String(localized:" [CV124.0]"),
      .preserveDirection,
      .checkBox,
      []
    ),
    .enableStartingDelay
    : (
      String(localized:"Delay Starting if Drive Sound is Enabled"),
      String(localized:"Delay starting if drive sound is enabled."),
      String(localized:" [CV124.2]"),
      .startingDelay,
      .checkBox,
      []
    ),
    .physicalOutput
    : (
      String(localized:"Physical Output"),
      String(localized:"Physical Output."),
      String(localized:""),
      .physicalOutputConfiguration,
      .comboBox,
      []
    ),
    .physicalOutputPowerOnDelay
    : (
      String(localized:"Power On Delay"),
      String(localized:"Power on delay."),
      String(localized:""),
      .physicalOutputConfiguration,
      .textFieldWithInfoWithSlider,
      []
    ),
    .physicalOutputPowerOffDelay
    : (
      String(localized:"Power Off Delay"),
      String(localized:"Power off delay."),
      String(localized:""),
      .physicalOutputConfiguration,
      .textFieldWithInfoWithSlider,
      []
    ),
    .physicalOutputEnableFunctionTimeout
    : (
      String(localized:"Enable Function Timeout"),
      String(localized:"Enable function timeout."),
      String(localized:""),
      .physicalOutputConfiguration,
      .checkBox,
      []
    ),
    .physicalOutputTimeUntilAutomaticPowerOff
    : (
      String(localized:"Time until Automatic Power Off"),
      String(localized:"Time until automatic power off."),
      String(localized:""),
      .physicalOutputConfiguration,
      .textFieldWithInfoWithSlider,
      []
    ),
    .physicalOutputOutputMode
    : (
      String(localized:"Output Mode (Effect)"),
      String(localized:"Output mode (effect)."),
      String(localized:""),
      .physicalOutputConfiguration,
      .comboBox,
      []
    ),
    .physicalOutputBrightness
    : (
      String(localized:"Brightness"),
      String(localized:"Brightness."),
      String(localized:""),
      .physicalOutputConfiguration,
      .textFieldWithSlider,
      []
    ),
    .physicalOutputPhaseShift
    : (
      String(localized:"Phase Shift"),
      String(localized:"Phase shift."),
      String(localized:""),
      .physicalOutputConfiguration,
      .textFieldWithSlider,
      []
    ),
    .physicalOutputStartupTime
    : (
      String(localized:"Startup Time"),
      String(localized:"Startup time."),
      String(localized:""),
      .physicalOutputConfiguration,
      .textFieldWithSlider,
      []
    ),
    .physicalOutputStartupTimeInfo
    : (
      String(localized:""),
      String(localized:"."),
      String(localized:""),
      .physicalOutputConfiguration,
      .description,
      []
    ),
    .physicalOutputLevel
    : (
      String(localized:"Level"),
      String(localized:"Level."),
      String(localized:""),
      .physicalOutputConfiguration,
      .textFieldWithSlider,
      []
    ),
    .physicalOutputSmokeUnitControlMode
    : (
      String(localized:"Control Mode"),
      String(localized:"Control mode."),
      String(localized:""),
      .physicalOutputConfiguration,
      .comboBox,
      []
    ),
    .physicalOutputSpeed
    : (
      String(localized:"Speed"),
      String(localized:"Speed."),
      String(localized:""),
      .physicalOutputConfiguration,
      .textFieldWithSlider,
      []
    ),
    .physicalOutputAccelerationRate
    : (
      String(localized:"Acceleration Rate"),
      String(localized:"Acceleration Rate."),
      String(localized:""),
      .physicalOutputConfiguration,
      .textFieldWithSlider,
      []
    ),
    .physicalOutputDecelerationRate
    : (
      String(localized:"Deceleration Rate"),
      String(localized:"Deceleration Rate."),
      String(localized:""),
      .physicalOutputConfiguration,
      .textFieldWithSlider,
      []
    ),
    .physicalOutputHeatWhileLocomotiveStands
    : (
      String(localized:"Heat while Locomotive Stands"),
      String(localized:"Heat while locomotive stands."),
      String(localized:""),
      .physicalOutputConfiguration,
      .textFieldWithSlider,
      []
    ),
    .physicalOutputMinimumHeatWhileLocomotiveDriving
    : (
      String(localized:"Minimum Heat while Locomotive is Driving"),
      String(localized:"Minimum heat while locomotive is driving."),
      String(localized:""),
      .physicalOutputConfiguration,
      .textFieldWithSlider,
      []
    ),
    .physicalOutputMaximumHeatWhileLocomotiveDriving
    : (
      String(localized:"Maximum Heat while Locomotive is Driving"),
      String(localized:"Maximum heat while locomotive is driving."),
      String(localized:""),
      .physicalOutputConfiguration,
      .textFieldWithSlider,
      []
    ),
    .physicalOutputChuffPower
    : (
      String(localized:"Chuff Power"),
      String(localized:"Chuff power."),
      String(localized:""),
      .physicalOutputConfiguration,
      .textFieldWithSlider,
      []
    ),
    .physicalOutputFanPower
    : (
      String(localized:"Fan Power"),
      String(localized:"Fan power."),
      String(localized:""),
      .physicalOutputConfiguration,
      .textFieldWithSlider,
      []
    ),
    .physicalOutputTimeout
    : (
      String(localized:"Timeout"),
      String(localized:"Timeout."),
      String(localized:""),
      .physicalOutputConfiguration,
      .textFieldWithInfoWithSlider,
      []
    ),
    .physicalOutputCouplerForce
    : (
      String(localized:"Coupler Force"),
      String(localized:"Coupler force."),
      String(localized:""),
      .physicalOutputConfiguration,
      .textFieldWithSlider,
      []
    ),
    .physicalOutputServoDurationA
    : (
      String(localized:"Duration (speed) A"),
      String(localized:"Duration (speed) A."),
      String(localized:""),
      .physicalOutputConfiguration,
      .textFieldWithInfoWithSlider,
      []
    ),
    .physicalOutputServoDurationB
    : (
      String(localized:"Duration (speed) B"),
      String(localized:"Duration (speed) B."),
      String(localized:""),
      .physicalOutputConfiguration,
      .textFieldWithInfoWithSlider,
      []
    ),
    .physicalOutputServoPositionA
    : (
      String(localized:"Position A (Off)"),
      String(localized:"Position A (off)."),
      String(localized:""),
      .physicalOutputConfiguration,
      .textFieldWithSlider,
      []
    ),
    .physicalOutputServoPositionB
    : (
      String(localized:"Position B (On)"),
      String(localized:"Position B (on)."),
      String(localized:""),
      .physicalOutputConfiguration,
      .textFieldWithSlider,
      []
    ),
    .physicalOutputServoDoNotDisableServoPulseAtPositionA
    : (
      String(localized:"Do Not Disable Servo Pulse at Position A"),
      String(localized:"Do not disable servo pulse at position A."),
      String(localized:""),
      .physicalOutputConfiguration,
      .checkBox,
      []
    ),
    .physicalOutputServoDoNotDisableServoPulseAtPositionB
    : (
      String(localized:"Do Not Disable Servo Pulse at Position B"),
      String(localized:"Do not disable servo pulse at position B."),
      String(localized:""),
      .physicalOutputConfiguration,
      .checkBox,
      []
    ),
    .physicalOutputUseClassLightLogic
    : (
      String(localized:"Use Class Light Logic"),
      String(localized:"Use class light logic."),
      String(localized:""),
      .physicalOutputConfiguration,
      .checkBox,
      []
    ),
    .physicalOutputExternalSmokeUnitType
    : (
      String(localized:"External Smoke Unit Type"),
      String(localized:"External smoke unit type."),
      String(localized:""),
      .physicalOutputConfiguration,
      .comboBox,
      []
    ),
    .physicalOutputSequencePosition
    : (
      String(localized:"Sequence Position"),
      String(localized:"Sequence position."),
      String(localized:""),
      .physicalOutputConfiguration,
      .textFieldWithSlider,
      []
    ),
    .physicalOutputSpecialFunctions
    : (
      String(localized:"Rule 17 Forward"),
      String(localized:"Rule 17 forward."),
      String(localized:""),
      .physicalOutputConfiguration,
      .description,
      []
    ),
    .physicalOutputGradeCrossing
    : (
      String(localized:"Grade Crossing"),
      String(localized:"Grade Crossing."),
      String(localized:""),
      .physicalOutputConfiguration,
      .checkBox,
      []
    ),
    .physicalOutputRule17Forward
    : (
      String(localized:"Rule 17 Forward"),
      String(localized:"Rule 17 forward."),
      String(localized:""),
      .physicalOutputConfiguration,
      .checkBox,
      []
    ),
    .physicalOutputRule17Reverse
    : (
      String(localized:"Rule 17 Reverse"),
      String(localized:"Rule 17 Reverse."),
      String(localized:""),
      .physicalOutputConfiguration,
      .checkBox,
      []
    ),
    .physicalOutputDimmer
    : (
      String(localized:"Dimmer"),
      String(localized:"Dimmer."),
      String(localized:""),
      .physicalOutputConfiguration,
      .checkBox,
      []
    ),
    .physicalOutputLEDMode
    : (
      String(localized:"LED Mode"),
      String(localized:"LED mode."),
      String(localized:""),
      .physicalOutputConfiguration,
      .checkBox,
      []
    ),
    .frequencyForBlinkingEffects
    : (
      String(localized:"Frequency for Blinking Effects"),
      String(localized:"Frequency for blinking effects."),
      String(localized:" [CV112]"),
      .generalPhysicalOutputSettings,
      .textFieldWithInfoWithSlider,
      []
    ),
    .gradeCrossingHoldingTime
    : (
      String(localized:"Grade Crossing Holding Time"),
      String(localized:"Grade crossing holding time."),
      String(localized:" [CV132]"),
      .generalPhysicalOutputSettings,
      .textFieldWithInfoWithSlider,
      []
    ),
    .fadeInTimeOfLightEffects
    : (
      String(localized:"Fade-In Time of Light Effects"),
      String(localized:"Fade-in time of light effects."),
      String(localized:" [CV114]"),
      .generalPhysicalOutputSettings,
      .textFieldWithInfoWithSlider,
      []
    ),
    .fadeOutTimeOfLightEffects
    : (
      String(localized:"Fade-Out Time of Light Effects"),
      String(localized:"Fade-out time of light effects."),
      String(localized:" [CV115]"),
      .generalPhysicalOutputSettings,
      .textFieldWithInfoWithSlider,
      []
    ),
    .logicalFunctionDimmerBrightnessReduction
    : (
      String(localized:"Logical Function Dimmer Brightness Reduction"),
      String(localized:"Logical function dimmer brightness reduction."),
      String(localized:" [CV131]"),
      .generalPhysicalOutputSettings,
      .textFieldWithInfoWithSlider,
      []
    ),
    .classLightLogicSequenceLength
    : (
      String(localized:"Class Light Logic Sequence Length"),
      String(localized:"Class light logic sequence length."),
      String(localized:" [CV199]"),
      .generalPhysicalOutputSettings,
      .comboBox,
      []
    ),
    .enforceSlaveCommunicationOnAUX3AndAUX4
    : (
      String(localized:"Enforce Slave Communication on AUX3 and AUX4"),
      String(localized:"Enforce slave communication on AUX3 and AUX4."),
      String(localized:" [CV114]"),
      .generalPhysicalOutputSettings,
      .checkBox,
      []
    ),
    .decoderSensorSettings
    : (
      String(localized:"Sensor Settings"),
      String(localized:"Sensor settings."),
      String(localized:" [CV124.4]"),
      .sensorSettings,
      .comboBox,
      []
    ),
    .enableAutomaticUncoupling
    : (
      String(localized:"Enable Automatic Uncoupling"),
      String(localized:"Enable automatic uncoupling."),
      String(localized:" [CV246]"),
      .automaticUncoupling,
      .checkBox,
      []
    ),
    .automaticUncouplingSpeed
    : (
      String(localized:"Automatic Uncoupling Speed"),
      String(localized:"Automatic uncoupling speed."),
      String(localized:" [CV246]"),
      .automaticUncoupling,
      .textFieldWithSlider,
      []
    ),
    .automaticUncouplingPushTime
    : (
      String(localized:"Automatic Uncoupling Push Time"),
      String(localized:"Automatic uncoupling push time."),
      String(localized:" [CV248]"),
      .automaticUncoupling,
      .textFieldWithInfoWithSlider,
      []
    ),
    .automaticUncouplingWaitTime
    : (
      String(localized:"Automatic Uncoupling Wait Time"),
      String(localized:"Automatic uncoupling wait time."),
      String(localized:" [CV245]"),
      .automaticUncoupling,
      .textFieldWithInfoWithSlider,
      []
    ),
    .automaticUncouplingMoveTime
    : (
      String(localized:"Automatic Uncoupling Move Time"),
      String(localized:"Automatic uncoupling move time."),
      String(localized:" [CV247]"),
      .automaticUncoupling,
      .textFieldWithInfoWithSlider,
      []
    ),
    .userId1
    : (
      String(localized:"User ID #1"),
      String(localized:"User ID #1."),
      String(localized:" [CV105]"),
      .userIdentification,
      .textField,
      []
    ),
    .userId2
    : (
      String(localized:"User ID #2"),
      String(localized:"User ID #2."),
      String(localized:" [CV106]"),
      .userIdentification,
      .textField,
      []
    ),
    .enableSerialFunctionModeF1toF8ForLGBMTS
    : (
      String(localized:"Serial Function Mode for LGB MTS"),
      String(localized:"Serial function mode for LGB MTS."),
      String(localized:" [CV49.5]"),
      .settingsForCertainCommandStations,
      .checkBox,
      []
    ),
    .enableSupportForBroadwayLimitedSteamEngineControl
    : (
      String(localized:"Enable Support for Broadway Limited Steam Engine Control"),
      String(localized:"Enable support for Broadway Limited Steam Engine Control."),
      String(localized:" [CV122.7]"),
      .broadwayLimitedSteamEngineControl,
      .checkBox,
      []
    ),
    .enableSUSIMaster
    : (
      String(localized:"Enable Serial User Standard Interface (SUSI Master)"),
      String(localized:"Enable serial user standard interface (SUSI Master)."),
      String(localized:" [CV124.3]"),
      .serialUserStandardInterface,
      .checkBox,
      []
    ),
    .susiWarning
    : (
      String(localized:""),
      String(localized:""),
      String(localized:""),
      .serialUserStandardInterface,
      .warning,
      []
    ),
    .enableSUSISlave
    : (
      String(localized:"Enable Serial User Standard Interface (SUSI Slave)"),
      String(localized:"Enable serial user standard interface (SUSI Slave)."),
      String(localized:" [CV124.1]"),
      .serialUserStandardInterface,
      .checkBox,
      []
    ),
    .esuSpeedTable
    : (
      String(localized:""),
      String(localized:""),
      String(localized:" [CV67 to CV94]"),
      .speedTable,
      .esuSpeedTable,
      []
    ),
    .speedTableIndex
    : (
      String(localized:"Speed Table Index"),
      String(localized:"Speed table index"),
      String(localized:""),
      .speedTable,
      .comboBox,
      []
    ),
    .speedTableEntryValue
    : (
      String(localized:"Value"),
      String(localized:"Value"),
      String(localized:""),
      .speedTable,
      .textField,
      []
    ),
    .speedTablePreset
    : (
      String(localized:"Preset"),
      String(localized:"Preset"),
      String(localized:""),
      .speedTable,
      .comboBox,
      []
    ),
    .minimumSpeed
    : (
      String(localized:"Minimum Speed"),
      String(localized:"Minimum speed."),
      String(localized:" [CV2]"),
      .speedTable,
      .textFieldWithInfoWithSlider,
      []
    ),
    .maximumSpeed
    : (
      String(localized:"Maximum Speed"),
      String(localized:"Maximum speed."),
      String(localized:" [CV5]"),
      .speedTable,
      .textFieldWithInfoWithSlider,
      []
    ),
    .emfBasicSettings
    : (
      String(localized:""),
      String(localized:""),
      String(localized:""),
      .loadControlBackEMF,
      .description,
      []
    ),
    .emfSlowSpeedSettings
    : (
      String(localized:""),
      String(localized:""),
      String(localized:""),
      .loadControlBackEMF,
      .description,
      []
    ),
    .emfBackEMFSettings
    : (
      String(localized:""),
      String(localized:""),
      String(localized:""),
      .loadControlBackEMF,
      .description,
      []
    ),
    .enableLoadControlBackEMF
    : (
      String(localized:"Enable Load Control / Back EMF"),
      String(localized:"Enable load control / back EMF."),
      String(localized:" [CV49.0]"),
      .loadControlBackEMF,
      .checkBox,
      []
    ),
    .regulationReference
    : (
      String(localized:"Regulation Reference"),
      String(localized:"Regulation reference."),
      String(localized:" [CV53]"),
      .loadControlBackEMF,
      .textFieldWithInfoWithSlider,
      []
    ),
    .regulationParameterK
    : (
      String(localized:"Regulation Parameter \"K\""),
      String(localized:"Regulation parameter \"K\"."),
      String(localized:" [CV54]"),
      .loadControlBackEMF,
      .textFieldWithSlider,
      []
    ),
    .regulationParameterI
    : (
      String(localized:"Regulation Parameter \"I\""),
      String(localized:"Regulation parameter \"I\"."),
      String(localized:" [CV55]"),
      .loadControlBackEMF,
      .textFieldWithInfoWithSlider,
      []
    ),
    .regulationParameterKSlow
    : (
      String(localized:"Regulation Parameter \"K Slow\""),
      String(localized:"Regulation parameter \"K Slow\"."),
      String(localized:" [CV54]"),
      .loadControlBackEMF,
      .textFieldWithSlider,
      []
    ),
    .largestInternalSpeedStepThatUsesKSlow
    : (
      String(localized:"Largest Internal Speed Step that uses \"K Slow\""),
      String(localized:"Largest internal speed step that uses \"K Slow\"."),
      String(localized:" [CV51]"),
      .loadControlBackEMF,
      .textFieldWithSlider,
      []
    ),
    .regulationInfluenceDuringSlowSpeed
    : (
      String(localized:"Regulation Influence During Slow Speed"),
      String(localized:"Regulation influence during slow speed."),
      String(localized:" [CV56]"),
      .loadControlBackEMF,
      .textFieldWithInfoWithSlider,
      []
    ),
    .slowSpeedBackEMFSamplingPeriod
    : (
      String(localized:"Slow Speed Back EMF Sampling Period"),
      String(localized:"Slow speed back EMF sampling period."),
      String(localized:" [CV116]"),
      .loadControlBackEMF,
      .textFieldWithInfoWithSlider,
      []
    ),
    .fullSpeedBackEMFSamplingPeriod
    : (
      String(localized:"Full Speed Back EMF Sampling Period"),
      String(localized:"Full speed back EMF sampling period."),
      String(localized:" [CV117]"),
      .loadControlBackEMF,
      .textFieldWithInfoWithSlider,
      []
    ),
    .slowSpeedLengthOfMeasurementGap
    : (
      String(localized:"Slow Speed Length of Measurement Gap"),
      String(localized:"Slow speed length of measurement gap."),
      String(localized:" [CV118]"),
      .loadControlBackEMF,
      .textFieldWithInfoWithSlider,
      []
    ),
    .fullSpeedLengthOfMeasurementGap
    : (
      String(localized:"Full Speed Length of Measurement Gap"),
      String(localized:"Full speed length of measurement gap."),
      String(localized:" [CV119]"),
      .loadControlBackEMF,
      .textFieldWithInfoWithSlider,
      []
    ),
    .enableMotorOverloadProtection
    : (
      String(localized:"Enable Motor Overload Protection"),
      String(localized:"Enable motor overload protection."),
      String(localized:" [CV124.5]"),
      .motorOverloadProtection,
      .checkBox,
      []
    ),
    .enableMotorCurrentLimiter
    : (
      String(localized:"Enable Motor Current Limiter"),
      String(localized:"Enable motor current limiter."),
      String(localized:" [CV100]"),
      .motorOverloadProtection,
      .checkBox,
      []
    ),
    .motorCurrentLimiterLimit
    : (
      String(localized:"Motor Current Limiter Limit"),
      String(localized:"Motor current limiter limit."),
      String(localized:" [CV100]"),
      .motorOverloadProtection,
      .textFieldWithInfoWithSlider,
      []
    ),
    .motorPulseFrequency
    : (
      String(localized:"Motor Pulse Frequency"),
      String(localized:"Motor pulse frequency."),
      String(localized:" [CV9]"),
      .pwmFrequency,
      .textFieldWithInfoWithSlider,
      []
    ),
    .enableAutomaticParkingBrake
    : (
      String(localized:"Enable Automatic Parking Brake"),
      String(localized:"Enable automatic parking brake."),
      String(localized:" [CV124.6]"),
      .automaticParkingBrake,
      .checkBox,
      []
    ),
    .smokeUnitTimeUntilPowerOff
    : (
      String(localized:"Time until Smoke Unit Automatic Power Off"),
      String(localized:"Time until smoke unit automatic power off."),
      String(localized:" [CV140]"),
      .esuSmokeUnit,
      .textFieldWithInfoWithSlider,
      []
    ),
    .smokeUnitFanSpeedTrim
    : (
      String(localized:"Fan Speed Trim"),
      String(localized:"Fan speed trim."),
      String(localized:" [CV138]"),
      .esuSmokeUnit,
      .textFieldWithInfoWithSlider,
      []
    ),
    .smokeUnitTemperatureTrim
    : (
      String(localized:"Temperature Trim"),
      String(localized:"Temperature trim."),
      String(localized:" [CV139]"),
      .esuSmokeUnit,
      .textFieldWithInfoWithSlider,
      []
    ),
    .smokeUnitPreheatingTemperatureForSecondarySmokeUnits
    : (
      String(localized:"Preheating Temperature for Secondary Smoke Units"),
      String(localized:"Preheating temperature for secondary smoke units."),
      String(localized:" [CV144]"),
      .esuSmokeUnit,
      .textFieldWithInfoWithSlider,
      []
    ),
    .smokeChuffsDurationRelativeToTriggerDistance
    : (
      String(localized:"Duration of Steam Chuffs Relative to Trigger Distance"),
      String(localized:"Duration of steam chuffs relative to trigger distance."),
      String(localized:" [CV143]"),
      .smokeChuffs,
      .textFieldWithInfoWithSlider,
      []
    ),
    .smokeChuffsMinimumDuration
    : (
      String(localized:"Minimum Steam Chuff Duration"),
      String(localized:"Minimum steam chuff duration."),
      String(localized:" [CV141]"),
      .smokeChuffs,
      .textFieldWithInfoWithSlider,
      []
    ),
    .smokeChuffsMaximumDuration
    : (
      String(localized:"Maximum Steam Chuff Duration"),
      String(localized:"Maximum steam chuff duration."),
      String(localized:" [CV142]"),
      .smokeChuffs,
      .textFieldWithInfoWithSlider,
      []
    ),
    .enableDCCProtocol
    : (
      String(localized:"DCC Protocol"),
      String(localized:"Enable DCC protocol."),
      String(localized:" [CV47.0]"),
      .enabledProtocols,
      .checkBox,
      []
    ),
    .enableMarklinMotorolaProtocol
    : (
      String(localized:"Märklin Motorola Protocol"),
      String(localized:"Enable Märklin Motorola protocol."),
      String(localized:" [CV47.2]"),
      .enabledProtocols,
      .checkBox,
      []
    ),
    .enableSelectrixProtocol
    : (
      String(localized:"Selectrix"),
      String(localized:"Enable Selectrix protocol."),
      String(localized:" [CV47.3]"),
      .enabledProtocols,
      .checkBox,
      []
    ),
    .enableM4Protocol
    : (
      String(localized:"M4 Protocol"),
      String(localized:"Enable M4 protocol."),
      String(localized:" [CV47.1]"),
      .enabledProtocols,
      .checkBox,
      []
    ),
    .memoryPersistentFunction
    : (
      String(localized:"Persistent Function"),
      String(localized:"Enable persistent function."),
      String(localized:" [CV122.0]"),
      .memorySettings,
      .checkBox,
      []
    ),
    .memoryPersistentSpeed
    : (
      String(localized:"Persistent Speed"),
      String(localized:"Enable persistent speed."),
      String(localized:" [CV122.1]"),
      .memorySettings,
      .checkBox,
      []
    ),
    .enableRailComPlusSynchronization
    : (
      String(localized:"This decoder synchronizes RailComPlus / M4 address with a Master decoder"),
      String(localized:"This decoder synchronizes RailComPlus / M4 address with a Master decoder."),
      String(localized:" [CV191]"),
      .railComDecoderSync,
      .checkBox,
      []
    ),
    .m4MasterDecoderManufacturer
    : (
      String(localized:"Decoder Manufacturer"),
      String(localized:"Decoder manufacturer."),
      String(localized:" [CV191]"),
      .railComDecoderSync,
      .comboBox,
      []
    ),
    .m4MasterDecoderSerialNumber
    : (
      String(localized:"Decoder Serial Number"),
      String(localized:"Decoder serial number."),
      String(localized:" [CV195, CV194, CV193, CV192]"),
      .railComDecoderSync,
      .textField,
      []
    ),
    .steamChuffMode
    : (
      String(localized:"Steam Chuff Mode"),
      String(localized:"Steam chuff mode."),
      String(localized:" [CV57]"),
      .steamChuffs,
      .comboBox,
      []
    ),
    .distanceOfSteamChuffsAtSpeedStep1
    : (
      String(localized:"Distance of Steam Chuffs at Speed Step 1"),
      String(localized:"Distance of steam chuffs at speed step 1."),
      String(localized:" [CV57]"),
      .steamChuffs,
      .textFieldWithInfoWithSlider,
      []
    ),
    .steamChuffAdjustmentAtHigherSpeedSteps
    : (
      String(localized:"Adjustment at Higher Speed Steps"),
      String(localized:"Adjustment at higher speed steps."),
      String(localized:" [CV58]"),
      .steamChuffs,
      .textFieldWithSlider,
      []
    ),
    .triggerImpulsesPerSteamChuff
    : (
      String(localized:"Trigger Impulses per Steam Chuff"),
      String(localized:"Trigger impulses per steam chuff."),
      String(localized:" [CV58]"),
      .steamChuffs,
      .textFieldWithSlider,
      []
    ),
    .divideTriggerImpulsesInTwoIfShuntingModeEnabled
    : (
      String(localized:"Divide Trigger Impulses in Two if Shunting Mode Enabled"),
      String(localized:"Divide trigger impulses in two if shunting mode enabled."),
      String(localized:" [CV122.3]"),
      .steamChuffs,
      .checkBox,
      []
    ),
    .enableSecondaryTrigger
    : (
      String(localized:"Enable Secondary Trigger"),
      String(localized:"Enable secondary trigger."),
      String(localized:" [CV250]"),
      .steamChuffs,
      .checkBox,
      []
    ),
    .secondaryTriggerDistanceReduction
    : (
      String(localized:"Reduce Secondary Trigger Distance by:"),
      String(localized:"Reduce secondary trigger distance by."),
      String(localized:" [CV250]"),
      .steamChuffs,
      .textFieldWithInfoWithSlider,
      []
    ),
    .enableMinimumDistanceOfSteamChuffs
    : (
      String(localized:"Enable Minimum Distance of Steam Chuffs"),
      String(localized:"Enable minimum distance of steam chuffs."),
      String(localized:" [CV249]"),
      .steamChuffs,
      .checkBox,
      []
    ),
    .minimumDistanceofSteamChuffs
    : (
      String(localized:"Minimum Distance of Steam Chuffs"),
      String(localized:"Minimum distance of steam chuffs."),
      String(localized:" [CV249]"),
      .steamChuffs,
      .textFieldWithInfoWithSlider,
      []
    ),
    .masterVolume
    : (
      String(localized:"Master Volume"),
      String(localized:"Master volume."),
      String(localized:" [CV63]"),
      .volume,
      .textFieldWithInfoWithSlider,
      []
    ),
    .fadeSoundVolumeReduction
    : (
      String(localized:"Fade Sound Volume Reduction"),
      String(localized:"Fade sound volume reduction."),
      String(localized:" [CV133]"),
      .volume,
      .textFieldWithInfoWithSlider,
      []
    ),
    .soundFadeOutFadeInTime
    : (
      String(localized:"Sound Fade-In and Fade-Out Time"),
      String(localized:"Sound fade-in and fade-out time."),
      String(localized:" [CV135]"),
      .volume,
      .textFieldWithInfoWithSlider,
      []
    ),
    .soundBass
    : (
      String(localized:"Bass"),
      String(localized:"Bass."),
      String(localized:" [CV196]"),
      .toneControl,
      .textFieldWithInfoWithSlider,
      []
    ),
    .soundTreble
    : (
      String(localized:"Treble"),
      String(localized:"Treble."),
      String(localized:" [CV197]"),
      .toneControl,
      .textFieldWithInfoWithSlider,
      []
    ),
    .brakeSoundSwitchingOnThreshold
    : (
      String(localized:"Switching On Threshold"),
      String(localized:"Switching on threshold."),
      String(localized:" [CV64]"),
      .brakeSound,
      .textFieldWithSlider,
      []
    ),
    .brakeSoundSwitchingOffThreshold
    : (
      String(localized:"Switching Off Threshold"),
      String(localized:"Switching off threshold."),
      String(localized:" [CV65]"),
      .brakeSound,
      .textFieldWithSlider,
      []
    ),
    .soundControlBasis
    : (
      String(localized:"Sound Control Basis"),
      String(localized:"Sound control basis."),
      String(localized:" [CV200]"),
      .dynamicSoundControl,
      .comboBox,
      []
    ),
    .trainLoadAtLowSpeed
    : (
      String(localized:"Train Load at Low Speed"),
      String(localized:"Train load at low speed."),
      String(localized:" [CV200]"),
      .dynamicSoundControl,
      .textFieldWithInfoWithSlider,
      []
    ),
    .trainLoadAtHighSpeed
    : (
      String(localized:"Train Load at High Speed"),
      String(localized:"Train load at high speed."),
      String(localized:" [CV201]"),
      .dynamicSoundControl,
      .textFieldWithInfoWithSlider,
      []
    ),
    .enableLoadOperationThreshold
    : (
      String(localized:"Enable Threshold for Load Operation"),
      String(localized:"Enable threshold for load operation."),
      String(localized:" [CV202]"),
      .dynamicSoundControl,
      .checkBox,
      []
    ),
    .loadOperationThreshold
    : (
      String(localized:"Threshold for Load Operation"),
      String(localized:"threshold for load operation."),
      String(localized:" [CV202]"),
      .dynamicSoundControl,
      .textFieldWithSlider,
      []
    ),
    .loadOperationTriggeredFunction
    : (
      String(localized:"Triggered Function"),
      String(localized:"Triggered function."),
      String(localized:" [CV204]"),
      .dynamicSoundControl,
      .comboBox,
      []
    ),
    .enableIdleOperationThreshold
    : (
      String(localized:"Enable Threshold for Idle Operation"),
      String(localized:"Enable threshold for idle operation."),
      String(localized:" [CV203]"),
      .dynamicSoundControl,
      .checkBox,
      []
    ),
    .idleOperationThreshold
    : (
      String(localized:"Threshold for Idle Operation"),
      String(localized:"Threshold for idle operation."),
      String(localized:" [CV203]"),
      .dynamicSoundControl,
      .textFieldWithSlider,
      []
    ),
    .idleOperationTriggeredFunction
    : (
      String(localized:"Triggered Function"),
      String(localized:"Triggered function."),
      String(localized:" [CV205]"),
      .dynamicSoundControl,
      .comboBox,
      []
    ),

  ]

  // MARK: Public Class Properties
  
  public static var inspectorPropertyFields: [ProgrammerToolSettingsPropertyField] {
    
    var result : [ProgrammerToolSettingsPropertyField] = []
    
//    let labelFontSize : CGFloat = 10.0
    let textFontSize  : CGFloat = 11.0
    
    for item in ProgrammerToolSettingsProperty.allCases {
      
      if let definition = ProgrammerToolSettingsProperty.definitions[item] {
        
        var field : ProgrammerToolSettingsPropertyField = (view:nil, label:nil, control:nil, item, customView:nil, cvLabel:nil, slider:nil)
        
        if definition.controlType != .checkBox && definition.controlType != .description && definition.controlType != .warning {
          field.label = NSTextField(labelWithString: item.label)
        }
        
        switch definition.controlType {
        case .checkBox:
          let checkBox = NSButton()
          checkBox.setButtonType(.switch)
          checkBox.title = item.label
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
          let textField = NSTextField(labelWithString: definition.title)
          textField.lineBreakMode = .byWordWrapping
          textField.maximumNumberOfLines = 0
          textField.preferredMaxLayoutWidth = 400.0
          field.control = textField
        case .textField:
          field.control = NSTextField()
        case .textFieldWithSlider:
          field.control = NSTextField()
          field.slider = NSSlider()
        case .functionsConsistMode, .functionsAnalogMode:
          field.customView = NSView()
        case .esuSpeedTable:
          field.customView = ESUSpeedTable()
        default:
          break
        }
        
        if definition.infoType != .none {
          let info = NSTextField(labelWithString: "")
          info.fontSize = textFontSize
          field.customView = info
        }
        
        /// https://manasaprema04.medium.com/autolayout-fundamental-522f0a6e5790
        
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 500), for: .horizontal)
        field.view = view
        
        if let label = field.label {
          label.stringValue = definition.title
          label.translatesAutoresizingMaskIntoConstraints = false
          label.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 250), for: .horizontal)
          view.addSubview(label)
        }
        
        if let slider = field.slider {
          slider.translatesAutoresizingMaskIntoConstraints = false
          slider.altIncrementValue = 1
          slider.minValue = definition.minValue!
          slider.maxValue = definition.maxValue!
          slider.tag = item.rawValue
          view.addSubview(slider)
        }
        
        if let control = field.control {
          control.translatesAutoresizingMaskIntoConstraints = false
          control.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 1), for: .horizontal)
          control.tag = item.rawValue
          view.addSubview(control)
        }
        
        if let customView = field.customView {
          customView.translatesAutoresizingMaskIntoConstraints = false
          view.addSubview(customView)
        }
        
        if let cv = definition.cv {
          
          field.cvLabel = NSTextField(labelWithString: "")
          
          if let cvLabel = field.cvLabel {
            cvLabel.translatesAutoresizingMaskIntoConstraints = false
            cvLabel.alignment = .right
            view.addSubview(cvLabel)
          }
          
        }
        
        result.append(field)
        
      }
      
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
    case .classLightLogicSequenceLength:
      ClassLightLogicSequenceLength.populate(comboBox: comboBox)
    case .decoderSensorSettings:
      DecoderSensorSettings.populate(comboBox: comboBox)
    case .steamChuffMode:
      SteamChuffMode.populate(comboBox: comboBox)
    case .soundControlBasis:
      SoundControlBasis.populate(comboBox: comboBox)
    case .idleOperationTriggeredFunction, .loadOperationTriggeredFunction:
      TriggeredFunction.populate(comboBox: comboBox)
    case .physicalOutputSmokeUnitControlMode:
      SmokeUnitControlMode.populate(comboBox: comboBox)
    case .physicalOutputExternalSmokeUnitType:
      ExternalSmokeUnitType.populate(comboBox: comboBox)
    case .speedTableIndex:
      comboBox.removeAllItems()
      for index in 1 ... 28 {
        comboBox.addItem(withObjectValue: "\(index)")
      }
    case .speedTablePreset:
      SpeedTablePreset.populate(comboBox: comboBox)
    default:
      break
    }
    
  }
  
}
