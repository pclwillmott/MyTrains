//
//  LocoNetGatewayDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 12/06/2024.
//

import Foundation

@objc public protocol LocoNetGatewayDelegate {
  
  @objc var nodeId : UInt64 { get }
  @objc optional func locoNetConnected(gateway:LocoNetGateway)
  @objc optional func locoNetDisconnected(gateway:LocoNetGateway)
  @objc optional func locoNetMessageReceived(message: LocoNetMessage)

}
