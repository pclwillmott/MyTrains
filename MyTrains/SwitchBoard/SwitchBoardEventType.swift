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
  case sw1Thrown          = 5
  case sw1Closed          = 6
  case sw2Thrown          = 7
  case sw2Closed          = 8
  case throwSW1           = 9
  case closeSW1           = 10
  case throwSW2           = 11
  case closeSW2           = 12
  
  public var title : String {
    return SwitchBoardEventType.titles[self.rawValue]
  }
  
  public static let titles = [
    "Enter Detection Zone Event ID",
    "Exit Detection Zone Event ID",
    "Transponder Event ID",
    "Track Fault Event ID",
    "Track Fault Cleared Event ID",
    "Turnout Switch #1 Thrown Event ID",
    "Turnout Switch #1 Closed Event ID",
    "Turnout Switch #2 Thrown Event ID",
    "Turnout Switch #2 Closed Event ID",
    "Throw Turnout Switch #1 Event ID",
    "Close Turnout Switch #1 Event ID",
    "Throw Turnout Switch #2 Event ID",
    "Close Turnout Switch #2 Event ID",
  ]

}
