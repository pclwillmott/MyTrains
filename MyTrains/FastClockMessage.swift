//
//  FastClockMessage.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/11/2021.
//

import Foundation

public class FastClockMessage : LocoNetMessage {
  
  public var hours : Int {
    get {
      let temp : UInt16 = ((256 - UInt16(message[8])) & 0x7F) % 24
      return Int((24 - temp) % 24)
    }
  }
  
  public var minutes : Int {
    get {
      let temp : UInt16 = ((255 - UInt16(message[6])) & 0x7F) % 60
      return Int((60 - temp) % 60)
    }
  }
  
  let maxTicks : UInt16 = 0xBFF
  
  public var ticks : UInt16 {
    get {
      let temp = maxTicks - (0x3FFF - ((UInt16(message[4]) & 0x7F) | ((UInt16(message[5]) & 0x7F) << 7)))
  //    print("\(String(format:"%02x %02x %04x", message[4],message[5], temp))")

      return temp
    }
  }
  
  public var seconds : Double {
    get {
      
      let temp = ticks
      
      if temp > maxTicks {
        print("new maxTicks: \(temp)")
      }
      
      return 60.0 * Double(temp) / Double(maxTicks + 1)
    }
  }
  
  public var dataValid : Bool {
    get {
      return message[10] & 0b01000000 != 0x00
    }
  }
  
}
