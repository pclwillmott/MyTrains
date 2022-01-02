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
  
}

