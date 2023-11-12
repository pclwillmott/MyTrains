//
//  OpenLCBClockDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 26/05/2023.
//

import Foundation

public protocol OpenLCBClockDelegate {
  func clockTick(clock:OpenLCBClock)
}

