//
//  DuplexData.swift
//  MyTrains
//
//  Created by Paul Willmott on 14/04/2022.
//

import Foundation

public class DuplexData : LocoNetMessage {
  
  // MARK: Constructors
  
  // MARK: Public Properties
  
  public var groupName : String {
    
    get {
      
      var data : [UInt8] = []
      
      data.append(message[5] | ((message[4] & 0b00000001) == 0b00000001 ? 0x80 : 0x00))
      data.append(message[6] | ((message[4] & 0b00000010) == 0b00000010 ? 0x80 : 0x00))
      data.append(message[7] | ((message[4] & 0b00000100) == 0b00000100 ? 0x80 : 0x00))
      data.append(message[8] | ((message[4] & 0b00001000) == 0b00001000 ? 0x80 : 0x00))

      data.append(message[10] | ((message[9] & 0b00000001) == 0b00000001 ? 0x80 : 0x00))
      data.append(message[11] | ((message[9] & 0b00000010) == 0b00000010 ? 0x80 : 0x00))
      data.append(message[12] | ((message[9] & 0b00000100) == 0b00000100 ? 0x80 : 0x00))
      data.append(message[13] | ((message[9] & 0b00001000) == 0b00001000 ? 0x80 : 0x00))

      return String(bytes: data, encoding: String.Encoding.utf8)!
      
    }
    
  }
  
  public var groupPassword : String {
    
    get {
      
      let byte1 = Int(message[15] | ((message[14] & 0b00000001) == 0b00000001 ? 0x80 : 0x00))
      let byte2 = Int(message[16] | ((message[14] & 0b00000010) == 0b00000010 ? 0x80 : 0x00))

      let char1 = byte1 >> 4
      let char2 = byte1 & 0xf
      let char3 = byte2 >> 4
      let char4 = byte2 & 0xf

      return String(format: "%01X%01X%01X%01X", char1, char2, char3, char4)
      
    }
    
  }
  
  public var channelNumber : Int {
    get {
      return Int(message[17])
    }
  }
  
  public var groupID : Int {
    get {
      return Int(message[18])
    }
  }
  
}

