//
//  LoconetSlotDataMessage.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/10/2021.
//

import Foundation

public class LoconetSlotDataMessage : LoconetMessage {

  public var slotNumber : UInt8 {
    get {
      return message[2+0]
    }
  }
  
  public var locoAddress : UInt16 {
    get {
      let highAddr = UInt16(message[2+7])
      let lowAddr = UInt16(message[2+2])
      return (highAddr << 7) | lowAddr
    }
  }
  
  public var speedType : LoconetSlotSpeedType {
    return LoconetSlotSpeedType.init(rawValue: message[2+3]) ?? .speedIncreasing
  }
  
  public var speed : UInt8 {
    let value = message[2+3]
    return value > 0x01 ? value : 0x00
  }
  
  public var decoderType : LoconetDecoderType {
    get {
      return LoconetDecoderType.init(rawValue:  message[2+1] & 0b00000111) ?? .unknown
    }
  }
  
  public var locoUsage : LoconetLocoUsage {
    return LoconetLocoUsage.init(rawValue: message[2+1] & 0b00110000) ?? .unknown
  }
  
  public var progTrackBusy : Bool {
    get {
      return message[2+5] & 0b00001000 != 0x00
    }
  }

  public var MLOK1 : Bool {
    get {
      return message[2+5] & 0b00000100 != 0x00
    }
  }

  public var trackPaused : Bool {
    get {
      return message[2+5] & 0b00000010 == 0x00
    }
  }

  public var trackPower : Bool {
    get {
      return message[2+5] & 0b00000001 != 0x00
    }
  }
  
  public var locoDirection : LoconetLocoDirection {
    get {
      return LoconetLocoDirection.init(rawValue: message[2+4] & 0b00100000) ?? .unknown
    }
  }
  
  public var stateF0 : Bool {
    return message[2+4] & 0b00010000 != 0x00
  }
  
  public var stateF4 : Bool {
    return message[2+4] & 0b00001000 != 0x00
  }
  
  public var stateF3 : Bool {
    return message[2+4] & 0b00000100 != 0x00
  }
  
  public var stateF2 : Bool {
    return message[2+4] & 0b00000010 != 0x00
  }
  
  public var stateF1 : Bool {
    return message[2+4] & 0b00000001 != 0x00
  }
  
}

