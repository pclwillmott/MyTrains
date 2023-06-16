//
//  LoconetLongAcknowledgeMessage.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/11/2021.
//

import Foundation

public class Ack : LocoNetMessage {

  var opCodeResponding : LocoNetMessageOpcode {
    get {
      return LocoNetMessageOpcode(rawValue: message[1] | 0x80) ?? .OPC_UNKNOWN
    }
  }
  
  var responseCode : LocoNetResponse {
    get {
      return LocoNetResponse(rawValue: responseCodeRawValue) ?? .unknown
    }
  }
  
  var responseCodeRawValue : UInt16 {
    get {
      return (UInt16(message[1]) << 8) | UInt16(message[2])
    }
  }
  
}

