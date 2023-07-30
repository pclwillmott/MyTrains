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
    get {
      return OpenLCBFunction.titles[self]!
    }
  }
  
  public static var keyValues : [(key:OpenLCBFunction, value:String)] {
    get {
      
      var result : [(key:OpenLCBFunction, value:String)] = []
      
      for (key, value) in titles {
        if key != .unassigned && key != .unavailable {
          result.append((key:key, value:value))
        }
      }
      
      result.sort {$0.value < $1.value}
      
      result.insert((key:OpenLCBFunction.unassigned, value:"Unassigned"), at: 0)
      
      result.append((key:OpenLCBFunction.unavailable, value:"Unavailable"))
      
      return result
      
    }
  }
  
  public static var cdiMap : String {
    
    get {
      
      var result = "<map>\n"
      
      for item in keyValues {
        result += "<relation><property>\(item.key.rawValue)</property><value>\(item.value)</value></relation>\n"
      }
      
      result += "</map>\n"
      
      return result
      
    }
    
  }
  
  public static let titles : [OpenLCBFunction:String] = [
    .unassigned          : "Unassigned",
    .headlight           : "Headlight",
    .interiorLights      : "Interior Lights",
    .cabLight            : "Cab Light",
    .engine              : "Engine",
    .announce            : "Announce",
    .shuntingMode        : "Shunting Mode",
    .momentum            : "Momentum",
    .uncouple            : "Uncouple",
    .smoke               : "Smoke",
    .pantograph          : "Pantograph",
    .farLight            : "Far Light",
    .bell                : "Bell",
    .horn                : "Horn",
    .whistle             : "Whistle",
    .radiatorFan         : "Radiator Fan",
    .shoveling           : "Shoveling",
    .brakeSqueal         : "Brake Squeal",
    .cabChatter          : "Cab Chatter",
    .couplerClank        : "Coupler Clank",
    .manualNotchUp       : "Manual Notch Up",
    .manualNotchDown     : "Manual Notch Down",
    .waterFill           : "Water Fill",
    .curveSqueal         : "Curve Squeal",
    .safety              : "Safety",
    .dynamicBrake        : "Dynamic Brake",
    .airCompressor       : "Air Compressor",
    .airPump             : "Air Pump",
    .ditchLights         : "Ditch Lights",
    .dimmer              : "Dimmer",
    .sanding             : "Sanding",
    .blowDown            : "Blow Down",
    .brake               : "Brake",
    .switchingLights     : "Switching Lights",
    .injector            : "Injector",
    .tailLights          : "Tail Lights",
    .dopplerHorn         : "Doppler Horn",
    .shortWhistle        : "Short Whistle",
    .steamGenerator      : "Steam Generator",
    .reverser            : "Reverser",
    .light               : "Light",
    .ashDump             : "Ash Dump",
    .stepLights          : "Step Lights",
    .mute                : "Mute",
    .longWhistle         : "Long Whistle",
    .blower              : "Blower",
    .exhaustFan          : "Exhaust Fan",
    .couple              : "Couple",
    .brakeRelease        : "Brake Release",
    .sound               : "Sound Enable",
    .heavyLoad           : "Heavy Load",
    .manualNotchingLogic : "Manual Notching Logic",
    .coasting            : "Coasting",
    .maximumRevs         : "Maximum Revs",
    .flangeSqueal        : "Flange Squeal",
    .fanOperation        : "Fan Operation",
    .guardsWhistle       : "Guard's Whistle",
    .autoUncoupleCycle   : "Auto Uncouple Cycle",
    .awsHorn             : "AWS Horn",
    .awsBell             : "AWS Bell",
    .soundFade           : "Sound Fade",
    .spiraxValve         : "Spirax Valve",
    .driversDoor         : "Driver's Door",
    .machineRoomLights   : "Machine Room Lights",
    .airDump             : "Air Dump",
    .unavailable         : "Unavaliable",
    .passengerDoorSlams  : "Passenger Door Slams",
    .airBuildUp          : "Air Build Up",
    .railJoints          : "Rail Joints",
    .lightOffFront       : "Lights Off Front",
    .lightOffRear        : "Lights Off Rear",
    .destinationFront    : "Destination Blind Front",
    .destinationRear     : "Destination Blind Rear",
    .driveHold           : "Drive Hold",
    .stop                : "Stop",

  ]
  
}
