//
//  OpenLCBClockType.swift
//  MyTrains
//
//  Created by Paul Willmott on 26/05/2023.
//

import Foundation

public enum OpenLCBClockType : UInt64 {
  
  case fastClock       = 0x0101000001000000
  case realTimeClock   = 0x0101000001010000
  case alternateClock1 = 0x0101000001020000
  case alternateClock2 = 0x0101000001030000

}
