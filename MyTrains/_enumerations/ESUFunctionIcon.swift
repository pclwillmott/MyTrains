//
//  ESUFunctionIcon.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/07/2024.
//

import Foundation
import AppKit

public enum ESUFunctionIcon : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case disabled                 = 1 
  case genericFunction          = 2 
  case headlight                = 3 
  case interiorLight            = 4 
  case cabLight                 = 5 
  case driveSound               = 6 
  case genericSound             = 7 
  case stationAnnouncement      = 8 
  case routingSpeed             = 9 
  case startStopDelay           = 10 
  case automaticCoupler         = 11 
  case smokeUnit                = 12 
  case pantograph               = 13 
  case highbeam                 = 14 
  case bell                     = 15 
  case horn                     = 16 
  case whistle                  = 17 
  case doors                    = 18 
  case fan                      = 19 
  case shovelWork               = 20 
  case shift                    = 21 
  case plateLight               = 22 
  case brakeSound               = 23 
  case craneRaiseLower          = 24 
  case craneHookRaiseLower      = 25 
  case wheelLight               = 26 
  case craneTurn                = 27 
  case steamBlow                = 28 
  case radioSound               = 29 
  case couplerSound             = 30 
  case trackSound               = 31 
  case notchUp                  = 32 
  case notchDown                = 33 
  case thundererWhistle         = 34 
  case bufferSound              = 35 
  case cabLight2                = 36 
  case curveSound               = 38 
  case turnoutSound             = 39 
  case reliefValve              = 40 
  case oilBurner                = 41 
  case stoker                   = 42 
  case dynamicBrake             = 43 
  case compressor               = 44 
  case airBlow                  = 45 
  case handbrake                = 46 
  case airPump                  = 47 
  case waterPump                = 48 
  // 49 Missing
  case ditchLight               = 50 
  case marsLight                = 51 
  // 52 missing
  // 53 missing
  case rotaryBeacon             = 54 
  case firebox                  = 55 
  // 56 missing
  case sanding                  = 57 
  case drainValve               = 58 
  case setBrakeAutomaticRelease = 59 
  case shuntingLight            = 60 
  case boardLight               = 61 
  case injector                 = 62 
  case auxilaryDiesel           = 63 
  // 64 missing
  case doppler                  = 65 
  case whistleShort             = 66 
  // 67 missing
  case heating                  = 68 
  case generatorSteamLoco       = 69 
  // 70 - 73 missing
  case sifaMessage              = 74 
  // 75 missing
  case heavyLoad                = 76 
  case coastOperation           = 77 
  case rearLight                = 78 
  case frontLight               = 79 
  case highbeamRear             = 80 
  case highbeamFront            = 81 
  // 81 - 82 missing
  case tableLight1              = 84 
  // 85 missing
  case stepLights               = 86 
  case cabLightRear             = 87 
  case cabLightFront            = 88 
  case pantoRear                = 89 
  case pantoFront               = 90 
  // 91 - 92 missing
  case autoCouplerRear          = 93 
  case autoCouplerFront         = 94 
  case craneLeft                = 95 
  case craneRight               = 96 
  case craneUp                  = 97 
  case craneDown                = 98 
  case craneLeftRight           = 99 
  // 100 missing
  case soundFaderMute           = 101 
  // 102 - 105 missing
  case doubleHorn               = 106 
  case party                    = 107 
  // 108 - 113 missing
  case craneMagnet              = 114 
  // 115 - 123 missing
  case refillDiesel             = 124 
  
  // MARK: Constructors
  
  init?(title:String) {
    for temp in ESUFunctionIcon.allCases {
      if temp.title == title {
        self = temp
        return
      }
    }
    return nil
  }

  // MARK: Public Properties
  
  public var title : String {
    return ESUFunctionIcon.titles[self]!
  }
  
  public var category : ESUFunctionIconCategory {
    return ESUFunctionIcon.category[self]!
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [ESUFunctionIcon:String] = [
    
    .disabled                 : String(localized:"(disabled)"),
    .genericFunction          : String(localized:"Generic Function"),
    .headlight                : String(localized:"Headlight"),
    .interiorLight            : String(localized:"Interior Light"),
    .cabLight                 : String(localized:"Cab Light"),
    .driveSound               : String(localized:"Drive Sound"),
    .genericSound             : String(localized:"Generic Sound"),
    .stationAnnouncement      : String(localized:"Station Announcement"),
    .routingSpeed             : String(localized:"Routing Speed"),
    .startStopDelay           : String(localized:"Start/Stop Delay"),
    .automaticCoupler         : String(localized:"Automatic Coupler"),
    .smokeUnit                : String(localized:"Smoke Unit"),
    .pantograph               : String(localized:"Pantograph"),
    .highbeam                 : String(localized:"Highbeam"),
    .bell                     : String(localized:"Bell"),
    .horn                     : String(localized:"Horn"),
    .whistle                  : String(localized:"Whistle"),
    .doors                    : String(localized:"Doors"),
    .fan                      : String(localized:"Fan"),
    .shovelWork               : String(localized:"Shovel Work"),
    .shift                    : String(localized:"Shift"),
    .plateLight               : String(localized:"Plate Light"),
    .brakeSound               : String(localized:"Brake Sound"),
    .craneRaiseLower          : String(localized:"Crane Raise/Lower"),
    .craneHookRaiseLower      : String(localized:"Crane Hook Raise/Lower"),
    .wheelLight               : String(localized:"Wheel Light"),
    .craneTurn                : String(localized:"Crane Turn"),
    .steamBlow                : String(localized:"Steam Blow"),
    .radioSound               : String(localized:"Radio Sound"),
    .couplerSound             : String(localized:"Coupler Sound"),
    .trackSound               : String(localized:"Track Sound"),
    .notchUp                  : String(localized:"Notch Up"),
    .notchDown                : String(localized:"Notch Down"),
    .thundererWhistle         : String(localized:"Thunderer Whistle"),
    .bufferSound              : String(localized:"Buffer Sound"),
    .cabLight2                : String(localized:"Cab Light 2"),
    .curveSound               : String(localized:"Curve Sound"),
    .turnoutSound             : String(localized:"Turnout Sound"),
    .reliefValve              : String(localized:"Relief Valve"),
    .oilBurner                : String(localized:"Oil Burner"),
    .stoker                   : String(localized:"Stoker"),
    .dynamicBrake             : String(localized:"Dynamic Brake"),
    .compressor               : String(localized:"Compressor"),
    .airBlow                  : String(localized:"Air Blow"),
    .handbrake                : String(localized:"Handbrake"),
    .airPump                  : String(localized:"Air Pump"),
    .waterPump                : String(localized:"Water Pump"),
    .ditchLight               : String(localized:"Ditch Light"),
    .marsLight                : String(localized:"Mars Light"),
    .rotaryBeacon             : String(localized:"Rotary Beacon"),
    .firebox                  : String(localized:"Firebox"),
    .sanding                  : String(localized:"Sanding"),
    .drainValve               : String(localized:"Drain Valve"),
    .setBrakeAutomaticRelease : String(localized:"Set Brake (Automatic Release)"),
    .shuntingLight            : String(localized:"Shunting Light"),
    .boardLight               : String(localized:"Board Light"),
    .injector                 : String(localized:"Injector"),
    .auxilaryDiesel           : String(localized:"Auxilary Diesel"),
    .doppler                  : String(localized:"Doppler"),
    .whistleShort             : String(localized:"Whistle (Short)"),
    .heating                  : String(localized:"Heating"),
    .generatorSteamLoco       : String(localized:"Generator (Steam Loco)"),
    .sifaMessage              : String(localized:"SIFA Message"),
    .heavyLoad                : String(localized:"Heavy Load"),
    .coastOperation           : String(localized:"Coast Operation"),
    .rearLight                : String(localized:"Rear Light"),
    .frontLight               : String(localized:"Front Light"),
    .highbeamRear             : String(localized:"Highbeam Rear"),
    .highbeamFront            : String(localized:"Highbeam Front"),
    .tableLight1              : String(localized:"Table Light 1"),
    .stepLights               : String(localized:"Step Lights"),
    .cabLightRear             : String(localized:"Cab Light Rear"),
    .cabLightFront            : String(localized:"Cab Light Front"),
    .pantoRear                : String(localized:"Pantograph Rear"),
    .pantoFront               : String(localized:"Pantograph Front"),
    .autoCouplerRear          : String(localized:"Autocoupler Rear"),
    .autoCouplerFront         : String(localized:"Autocoupler Front"),
    .craneLeft                : String(localized:"Crane Left"),
    .craneRight               : String(localized:"Crane Right"),
    .craneUp                  : String(localized:"Crane Up"),
    .craneDown                : String(localized:"Crane Down"),
    .craneLeftRight           : String(localized:"Crane Left/Right"),
    .soundFaderMute           : String(localized:"Soundfader Mute"),
    .doubleHorn               : String(localized:"Double Horn"),
    .party                    : String(localized:"Party"),
    .craneMagnet              : String(localized:"Crane Magnet"),
    .refillDiesel             : String(localized:"Refill Diesel"),
  ]
  
  private static let category : [ESUFunctionIcon:ESUFunctionIconCategory] = [
    .disabled                 : .physical,
    .genericFunction          : .physical,
    .headlight                : .light,
    .interiorLight            : .light,
    .cabLight                 : .light,
    .driveSound               : .sound,
    .genericSound             : .sound,
    .stationAnnouncement      : .sound,
    .routingSpeed             : .logical,
    .startStopDelay           : .logical,
    .automaticCoupler         : .physical,
    .smokeUnit                : .physical,
    .pantograph               : .physical,
    .highbeam                 : .light,
    .bell                     : .sound,
    .horn                     : .sound,
    .whistle                  : .sound,
    .doors                    : .sound,
    .fan                      : .sound,
    .shovelWork               : .sound,
    .shift                    : .logical,
    .plateLight               : .light,
    .brakeSound               : .sound,
    .craneRaiseLower          : .physical,
    .craneHookRaiseLower      : .physical,
    .wheelLight               : .light,
    .craneTurn                : .physical,
    .steamBlow                : .sound,
    .radioSound               : .sound,
    .couplerSound             : .sound,
    .trackSound               : .sound,
    .notchUp                  : .sound,
    .notchDown                : .sound,
    .thundererWhistle         : .sound,
    .bufferSound              : .sound,
    .cabLight2                : .light,
    .curveSound               : .sound,
    .turnoutSound             : .sound,
    .reliefValve              : .sound,
    .oilBurner                : .sound,
    .stoker                   : .sound,
    .dynamicBrake             : .sound,
    .compressor               : .sound,
    .airBlow                  : .sound,
    .handbrake                : .sound,
    .airPump                  : .sound,
    .waterPump                : .sound,
    .ditchLight               : .light,
    .marsLight                : .light,
    .rotaryBeacon             : .light,
    .firebox                  : .light,
    .sanding                  : .sound,
    .drainValve               : .sound,
    .setBrakeAutomaticRelease : .sound,
    .shuntingLight            : .light,
    .boardLight               : .physical,
    .injector                 : .sound,
    .auxilaryDiesel           : .sound,
    .doppler                  : .sound,
    .whistleShort             : .sound,
    .heating                  : .sound,
    .generatorSteamLoco       : .sound,
    .sifaMessage              : .sound,
    .heavyLoad                : .logical,
    .coastOperation           : .logical,
    .rearLight                : .light,
    .frontLight               : .light,
    .highbeamRear             : .light,
    .highbeamFront            : .light,
    .tableLight1              : .light,
    .stepLights               : .light,
    .cabLightRear             : .light,
    .cabLightFront            : .light,
    .pantoRear                : .physical,
    .pantoFront               : .physical,
    .autoCouplerRear          : .physical,
    .autoCouplerFront         : .physical,
    .craneLeft                : .physical,
    .craneRight               : .physical,
    .craneUp                  : .physical,
    .craneDown                : .physical,
    .craneLeftRight           : .physical,
    .soundFaderMute           : .logical,
    .doubleHorn               : .sound,
    .party                    : .sound,
    .craneMagnet              : .physical,
    .refillDiesel             : .sound,
  ]
  
  // MARK: Public Class Methods
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    for item in ESUFunctionIcon.allCases {
      comboBox.addItem(withObjectValue: item.title)
    }
  }

}

public enum ESUFunctionIconCategory : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case light    = 0b00000000
  case logical  = 0b00100000
  case sound    = 0b01000000
  case physical = 0b01100000
  
  // MARK: Public Properties
  
  public var title : String {
    return ESUFunctionIconCategory.titles[self]!
  }
  
  public var mask : UInt8 {
    return 0b01100000
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [ESUFunctionIconCategory:String] = [
    .physical : String(localized: "Physical"),
    .logical  : String(localized: "Logical"),
    .sound    : String(localized: "Sound"),
    .light    : String(localized: "Light"),
  ]
  
}
