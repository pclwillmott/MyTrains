//
//  LoconetMessage.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/10/2021.
//

import Foundation

class LoconetMessage : NSObject {
  
  init(message:[UInt8]) {
    self.message = message
    super.init()
  }
  
  public var message : [UInt8]
  
  public var checkSumOK : Bool {
    get {
      var checkSum = message[0]
      var index = 1
      while index < message.count {
        checkSum ^= message[index]
        index += 1
      }
      return checkSum == 0xff
    }
  }
  
  public var opCodeRawValue : UInt8 {
    get {
      return message[0]
    }
  }
  
  public var opCode : LoconetOpcode {
    get {
      return LoconetOpcode.init(rawValue: opCodeRawValue) ?? .OPC_UNKNOWN
    }
  }
  
  public var turnoutAddress : UInt16 {
    get {
      if opCode == .OPC_SW_REQ {
        return 1 + (UInt16(message[1]) | ((UInt16(message[2]) & 0b00001111) << 7))
      }
      else {
        return 0x0000
      }
    }
  }
  
  public var slotNumber : UInt8 {
    get {
      if opCode == .OPC_RQ_SL_DATA {
        return message[1]
      }
      else {
        return 0xff
      }
    }
  }
  
  public var turnoutId : String {
    get {
      let addr = turnoutAddress - 1
      return "\(1 + addr >> 2).\(1 + addr % 4)"
    }
  }
  
  public var turnoutState : UInt8 {
    get {
      if opCode == .OPC_SW_REQ {
        return (message[2] & 0b00110000) >> 4
      }
      else {
        return 0xff
      }
    }
  }

  
  public var sensorAddress : UInt16 {
    get {
      if opCode == .OPC_INPUT_REP || opCode == .OPC_SW_REP {
        let in2 = UInt16(message[2])
        return 1 + ((UInt16(message[1]) << 1) | ((in2 & 0b00001111) << 8) | ((in2 & 0b00100000) >> 5))
      }
      else {
        return 0x0000
      }
    }
  }
  
  public var sensorId : String {
    get {
      let addr = sensorAddress - 1
      return "\(1 + addr >> 3).\(1 + addr % 8)"
    }
  }
  
  public var sensorState : Bool {
    get {
      if opCode == .OPC_INPUT_REP || opCode == .OPC_SW_REP {
        return (message[2] & 0b00010000) != 0x00
      }
      else {
        return false
      }
    }
  }
  
}
