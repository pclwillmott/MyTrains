//
//  PeerXfer20.swift
//  MyTrains
//
//  Created by Paul Willmott on 25/11/2021.
//

import Foundation

public class PeerXferMessage20 : LoconetMessage {
  
  override init(interfaceId: String, message: [UInt8]) {
    
    super.init(interfaceId: interfaceId, message: message)
    
    let highBits1 = message[9] & 0x0f
    
    peerXferMessage[0] = message[10] | ((highBits1 & 0b0001) << 7)
    peerXferMessage[1] = message[11] | ((highBits1 & 0b0010) << 6)
    peerXferMessage[2] = message[12] | ((highBits1 & 0b0100) << 5)
    peerXferMessage[3] = message[13] | ((highBits1 & 0b1000) << 4)

    let highBits2 = message[14] & 0x0f
    
    peerXferMessage[4] = message[15] | ((highBits2 & 0b0001) << 7)
    peerXferMessage[5] = message[16] | ((highBits2 & 0b0010) << 6)
    peerXferMessage[6] = message[17] | ((highBits2 & 0b0100) << 5)
    peerXferMessage[7] = message[18] | ((highBits2 & 0b1000) << 4)

  }
  
  public var sourceId : UInt8 {
    get {
      return message[2]
    }
  }
  
  public var destId : UInt16 {
    get {
      return UInt16(message[3]) | (UInt16(message[4]) << 7)
    }
  }
  
  public var addressTypeCode : UInt8 {
    get {
      return message[5] >> 4
    }
  }
  
  public var hostId : UInt8 {
    get {
      return message[5]
    }
  }
  
  public var peerXferMessage = [UInt8].init(repeating: 0x00, count: 8)
  
}
