//
//  LoconetLongAcknowledgeMessage.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/11/2021.
//

import Foundation

public class Ack : LocoNetMessage {

  var opCodeResponding : NetworkMessageOpcode {
    get {
      return NetworkMessageOpcode(rawValue: message[1] | 0x80) ?? .OPC_UNKNOWN
    }
  }
  
  var responseCode : LoconetResponse {
    get {
      return LoconetResponse(rawValue: responseCodeRawValue) ?? .unknown
    }
  }
  
  var responseCodeRawValue : UInt16 {
    get {
      return (UInt16(message[1]) << 8) | UInt16(message[2])
    }
  }
  
}

