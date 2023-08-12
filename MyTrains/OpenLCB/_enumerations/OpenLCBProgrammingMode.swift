//
//  OpenLCBProgrammingMode.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/08/2023.
//

import Foundation
import Cocoa

public enum OpenLCBProgrammingMode : UInt32 {
  
  case defaultProgrammingMode     = 0x00000000
  case directModeProgramming      = 0x01000000
  case programOnTheMain           = 0x02000000
  case pagedModeProgramming       = 0x03000000
  case defaultProgrammingModeBit0 = 0x10000000
  case defaultProgrammingModeBit1 = 0x11000000
  case defaultProgrammingModeBit2 = 0x12000000
  case defaultProgrammingModeBit3 = 0x13000000
  case defaultProgrammingModeBit4 = 0x14000000
  case defaultProgrammingModeBit5 = 0x15000000
  case defaultProgrammingModeBit6 = 0x16000000
  case defaultProgrammingModeBit7 = 0x17000000
  
  // MARK: Public Methods
  
  public func locoNetProgrammingMode(isProgrammingTrack:Bool) -> LocoNetProgrammingMode {
    switch self {
    case .defaultProgrammingMode:
      return isProgrammingTrack ? .direct : .operations
    case .directModeProgramming:
      return .direct
    case .pagedModeProgramming:
      return .paged
    case .programOnTheMain:
      return .operations
    default:
      return isProgrammingTrack ? .direct : .operations
    }
  }
  
  // MARK: Class Properties
  
  public static var modeMask : UInt32 {
    return 0xff000000
  }
  
  public static var addressMark : UInt32 {
    return ~modeMask
  }
  
}
