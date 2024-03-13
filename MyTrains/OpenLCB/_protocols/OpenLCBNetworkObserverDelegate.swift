//
//  OpenLCBCANDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/11/2023.
//

import Foundation

@objc public protocol OpenLCBNetworkObserverDelegate {
  @objc optional func updateMonitor(text:String)
  @objc optional func gatewayRXPacket(gateway:Int)
  @objc optional func gatewayTXPacket(gateway:Int)
}
