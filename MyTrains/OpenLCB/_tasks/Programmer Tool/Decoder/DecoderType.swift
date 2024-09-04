//
//  DecoderType.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/07/2024.
//

import Foundation
import AppKit

public enum DecoderType : UInt64, Codable, CaseIterable {
  
  // MARK: Enumeration
  
  // ESU LokSound V5
  
  case lokSound5                          = 1  // "LokSound 5"
  case lokSound5DCC                       = 49 // "LokSound 5 DCC"
  case lokSound5micro                     = 74 // "LokSound 5 micro"
  case lokSound5microDCC                  = 7  // "LokSound 5 micro DCC"
  case lokSound5microDCCDirect            = 36 // "LokSound 5 micro DCC Direct"
  case lokSound5microDCCDirectAtlasLegacy = 30 // "LokSound 5 micro DCC Direct Atlas Legacy"
  case lokSound5microDCCDirectAtlasS2     = 68 // "LokSound 5 micro DCC Direct Atlas S2"
  case lokSound5nanoDCC                   = 51 // "LokSound 5 nano DCC"
  case lokSound5nanoDCCNext18             = 15 // "LokSound 5 nano DCC Next18"
  case lokSound5L                         = 45 // "LokSound 5 L"
  case lokSound5LDCC                      = 73 // "LokSound 5 L DCC"
  case lokSound5XL                        = 17 // "LokSound 5 XL"
  case lokSound5Fx                        = 24 // "LokSound 5 Fx"
  case lokSound5FxDCC                     = 57 // "LokSound 5 Fx DCC"
  case lokSound5MKL                       = 39 // "LokSound 5 MKL"
  case lokSound5microKATO                 = 12 // "LokSound 5 micro KATO"

  // ESU LokSound V4

  case lokSoundV4_0                       = 64 // "LokSound V4.0"
  case lokSoundmicroV4_0                  = 43 // "LokSound micro V4.0"
  case lokSoundXLV4_0                     = 8  // "LokSound XL V4.0"
  case lokSoundV4_0M4                     = 14 // "LokSound V4.0 M4"
  case lokSoundV4_0M4OEM                  = 2  // "LokSound V4.0 M4 OEM"
  case lokSoundLV4_0                      = 44 // "LokSound L V4.0"

  // ESU LokSound Select
  
  case lokSoundSelect                     = 70 // "LokSound Select"
  case lokSoundSelectdirect_micro         = 35 // "LokSound Select direct / micro"
  case lokSoundSelectOEM                  = 37 // "LokSound Select OEM"
  case lokSoundSelectL                    = 26 // "LokSound Select L"

  // ESU LokSound V3

  case lokSoundV3_5                       = 33 // "LokSound V3.5"
  case lokSoundXLV3_5                     = 38 // "LokSound XL V3.5"
  case lokSoundV3_0M4                     = 59 // "LokSound V3.0 M4"
  case lokSoundmicroV3_5                  = 6  // "LokSound micro V3.5"

  // ESU LokPilot V5
  
  case lokPilot5                          = 25 // "LokPilot 5"
  case lokPilot5DCC                       = 61 // "LokPilot 5 DCC"
  case lokPilot5micro                     = 55 // "LokPilot 5 micro"
  case lokPilot5microDCC                  = 28 // "LokPilot 5 micro DCC"
  case lokPilot5microDCCDirect            = 47 // "LokPilot 5 micro DCC Direct"
  case lokPilot5microNext18               = 69 // "LokPilot 5 micro Next18"
  case lokPilot5microNext18DCC            = 19 // "LokPilot 5 micro Next18 DCC"
  case lokPilot5nanoDCC                   = 63 // "LokPilot 5 nano DCC"
  case lokPilot5L                         = 29 // "LokPilot 5 L"
  case lokPilot5LDCC                      = 54 // "LokPilot 5 L DCC"
  case lokPilot5Fx                        = 5  // "LokPilot 5 Fx"
  case lokPilot5FxDCC                     = 27 // "LokPilot 5 Fx DCC"
  case lokPilot5Fxmicro                   = 46 // "LokPilot 5 Fx micro"
  case lokPilot5FxmicroDCC                = 20 // "LokPilot 5 Fx micro DCC"
  case lokPilot5FxmicroNext18             = 31 // "LokPilot 5 Fx micro Next18"
  case lokPilot5FxmicroNext18DCC          = 23 // "LokPilot 5 Fx micro Next18 DCC"
  case lokPilot5MKL                       = 72 // "LokPilot 5 MKL"
  case lokPilot5MKLDCC                    = 10 // "LokPilot 5 MKL DCC"
  case lokPilot5Basic                     = 9  // "LokPilot 5 Basic"

  // ESU LokPilot V4
  
  case lokPilotV4_0                       = 50 // "LokPilot V4.0"
  case lokPilotV4_0DCC                    = 3  // "LokPilot V4.0 DCC"
  case lokPilotV4_0DCCPX                  = 58 // "LokPilot V4.0 DCC PX"
  case lokPilotmicroV4_0                  = 60 // "LokPilot micro V4.0"
  case lokPilotmicroV4_0DCC               = 18 // "LokPilot micro V4.0 DCC"
  case lokPilotV4_0M4                     = 11 // "LokPilot V4.0 M4"
  case lokPilotXLV4_0                     = 13 // "LokPilot XL V4.0"
  case lokPilotFxV4_0                     = 53 // "LokPilot Fx V4.0"
  case lokPilotV4_0M4MKL                  = 65 // "LokPilot V4.0 M4 MKL"
  case lokPilotMicroSlideInV4_0DCC        = 62 // "LokPilot Micro SlideIn V4.0 DCC"

  // ESU LokPilot Standard
  
  case lokPilotStandardV1_0               = 71 // "LokPilot Standard V1.0"
  case lokPilotNanoStandardV1_0           = 22 // "LokPilot Nano Standard V1.0"
  case lokPilotFxNanoV1_0                 = 41 // "LokPilot Fx Nano V1.0"

  // ESU LokPilot V3

  case lokPilotV3_0                       = 56 // "LokPilot V3.0"
  case lokPilotV3_0DCC                    = 4  // "LokPilot V3.0 DCC"
  case lokPilotV3_0M4                     = 66 // "LokPilot V3.0 M4"
  case lokPilotV3_0OEM                    = 42 // "LokPilot V3.0 OEM"
  case lokPilotmicroV3_0                  = 52 // "LokPilot micro V3.0"
  case lokPilotmicroV3_0DCC               = 16 // "LokPilot micro V3.0 DCC"
  case lokPilotXLV3_0                     = 21 // "LokPilot XL V3.0"
  case lokPilotFxV3_0                     = 48 // "LokPilot Fx V3.0"
  case lokPilotFxmicroV3_0                = 32 // "LokPilot Fx micro V3.0"

  // ESU LokPilot Basic
  
  case lokPilotBasic                      = 34 // "LokPilot Basic"
  case lokPilotBasicLA                    = 67 // "LokPilot Basic (LA)"

  // ESU SignalPilot

  case signalPilot                        = 75

  // ESU SwitchPilot V3.0

  case switchPilot3                       = 76
  case switchPilot3Plus                   = 77
  case switchPilot3Servo                  = 78

  // ESU SwitchPilot V2.0
  
  case switchPilotV2_0                    = 79
  case switchPilotServoV2_0               = 80

  // ESU SwitchPilot
  
  case switchPilot                        = 95
  case switchPilotServo                   = 96
  case switchPilotServoMA                 = 97
  case switchPilotServo2013               = 98
  
  // ESU Miscellaneous
  
  case essentialSoundUnit                 = 40 // "Essential Sound Unit"
  case testCoachEHG388                    = 81
  case testCoachEHG388M4                  = 82
  case clubCarWgye                        = 83
  case smokeUnitGauge0G                   = 84
  case kM1SmokeUnit                       = 85
  case esudigitalinteriorlight            = 86
  case scaleTrainsTenderLight             = 87
  case pullmanpanoramacarBEX              = 88
  case pullmanSilberling                  = 89
  case pullmanBLSBt9                      = 90
  case mbwSilberling                      = 91
  case bachmannMK2F                       = 92
  case walthersML8                        = 93
  case zeitgeistModelszugspitzcar         = 94

  // NMRA Generic
  
  case nmra                               = 0

  // MARK: Constructors
  
  init?(esuProductId:UInt32) {
    guard let id = DecoderType.esuProductIdLookup[esuProductId] else {
      return nil
    }
    self = id
  }
  
  // MARK: Constructors
  
  init?(title:String) {
    for temp in DecoderType.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }
  
  // MARK: Public Properties
  
  public var title : String {
    return DecoderType.titles[self]!
  }
  
  // MARK: Public Methods
  
  public func isSettingsPropertySupported(property:ProgrammerToolSettingsProperty) -> Bool {
    let requiredCapabilities = property.definition.requiredCapabilities
    return requiredCapabilities.intersection(self.capabilities) == requiredCapabilities
  }
  
  public func isInspectorPropertySupported(property:ProgrammerToolInspectorProperty) -> Bool {
    let requiredCapabilities = property.requiredCapabilities
    return requiredCapabilities.intersection(self.capabilities) == requiredCapabilities
  }

  /*
  public var offsetMethod : ESUPhysicalOutputCVIndexOffsetMethod {
    
    if capabilities.contains(.physicalOutputsPropertiesA) {
      
      if capabilities.contains(.lok5) {
        return .lok5
      }
      else {
        return .lok4
      }
      
    }
    else if capabilities.contains(.physicalOutputsPropertiesB) {
      return .lok3
    }
    
    return .none
    
  }
*/
  
  // MARK: Private Class Properties
  
  private static let titles : [DecoderType: String] = [
    .switchPilot : "SwitchPilot",
    .switchPilotServo : "SwitchPilot Servo",
    .switchPilotServoMA : "SwitchPilot Servo (MA)",
    .switchPilotServo2013 : "SwitchPilot Servo (2013)",
    .nmra : "NMRA Standard Decoder",
    .lokPilotV4_0DCCPX : "LokPilot V4.0 DCC PX",
    .lokPilot5L : "LokPilot 5 L",
    .lokPilotV3_0 : "LokPilot V3.0",
    .lokPilot5FxmicroDCC : "LokPilot 5 Fx micro DCC",
    .lokSoundmicroV4_0 : "LokSound micro V4.0",
    .lokPilotBasic : "LokPilot Basic",
    .lokSoundSelect : "LokSound Select",
    .lokSound5 : "LokSound 5",
    .lokPilot5FxmicroNext18DCC : "LokPilot 5 Fx micro Next18 DCC",
    .lokPilotV4_0M4 : "LokPilot V4.0 M4",
    .lokSoundSelectL : "LokSound Select L",
    .lokSound5micro : "LokSound 5 micro",
    .lokPilot5Basic : "LokPilot 5 Basic",
    .lokPilot5micro : "LokPilot 5 micro",
    .lokPilotmicroV4_0 : "LokPilot micro V4.0",
    .lokPilotFxNanoV1_0 : "LokPilot Fx Nano V1.0",
    .lokPilotMicroSlideInV4_0DCC : "LokPilot Micro SlideIn V4.0 DCC",
    .lokSoundV4_0M4 : "LokSound V4.0 M4",
    .lokSound5microDCC : "LokSound 5 micro DCC",
    .lokPilotStandardV1_0 : "LokPilot Standard V1.0",
    .lokPilot5 : "LokPilot 5",
    .lokSoundV3_5 : "LokSound V3.5",
    .lokPilot5microNext18 : "LokPilot 5 micro Next18",
    .lokSound5XL : "LokSound 5 XL",
    .lokSoundV4_0M4OEM : "LokSound V4.0 M4 OEM",
    .lokSoundXLV3_5 : "LokSound XL V3.5",
    .lokSound5microDCCDirect : "LokSound 5 micro DCC Direct",
    .lokPilot5MKL : "LokPilot 5 MKL",
    .lokPilot5FxDCC : "LokPilot 5 Fx DCC",
    .lokPilot5Fxmicro : "LokPilot 5 Fx micro",
    .lokSound5microDCCDirectAtlasS2 : "LokSound 5 micro DCC Direct Atlas S2",
    .lokPilot5Fx : "LokPilot 5 Fx",
    .lokSound5MKL : "LokSound 5 MKL",
    .lokSound5nanoDCCNext18 : "LokSound 5 nano DCC Next18",
    .lokSoundV4_0 : "LokSound V4.0",
    .lokSound5Fx : "LokSound 5 Fx",
    .lokPilot5MKLDCC : "LokPilot 5 MKL DCC",
    .lokPilot5microDCCDirect : "LokPilot 5 micro DCC Direct",
    .lokPilot5LDCC : "LokPilot 5 L DCC",
    .lokPilotV4_0DCC : "LokPilot V4.0 DCC",
    .lokPilotXLV4_0 : "LokPilot XL V4.0",
    .lokPilotmicroV3_0 : "LokPilot micro V3.0",
    .lokPilotmicroV4_0DCC : "LokPilot micro V4.0 DCC",
    .lokSoundSelectdirect_micro : "LokSound Select direct / micro",
    .lokPilotmicroV3_0DCC : "LokPilot micro V3.0 DCC",
    .lokSoundmicroV3_5 : "LokSound micro V3.5",
    .lokPilotBasicLA : "LokPilot Basic (LA)",
    .lokPilotFxmicroV3_0 : "LokPilot Fx micro V3.0",
    .lokSoundXLV4_0 : "LokSound XL V4.0",
    .lokSoundSelectOEM : "LokSound Select OEM",
    .lokSound5nanoDCC : "LokSound 5 nano DCC",
    .essentialSoundUnit : "Essential Sound Unit",
    .lokPilotNanoStandardV1_0 : "LokPilot Nano Standard V1.0",
    .lokSoundV3_0M4 : "LokSound V3.0 M4",
    .lokSound5LDCC : "LokSound 5 L DCC",
    .lokPilotV3_0OEM : "LokPilot V3.0 OEM",
    .lokPilotFxV3_0 : "LokPilot Fx V3.0",
    .lokPilotXLV3_0 : "LokPilot XL V3.0",
    .lokPilot5DCC : "LokPilot 5 DCC",
    .lokSound5microDCCDirectAtlasLegacy : "LokSound 5 micro DCC Direct Atlas Legacy",
    .lokSound5L : "LokSound 5 L",
    .lokPilotV4_0M4MKL : "LokPilot V4.0 M4 MKL",
    .lokSoundLV4_0 : "LokSound L V4.0",
    .lokPilotV3_0M4 : "LokPilot V3.0 M4",
    .lokPilot5FxmicroNext18 : "LokPilot 5 Fx micro Next18",
    .lokSound5FxDCC : "LokSound 5 Fx DCC",
    .lokPilot5microDCC : "LokPilot 5 micro DCC",
    .lokPilotFxV4_0 : "LokPilot Fx V4.0",
    .lokPilot5nanoDCC : "LokPilot 5 nano DCC",
    .lokPilotV4_0 : "LokPilot V4.0",
    .lokPilotV3_0DCC : "LokPilot V3.0 DCC",
    .lokPilot5microNext18DCC : "LokPilot 5 micro Next18 DCC",
    .lokSound5DCC : "LokSound 5 DCC",
    .lokSound5microKATO : "LokSound 5 micro KATO",
    .signalPilot : "SignalPilot",
    .switchPilot3 : "SwitchPilot 3",
    .switchPilot3Plus : "SwitchPilot 3 Plus",
    .switchPilot3Servo : "SwitchPilot 3 Servo",
    .switchPilotV2_0 : "SwitchPilot V2.0",
    .switchPilotServoV2_0 : "SwitchPilot Servo V2.0",
    .testCoachEHG388 : "Test coach EGH388",
    .testCoachEHG388M4 : "Test coach EGH388 M4",
    .clubCarWgye : "Club car WGye",
    .smokeUnitGauge0G : "Smoke Unit (Gauge 0, G)",
    .kM1SmokeUnit : "KM1 Smoke Unit",
    .esudigitalinteriorlight : "ESU digital interior light",
    .scaleTrainsTenderLight : "Scale Trains Tender Light",
    .pullmanpanoramacarBEX : "Pullman panorama car BEX",
    .pullmanSilberling : "Pullman Silberling",
    .pullmanBLSBt9 : "Pullman BLS Bt9",
    .mbwSilberling : "MBW Silberling",
    .bachmannMK2F : "Bachmann MK2F",
    .walthersML8 : "Walthers ML8",
    .zeitgeistModelszugspitzcar : "Zeitgeist Models zugspitz car",
  ]
  
  private static var _decoderDefinitions : [DecoderType:DecoderDefinition]?
  
  private static var _esuProductIdLookup : [UInt32:DecoderType]?

  // MARK: Public Class Properties
  
  public static var decoderDefinitions : [DecoderType:DecoderDefinition] {
    
    if _decoderDefinitions == nil {
      
      do {
        
        let url = URL(fileURLWithPath: "\(Bundle.main.resourcePath!)/DECODER_INFO.json")
        
        let json = try Data(contentsOf: url)
        
        let jsonDecoder = JSONDecoder()
        
        _decoderDefinitions = try jsonDecoder.decode([DecoderType:DecoderDefinition].self, from: json)
        
      }
      catch {
        #if DEBUG
        debugLog("Failed to load DECODER_INFO.json")
        #endif
      }
      
    }
    
    return _decoderDefinitions!
    
  }
  
  public static var esuProductIdLookup : [UInt32:DecoderType] {
    
    if _esuProductIdLookup == nil {
      
      var lookup : [UInt32:DecoderType] = [:]
      
      let definitions = decoderDefinitions
      
      for (decoderType, definition) in definitions {
        
        for productId in definition.esuProductIds {
          lookup[productId] = decoderType
        }
        
      }
      
      _esuProductIdLookup = lookup
      
    }
    
    return _esuProductIdLookup!
    
  }
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in DecoderType.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

}
