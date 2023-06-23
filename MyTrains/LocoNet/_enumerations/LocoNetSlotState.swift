//
//  LocoNetSlotState.swift
//  MyTrains
//
//  Created by Paul Willmott on 23/06/2023.
//

import Foundation

public enum LocoNetSlotState : UInt8 {
  
  case free   = 0b00000000
  case common = 0b00010000
  case idle   = 0b00100000
  case inUse  = 0b00110000
  
  public var setMask : UInt8 {
    get {
      return self.rawValue
    }
  }

  public static var protectMask : UInt8 {
    get {
      return 0b11001111
    }
  }
  
}
