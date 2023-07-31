//
//  OpenLCBLocoNetMonitorDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/07/2023.
//

import Foundation

@objc public protocol OpenLCBLocoNetMonitorDelegate {
  @objc optional func locoNetGatewaysUpdated(monitorNode:OpenLCBLocoNetMonitorNode, gateways:[UInt64:String])
  @objc optional func locoNetMessageReceived(message:LocoNetMessage)
}
