//
//  LocoNetDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 02/07/2023.
//

import Foundation

@objc public protocol LocoNetDelegate {
  @objc optional func locoNetMessageReceived(gatewayNodeId:UInt64, message:LocoNetMessage)
  @objc optional func locoNetError(gatewayNodeId:UInt64, errorCode:UInt16)
}
