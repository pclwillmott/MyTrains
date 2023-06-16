//
//  NetworkTurnoutOutputMessage.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/11/2021.
//

import Foundation

public class NetworkTurnoutOutputMessage : LocoNetMessage {
  
  public var turnoutAddress : UInt16 {
    get {
      let sn1 = UInt16(message[1])
      let sn2 = UInt16(message[2])
      return 1 + (
        (sn1) |
        ((sn2 & 0b00001111) << 7)
        )
    }
  }
  
  public var turnoutId : String {
    get {
      let addr = turnoutAddress - 1
      return "\(1 + addr >> 2).\(1 + addr % 4)"
    }
  }
  
  public var turnoutClosedOutput : NetworkTurnoutOutput {
    let status = (message[2] & 0b00110000) >> 4
    return (status & 0b10) != 0x00 ? .on : .off
  }

  public var turnoutThrownOutput : NetworkTurnoutOutput {
    let status = (message[2] & 0b00110000) >> 4
    return (status & 0b01) != 0x00 ? .on : .off
  }

}

