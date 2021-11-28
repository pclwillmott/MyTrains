//
//  LoconetSwitchRequestMessage.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/10/2021.
//

import Foundation

public class LoconetSwitchRequestMessage : NetworkMessage {
  
  public var switchAddress : UInt16 {
    get {
      let sw1 = UInt16(message[1])
      let sw2 = UInt16(message[2])
      return 1 + (
        (sw1) |
        ((sw2 & 0b00001111) << 7) 
        )
    }
  }
  
  public var switchId : String {
    get {
      let addr = switchAddress - 1
      return "\(1 + addr >> 2).\(1 + addr % 4)"
    }
  }
    
  public var switchState : UInt8 {
    get {
      return (message[2] & 0b00110000) >> 4
    }
  }
  
  public var switchDirection : LoconetSwitchDirection {
    get {
      return switchState & 0b10 != 0x00 ? .closed : .thrown
    }
  }
  
  public var switchOutput : LoconetSwitchOutput {
    return switchState & 0b01 != 0x00 ? .on : .off
  }

}

