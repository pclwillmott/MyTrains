//
//  OpenLCBCANDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/11/2023.
//

import Foundation

@objc public protocol OpenLCBNetworkObserverDelegate {
  @objc optional func openLCBMessageReceived(message:OpenLCBMessage)
  @objc optional func canFrameReceived(gateway:OpenLCBCANGateway, frame:LCCCANFrame)
  @objc optional func canFrameSent(gateway:OpenLCBCANGateway, frame:LCCCANFrame)
}
