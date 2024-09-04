//
//  ESUPhysicalOutputMode.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/07/2024.
//

import Foundation
import AppKit

public enum ESUPhysicalOutputMode : UInt8, CaseIterable, Codable {
  
  // MARK: Enumeration
  
  /// The rawValues no longer match the CV byte values.
  ///
  case disabled                                = 0
  case dimmableHeadlight                       = 1
  case dimmableHeadlightFadeInFadeOut          = 2
  case firebox                                 = 3
  case smartFirebox                            = 4
  case singleStrobe                            = 5
  case doubleStrobe                            = 6
  case rotaryBeacon                            = 7
  case stratoLight                             = 8
  case ditchLightType1                         = 9
  case ditchLightType2                         = 10
  case oscillatingHeadlight                    = 11
  case flashLight                              = 12
  case marsLight                               = 13
  case gyraLight                               = 14
  case endOfTrainFlasher                       = 15
  case neonLight                               = 16
  case lowEnergyLight                          = 17
  case singleStrobeRandom                      = 18
  case brakeLight                              = 19
  case sixteenTwoThirdsHzFlickering            = 20
  case esuCoupler                              = 21
  case smokeUnitControlledBySound              = 22
  case ventilator                              = 23
  case seutheSmokeUnit                         = 24
  case triggerSmokeChuff                       = 25
  case externalControlledSmokeUnit             = 26
  case servoOutput                             = 27
  case coupler                                 = 28
  case rocoCoupler                             = 29
  case pantograph                              = 30
  case powerPackControl                        = 31
  case servoPower                              = 32
  case autoCoupleCoil2                         = 33
  case servoOutputSteamEngineJohnsonBarControl = 34

  case dimmableHeadlightLok3                   = 100
  case flashLightPhase1Lok3                    = 101
  case flashLightPhase2Lok3                    = 102
  case singleStrobeLok3                        = 103
  case doubleStrobeLok3                        = 104
  case fireboxLok3                             = 105
  case seutheSmokeUnitLok3                     = 106
  case dimmableHeadlightFadeInFadeOutLok3      = 107
  case marsLightLok3                           = 108
  case gyraLightLok3                           = 109
  case rule17ForwardLok3                       = 110
  case rule17ReverseLok3                       = 111
  case pulseLok3                               = 112
  case ditchLightPhase1Lok3                    = 113
  case ditchLightPhase2Lok3                    = 114

  // MARK: Constructors
  
  init?(title:String, decoder:Decoder) {
    
    if let lookup = ESUPhysicalOutputMode.valueLookup[decoder.esuPhysicalOutputCVIndexOffsetMethod] {
      
      for temp in ESUPhysicalOutputMode.allCases {
        if lookup.keys.contains(temp), temp.title(decoder: decoder) == title {
          self = temp
          return
        }
      }
      
    }
    
    return nil
    
  }

  init?(value:UInt8, decoder:Decoder) {
    
    if let lookup = ESUPhysicalOutputMode.valueLookup[decoder.esuPhysicalOutputCVIndexOffsetMethod] {
      for (key, tempValue) in lookup {
        if value == tempValue {
          self = key
          return
        }
      }
    }
    
    return nil
    
  }
  
  // MARK: Public Properties
  
  public var title : String {
    return ESUPhysicalOutputMode.titles[self]!
  }

  // MARK: Public Methods
  
  public func title(decoder:Decoder) -> String {
    
    if let dictionary = ESUPhysicalOutputMode.lookup[self] {
      if let title = dictionary[decoder.esuDecoderPhysicalOutput] {
        return title
      }
    }

    return self.title

  }
  
  public func cvValue(decoder:Decoder) -> UInt8? {
    
    if let lookup = ESUPhysicalOutputMode.valueLookup[decoder.esuPhysicalOutputCVIndexOffsetMethod], let value = lookup[self] {
      return value
    }
    
    return nil
    
  }
  
  // MARK: Private Class Properties
  
  private static let valueLookup : [ESUPhysicalOutputCVIndexOffsetMethod:[ESUPhysicalOutputMode:UInt8]] = [
    
    .none: [:],
    
    .lok5: [
      .disabled                                : 0,
      .dimmableHeadlight                       : 1,
      .dimmableHeadlightFadeInFadeOut          : 2,
      .firebox                                 : 3,
      .smartFirebox                            : 4,
      .singleStrobe                            : 5,
      .doubleStrobe                            : 6,
      .rotaryBeacon                            : 7,
      .stratoLight                             : 8,
      .ditchLightType1                         : 9,
      .ditchLightType2                         : 10,
      .oscillatingHeadlight                    : 11,
      .flashLight                              : 12,
      .marsLight                               : 13,
      .gyraLight                               : 14,
      .endOfTrainFlasher                       : 15,
      .neonLight                               : 16,
      .lowEnergyLight                          : 17,
      .singleStrobeRandom                      : 18,
      .brakeLight                              : 19,
      .sixteenTwoThirdsHzFlickering            : 20,
      .esuCoupler                              : 21,
      .smokeUnitControlledBySound              : 22,
      .ventilator                              : 23,
      .seutheSmokeUnit                         : 24,
      .triggerSmokeChuff                       : 25,
      .externalControlledSmokeUnit             : 26,
      .servoOutput                             : 27,
      .coupler                                 : 28,
      .rocoCoupler                             : 29,
      .pantograph                              : 30,
      .powerPackControl                        : 31,
      .servoPower                              : 32,
      .autoCoupleCoil2                         : 33,
      .servoOutputSteamEngineJohnsonBarControl : 34,
    ],
    
    .lok4: [
      .disabled                                : 0,
      .dimmableHeadlight                       : 1,
      .dimmableHeadlightFadeInFadeOut          : 2,
      .firebox                                 : 3,
      .smartFirebox                            : 4,
      .singleStrobe                            : 5,
      .doubleStrobe                            : 6,
      .rotaryBeacon                            : 7,
      .stratoLight                             : 8,
      .ditchLightType1                         : 9,
      .ditchLightType2                         : 10,
      .oscillatingHeadlight                    : 11,
      .flashLight                              : 12,
      .marsLight                               : 13,
      .gyraLight                               : 14,
      .endOfTrainFlasher                       : 15,
      .neonLight                               : 16,
      .lowEnergyLight                          : 17,
      .singleStrobeRandom                      : 18,
      .brakeLight                              : 19,
      .sixteenTwoThirdsHzFlickering            : 20,
      .esuCoupler                              : 21,
      .smokeUnitControlledBySound              : 22,
      .ventilator                              : 23,
      .seutheSmokeUnit                         : 24,
      .triggerSmokeChuff                       : 25,
      .externalControlledSmokeUnit             : 26,
      .servoOutput                             : 27,
      .coupler                                 : 28,
      .rocoCoupler                             : 29,
      .pantograph                              : 30,
      .powerPackControl                        : 31,
      .servoPower                              : 32,
      .autoCoupleCoil2                         : 33,
      .servoOutputSteamEngineJohnsonBarControl : 34,
    ],

    .lok3: [
      .dimmableHeadlightLok3              : 0b00000000,
      .flashLightPhase1Lok3               : 0b00010000,
      .flashLightPhase2Lok3               : 0b00100000,
      .singleStrobeLok3                   : 0b00110000,
      .doubleStrobeLok3                   : 0b01000000,
      .fireboxLok3                        : 0b01010000,
      .seutheSmokeUnitLok3                : 0b01100000,
      .dimmableHeadlightFadeInFadeOutLok3 : 0b01110000,
      .marsLightLok3                      : 0b10000000,
      .gyraLightLok3                      : 0b10010000,
      .rule17ForwardLok3                  : 0b10100000,
      .rule17ReverseLok3                  : 0b10110000,
      .pulseLok3                          : 0b11000000,
      .ditchLightPhase1Lok3               : 0b11010000,
      .ditchLightPhase2Lok3               : 0b11100000,
    ]
    
  ]
  
  private static let titles : [ESUPhysicalOutputMode:String] = [
    .disabled                                : String(localized:"(disabled)"),
    .dimmableHeadlight                       : String(localized:"Dimmable headlight"),
    .dimmableHeadlightFadeInFadeOut          : String(localized:"Dimmable headlight (fade in/out)"),
    .firebox                                 : String(localized:"Firebox"),
    .smartFirebox                            : String(localized:"Smart firebox"),
    .singleStrobe                            : String(localized:"Single strobe"),
    .doubleStrobe                            : String(localized:"Double strobe"),
    .rotaryBeacon                            : String(localized:"Rotary beacon"),
    .stratoLight                             : String(localized:"Strato light"),
    .ditchLightType1                         : String(localized:"Ditch light type 1"),
    .ditchLightType2                         : String(localized:"Ditch light type 2"),
    .oscillatingHeadlight                    : String(localized:"Oscillating headlight"),
    .esuCoupler                              : String(localized:"ESU Coupler"),
    .flashLight                              : String(localized:"Flash light"),
    .marsLight                               : String(localized:"Mars light"),
    .gyraLight                               : String(localized:"Gyra light"),
    .endOfTrainFlasher                       : String(localized:"End of train flasher"),
    .neonLight                               : String(localized:"Neon light"),
    .lowEnergyLight                          : String(localized:"Low energy light"),
    .singleStrobeRandom                      : String(localized:"Single strobe random"),
    .brakeLight                              : String(localized:"Brake light"),
    .sixteenTwoThirdsHzFlickering            : String(localized:"16 2/3 Hz flickering"),
    .smokeUnitControlledBySound              : String(localized:"Smoke unit (controlled by sound)"),
    .ventilator                              : String(localized:"Ventilator"),
    .seutheSmokeUnit                         : String(localized:"Seuthe smoke unit"),
    .triggerSmokeChuff                       : String(localized:"Trigger smoke chuff"),
    .coupler                                 : String(localized:"Coupler"),
    .powerPackControl                        : String(localized:"Power pack control"),
    .servoPower                              : String(localized:"Servo power"),
    .autoCoupleCoil2                         : String(localized:"Autocoupler coil #2"),
    .externalControlledSmokeUnit             : String(localized:"External controlled smoke unit"),
    .rocoCoupler                             : String(localized:"Roco coupler"),
    .servoOutputSteamEngineJohnsonBarControl : String(localized:"Servo output steam engine Johnson bar control"),
    .servoOutput                             : String(localized:"Servo output"),
    .pantograph                              : String(localized:"Pantograph"),
    .dimmableHeadlightLok3                   : String(localized:"Dimmable headlight"),
    .flashLightPhase1Lok3                    : String(localized:"Flash light (Phase 1)"),
    .flashLightPhase2Lok3                    : String(localized:"Flash light (Phase 2)"),
    .singleStrobeLok3                        : String(localized:"Single strobe"),
    .doubleStrobeLok3                        : String(localized:"Double strobe"),
    .fireboxLok3                             : String(localized:"Firebox"),
    .seutheSmokeUnitLok3                     : String(localized:"Seuthe smoke unit"),
    .dimmableHeadlightFadeInFadeOutLok3      : String(localized:"Dimmable headlight (fade in/out)"),
    .marsLightLok3                               : String(localized:"Mars light"),
    .gyraLightLok3                               : String(localized:"Gyra light"),
    .rule17ForwardLok3                       : String(localized:"Rule 17 Forward"),
    .rule17ReverseLok3                       : String(localized:"Rule 17 Reverse"),
    .pulseLok3                               : String(localized:"Pulse"),
    .ditchLightPhase1Lok3                    : String(localized:"Ditch light (Phase 1)"),
    .ditchLightPhase2Lok3                    : String(localized:"Ditch light (Phase 2)"),
    ]
    
  // MARK: Private Class Methods
  
  private static let lookup : [ESUPhysicalOutputMode:[ESUDecoderPhysicalOutput:String]] = [
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

  // MARK: Public Class Methods
  
  public static func possibleOutputModes(decoder:Decoder) -> Set<ESUPhysicalOutputMode> {
 
    var result : Set<ESUPhysicalOutputMode> = []

    guard let lookup = valueLookup[decoder.esuPhysicalOutputCVIndexOffsetMethod] else {
      return result
    }
    
    for item in ESUPhysicalOutputMode.allCases {
      
      if lookup.keys.contains(item) {
        result.insert(item)
      }
      
    }

    return result
    
  }
  
  public static func applicableOutputModes(output:ESUDecoderPhysicalOutput, decoder:Decoder) -> Set<ESUPhysicalOutputMode> {
    
    var result : Set<ESUPhysicalOutputMode> = []

    guard let lookup = valueLookup[decoder.esuPhysicalOutputCVIndexOffsetMethod] else {
      return result
    }
    /*
    let hasExternalControlledSmokeUnit : Set<ESUDecoderPhysicalOutput> = [
      .aux1_1,
      .aux1_2,
    ]
    
    let hasRocoCoupler : Set<ESUDecoderPhysicalOutput> = [
      .aux1_1,
      .aux1_2,
      .aux2_1,
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
      .aux15,
      .aux7,
      .aux8,
    ]

    let hasExternalSmokeUnit : Set<ESUDecoderPhysicalOutput> = [
      .aux1_1,
      .aux1_2,
    ]
    
    let hasPantograph : Set<ESUDecoderPhysicalOutput> = [
      .aux9,
      .aux10,
    ]

    let noESUCoupler : Set<DecoderType> = [
      .lokSound5microDCCDirect,
    ]
    
    let noServoPower : Set<DecoderType> = [
      .lokSound5microDCCDirect,
      .lokSound5microDCCDirectAtlasLegacy,
      .lokSound5microDCCDirectAtlasS2,
    ]
    */
    
    if let applicable = decoder.applicableOutputModes[output] {
    
      for item in ESUPhysicalOutputMode.allCases {
        
        if lookup.keys.contains(item), applicable.contains(item) {
          
          var ok = true
          /*
          ok = ok && (item != .rocoCoupler || hasRocoCoupler.contains(output))
          ok = ok && (item != .externalControlledSmokeUnit || hasExternalControlledSmokeUnit.contains(output))
          ok = ok && (item != .servoOutput || hasServoOutput.contains(output))
          ok = ok && (item != .servoOutputSteamEngineJohnsonBarControl || hasServoOutputJohnson.contains(output))
          ok = ok && (item != .esuCoupler || (hasESUCoupler.contains(output) && !noESUCoupler.contains(decoder.decoderType)))
          ok = ok && (item != .externalControlledSmokeUnit || hasExternalSmokeUnit.contains(output))
          ok = ok && (item != .pantograph || hasPantograph.contains(output))
          ok = ok && (item != .servoPower || !noServoPower.contains(decoder.decoderType))
          */
          if ok {
            result.insert(item)
          }
          
        }
        
      }
      
    }

    return result
    
  }
  
  public static func populate(comboBox:NSComboBox, decoder:Decoder) {
    
    let target = comboBox.target
    let action = comboBox.action
    comboBox.target = nil
    comboBox.action = nil
    
    comboBox.removeAllItems()
    
    var sorted : [String] = []
    
    let output = decoder.esuDecoderPhysicalOutput
    
    let applicable = applicableOutputModes(output: output, decoder: decoder)
    
    for item in ESUPhysicalOutputMode.allCases {
      
      if applicable.contains(item) {
        sorted.append(item.title(decoder: decoder))
      }
      
    }
    
//    sorted.sort {$0 < $1}
    
    comboBox.addItems(withObjectValues: sorted)

    comboBox.target = target
    comboBox.action = action

  }

}
