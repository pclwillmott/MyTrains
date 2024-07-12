//
//  DecoderType - Capabilities.swift
//  MyTrains
//
//  Created by Paul Willmott on 12/07/2024.
//

import Foundation

extension DecoderType {
  
  // MARK: Public Properties
  
  public var capabilities : Set<DecoderCapability> {
    
    let capabilityLookup : [DecoderType:Set<DecoderCapability>] = [
    
      .lokSound5 : [],
      .lokSound5DCC : [],
      .lokSound5micro : [],
      .lokSound5microDCC : [],
      .lokSound5microDCCDirect : [],
      .lokSound5microDCCDirectAtlasLegacy : [],
      .lokSound5microDCCDirectAtlasS2 : [],
      .lokSound5nanoDCC : [],
      .lokSound5nanoDCCNext18 : [],
      .lokSound5L : [],
      .lokSound5LDCC : [],
      .lokSound5XL : [],
      .lokSound5Fx : [],
      .lokSound5FxDCC : [],
      .lokSound5MKL : [],
      .lokSound5microKATO : [],
      .lokSoundV4_0 : [],
      .lokSoundSelect : [],
      .lokSoundmicroV4_0 : [],
      .lokSoundSelectdirect_micro : [],
      .lokSoundSelectOEM : [],
      .lokSoundXLV4_0 : [],
      .lokSoundV4_0M4 : [],
      .lokSoundV4_0M4OEM : [],
      .lokSoundLV4_0 : [],
      .lokSoundSelectL : [],
      .lokSoundV3_5 : [],
      .lokSoundXLV3_5 : [],
      .lokSoundV3_0M4 : [],
      .lokSoundmicroV3_5 : [],
      .lokPilot5 : [],
      .lokPilot5DCC : [],
      .lokPilot5micro : [],
      .lokPilot5microDCC : [],
      .lokPilot5microDCCDirect : [],
      .lokPilot5microNext18 : [],
      .lokPilot5microNext18DCC : [],
      .lokPilot5nanoDCC : [],
      .lokPilot5L : [],
      .lokPilot5LDCC : [],
      .lokPilot5Fx : [],
      .lokPilot5FxDCC : [],
      .lokPilot5Fxmicro : [],
      .lokPilot5FxmicroDCC : [],
      .lokPilot5FxmicroNext18 : [],
      .lokPilot5FxmicroNext18DCC : [],
      .lokPilot5MKL : [],
      .lokPilot5MKLDCC : [],
      .lokPilot5Basic : [],
      .lokPilotV4_0 : [],
      .lokPilotV4_0DCC : [],
      .lokPilotV4_0DCCPX : [],
      .lokPilotmicroV4_0 : [],
      .lokPilotmicroV4_0DCC : [],
      .lokPilotV4_0M4 : [],
      .lokPilotXLV4_0 : [],
      .lokPilotFxV4_0 : [],
      .lokPilotV4_0M4MKL : [],
      .lokPilotMicroSlideInV4_0DCC : [],
      .lokPilotStandardV1_0 : [],
      .lokPilotNanoStandardV1_0 : [],
      .lokPilotFxNanoV1_0 : [],
      .lokPilotV3_0 : [],
      .lokPilotV3_0DCC : [],
      .lokPilotV3_0M4 : [],
      .lokPilotV3_0OEM : [],
      .lokPilotmicroV3_0 : [],
      .lokPilotmicroV3_0DCC : [],
      .lokPilotXLV3_0 : [],
      .lokPilotFxV3_0 : [],
      .lokPilotFxmicroV3_0 : [],
  //    .signalPilot : [],
  //    .switchPilot3 : [],
  //    .switchPilot3Plus : [],
  //    .switchPilot3Servo : [],
  //    .switchPilotV2_0 : [],
  //    .switchPilotServoV2_0 : [],
      .essentialSoundUnit : [],
  //    .testCoachEHG388 : [],
  //    .testCoachEHG388M4 : [],
  //    .clubCarWgye : [],
  //    .smokeUnitGauge0G : [],
  //    .kM1SmokeUnit : [],
  //    .esudigitalinteriorlight : [],
  //    .scaleTrainsTenderLight : [],
  //    .pullmanpanoramacarBEX : [],
  //    .pullmanSilberling : [],
  //    .pullmanBLSBt9 : [],
  //    .mbwSilberling : [],
  //    .bachmannMK2F : [],
  //    .walthersML8 : [],
  //    .zeitgeistModelszugspitzcar : [],
    ]

    return capabilityLookup[self]!
    
  }
  
}
