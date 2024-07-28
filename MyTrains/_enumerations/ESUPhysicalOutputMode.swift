//
//  ESUPhysicalOutputMode.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/07/2024.
//

import Foundation
import AppKit

public enum ESUPhysicalOutputMode : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case disabled = 0
  case dimmableHeadlight = 1
  case dimmableHeadlightFadeInFadeOut = 2
  case firebox = 3
  case smartFirebox = 4
  case singleStrobe = 5
  case doubleStrobe = 6
  case rotaryBeacon = 7
  case stratoLight = 8
  case ditchLightType1 = 9
  case ditchLightType2 = 10
  case oscillatingHeadlight = 11
  case flashLight = 12
  case marsLight = 13
  case gyraLight = 14
  case endOfTrainFlasher = 15
  case neonLight = 16
  case lowEnergyLight = 17
  case singleStrobeRandom = 18
  case brakeLight = 19
  case sixteenTwoThirdsHzFlickering = 20
  case esuCoupler = 21
  case smokeUnitControlledBySound = 22
  case ventilator = 23
  case seutheSmokeUnit = 24
  case triggerSmokeChuff = 25
  case externalControlledSmokeUnit =  26
  case servoOutput = 27
  case coupler = 28
  case rocoCoupler = 29
  case pantograph = 30
  case powerPackControl = 31
  case servoPower = 32
  case autoCoupleCoil2 = 33
  case servoOutputSteamEngineJohnsonBarControl = 34
  
  // MARK: Constructors
  
  init?(title:String, decoder:Decoder) {
    for temp in ESUPhysicalOutputMode.allCases {
      if temp.title(decoder: decoder) == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [ESUPhysicalOutputMode:String] = [
      .disabled : String(localized:"(disabled)"),
      .dimmableHeadlight : String(localized:"Dimmable headlight"),
      .dimmableHeadlightFadeInFadeOut : String(localized:"Dimmable headlight (fade in/out)"),
      .firebox : String(localized:"Firebox"),
      .smartFirebox : String(localized:"Smart firebox"),
      .singleStrobe : String(localized:"Single strobe"),
      .doubleStrobe : String(localized:"Double strobe"),
      .rotaryBeacon : String(localized:"Rotary beacon"),
      .stratoLight : String(localized:"Strato light"),
      .ditchLightType1 : String(localized:"Ditch light type 1"),
      .ditchLightType2 : String(localized:"Ditch light type 2"),
      .oscillatingHeadlight : String(localized:"Oscillating headlight"),
      .esuCoupler : String(localized:"ESU Coupler"),
      .flashLight : String(localized:"Flash light"),
      .marsLight : String(localized:"Mars light"),
      .gyraLight : String(localized:"Gyra light"),
      .endOfTrainFlasher : String(localized:"End of train flasher"),
      .neonLight : String(localized:"Neon light"),
      .lowEnergyLight : String(localized:"Low energy light"),
      .singleStrobeRandom : String(localized:"Single strobe random"),
      .brakeLight : String(localized:"Brake light"),
      .sixteenTwoThirdsHzFlickering : String(localized:"16 2/3 Hz flickering"),
      .smokeUnitControlledBySound : String(localized:"Smoke unit (controlled by sound)"),
      .ventilator : String(localized:"Ventilator"),
      .seutheSmokeUnit : String(localized:"Seuthe smoke unit"),
      .triggerSmokeChuff : String(localized:"Trigger smoke chuff"),
      .coupler : String(localized:"Coupler"),
      .powerPackControl : String(localized:"Power pack control"),
      .servoPower : String(localized:"Servo power"),
      .autoCoupleCoil2 : String(localized:"Autocoupler coil #2"),
      .externalControlledSmokeUnit : String(localized:"External controlled smoke unit"),
      .rocoCoupler : String(localized:"Roco coupler"),
      .servoOutputSteamEngineJohnsonBarControl : String(localized:"Servo output steam engine Johnson bar control"),
      .servoOutput : String(localized:"Servo output"),
      .pantograph : String(localized:"Pantograph"),

    ]
    
    return titles[self]!
    
  }
  
  public var supportedProperties : Set<ProgrammerToolSettingsProperty> {
    
    let lookup : [ESUPhysicalOutputMode:Set<ProgrammerToolSettingsProperty>] = [
      .disabled : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputOutputMode,
      ],
      .dimmableHeadlight : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputBrightness,
        .physicalOutputUseClassLightLogic,
        .physicalOutputSequencePosition,
        .physicalOutputSpecialFunctions,
        .physicalOutputRule17Forward,
        .physicalOutputRule17Reverse,
        .physicalOutputDimmer,
        .physicalOutputLEDMode,
        .physicalOutputOutputMode,
      ],
      .dimmableHeadlightFadeInFadeOut : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputBrightness,
        .physicalOutputUseClassLightLogic,
        .physicalOutputSequencePosition,
        .physicalOutputSpecialFunctions,
        .physicalOutputRule17Forward,
        .physicalOutputRule17Reverse,
        .physicalOutputDimmer,
        .physicalOutputLEDMode,
        .physicalOutputOutputMode,
      ],
      .firebox : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputBrightness,
        .physicalOutputSpecialFunctions,
        .physicalOutputLEDMode,
        .physicalOutputOutputMode,
      ],
      .smartFirebox : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputBrightness,
        .physicalOutputSpecialFunctions,
        .physicalOutputLEDMode,
        .physicalOutputOutputMode,
      ],
      .singleStrobe  : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputBrightness,
        .physicalOutputPhaseShift,
        .physicalOutputSpecialFunctions,
        .physicalOutputGradeCrossing,
        .physicalOutputOutputMode,
      ],
      .doubleStrobe : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputBrightness,
        .physicalOutputPhaseShift,
        .physicalOutputSpecialFunctions,
        .physicalOutputGradeCrossing,
        .physicalOutputOutputMode,
      ],
      .rotaryBeacon : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputBrightness,
        .physicalOutputPhaseShift,
        .physicalOutputSpecialFunctions,
        .physicalOutputGradeCrossing,
        .physicalOutputLEDMode,
        .physicalOutputOutputMode,
      ],
      .stratoLight : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputBrightness,
        .physicalOutputPhaseShift,
        .physicalOutputSpecialFunctions,
        .physicalOutputGradeCrossing,
        .physicalOutputLEDMode,
        .physicalOutputOutputMode,
      ],
      .ditchLightType1 : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputBrightness,
        .physicalOutputPhaseShift,
        .physicalOutputSpecialFunctions,
        .physicalOutputGradeCrossing,
        .physicalOutputLEDMode,
        .physicalOutputOutputMode,
      ],
      .ditchLightType2 : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputBrightness,
        .physicalOutputPhaseShift,
        .physicalOutputSpecialFunctions,
        .physicalOutputGradeCrossing,
        .physicalOutputLEDMode,
        .physicalOutputOutputMode,
      ],
      .oscillatingHeadlight : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputBrightness,
        .physicalOutputPhaseShift,
        .physicalOutputSpecialFunctions,
        .physicalOutputGradeCrossing,
        .physicalOutputLEDMode,
        .physicalOutputOutputMode,
      ],
      .flashLight : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputBrightness,
        .physicalOutputPhaseShift,
        .physicalOutputSpecialFunctions,
        .physicalOutputGradeCrossing,
        .physicalOutputOutputMode,
      ],
      .marsLight : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputBrightness,
        .physicalOutputPhaseShift,
        .physicalOutputSpecialFunctions,
        .physicalOutputGradeCrossing,
        .physicalOutputLEDMode,
        .physicalOutputOutputMode,
      ],
      .gyraLight : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputBrightness,
        .physicalOutputPhaseShift,
        .physicalOutputSpecialFunctions,
        .physicalOutputGradeCrossing,
        .physicalOutputLEDMode,
        .physicalOutputOutputMode,
      ],
      .endOfTrainFlasher : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputBrightness,
        .physicalOutputPhaseShift,
        .physicalOutputSpecialFunctions,
        .physicalOutputGradeCrossing,
        .physicalOutputLEDMode,
        .physicalOutputOutputMode,
      ],
      .neonLight : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputBrightness,
        .physicalOutputStartupTime,
        .physicalOutputStartupDescription,
        .physicalOutputOutputMode,
      ],
      .lowEnergyLight : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputBrightness,
        .physicalOutputStartupTime,
        .physicalOutputStartupDescription,
        .physicalOutputOutputMode,
      ],
      .singleStrobeRandom : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputBrightness,
        .physicalOutputOutputMode,
      ],
      .brakeLight : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputBrightness,
        .physicalOutputLevel,
        .physicalOutputOutputMode,
      ],
      .sixteenTwoThirdsHzFlickering : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputBrightness,
        .physicalOutputOutputMode,
      ],
      .smokeUnitControlledBySound : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputSmokeUnitControlMode,
        .physicalOutputOutputMode,
      ],
      .ventilator : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputSpeed,
        .physicalOutputAccelerationRate,
        .physicalOutputDecelerationRate,
        .physicalOutputOutputMode,
      ],
      .seutheSmokeUnit : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputHeatWhileLocomotiveStands,
        .physicalOutputMinimumHeatWhileLocomotiveDriving,
        .physicalOutputMaximumHeatWhileLocomotiveDriving,
        .physicalOutputOutputMode,
      ],
      .triggerSmokeChuff : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputChuffPower,
        .physicalOutputFanPower,
        .physicalOutputTimeout,
        .physicalOutputOutputMode,
      ],
      .externalControlledSmokeUnit : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputExternalSmokeUnitType,
        .physicalOutputOutputMode,
      ],
      .servoOutput : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputServoDurationA,
        .physicalOutputServoDurationB,
        .physicalOutputServoPositionA,
        .physicalOutputServoPositionB,
        .physicalOutputServoDoNotDisableServoPulseAtPositionA,
        .physicalOutputServoDoNotDisableServoPulseAtPositionB,
        .physicalOutputOutputMode,
      ],
      .coupler : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputCouplerForce,
        .physicalOutputOutputMode,
      ],
      .rocoCoupler : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputOutputMode,
      ],
      .powerPackControl : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputOutputMode,
      ],
      .servoPower : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputOutputMode,
      ],
      .autoCoupleCoil2 : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputCouplerForce,
        .physicalOutputOutputMode,
      ],
      .servoOutputSteamEngineJohnsonBarControl : [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputServoDurationA,
        .physicalOutputServoDurationB,
        .physicalOutputServoPositionA,
        .physicalOutputServoPositionB,
        .physicalOutputOutputMode,
      ],
      .esuCoupler: [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputOutputMode,
      ],
      .pantograph: [
        .physicalOutputPowerOnDelay,
        .physicalOutputPowerOffDelay,
        .physicalOutputEnableFunctionTimeout,
        .physicalOutputTimeUntilAutomaticPowerOff,
        .physicalOutputOutputMode,
//        .physicalOutputPantographHeight,
      ]
    ]
    
    return lookup[self] ?? []
    
  }
  
  // MARK: Public Methods
  
  public func title(decoder:Decoder) -> String {
    
    let lookup : [ESUPhysicalOutputMode:[ESUDecoderPhysicalOutput:String]] = [
      .pantograph : [
        .aux9:  String(localized: "Pantograph 1"),
        .aux10: String(localized: "Pantograph 2"),
      ],
      .servoOutputSteamEngineJohnsonBarControl : [
        .aux15: String(localized: "Servo output 1 Steam engine Johnson Bar Control"),
        .aux16: String(localized: "Servo output 2 Steam engine Johnson Bar Control"),
        .aux17: String(localized: "Servo output 3 Steam engine Johnson Bar Control"),
        .aux18: String(localized: "Servo output 4 Steam engine Johnson Bar Control"),
        .aux11: String(localized: "Servo output 5 Steam engine Johnson Bar Control"),
        .aux12: String(localized: "Servo output 6 Steam engine Johnson Bar Control"),
      ],
      .servoOutput: [
        .aux15: String(localized: "Servo output 1"),
        .aux16: String(localized: "Servo output 2"),
        .aux17: String(localized: "Servo output 3"),
        .aux18: String(localized: "Servo output 4"),
        .aux11: String(localized: "Servo output 5"),
        .aux12: String(localized: "Servo output 6"),
      ],
      .esuCoupler: [
        .aux7:  String(localized: "ESU coupler 1"),
        .aux15: String(localized: "ESU coupler 1"),
        .aux8:  String(localized: "ESU coupler 2"),
        .aux16: String(localized: "ESU coupler 2"),
      ],
    ]
    
    if let dictionary = lookup[self] {
      if let title = dictionary[decoder.esuDecoderPhysicalOutput] {
        return title
      }
    }

    return self.title

  }
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox, decoder:Decoder) {
    
    let target = comboBox.target
    let action = comboBox.action
    comboBox.target = nil
    comboBox.action = nil
    
    let hasExternalControlledSmokeUnit : Set<ESUDecoderPhysicalOutput> = [
      .aux1,
      .aux1_2,
    ]
    
    let hasRocoCoupler : Set<ESUDecoderPhysicalOutput> = [
      .aux1,
      .aux1_2,
      .aux2,
      .aux2_2,
    ]

    let hasServoOutput : Set<ESUDecoderPhysicalOutput> = [
      .aux15,
      .aux16,
      .aux17,
      .aux18,
      .aux11,
      .aux12,
    ]

    let hasServoOutputJohnson : Set<ESUDecoderPhysicalOutput> = [
      .aux15,
      .aux16,
      .aux17,
      .aux18,
      .aux11,
      .aux12,
    ]

    let hasESUCoupler : Set<ESUDecoderPhysicalOutput> = [
      .aux16,
      .aux7,
      .aux8,
    ]

    let hasExternalSmokeUnit : Set<ESUDecoderPhysicalOutput> = [
      .aux1,
    ]
    
    let hasPantograph : Set<ESUDecoderPhysicalOutput> = [
      .aux9,
      .aux10,
    ]

    comboBox.removeAllItems()
    
    var sorted : [String] = []
    
    let output = decoder.esuDecoderPhysicalOutput
    
    for item in ESUPhysicalOutputMode.allCases {
      var ok = true
      ok = ok && (item != .rocoCoupler || hasRocoCoupler.contains(output))
      ok = ok && (item != .externalControlledSmokeUnit || hasExternalControlledSmokeUnit.contains(output))
      ok = ok && (item != .servoOutput || hasServoOutput.contains(output))
      ok = ok && (item != .servoOutputSteamEngineJohnsonBarControl || hasServoOutputJohnson.contains(output))
      ok = ok && (item != .esuCoupler || hasESUCoupler.contains(output))
      ok = ok && (item != .externalControlledSmokeUnit || hasExternalSmokeUnit.contains(output))
      ok = ok && (item != .pantograph || hasPantograph.contains(output))
      if ok {
        sorted.append(item.title(decoder: decoder))
      }
    }
    
    sorted.sort {$0 < $1}
    
    comboBox.addItems(withObjectValues: sorted)

    comboBox.target = target
    comboBox.action = action

  }

}
