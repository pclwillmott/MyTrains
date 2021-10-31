//
//  LoconetMessage.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/10/2021.
//

import Foundation

public class LoconetMessage : NSObject {
  
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
    
}
