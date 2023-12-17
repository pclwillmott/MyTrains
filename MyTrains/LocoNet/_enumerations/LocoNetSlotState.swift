//
//  SlotState.swift
//  MyTrains
//
//  Created by Paul Willmott on 04/08/2022.
//

import Foundation

public enum LocoNetSlotState : UInt8 {
  
  case free   = 0b00000000
  case common = 0b00010000
  case idle   = 0b00100000
  case inUse  = 0b00110000

  public var title : String {
    get {
      return LocoNetSlotState.titles[Int(self.rawValue)]
    }
  }
  
  private static let titles = [
    "Free",
    "Common",
    "Idle",
    "In Use",
  ]
  
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

