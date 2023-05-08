//
//  SlotState.swift
//  MyTrains
//
//  Created by Paul Willmott on 04/08/2022.
//

import Foundation

public enum SlotState : Int {
  
  case free = 0
  case common = 1
  case idle = 2
  case inUse = 3
  
  public var title : String {
    get {
      return SlotState.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "Free",
    "Common",
    "Idle",
    "In Use",
  ]
  
}

