//
//  NetworkMessage.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/10/2021.
//

import Foundation

public class NetworkMessage {
  
  init(interfaceId:String, message:[UInt8]) {
    self.message = message
    self.interfaceId = interfaceId
  }
  
  public var message : [UInt8]
  
  public var interfaceId : String
  
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
  
  public static func checkSum(data: Data, length: Int) -> UInt8 {
    var cs : UInt8 = 0xff
    var index : Int = 0
    while (index < length - 1) {
      cs ^= data[index]
      index += 1
    }
    return cs
  }
  
  public static func formLoconetMessage(opCode:LoconetOpcode, data:Data) -> Data {
    let length = 1 + data.count + 1
    var message : Data = Data(repeating: 0x00, count: length)
    message[0] = opCode.rawValue
    var index : Int = 0
    while index < data.count {
      message[1+index] = data[index]
      index += 1
    }
    message[length-1] = NetworkMessage.checkSum(data: message, length: length)
    return message
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
  
  public var messageLength : UInt8 {
    get {
      
      var length = (message[0] & 0b01100000) >> 5
      
      switch length {
      case 0b00 :
        length = 2
        break
      case 0b01 :
        length = 4
        break
      case 0b10 :
        length = 6
        break
      default :
        length = message[1]
        break
      }
      
      return length
    }
  }
  
  public var messageHex : String {
    get {
      var str : String = ""
      for x in message {
        str += String(format: "%02X ",x)
      }
      return str.trimmingCharacters(in: [" "])
    }
  }
    
}
