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
  
  public var definition : ProgrammerToolSettingsPropertyDefinition {
    return ProgrammerToolSettingsProperty.definitions[self]!
  }
  
  public var section : ProgrammerToolSettingsSection {
    return definition.section
  }
  
  public var controlType : ProgrammerToolControlType {
    return definition.controlType
  }
  
  public func cvLabel(decoder:Decoder) -> String? {
    
    guard let definition = ProgrammerToolSettingsProperty.definitions[self], let cvs = definition.cv, let masks = definition.mask, let cvIndexingMethod = definition.cvIndexingMethod else {
      return nil
    }
    
    func decode(cv:CV, mask:UInt8) -> String {
      
      var bits = ""
      
      if mask != 0xff {
        
        var temp = ByteMask.d7
        var index = 7
        var firstBit : Int?
        var lastBit : Int?
        
        while temp != 0 {
          if (mask & temp) == temp {
            if firstBit == nil {
              firstBit = index
            }
            lastBit = index
          }
          temp >>= 1
          index -= 1
        }
        
        if let firstBit, let lastBit {
          if firstBit == lastBit {
            bits = ".\(firstBit)"
          }
          else {
            bits = ".\(firstBit):\(lastBit)"
          }
        }
        
      }
      
      return "CV\(cv.cv)\(bits)"
      
    }
    
    let offset = decoder.cvIndexOffset(indexingMethod: cvIndexingMethod)
    
    let isMultiple = cvs.count > 2
    
    if isMultiple {
      
      var isContiguous = true
      
      for index in 1 ... cvs.count - 1 {
        let previous = cvs[index - 1] + offset
        if let test = CV(cv31: previous.cv31, cv32: previous.cv32, cv: previous.cv + 1, indexMethod: previous.indexMethod) {
          if !(cvs[index] + offset == test && masks[index] == masks[index - 1]) {
            isContiguous = false
            break
          }
        }
        else {
          isContiguous = false
          break
        }
      }
      
      if isContiguous {
        let first = cvs.first! + offset
        var result = "\(decode(cv: first, mask: masks.first!)) to \(decode(cv: cvs.last! + offset, mask: masks.last!))"
        if first.cv31 != 0 || first.cv32 != 0 {
          result += " (CV31 = \(first.cv31), CV32 = \(first.cv32))"
        }
        return result
      }
      
    }
    
    var result = ""
    
    for index in 0 ... cvs.count - 1 {
      if !result.isEmpty {
        result += ", "
      }
      let temp = cvs[index] + offset
      result += decode(cv: temp, mask: masks[index])
      if temp.cv31 != 0 || temp.cv32 != 0 {
        result += " (CV31=\(temp.cv31), CV32=\(temp.cv32))"
      }
    }
    
    return result

  }
  
  // MARK: Public Class Properties
  
  public static var inspectorPropertyFields: [ProgrammerToolSettingsPropertyField] {
    
    var result : [ProgrammerToolSettingsPropertyField] = []
    
//    let labelFontSize : CGFloat = 10.0
    let textFontSize  : CGFloat = 11.0
    
    for item in ProgrammerToolSettingsProperty.allCases {
      
      if let definition = ProgrammerToolSettingsProperty.definitions[item] {
        
        var field : ProgrammerToolSettingsPropertyField = (view:nil, label:nil, control:nil, item, customView:nil, cvLabel:nil, slider:nil)
        
        if definition.controlType != .checkBox && definition.controlType != .description && definition.controlType != .warning {
          field.label = NSTextField(labelWithString: definition.title)
        }
        
        switch definition.controlType {
        case .checkBox:
          let checkBox = NSButton()
          checkBox.setButtonType(.switch)
          checkBox.title = definition.title
          field.control = checkBox
        case .comboBox:
          let comboBox = MyComboBox()
          comboBox.isEditable = false
          field.control = comboBox
          initComboBox(property: field.property, comboBox: comboBox)
        case .comboBoxDynamic:
          let comboBox = MyComboBox()
          comboBox.isEditable = false
          field.control = comboBox
        case .warning:
          field.customView = NSImageView(image: MyIcon.warning.image!)
          field.control = NSTextField(labelWithString: definition.title)
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
        
        if definition.cv != nil {
          
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
