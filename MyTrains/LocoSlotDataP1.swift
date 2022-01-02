//
//  LocoSlotDataP1.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/10/2021.
//

import Foundation

public enum SlotState {
  case free
  case common
  case idle
  case inUse
}

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
      return Int(message[4]) | (Int(message[9]) << 7)
    }
  }
  
}

