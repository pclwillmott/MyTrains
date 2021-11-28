//
//  LoconetSensorMessage.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/10/2021.
//

import Foundation

public enum LoconetSensorMessageType {
  case general
  case turnout
}

public class LoconetSensorMessage : NetworkMessage {
  
  public var sensorAddress : UInt16 {
    get {
      let in1 = UInt16(message[1])
      let in2 = UInt16(message[2])
      return 1 + (
        (in1 << 1) |
        ((in2 & 0b00001111) << 8) |
        ((in2 & 0b00100000) >> 5)
        )
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
      return (message[2] & 0b00010000) != 0x00
    }
  }
  
  public var sensorMessageType : LoconetSensorMessageType {
    get {
      return opCode == .OPC_INPUT_REP ? .general : .turnout
    }
  }
  
}
