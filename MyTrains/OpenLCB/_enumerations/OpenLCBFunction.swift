//
//  OpenLCBFunction.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/07/2023.
//

import Foundation

public enum OpenLCBFunction : UInt8 {

  case unassigned          = 0
  case headlight           = 1
  case interiorLights      = 2
  case cabLight            = 3
  case engine              = 4
  case announce            = 6
  case shuntingMode        = 7
  case momentum            = 8
  case uncouple            = 9
  case smoke               = 10
  case pantograph          = 11
  case farLight            = 12
  case bell                = 13
  case horn                = 14
  case whistle             = 15
  case radiatorFan         = 17
  case shoveling           = 18
  case heavyLoad           = 19
  case manualNotchingLogic = 20
  case brakeSqueal         = 21
  case coasting            = 22
  case maximumRevs         = 23
  case flangeSqueal        = 24
  case fanOperation        = 25
  case guardsWhistle       = 26
  case cabChatter          = 27
  case couplerClank        = 28
  case autoUncoupleCycle   = 29
  case manualNotchUp       = 30
  case manualNotchDown     = 31
  case awsHorn             = 32
  case awsBell             = 33
  case soundFade           = 34
  case waterFill           = 35
  case curveSqueal         = 36
  case spiraxValve         = 37
  case safety              = 38
  case driversDoor         = 39
  case passengerDoorSlams  = 40
  case dynamicBrake        = 41
  case airCompressor       = 42
  case machineRoomLights   = 43
  case airDump             = 44
  case airPump             = 45
  case airBuildUp          = 46
  case railJoints          = 47
  case ditchLights         = 48
  case lightOffFront       = 49
  case lightOffRear        = 50
  case dimmer              = 51
  case destinationFront    = 52
  case destinationRear     = 53
  case driveHold           = 54
  case sanding             = 55
  case blowDown            = 56
  case brake               = 57
  case switchingLights     = 58
  case injector            = 60
  case stop                = 61
  case tailLights          = 62
  case dopplerHorn         = 63
  case shortWhistle        = 64
  case steamGenerator      = 66
  case reverser            = 69
  case light               = 74
  case ashDump             = 88
  case stepLights          = 98
  case mute                = 100
  case sound               = 101
  case longWhistle         = 103
  case blower              = 105
  case exhaustFan          = 108
  case couple              = 122
  case brakeRelease        = 200
  case unavailable         = 255

  public var title : String {
    return OpenLCBFunction.titles[self]!
  }
  
  public static var keyValues : [(key:OpenLCBFunction, value:String)] {
    
    var result : [(key:OpenLCBFunction, value:String)] = []
    
    for (key, value) in titles {
      if key != .unassigned && key != .unavailable {
        result.append((key:key, value:value))
      }
    }
    
    result.sort {$0.value < $1.value}
    
    result.insert((key:OpenLCBFunction.unassigned, value:OpenLCBFunction.unassigned.title), at: 0)
    
    result.append((key:OpenLCBFunction.unavailable, value:OpenLCBFunction.unavailable.title))
    
    return result
    
  }
  
  private static var map : String {
      
    var result = "<map>\n"
    
    for item in keyValues {
      result += "<relation><property>\(item.key.rawValue)</property><value>\(item.value)</value></relation>\n"
    }
    
    result += "</map>\n"
    
    return result

  }
  
  public static let titles : [OpenLCBFunction:String] = [
    .unassigned          : String(localized: "Unassigned", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .headlight           : String(localized: "Headlight", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .interiorLights      : String(localized: "Interior Lights", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .cabLight            : String(localized: "Cab Light", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .engine              : String(localized: "Engine", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .announce            : String(localized: "Announce", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .shuntingMode        : String(localized: "Shunting Mode", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .momentum            : String(localized: "Momentum", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .uncouple            : String(localized: "Uncouple", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .smoke               : String(localized: "Smoke", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .pantograph          : String(localized: "Pantograph", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .farLight            : String(localized: "Far Light", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .bell                : String(localized: "Bell", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .horn                : String(localized: "Horn", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .whistle             : String(localized: "Whistle", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .radiatorFan         : String(localized: "Radiator Fan", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .shoveling           : String(localized: "Shoveling", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .brakeSqueal         : String(localized: "Brake Squeal", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .cabChatter          : String(localized: "Cab Chatter", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .couplerClank        : String(localized: "Coupler Clank", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .manualNotchUp       : String(localized: "Manual Notch Up", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .manualNotchDown     : String(localized: "Manual Notch Down", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .waterFill           : String(localized: "Water Fill", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .curveSqueal         : String(localized: "Curve Squeal", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .safety              : String(localized: "Safety", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .dynamicBrake        : String(localized: "Dynamic Brake", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .airCompressor       : String(localized: "Air Compressor", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .airPump             : String(localized: "Air Pump", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .ditchLights         : String(localized: "Ditch Lights", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .dimmer              : String(localized: "Dimmer", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .sanding             : String(localized: "Sanding", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .blowDown            : String(localized: "Blow Down", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .brake               : String(localized: "Brake", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .switchingLights     : String(localized: "Switching Lights", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .injector            : String(localized: "Injector", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .tailLights          : String(localized: "Tail Lights", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .dopplerHorn         : String(localized: "Doppler Horn", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .shortWhistle        : String(localized: "Short Whistle", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .steamGenerator      : String(localized: "Steam Generator", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .reverser            : String(localized: "Reverser", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .light               : String(localized: "Light", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .ashDump             : String(localized: "Ash Dump", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .stepLights          : String(localized: "Step Lights", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .mute                : String(localized: "Mute", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .longWhistle         : String(localized: "Long Whistle", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .blower              : String(localized: "Blower", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .exhaustFan          : String(localized: "Exhaust Fan", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .couple              : String(localized: "Couple", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .brakeRelease        : String(localized: "Brake Release", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .sound               : String(localized: "Sound Enable", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .heavyLoad           : String(localized: "Heavy Load", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .manualNotchingLogic : String(localized: "Manual Notching Logic", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .coasting            : String(localized: "Coasting", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .maximumRevs         : String(localized: "Maximum Revs", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .flangeSqueal        : String(localized: "Flange Squeal", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .fanOperation        : String(localized: "Fan Operation", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .guardsWhistle       : String(localized: "Guard's Whistle", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .autoUncoupleCycle   : String(localized: "Auto Uncouple Cycle", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .awsHorn             : String(localized: "AWS Horn", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .awsBell             : String(localized: "AWS Bell", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .soundFade           : String(localized: "Sound Fade", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .spiraxValve         : String(localized: "Spirax Valve", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .driversDoor         : String(localized: "Driver's Door", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .machineRoomLights   : String(localized: "Machine Room Lights", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .airDump             : String(localized: "Air Dump", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .unavailable         : String(localized: "Unavaliable", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .passengerDoorSlams  : String(localized: "Passenger Door Slams", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .airBuildUp          : String(localized: "Air Build Up", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .railJoints          : String(localized: "Rail Joints", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .lightOffFront       : String(localized: "Lights Off Front", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .lightOffRear        : String(localized: "Lights Off Rear", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .destinationFront    : String(localized: "Destination Blind Front", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .destinationRear     : String(localized: "Destination Blind Rear", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .driveHold           : String(localized: "Drive Hold", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),
    .stop                : String(localized: "Stop", comment: "Used as a label for a button that controls a trains's functions such as sound effects"),

  ]
  
  public static func insertMap(cdi:String) -> String {
    return cdi.replacingOccurrences(of: CDI.FUNCTIONS_MAP, with: map)
  }
  
}
