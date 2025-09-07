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

  // Not automatically routed

  case duplicateNodeIdDetected             = 0x0101000000000201
  case nodeIsATrain                        = 0x0101000000000303
  case nodeIsATrainControlProxy            = 0x0101000000000304
  case firmwareCorrupted                   = 0x0101000000000601
  case firmwareUpgradeRequestedBySwitch    = 0x0101000000000602
  case defaultFastClock                    = 0x0101000001000000
  case defaultRealTimeClock                = 0x0101000001010000
  case alternateClock1                     = 0x0101000001020000
  case alternateClock2                     = 0x0101000001030000
  case locationServicesReport              = 0x0102000000000000
  case nodeIsAMyTrainsLayout               = 0x050101017b00ffff
  case trainSearchEvent                    = 0x090099ff00000000
  case nodeIsADCCProgrammingTrack          = 0x090099feffff0002
  case trainSearchDCCShortAddress          = 0x090099ffffffff08
  case trainSearchDCCLongAddress           = 0x090099ffffffff0c
  case trainMoveStart                      = 0x1000000000000000 // ?
  case trainMoveComplete                   = 0x1001000000000000 // ?
  case trainMoveUpdate                     = 0x1002000000000000 // ?

  // MARK: Public Properties
  
  public var isAutomaticallyRouted : Bool {
    return OpenLCBWellKnownEvent.isAutomaticallyRouted(eventId: self.rawValue)
  }
  
  public var title : String {
    return OpenLCBWellKnownEvent.titles[self]!
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [OpenLCBWellKnownEvent:String] = [
    .emergencyOffAll : String(localized: "Emergency Off All"),
    .clearEmergencyOffAll : String(localized: "Clear Emergency Off All"),
    .emergencyStopAll : String(localized: "Emergency Stop All"),
    .clearEmergencyStopAll : String(localized: "Clear Emergency Stop All"),
    .nodeRecordedNewLogEntry : String(localized: "Node Recorded New Log Entry"),
    .powerSupplyBrownoutDetectedNode : String(localized: "Power Supply Brownout Detected Node"),
    .powerSupplyBrownoutDetectedStandard : String(localized: "Power Supply Brownout Detected Standard"),
    .identButtonCombinationPressed : String(localized: "Ident Button Combination Pressed"),
    .linkErrorCode1 : String(localized: "Link Error Code 1"),
    .linkErrorCode2 : String(localized: "Link Error Code 2"),
    .linkErrorCode3 : String(localized: "Link Error Code 3"),
    .linkErrorCode4 : String(localized: "Link Error Code 4"),
    .duplicateNodeIdDetected : String(localized: "Duplicate Node ID Detected"),
    .nodeIsATrain : String(localized: "Node Is A Train"),
    .nodeIsATrainControlProxy : String(localized: "Node Is A Train Control Proxy"),
    .firmwareCorrupted : String(localized: "Firmware Corrupted"),
    .firmwareUpgradeRequestedBySwitch : String(localized: "Firmware Upgrade Requested By Switch"),
    .defaultFastClock : String(localized: "Default Fast Clock"),
    .defaultRealTimeClock : String(localized: "Default Real-Time Clock"),
    .alternateClock1 : String(localized: "Alternate Clock 1"),
    .alternateClock2 : String(localized: "Alternate Clock 2"),
    .locationServicesReport : String(localized: "Location Services Report"),
    .trainSearchEvent : String(localized: "Train Search"),
    .nodeIsAMyTrainsLayout : String(localized: "Node Is A MyTrains Layout"),
    .nodeIsADCCProgrammingTrack : String(localized: "Node Is A DCC Programming Track"),
    .trainSearchDCCShortAddress : String(localized: "Train Search DCC Short Address"),
    .trainSearchDCCLongAddress : String(localized: "Train Search DCC Long Address"),
    .trainMoveStart : String(localized: "Train Move Start"),
    .trainMoveComplete : String(localized: "Train Move Complete"),
    .trainMoveUpdate : String(localized: "Train Move Update"),
  ]
  
  // MARK: Public Class Properties
  
  public static func isAutomaticallyRouted(eventId:UInt64) -> Bool {
    return (eventId & 0xffff000000000000) == 0x0100000000000000
  }
  
}
