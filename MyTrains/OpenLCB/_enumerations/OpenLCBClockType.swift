//
//  OpenLCBClockType.swift
//  MyTrains
//
//  Created by Paul Willmott on 26/05/2023.
//

import Foundation

public enum OpenLCBClockType : UInt8 {
  
  case fastClock       = 0
  case realTimeClock   = 1
  case alternateClock1 = 2
  case alternateClock2 = 3
  case customClock     = 4
  
}
