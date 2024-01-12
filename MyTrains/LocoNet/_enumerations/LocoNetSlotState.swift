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

  // MARK: Public Properties
  
  public var title : String {
    return LocoNetSlotState.titles[Int(self.rawValue >> 4)]
  }

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

  // MARK: Private Class Properties
  
  private static let titles = [
    String(localized: "Free", comment: "Used to indicate a LocoNet command station slot status"),
    String(localized: "Common", comment: "Used to indicate a LocoNet command station slot status"),
    String(localized: "Idle", comment: "Used to indicate a LocoNet command station slot status"),
    String(localized: "In Use", comment: "Used to indicate a LocoNet command station slot status"),
  ]
  
}

