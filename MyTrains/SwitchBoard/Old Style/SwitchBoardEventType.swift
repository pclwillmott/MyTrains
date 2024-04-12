//
//  SwitchBoardEventType.swift
//  MyTrains
//
//  Created by Paul Willmott on 15/12/2023.
//

import Foundation

public enum SwitchBoardEventType : Int {
  
  case enterDetectionZone = 0
  case exitDetectionZone  = 1
  case transponder        = 2
  case trackFault         = 3
  case trackFaultCleared  = 4
  case sw1CommandedThrown = 5
  case sw1CommandedClosed = 6
  case sw1Thrown          = 7
  case sw1Closed          = 8
  case sw2CommandedThrown = 9
  case sw2CommandedClosed = 10
  case sw2Thrown          = 11
  case sw2Closed          = 12
  case throwSW1           = 13
  case closeSW1           = 14
  case throwSW2           = 15
  case closeSW2           = 16
  
  public var title : String {
    return SwitchBoardEventType.titles[self.rawValue]
  }
  
  public static let titles = [
    "Enter Detection Zone Event ID",
    "Exit Detection Zone Event ID",
    "Transponder Event ID",
    "Track Fault Event ID",
    "Track Fault Cleared Event ID",
    "Turnout Switch #1 Commanded Thrown Event ID",
    "Turnout Switch #1 Commanded Closed Event ID",
    "Turnout Switch #1 Thrown Event ID",
    "Turnout Switch #1 Closed Event ID",
    "Turnout Switch #2 Commanded Thrown Event ID",
    "Turnout Switch #2 Commanded Closed Event ID",
    "Turnout Switch #2 Thrown Event ID",
    "Turnout Switch #2 Closed Event ID",
    "Throw Turnout Switch #1 Event ID",
    "Close Turnout Switch #1 Event ID",
    "Throw Turnout Switch #2 Event ID",
    "Close Turnout Switch #2 Event ID",
  ]

}
