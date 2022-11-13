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
  
  public var stat1Mask : UInt8 {
    get {
      
      var    mask : UInt8 = (((self.rawValue & 0b01) == 0b01) ? 0b01000000 : 0x00)
      return mask         | (((self.rawValue & 0b10) == 0b10) ? 0b00001000 : 0x00)

    }
  }
  
  private static let titles = [
   "Not Linked",
   "Sub-Member",
   "Top-Member",
   "Mid-Consist",
  ]

}

