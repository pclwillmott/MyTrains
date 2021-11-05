//
//  LoconetLongAcknowledgeMessage.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/11/2021.
//

import Foundation

public class LoconetLongAcknowledgeMessage : LoconetMessage {

  var opCodeResponding : LoconetOpcode {
    get {
      return LoconetOpcode(rawValue: message[1] | 0x80) ?? .OPC_UNKNOWN
    }
  }
  
  var responseCode : LoconetResponse {
    get {
      return LoconetResponse(rawValue: (UInt16(message[1]) << 8) | UInt16(message[2])) ?? .unknown
    }
  }
  
}

