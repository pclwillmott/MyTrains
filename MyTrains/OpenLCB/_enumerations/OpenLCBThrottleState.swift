//
//  OpenLCBThrottleState.swift
//  MyTrains
//
//  Created by Paul Willmott on 25/06/2023.
//

import Foundation

public enum OpenLCBThrottleState : Int {
  
  case idle             = 0
  case selected         = 1
  case listener         = 2
  case activeController = 3
  
  public var title : String {
    get {
      return OpenLCBThrottleState.titles[self.rawValue]
    }
  }
  
  private static let titles = [
    "IDLE",
    "SELECTED",
    "LISTENER",
    "ACTIVE CONTROLLER",
  ]

}
