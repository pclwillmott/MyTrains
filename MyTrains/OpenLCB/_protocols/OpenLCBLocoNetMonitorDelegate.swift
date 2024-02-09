//
//  OpenLCBLocoNetMonitorDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/07/2023.
//

import Foundation

@objc public protocol OpenLCBLocoNetMonitorDelegate {
  @objc optional func locoNetMessageReceived(message:LocoNetMessage)
}
