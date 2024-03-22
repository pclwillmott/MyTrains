//
//  OpenLCBClockDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 26/05/2023.
//

import Foundation

@objc public protocol OpenLCBClockDelegate {
  @objc func clockTick(clock:OpenLCBClock)
}

