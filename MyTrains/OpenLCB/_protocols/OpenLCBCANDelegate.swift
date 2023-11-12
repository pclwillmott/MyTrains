//
//  OpenLCBCANDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/11/2023.
//

import Foundation

@objc public protocol OpenLCBCANDelegate {
  @objc func OpenLCBMessageReceived(message:OpenLCBMessage)
  @objc func rawCANPacketReceived(packet:String)
  @objc func rawCANPacketSent(packet:String)
  @objc func openLCBCANPacketReceived(packet:LCCCANFrame)
  @objc func openLCBCANPacketSent(packet:LCCCANFrame)
}
