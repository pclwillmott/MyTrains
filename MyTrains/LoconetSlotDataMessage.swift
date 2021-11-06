//
//  LoconetSlotDataMessage.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/10/2021.
//

import Foundation

public class LoconetSlotDataMessage : LoconetMessage {

  private var _slot : LoconetSlot? = nil
  
  public var slot : LoconetSlot {
    get {
      if _slot == nil {
        _slot = LoconetSlot(message: message)
      }
      return _slot!
    }
  }
  
}

