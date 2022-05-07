//
//  LocoSlotDataP2.swift.swift
//  MyTrains
//

import Foundation

public class LocoSlotDataP2 : NetworkMessage {

  // MARK: Public Properties
  
  public var slotStatus1 : UInt8 {
    get {
      return message[4]
    }
  }
  
  public var slotState : SlotState {
    get {
      switch (slotStatus1 & 0b00110000) >> 4 {
        case 0b00:
          return .free
        case 0b01:
          return .common
        case 0b10:
          return.idle
      default:
        return .inUse
      }
    }
  }
  
  public var consistState : ConsistState {
    get {
      var value = (slotStatus1 & 0b00001000) == 0b00001000 ? 0b10 : 0b00
      value    |= (slotStatus1 & 0b01000000) == 0b01000000 ? 0b01 : 0b00
      switch value {
      case 0b01:
        return .SubMember
      case 0b10:
        return .TopMember
      case 0b11:
        return .MidConsist
      default:
        return .NotLinked
      }
    }
  }
  
  public var slotPage : Int {
    get {
      return Int(message[2])
    }
  }
  
  public var slotNumber : Int {
    get {
      return Int(message[3])
    }
  }
  
  public var address : Int {
    get {
      return Int(message[5]) | (Int(message[6]) << 7)
    }
  }
  
  public var mobileDecoderType : SpeedSteps {
    get {
      
      let decoderType = message[4] & 0b111
      
      switch decoderType {
      case 0b000:
        return .dcc28
      case 0b001:
        return .dcc28T
      case 0b010:
        return .dcc14
      case 0b011:
        return .dcc128
      case 0b100:
        return .dcc28A
      case 0b101:
        return .unknown
      case 0b110:
        return .unknown
      case 0b111:
        return .dcc128A
      default:
        return .unknown
      }
      
    }
  }
  
  public var direction : LocomotiveDirection {
    get {
      let directionMask : UInt8 = 0b00100000
      return (message[10] & directionMask) == directionMask ? .forward : .reverse
    }
  }
  
  public var speed : Int {
    get {
      return Int(message[8])
    }
  }
  
  public var throttleID : Int {
    get {
      return Int(message[18]) | Int(message[19]) << 8
    }
  }
  
  public var functions : Int {
    get {
      
      var fnx : Int = 0
      
      var byte = message[9]

      fnx |= (byte & 0b00010000) == 0b00010000 ? maskF12 : 0
      fnx |= (byte & 0b00100000) == 0b00100000 ? maskF20 : 0
      fnx |= (byte & 0b01000000) == 0b01000000 ? maskF28 : 0

      byte = message[10]

      fnx |= (byte & 0b00010000) == 0b00010000 ? maskF0 : 0
      fnx |= (byte & 0b00000001) == 0b00000001 ? maskF1 : 0
      fnx |= (byte & 0b00000010) == 0b00000010 ? maskF2 : 0
      fnx |= (byte & 0b00000100) == 0b00000100 ? maskF3 : 0
      fnx |= (byte & 0b00001000) == 0b00001000 ? maskF4 : 0

      byte = message[11]

      fnx |= (byte & 0b00000001) == 0b00000001 ? maskF5 : 0
      fnx |= (byte & 0b00000010) == 0b00000010 ? maskF6 : 0
      fnx |= (byte & 0b00000100) == 0b00000100 ? maskF7 : 0
      fnx |= (byte & 0b00001000) == 0b00001000 ? maskF8 : 0
      fnx |= (byte & 0b00010000) == 0b00010000 ? maskF9 : 0
      fnx |= (byte & 0b00100000) == 0b00100000 ? maskF10 : 0
      fnx |= (byte & 0b01000000) == 0b01000000 ? maskF11 : 0

      byte = message[12]

      fnx |= (byte & 0b01000000) == 0b01000000 ? maskF19 : 0
      fnx |= (byte & 0b00100000) == 0b00100000 ? maskF18 : 0
      fnx |= (byte & 0b00010000) == 0b00010000 ? maskF17 : 0
      fnx |= (byte & 0b00001000) == 0b00001000 ? maskF16 : 0
      fnx |= (byte & 0b00000100) == 0b00000100 ? maskF15 : 0
      fnx |= (byte & 0b00000010) == 0b00000010 ? maskF14 : 0
      fnx |= (byte & 0b00000001) == 0b00000001 ? maskF13 : 0

      byte = message[13]
 
      fnx |= (byte & 0b01000000) == 0b01000000 ? maskF27 : 0
      fnx |= (byte & 0b00100000) == 0b00100000 ? maskF26 : 0
      fnx |= (byte & 0b00010000) == 0b00010000 ? maskF25 : 0
      fnx |= (byte & 0b00001000) == 0b00001000 ? maskF24 : 0
      fnx |= (byte & 0b00000100) == 0b00000100 ? maskF23 : 0
      fnx |= (byte & 0b00000010) == 0b00000010 ? maskF22 : 0
      fnx |= (byte & 0b00000001) == 0b00000001 ? maskF21 : 0

      return fnx
      
    }
  }
  
  public let isF9F28Available = true

}

