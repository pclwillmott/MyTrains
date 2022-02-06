//
//  CommandStationOptionSwitch.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/02/2022.
//

import Foundation

public enum OptionSwitchState : Int {
  case thrown = 0
  case closed = 1
}

public enum OptionSwitchDefinitionType {
  case decoder
  case standard
}

public typealias CommandStationSwitchDefinition = (
  definitionType: OptionSwitchDefinitionType,
  model: CommandStationModel,
  switchNumber: Int,
  defaultState : OptionSwitchState,
  configByte: Int,
  configBit: Int,
  thrownEffect : String,
  closedEffect : String
)

public class CommandStationOptionSwitch {
  
  // MARK: Constructors
  
  init(commandStation: CommandStation, switchNumber: Int, switchDefinition:CommandStationSwitchDefinition) {
    
    self._commandStation = commandStation
    
    self._switchNumber = switchNumber
    
    self._switchDefinition = switchDefinition
    
  }
  
  // MARK: Private TypeAlias
  
  private typealias MasksEtAl = (
    opsw : Int,
    word : Int,
    bit  : Int,
    mask : Int64
  )
  
  // MARK: Private Properties
  
  private var _commandStation : CommandStation
  
  private var _switchNumber : Int
  
  private var _switchDefinition : CommandStationSwitchDefinition
  
  // MARK: Public Properties
  
  public var commandStation : CommandStation {
    get {
      return _commandStation
    }
  }
  
  public var switchNumber : Int {
    get {
      return _switchNumber
    }
  }
  
  public var switchDefinition : CommandStationSwitchDefinition {
    get {
      return _switchDefinition
    }
  }
  
  public var state : OptionSwitchState {
    get {
      return getState(switchNumber: self.switchNumber)
    }
    set(value) {
      setState(switchNumber: self.switchNumber, value: value)
      newState = value
    }
  }
  
  public var newState : OptionSwitchState = .thrown
  
  public var newDefaultDecoderType : MobileDecoderType = .unknown
  
  public var defaultDecoderType : MobileDecoderType {
    get {
      
      var value : UInt8 = (getState(switchNumber: 21) == .closed ? 1 : 0) << 2
      value |= (getState(switchNumber: 22) == .closed ? 1 : 0) << 1
      value |= (getState(switchNumber: 23) == .closed ? 1 : 0)
      
      let mask128  : UInt8 = 0b000
      let mask14   : UInt8 = 0b001
      let mask28   : UInt8 = 0b010
      let mask128A : UInt8 = 0b100
      let mask28A  : UInt8 = 0b110
      let mask28T  : UInt8 = 0b011
      
      switch value {
      case mask128:
        return .dcc128
      case mask14:
        return .dcc14
      case mask28:
        return .dcc28
      case mask128A:
        return .dcc128A
      case mask28A:
        return .dcc28A
      case mask28T:
        return .dcc28T
      default:
        return .unknown
      }

    }
    set(value) {

      let mask128  : UInt8 = 0b000
      let mask14   : UInt8 = 0b001
      let mask28   : UInt8 = 0b010
      let mask128A : UInt8 = 0b100
      let mask28A  : UInt8 = 0b110
      let mask28T  : UInt8 = 0b011
      
      var bits : UInt8 = 0
      
      switch value {
      case .dcc28:
        bits = mask28
      case .dcc28T:
        bits = mask28T
      case .dcc14:
        bits = mask14
      case .dcc128:
        bits = mask128
      case .dcc28A:
        bits = mask28A
      case .dcc128A:
        bits = mask128A
      default:
        break
      }
      
      setState(switchNumber: 21, value: (bits & 0b100) == 0b100 ? .closed : .thrown)
      setState(switchNumber: 22, value: (bits & 0b010) == 0b010 ? .closed : .thrown)
      setState(switchNumber: 23, value: (bits & 0b001) == 0b001 ? .closed : .thrown)
      
      newDefaultDecoderType = value
      
    }
  }
  
  // MARK: Private Methods
  
  private func masksEtAl(switchNumber: Int) -> MasksEtAl {
    let opsw = switchNumber - 1
    let word = opsw >> 6
    let bit = opsw & 0b00111111
    let mask : Int64 = 1 << bit
    return (opsw: opsw, word: word, bit: bit, mask: mask)
  }
  
  // MARK: Public Methods
  
  
  public func getState(switchNumber: Int) -> OptionSwitchState {
    let masks = masksEtAl(switchNumber: switchNumber)
    let mask = masks.mask
    switch masks.word {
      case 0:
      return ((commandStation.optionSwitches0 & mask) == mask) ? .closed : .thrown
      case 1:
      return ((commandStation.optionSwitches1 & mask) == mask) ? .closed : .thrown
      case 2:
      return ((commandStation.optionSwitches2 & mask) == mask) ? .closed : .thrown
      case 3:
      return ((commandStation.optionSwitches3 & mask) == mask) ? .closed : .thrown
    default:
      break
    }
    return .thrown
  }

  public func setState(switchNumber: Int, value: OptionSwitchState) {
    let masks = masksEtAl(switchNumber: switchNumber)
    let mask = masks.mask
    let safe = ~mask
    let temp : Int64 = value == .closed ? mask : 0
    switch masks.word {
      case 0:
      commandStation.optionSwitches0 = (commandStation.optionSwitches0 & safe) | temp
      case 1:
      commandStation.optionSwitches1 = (commandStation.optionSwitches1 & safe) | temp
      case 2:
      commandStation.optionSwitches2 = (commandStation.optionSwitches2 & safe) | temp
      case 3:
      commandStation.optionSwitches3 = (commandStation.optionSwitches3 & safe) | temp
    default:
      break
    }
  }

  
  // MARK: Class Properties
  
  public static let allOptions : [CommandStationSwitchDefinition] = [
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 1,
      defaultState : .thrown,
      configByte: 3,
      configBit: 0,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 2,
      defaultState : .thrown,
      configByte: 3,
      configBit: 1,
      thrownEffect : "command station mode",
      closedEffect : "booster only mode"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 3,
      defaultState : .thrown,
      configByte: 3,
      configBit: 2,
      thrownEffect : "command station's booster is normal",
      closedEffect : "command station's booster is auto-reversing"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 4,
      defaultState : .thrown,
      configByte: 3,
      configBit: 3,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 5,
      defaultState : .thrown,
      configByte: 3,
      configBit: 4,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 6,
      defaultState : .thrown,
      configByte: 3,
      configBit: 5,
      thrownEffect : "check for decoder before programming",
      closedEffect : "program without checking for device"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 7,
      defaultState : .thrown,
      configByte: 3,
      configBit: 6,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 8,
      defaultState : .thrown,
      configByte: -1,
      configBit: -1,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 9,
      defaultState : .closed,
      configByte: 4,
      configBit: 0,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 10,
      defaultState : .closed,
      configByte: 4,
      configBit: 1,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 11,
      defaultState : .thrown,
      configByte: 4,
      configBit: 2,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 12,
      defaultState : .thrown,
      configByte: 4,
      configBit: 3,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 13,
      defaultState : .thrown,
      configByte: 4,
      configBit: 4,
      thrownEffect : "locomotive address purge time 200 seconds",
      closedEffect : "locomotive address purge time 600 seconds"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 14,
      defaultState : .thrown,
      configByte: 4,
      configBit: 5,
      thrownEffect : "locomotive address purging enabled",
      closedEffect : "locomotive address purging disabled"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 15,
      defaultState : .thrown,
      configByte: 4,
      configBit: 6,
      thrownEffect : "purging will not change locomotive speed",
      closedEffect : "purging will force locomotive speed to zero"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 16,
      defaultState : .thrown,
      configByte: -1,
      configBit: -1,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 17,
      defaultState : .thrown,
      configByte: 5,
      configBit: 0,
      thrownEffect : "automatic advanced decode (FX) consists are enabled",
      closedEffect : "automatic advanced decode (FX) consists are disabled"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 18,
      defaultState : .thrown,
      configByte: 5,
      configBit: 1,
      thrownEffect : "normal command station booster short circuit shutdown time",
      closedEffect : "extended command station booster short circuit shutdown time"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 19,
      defaultState : .thrown,
      configByte: 5,
      configBit: 2,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 20,
      defaultState : .thrown,
      configByte: 5,
      configBit: 3,
      thrownEffect : "enable address 0 for analog stretching for conventional locomotives",
      closedEffect : "disable address 0 for analog stretching for conventional locomotives"
    ),
    (
      definitionType: .decoder,
      model: .dcs240,
      switchNumber: 21,
      defaultState : .thrown,
      configByte: 5,
      configBit: 4,
      thrownEffect : "",
      closedEffect : ""
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 24,
      defaultState : .thrown,
      configByte: -1,
      configBit: -1,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 25,
      defaultState : .thrown,
      configByte: 6,
      configBit: 0,
      thrownEffect : "enable route echo over Loconet",
      closedEffect : "disable route echo over Loconet"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 26,
      defaultState : .closed,
      configByte: 6,
      configBit: 1,
      thrownEffect : "disable routes",
      closedEffect : "enabled routes"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 27,
      defaultState : .thrown,
      configByte: 6,
      configBit: 2,
      thrownEffect : "enable normal switch commands, a.k.a. the \"Bushby bit\"",
      closedEffect : "disable normal switch commands, a.k.a. the \"Bushby bit\""
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 28,
      defaultState : .thrown,
      configByte: 6,
      configBit: 3,
      thrownEffect : "enable interrogate commands at power on",
      closedEffect : "disable interrogate commands at power on"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 29,
      defaultState : .thrown,
      configByte: 6,
      configBit: 4,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 30,
      defaultState : .thrown,
      configByte: 6,
      configBit: 5,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 31,
      defaultState : .thrown,
      configByte: 6,
      configBit: 6,
      thrownEffect : "normal route/switch output rate when not trinary",
      closedEffect : "fast route/switch output rate when not trinary"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 32,
      defaultState : .thrown,
      configByte: -1,
      configBit: -1,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 33,
      defaultState : .closed,
      configByte: 8,
      configBit: 0,
      thrownEffect : "track power off at power on",
      closedEffect : "allow track power to restore to prior state at power on"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 34,
      defaultState : .thrown,
      configByte: 8,
      configBit: 1,
      thrownEffect : "disallow track to power up to run state, if set to run prior to power up",
      closedEffect : "allow track to power up to run state, if set to run prior to power up"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 35,
      defaultState : .thrown,
      configByte: 8,
      configBit: 2,
      thrownEffect : "enable loco reset button",
      closedEffect : "disable loco reset button"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 36,
      defaultState : .thrown,
      configByte: 8,
      configBit: 3,
      thrownEffect : "",
      closedEffect : "clears all mobile decoder info and consists"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 37,
      defaultState : .thrown,
      configByte: 8,
      configBit: 4,
      thrownEffect : "",
      closedEffect : "clears all routes"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 38,
      defaultState : .thrown,
      configByte: 8,
      configBit: 5,
      thrownEffect : "loco reset button activates OpSw 39",
      closedEffect : "loco reset activates slot zero"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 39,
      defaultState : .thrown,
      configByte: 8,
      configBit: 6,
      thrownEffect : "",
      closedEffect : "clear all internal memory states, including OpSw 36 and 37"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 40,
      defaultState : .thrown,
      configByte: -1,
      configBit: -1,
      thrownEffect : "",
      closedEffect : "resets DCS240 to factory defaults"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 41,
      defaultState : .thrown,
      configByte: 9,
      configBit: 0,
      thrownEffect : "diagnostic click disabled",
      closedEffect : "diagnostic click when valid Loconet commands incoming and routes being output"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 42,
      defaultState : .thrown,
      configByte: 9,
      configBit: 1,
      thrownEffect : "enable 2 short beeps when locomotive address purged",
      closedEffect : "disable 2 short beeps when locomotive address purged"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 43,
      defaultState : .thrown,
      configByte: 9,
      configBit: 2,
      thrownEffect : "enable Loconet update of command station's track status",
      closedEffect : "disable Loconet update of command station's track status"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 44,
      defaultState : .thrown,
      configByte: 9,
      configBit: 3,
      thrownEffect : "maximum slots to 400",
      closedEffect : "maximum slots to 120"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 45,
      defaultState : .thrown,
      configByte: 9,
      configBit: 4,
      thrownEffect : "enable reply for switch state request",
      closedEffect : "disable reply for switch state request"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 46,
      defaultState : .thrown,
      configByte: 9,
      configBit: 5,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 47,
      defaultState : .thrown,
      configByte: 9,
      configBit: 6,
      thrownEffect : "normal programming track setting",
      closedEffect : "programming track is brake generator when not programming"
    ),
    /* FOLLOWING FROM KB1066 FOR DCS210+ */
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 49,
      defaultState : .thrown,
      configByte: -1,
      configBit: -1,
      thrownEffect : "disallow Idle power status",
      closedEffect : "allow Idle power status"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 54,
      defaultState : .thrown,
      configByte: -1,
      configBit: -1,
      thrownEffect : "do not recall last speedd at power on",
      closedEffect : "recall last speedd at power on"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 66,
      defaultState : .thrown,
      configByte: -1,
      configBit: -1,
      thrownEffect : "use advanced commands",
      closedEffect : "do not use advanced commands"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 70,
      defaultState : .thrown,
      configByte: -1,
      configBit: -1,
      thrownEffect : "enable <BB7F> checks for other command stations",
      closedEffect : "disable <BB7F> checks for other command stations"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 71,
      defaultState : .thrown,
      configByte: -1,
      configBit: -1,
      thrownEffect : "enable external command station disable",
      closedEffect : "disable external command station disable, just defer"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 75,
      defaultState : .thrown,
      configByte: -1,
      configBit: -1,
      thrownEffect : "enable programming track precharge",
      closedEffect : "disable programming track precharge"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 77,
      defaultState : .thrown,
      configByte: -1,
      configBit: -1,
      thrownEffect : "enable legacy commands",
      closedEffect : "after D5 commands lockout legacy commands"
    ),
    (
      definitionType: .standard,
      model: .dcs240,
      switchNumber: 78,
      defaultState : .closed,
      configByte: -1,
      configBit: -1,
      thrownEffect : "no not send Ack on B0 switch command",
      closedEffect : "send Ack on B0 switch command"
    )

  ]

  // MARK: Class Methods
  
  public static func switches(commandStationModel:CommandStationModel) -> [CommandStationSwitchDefinition] {
  
    var result : [CommandStationSwitchDefinition] = []
    
    for def in CommandStationOptionSwitch.allOptions {
      if def.model == commandStationModel {
        result.append(def)
      }
    }
        
    return result.sorted {
      $0.switchNumber < $1.switchNumber
    }
    
  }
  
}
