//
//  OpenLCBWellKnownEvent.swift
//  MyTrains
//
//  Created by Paul Willmott on 18/06/2023.
//

import Foundation

public enum OpenLCBWellKnownEvent : UInt64 {
  
  // Automatically routed
  
  case emergencyOffAll                     = 0x010000000000ffff // de-energize
  case clearEmergencyOffAll                = 0x010000000000fffe // energize
  case emergencyStopAll                    = 0x010000000000fffd
  case clearEmergencyStopAll               = 0x010000000000fffc
  case nodeRecordedNewLogEntry             = 0x010000000000fff8
  case powerSupplyBrownoutDetectedNode     = 0x010000000000fff1 // below minimum required by node
  case powerSupplyBrownoutDetectedStandard = 0x010000000000fff0 // below minimum required by standard
  case identButtonCombinationPressed       = 0x010000000000fe00
  case linkErrorCode1                      = 0x010000000000fd01
  case linkErrorCode2                      = 0x010000000000fd02
  case linkErrorCode3                      = 0x010000000000fd03
  case linkErrorCode4                      = 0x010000000000fd04
  case locoNetMessage                      = 0x0181000000000000

  // Not automatically routed
  
  case duplicateNodeIdDetected             = 0x0101000000000201
  case nodeIsATrain                        = 0x0101000000000303
  case nodeIsATractionProxy                = 0x0101000000000304
  case firmwareCorrupted                   = 0x0101000000000601
  case firmwareUpgradeRequestedBySwitch    = 0x0101000000000602
  case defaultFastClock                    = 0x0101000001000000
  case defaultRealTimeClock                = 0x0101000001010000
  case alternateClock1                     = 0x0101000001020000
  case alternateClock2                     = 0x0101000001030000
  case nodeIsALocoNetGateway               = 0x050101017b00ffff
  case trainSearchEvent                    = 0x090099ff00000000
  case nodeIsADCCProgrammingTrack          = 0x090099feffff0002
  case trainSearchDCCShortAddress          = 0x090099ffffffff08
  case trainSearchDCCLongAddress           = 0x090099ffffffff0c
  case trainMoveStart                      = 0x1000000000000000
  case trainMoveComplete                   = 0x1001000000000000
  case trainMoveUpdate                     = 0x1002000000000000

}
