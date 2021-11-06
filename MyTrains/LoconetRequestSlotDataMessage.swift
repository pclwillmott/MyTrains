//
//  LoconetRequestSlotDataMessage.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/11/2021.
//

import Foundation
public class LoconetRequestSlotDataMessage : LoconetMessage {
  
  public var slotNumber : UInt8 {
    get {
      return message[1]
    }
  }
  
}

