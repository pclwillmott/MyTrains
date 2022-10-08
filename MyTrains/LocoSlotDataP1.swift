//
//  LocoSlotDataP1.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/10/2021.
//

import Foundation

public class LocoSlotDataP1 : NetworkMessage {

  // MARK: Public Properties
  
  public var slotStatus1 : UInt8 {
    get {
      return message[3]
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
      var state = (slotStatus1 & 0b00001000) == 0b00001000 ? 0b10 : 0b00
      state    |= (slotStatus1 & 0b01000000) == 0b01000000 ? 0b01 : 0b00
      return ConsistState(rawValue: state) ?? .NotLinked
    }
  }
  
  public var slotPage : Int {
    get {
      return 0
    }
  }
 
  public var slotNumber : Int {
    get {
      return Int(message[2])
    }
  }
  
  public var address : Int {
    get {
      var address = Int(message[4])
      if message[9] != 0x7f {
        address |= Int(message[9]) << 7
      }
      return address
    }
  }
  
  public var mobileDecoderType : SpeedSteps {
    get {
      return SpeedSteps(rawValue: Int(message[3] & 0b111)) ?? SpeedSteps.defaultValue
    }
  }

  public var rawMobileDecoderType : Int {
    get {
      return Int(message[3] & 0b111)
    }
  }

  public var direction : LocomotiveDirection {
    get {
      let directionMask : UInt8 = 0b00100000
      return (message[6] & directionMask) == directionMask ? .forward : .reverse
    }
  }
  
  public var speed : Int {
    get {
      return Int(message[5])
    }
  }

  public var throttleID : Int {
    get {
      var id = Int(message[11])
      if message[9] == 0x7f && (message[8] & 0b100) == 0b100 {
        id |= Int(message[12]) << 7
      }
      else {
        id |= Int(message[12]) << 8
      }
      return id
    }
  }
  
  public var functions : Int {
    get {
      
      var fnx : Int = 0
      
      var byte = message[6]
      
      fnx |= (byte & 0b00010000) == 0b00010000 ? maskF0 : 0
      fnx |= (byte & 0b00000001) == 0b00000001 ? maskF1 : 0
      fnx |= (byte & 0b00000010) == 0b00000010 ? maskF2 : 0
      fnx |= (byte & 0b00000100) == 0b00000100 ? maskF3 : 0
      fnx |= (byte & 0b00001000) == 0b00001000 ? maskF4 : 0
      
      byte = message[10]
      
      fnx |= (byte & 0b00000001) == 0b00000001 ? maskF5 : 0
      fnx |= (byte & 0b00000010) == 0b00000010 ? maskF6 : 0
      fnx |= (byte & 0b00000100) == 0b00000100 ? maskF7 : 0
      fnx |= (byte & 0b00001000) == 0b00001000 ? maskF8 : 0

      return fnx
      
    }
  }
  
  public let isF9F28Available = false

}

