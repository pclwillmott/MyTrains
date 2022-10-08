//
//  ConsistState.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/10/2022.
//

import Foundation

public enum ConsistState : Int {
  
  case NotLinked  = 0b00
  case SubMember  = 0b01
  case TopMember  = 0b10
  case MidConsist = 0b11
  
  public var title : String {
    get {
      return ConsistState.titles[self.rawValue]
    }
  }
  
  private static let titles = [
   "Not Linked",
   "Sub-Member",
   "Top-Member",
   "Mid-Consist",
  ]

}

