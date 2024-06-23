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
  @objc optional func functionChanged(throttle:OpenLCBThrottle, address:UInt32, value:UInt16)
  @objc optional func speedChanged(throttle:OpenLCBThrottle, speed:Float)
  @objc optional func emergencyStopChanged(throttle:OpenLCBThrottle)
  @objc optional func globalEmergencyChanged(throttle:OpenLCBThrottle)
  @objc optional func fdiAvailable(throttle:OpenLCBThrottle)
  @objc optional func eventReceived(throttle:OpenLCBThrottle, message:OpenLCBMessage)
}
