//
//  OpenLCBThrottleDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 25/06/2023.
//

import Foundation

@objc public protocol OpenLCBThrottleDelegate {
  @objc optional func trainSearchResultsReceived(throttle:OpenLCBThrottle, results:[UInt64:String])
  @objc optional func throttleStateChanged(throttle:OpenLCBThrottle)
}
