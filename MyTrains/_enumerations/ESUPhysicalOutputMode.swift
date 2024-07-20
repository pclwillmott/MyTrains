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
  
  case disabled = 0                       // CV259 = 0 CV275 = 1
  case dimmableHeadlight = 1              // CV259 = 1 CV275 = 1
  case dimmableHeadlightFadeInFadeOut = 2 // CV259 = 2 CV275 = 1
  case firebox = 3                        // CV259 = 3 CV275 = 1
  case smartFirebox = 4                   // CV259 = 4 CV275 = 1
  case singleStrobe = 5                   // CV259 = 5 CV275 = 1
  case doubleStrobe = 6                   // CV259 = 6 CV275 = 1
  case rotaryBeacon = 7                   // CV259 = 7 CV275 = 1
  case stratoLight = 8                    // CV259 = 8 CV275 = 1
  case ditchLightType1 = 9                // CV259 = 9 CV275 = 1
  case ditchLightType2 = 10               // CV259 = 10 CV275 = 1
  case oscillatingHeadlight = 11          // CV259 = 11 CV275 = 1
  case flashLight = 12                    // CV259 = 12 CV275 = 1
  case marsLight = 13                     // CV259 = 13 CV275 = 1
  case gyraLight = 14                     // CV259 = 14 CV275 = 1
  case endOfTrainFlasher = 15             // CV259 = 15 CV275 = 1
  case neonLight = 16                     // CV259 = 16 CV275 = 1
  case lowEnergyLight = 17                // CV259 = 17 CV275 = 1
  case singleStrokeRandom = 18            // CV259 = 18 CV275 = 1
  case brakeLight = 19                    // CV259 = 19 CV275 = 1
  case sixteenTwoThirdsHzFlickering = 20  // CV259 = 20 CV275 = 1
  case esuCoupler = 21
  case smokeUnitControlledBySound = 22    // CV259 = 22 CV275 = 1
  case ventilator = 23                    // CV259 = 23 CV275 = 1
  case seutheSmokeUnit = 24               // CV259 = 24 CV275 = 1
  case triggerSmokeChuff = 25             // CV259 = 25 CV275 = 1
  case externalControlledSmokeUnit =  26  // CV259 =  CV275 =
  case servoOutput = 27
  case coupler = 28                       // CV259 = 28 CV275 = 1
  case RocoCoupler = 29
  // 30 Missing
  case powerPackControl = 31              // CV259 = 31 CV275 = 1
  case servoPower = 32                    // CV259 = 32 CV275 = 1
  case autoCoupleCoil2 = 33               // CV259 = 33 CV275 = 1
  case servoOutputSteamEngineJohnsonBarControl = 34
  
  // MARK: Constructors
  
  init?(title:String) {
    for temp in ESUPhysicalOutputMode.allCases {
      if temp.title == title {
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
      .singleStrokeRandom : String(localized:"Single strobe random"),
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
      .RocoCoupler : String(localized:"Roco coupler"),
      .servoOutputSteamEngineJohnsonBarControl : String(localized:"Servo output steam engine Johnson bar control"),
      .servoOutput : String(localized:"Servo output"),

    ]
    
    return titles[self]!
    
  }
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox, decoder:Decoder) {
    
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
    ]

    let hasServoOutputJohnson : Set<ESUDecoderPhysicalOutput> = [
      .aux17,
      .aux18,
    ]

    let hasESUCoupler : Set<ESUDecoderPhysicalOutput> = [
      .aux16,
      .aux7,
    ]

    comboBox.removeAllItems()
    
    var sorted : [String] = []
    
    let output = decoder.esuDecoderPhysicalOutput
    
    for item in ESUPhysicalOutputMode.allCases {
      var ok = true
      ok = ok && (item != .RocoCoupler || hasRocoCoupler.contains(output))
      ok = ok && (item != .externalControlledSmokeUnit || hasExternalControlledSmokeUnit.contains(output))
      ok = ok && (item != .servoOutput || hasServoOutput.contains(output))
      ok = ok && (item != .servoOutputSteamEngineJohnsonBarControl || hasServoOutputJohnson.contains(output))
      ok = ok && (item != .esuCoupler || hasESUCoupler.contains(output))
      if ok {
        sorted.append(item.title)
      }
    }
    
    sorted.sort {$0 < $1}
    
    comboBox.addItems(withObjectValues: sorted)
    
  }

}
