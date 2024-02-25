//
//  OpenLCBCANDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/11/2023.
//

import Foundation

@objc public protocol OpenLCBNetworkObserverDelegate {
  @objc optional func updateMonitor(text:String)
}
