//
//  OpenLCBWellKnownEvent.swift
//  MyTrains
//
//  Created by Paul Willmott on 18/06/2023.
//

import Foundation

public enum OpenLCBWellKnownEvent : UInt64 {
  
  // Automatically routed
  
  case emergencyOff                        = 0x010000000000ffff // de-energize
  case clearEmergencyOff                   = 0x010000000000fffe // energize
  case emergencyStopAllOperations          = 0x010000000000fffd
  case clearEmergencyStopAllOperations     = 0x010000000000fffc
  case nodeRecordedNewLogEntry             = 0x010000000000fff8
  case powerSupplyBrownoutDetectedNode     = 0x010000000000fff1 // below minimum required by node
  case powerSupplyBrownoutDetectedStandard = 0x010000000000fff0 // below minimum required by standard
  case identButtonCombinationPressed       = 0x010000000000fe00
  case linkErrorCode1                      = 0x010000000000fd01
  case linkErrorCode2                      = 0x010000000000fd02
  case linkErrorCode3                      = 0x010000000000fd03
  case linkErrorCode4                      = 0x010000000000fd04
  case trainSearchEvent                    = 0x090099ff00000000
  
  // Not automatically routed
  
  case duplicateNodeIdDetected             = 0x0101000000000201
  case nodeIsATrain                        = 0x0101000000000303
  case nodeIsATractionProxy                = 0x0101000000000304
  case firmwareCorrupted                   = 0x0101000000000601
  case firmwareUpgradeRequestBySwitch      = 0x0101000000000602
  case defaultFastClock                    = 0x0101000001000000
  case defaultRealTimeClock                = 0x0101000001010000
  case alternateClock1                     = 0x0101000001020000
  case alternateClock2                     = 0x0101000001030000

}