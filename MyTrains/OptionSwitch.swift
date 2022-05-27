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

public typealias OptionSwitchDefinition = (
  definitionType: OptionSwitchDefinitionType,
  model: Set<LocoNetProductId>,
  switchNumber: Int,
  defaultState : OptionSwitchState,
  bankAByte: Int,
  bankABit: Int,
  bankBByte: Int,
  bankBBit: Int,
  thrownEffect : String,
  closedEffect : String
)

public class OptionSwitch {
  
  // MARK: Constructors
  
  init(locoNetDevice: LocoNetDevice, switchNumber: Int, switchDefinition:OptionSwitchDefinition) {
    
    self._locoNetDevice = locoNetDevice
    
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
  
  private var _locoNetDevice : LocoNetDevice
  
  private var _switchNumber : Int
  
  private var _switchDefinition : OptionSwitchDefinition
  
  // MARK: Public Properties
  
  public var locoNetDevice : LocoNetDevice {
    get {
      return _locoNetDevice
    }
  }
  
  public var switchNumber : Int {
    get {
      return _switchNumber
    }
  }
  
  public var switchDefinition : OptionSwitchDefinition {
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
  
  public var newDefaultDecoderType : SpeedSteps = .unknown

  /*
        let mask128  : UInt8 = 0b000
        let mask14   : UInt8 = 0b001
        let mask28   : UInt8 = 0b010
        let mask128A : UInt8 = 0b100
        let mask28A  : UInt8 = 0b110
        let mask28T  : UInt8 = 0b011
  */

  // DCS240
  
  let mask14   : UInt8 = 0b010
  let mask128  : UInt8 = 0b110
  let mask128A : UInt8 = 0b111
  let mask28   : UInt8 = 0b000
  let mask28A  : UInt8 = 0b001
  let mask28T  : UInt8 = 0b100

  public var defaultDecoderType : SpeedSteps {
    get {
      
      var value : UInt8 = (getState(switchNumber: 21) == .closed ? 1 : 0) << 2
      value |= (getState(switchNumber: 22) == .closed ? 1 : 0) << 1
      value |= (getState(switchNumber: 23) == .closed ? 1 : 0)
      
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
      return ((locoNetDevice.optionSwitches0 & mask) == mask) ? .closed : .thrown
      case 1:
      return ((locoNetDevice.optionSwitches1 & mask) == mask) ? .closed : .thrown
      case 2:
      return ((locoNetDevice.optionSwitches2 & mask) == mask) ? .closed : .thrown
      case 3:
      return ((locoNetDevice.optionSwitches3 & mask) == mask) ? .closed : .thrown
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
      locoNetDevice.optionSwitches0 = (locoNetDevice.optionSwitches0 & safe) | temp
      case 1:
      locoNetDevice.optionSwitches1 = (locoNetDevice.optionSwitches1 & safe) | temp
      case 2:
      locoNetDevice.optionSwitches2 = (locoNetDevice.optionSwitches2 & safe) | temp
      case 3:
      locoNetDevice.optionSwitches3 = (locoNetDevice.optionSwitches3 & safe) | temp
    default:
      break
    }
  }

  
  // MARK: Class Properties
  
  public static let allOptions : [OptionSwitchDefinition] = [
    (
      definitionType: .standard,
      model: [.DCS50, .DCS51],
      switchNumber: 1,
      defaultState : .thrown,
      bankAByte: 3,
      bankABit: 0,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "one jump port",
      closedEffect : "two jump ports"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200],
      switchNumber: 1,
      defaultState : .thrown,
      bankAByte: 3,
      bankABit: 0,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200, .DCS50, .DCS51],
      switchNumber: 2,
      defaultState : .thrown,
      bankAByte: 3,
      bankABit: 1,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "command station mode",
      closedEffect : "booster only mode"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200, .DCS50, .DCS51],
      switchNumber: 3,
      defaultState : .thrown,
      bankAByte: 3,
      bankABit: 2,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "command station's booster is normal",
      closedEffect : "command station's booster is auto-reversing"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200],
      switchNumber: 4,
      defaultState : .thrown,
      bankAByte: 3,
      bankABit: 3,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: [.DCS50, .DCS51],
      switchNumber: 5,
      defaultState : .thrown, // Check
      bankAByte: 3,
      bankABit: 4,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "change allowed for Throttle ID, VMax and Brake Rate",
      closedEffect : "no change allowed for Throttle ID, VMax and Brake Rate"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS],
      switchNumber: 5,
      defaultState : .thrown,
      bankAByte: 3,
      bankABit: 4,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: [.DCS100, .DCS200],
      switchNumber: 5,
      defaultState : .thrown,
      bankAByte: 3,
      bankABit: 4,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "command station master mode off",
      closedEffect : "command station master mode on (recommended)"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS],
      switchNumber: 6,
      defaultState : .thrown,
      bankAByte: 3,
      bankABit: 5,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "check for decoder before programming",
      closedEffect : "program without checking for device"
    ),
    (
      definitionType: .standard,
      model: [.DCS100, .DCS200],
      switchNumber: 6,
      defaultState : .thrown,
      bankAByte: 3,
      bankABit: 5,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: [.DCS50, .DCS51],
      switchNumber: 6,
      defaultState : .thrown,
      bankAByte: 3,
      bankABit: 5,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "F3 is latching",
      closedEffect : "F3 is non-latching"
    ),
    (
      definitionType: .standard,
      model: [.DCS50, .DCS51],
      switchNumber: 7,
      defaultState : .closed,
      bankAByte: 3,
      bankABit: 6,
      bankBByte: -1,
      bankBBit: -1,
     thrownEffect : "Blast Mode programming disabled",
      closedEffect : "Blast mode programming enabled"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200],
      switchNumber: 7,
      defaultState : .thrown,
      bankAByte: 3,
      bankABit: 6,
      bankBByte: -1,
      bankBBit: -1,
     thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200],
      switchNumber: 8,
      defaultState : .thrown,
      bankAByte: -1,
      bankABit: -1,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200],
      switchNumber: 9,
      defaultState : .closed,
      bankAByte: 4,
      bankABit: 0,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: [.DCS51],
      switchNumber: 10,
      defaultState : .thrown,
      bankAByte: 4,
      bankABit: 1,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "Recall Depth 2",
      closedEffect : "Recall Depth 4"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200],
      switchNumber: 10,
      defaultState : .closed,
      bankAByte: 4,
      bankABit: 1,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: [.DCS51],
      switchNumber: 11,
      defaultState : .thrown,
      bankAByte: 4,
      bankABit: 2,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "",
      closedEffect : "Recall Depth 8"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200],
      switchNumber: 11,
      defaultState : .thrown,
      bankAByte: 4,
      bankABit: 2,
      bankBByte: -1,
      bankBBit: -1,
     thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200],
      switchNumber: 12,
      defaultState : .thrown,
      bankAByte: 4,
      bankABit: 3,
      bankBByte: -1,
      bankBBit: -1,
     thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200, .DCS50, .DCS51],
      switchNumber: 13,
      defaultState : .thrown,
      bankAByte: 4,
      bankABit: 4,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "locomotive address purge time 200 seconds",
      closedEffect : "locomotive address purge time 600 seconds"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200, .DCS50, .DCS51],
      switchNumber: 14,
      defaultState : .thrown,
      bankAByte: 4,
      bankABit: 5,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "locomotive address purging enabled",
      closedEffect : "locomotive address purging disabled"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200, .DCS50, .DCS51],
      switchNumber: 15,
      defaultState : .thrown,
      bankAByte: 4,
      bankABit: 6,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "purging will not change locomotive speed",
      closedEffect : "purging will force locomotive speed to zero"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200],
      switchNumber: 16,
      defaultState : .thrown,
      bankAByte: -1,
      bankABit: -1,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200, .DCS50, .DCS51],
      switchNumber: 17,
      defaultState : .thrown,
      bankAByte: 5,
      bankABit: 0,
      bankBByte: -1,
      bankBBit: -1,
     thrownEffect : "automatic advanced decode (FX) consists are enabled",
      closedEffect : "automatic advanced decode (FX) consists are disabled"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200, .DCS50, .DCS51],
      switchNumber: 18,
      defaultState : .thrown,
      bankAByte: 5,
      bankABit: 1,
      bankBByte: -1,
      bankBBit: -1,
     thrownEffect : "normal command station booster short circuit shutdown time",
      closedEffect : "extended command station booster short circuit shutdown time"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS100, .DCS200],
      switchNumber: 19,
      defaultState : .thrown,
      bankAByte: 5,
      bankABit: 2,
      bankBByte: -1,
      bankBBit: -1,
     thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: [.DCS210PLUS],
      switchNumber: 19,
      defaultState : .closed,
      bankAByte: 5,
      bankABit: 2,
      bankBByte: -1,
      bankBBit: -1,
     thrownEffect : "Ops mode feedback module not installed",
      closedEffect : "Ops mode feedback module installed"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200, .DCS50, .DCS51],
      switchNumber: 20,
      defaultState : .thrown,
      bankAByte: 5,
      bankABit: 3,
      bankBByte: -1,
      bankBBit: -1,
     thrownEffect : "enable address 0 for analog stretching for conventional locomotives",
      closedEffect : "disable address 0 for analog stretching for conventional locomotives"
    ),
    (
      definitionType: .decoder,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200],
      switchNumber: 21,
      defaultState : .thrown,
      bankAByte: 5,
      bankABit: 4,
      bankBByte: -1,
      bankBBit: -1,
     thrownEffect : "",
      closedEffect : ""
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200],
      switchNumber: 24,
      defaultState : .thrown,
      bankAByte: -1,
      bankABit: -1,
      bankBByte: -1,
      bankBBit: -1,
     thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS],
      switchNumber: 25,
      defaultState : .thrown,
      bankAByte: 6,
      bankABit: 0,
      bankBByte: -1,
      bankBBit: -1,
     thrownEffect : "enable route echo over Loconet",
      closedEffect : "disable route echo over Loconet"
    ),
    (
      definitionType: .standard,
      model: [.DCS100, .DCS200],
      switchNumber: 25,
      defaultState : .thrown,
      bankAByte: 6,
      bankABit: 0,
      bankBByte: -1,
      bankBBit: -1,
     thrownEffect : "enable aliasing",
      closedEffect : "disable aliasing"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200],
      switchNumber: 26,
      defaultState : .closed,
      bankAByte: 6,
      bankABit: 1,
      bankBByte: -1,
      bankBBit: -1,
     thrownEffect : "disable routes",
      closedEffect : "enabled routes"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200, .DCS50, .DCS51],
      switchNumber: 27,
      defaultState : .thrown,
      bankAByte: 6,
      bankABit: 2,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "enable normal switch commands, a.k.a. the \"Bushby bit\"",
      closedEffect : "disable normal switch commands, a.k.a. the \"Bushby bit\""
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200, .DCS50, .DCS51],
      switchNumber: 28,
      defaultState : .thrown,
      bankAByte: 6,
      bankABit: 3,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "enable interrogate commands at power on",
      closedEffect : "disable interrogate commands at power on"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200],
      switchNumber: 29,
      defaultState : .thrown,
      bankAByte: 6,
      bankABit: 4,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200],
      switchNumber: 30,
      defaultState : .thrown,
      bankAByte: 6,
      bankABit: 5,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200],
      switchNumber: 31,
      defaultState : .thrown,
      bankAByte: 6,
      bankABit: 6,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "normal route/switch output rate when not trinary",
      closedEffect : "fast route/switch output rate when not trinary"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200],
      switchNumber: 32,
      defaultState : .thrown,
      bankAByte: -1,
      bankABit: -1,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200, .DCS50, .DCS51],
      switchNumber: 33,
      defaultState : .closed,
      bankAByte: 8,
      bankABit: 0,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "track power off at power on",
      closedEffect : "allow track power to restore to prior state at power on"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200, .DCS50, .DCS51],
      switchNumber: 34,
      defaultState : .thrown,
      bankAByte: 8,
      bankABit: 1,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "disallow track to power up to run state, if set to run prior to power up",
      closedEffect : "allow track to power up to run state, if set to run prior to power up"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS],
      switchNumber: 35,
      defaultState : .thrown,
      bankAByte: 8,
      bankABit: 2,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "enable loco reset button",
      closedEffect : "disable loco reset button"
    ),
    (
      definitionType: .standard,
      model: [.DCS100, .DCS200],
      switchNumber: 35,
      defaultState : .thrown,
      bankAByte: 8,
      bankABit: 2,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200, .DCS50, .DCS51, .DCS52],
      switchNumber: 36,
      defaultState : .thrown,
      bankAByte: 8,
      bankABit: 3,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "",
      closedEffect : "clears all mobile decoder info and consists"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS100, .DCS200],
      switchNumber: 37,
      defaultState : .thrown,
      bankAByte: 8,
      bankABit: 4,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "",
      closedEffect : "clears all routes"
    ),
    (
      definitionType: .standard,
      model: [.DCS210, .DCS210PLUS],
      switchNumber: 38,
      defaultState : .thrown,
      bankAByte: 8,
      bankABit: 5,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "loco reset button activates OpSw 39",
      closedEffect : "loco reset activates slot zero"
    ),
    (
      definitionType: .standard,
      model: [.DCS240],
      switchNumber: 38,
      defaultState : .thrown,
      bankAByte: 8,
      bankABit: 5,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: [.DCS100, .DCS200],
      switchNumber: 38,
      defaultState : .thrown,
      bankAByte: 8,
      bankABit: 5,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "",
      closedEffect : "clear loco roster"
    ),
    (
      definitionType: .standard,
      model: [.DCS50, .DCS51],
      switchNumber: 39,
      defaultState : .thrown,
      bankAByte: 8,
      bankABit: 6,
      bankBByte: -1,
      bankBBit: -1,
     thrownEffect : "",
      closedEffect : "reset to factory defaults"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS100, .DCS200, .DCS52],
      switchNumber: 39,
      defaultState : .thrown,
      bankAByte: 8,
      bankABit: 6,
      bankBByte: -1,
      bankBBit: -1,
     thrownEffect : "",
      closedEffect : "clear all internal memory states, including OpSw 36 and 37"
    ),
    (
      definitionType: .standard,
      model: [.DCS210PLUS],
      switchNumber: 39,
      defaultState : .thrown,
      bankAByte: 8,
      bankABit: 6,
      bankBByte: -1,
      bankBBit: -1,
     thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS210PLUS, .DCS52],
      switchNumber: 40,
      defaultState : .thrown,
      bankAByte: -1,
      bankABit: -1,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "",
      closedEffect : "resets DCS240 to factory defaults"
    ),
    (
      definitionType: .standard,
      model: [.DCS100, .DCS200],
      switchNumber: 40,
      defaultState : .thrown,
      bankAByte: -1,
      bankABit: -1,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS100, .DCS200],
      switchNumber: 41,
      defaultState : .thrown,
      bankAByte: 9,
      bankABit: 0,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "diagnostic click disabled",
      closedEffect : "diagnostic click when valid Loconet commands incoming and routes being output"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS100, .DCS200],
      switchNumber: 42,
      defaultState : .thrown,
      bankAByte: 9,
      bankABit: 1,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "enable 2 short beeps when locomotive address purged",
      closedEffect : "disable 2 short beeps when locomotive address purged"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS100, .DCS200, .DCS50, .DCS51],
      switchNumber: 43,
      defaultState : .thrown,
      bankAByte: 9,
      bankABit: 2,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "enable Loconet update of command station's track status",
      closedEffect : "disable Loconet update of command station's track status"
    ),
    (
      definitionType: .standard,
      model: [.DCS210],
      switchNumber: 44,
      defaultState : .thrown,
      bankAByte: 9,
      bankABit: 3,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: [.DCS240],
      switchNumber: 44,
      defaultState : .thrown,
      bankAByte: 9,
      bankABit: 3,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "maximum slots to 400",
      closedEffect : "maximum slots to 120"
    ),
    (
      definitionType: .standard,
      model: [.DCS100, .DCS200],
      switchNumber: 44,
      defaultState : .thrown,
      bankAByte: 9,
      bankABit: 3,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "maximum slots to 22",
      closedEffect : "maximum slots to 120"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS100, .DCS200, .DCS50, .DCS51],
      switchNumber: 45,
      defaultState : .thrown,
      bankAByte: 9,
      bankABit: 4,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "enable reply for switch state request",
      closedEffect : "disable reply for switch state request"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS100, .DCS200],
      switchNumber: 46,
      defaultState : .thrown,
      bankAByte: 9,
      bankABit: 5,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "do not change",
      closedEffect : "do not change"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210, .DCS100, .DCS200],
      switchNumber: 47,
      defaultState : .thrown,
      bankAByte: 9,
      bankABit: 6,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "normal programming track setting",
      closedEffect : "programming track is brake generator when not programming"
    ),
    /* FOLLOWING FROM KB1066 FOR DCS210+ */
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210PLUS],
      switchNumber: 49,
      defaultState : .thrown,
      bankAByte: 10,
      bankABit: 0,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "disallow Idle power status",
      closedEffect : "allow Idle power status"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210PLUS],
      switchNumber: 54,
      defaultState : .thrown,
      bankAByte: 10,
      bankABit: 5,
      bankBByte: -1,
      bankBBit: -1,
      thrownEffect : "do not recall last speed at power on",
      closedEffect : "recall last speed at power on"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210PLUS],
      switchNumber: 66,
      defaultState : .thrown,
      bankAByte: -1,
      bankABit: -1,
      bankBByte: 3,
      bankBBit: 1,
      thrownEffect : "use advanced commands",
      closedEffect : "do not use advanced commands"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210PLUS],
      switchNumber: 70,
      defaultState : .thrown,
      bankAByte: -1,
      bankABit: -1,
      bankBByte: 3,
      bankBBit: 5,
      thrownEffect : "enable <BB7F> checks for other command stations",
      closedEffect : "disable <BB7F> checks for other command stations"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210PLUS],
      switchNumber: 71,
      defaultState : .thrown,
      bankAByte: -1,
      bankABit: -1,
      bankBByte: 3,
      bankBBit: 6,
      thrownEffect : "enable external command station disable",
      closedEffect : "disable external command station disable, just defer"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210PLUS],
      switchNumber: 75,
      defaultState : .thrown,
      bankAByte: -1,
      bankABit: -1,
      bankBByte: 4,
      bankBBit: 2,
      thrownEffect : "enable programming track precharge",
      closedEffect : "disable programming track precharge"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210PLUS],
      switchNumber: 77,
      defaultState : .thrown,
      bankAByte: -1,
      bankABit: -1,
      bankBByte: 4,
      bankBBit: 4,
      thrownEffect : "enable legacy commands",
      closedEffect : "after D5 commands lockout legacy commands"
    ),
    (
      definitionType: .standard,
      model: [.DCS240, .DCS210PLUS],
      switchNumber: 78,
      defaultState : .closed,
      bankAByte: -1,
      bankABit: -1,
      bankBByte: 4,
      bankBBit: 5,
      thrownEffect : "no not send Ack on B0 switch command",
      closedEffect : "send Ack on B0 switch command"
    ),
    (
      definitionType: .standard,
      model: [.DCS52],
      switchNumber: 83,
      defaultState : .thrown,
      bankAByte: -1,
      bankABit: -1,
      bankBByte: 5,
      bankBBit: 2,
      thrownEffect : "jump mode disabled",
      closedEffect : "jump mode enabled"
    )

  ]

  // MARK: Class Methods
  
  public static func switches(locoNetProductId: LocoNetProductId) -> [OptionSwitchDefinition] {
  
    var result : [OptionSwitchDefinition] = []
    
    for def in OptionSwitch.allOptions {
      if def.model.contains(locoNetProductId) {
        result.append(def)
      }
    }
        
    return result.sorted {
      $0.switchNumber < $1.switchNumber
    }
    
  }
  
}
