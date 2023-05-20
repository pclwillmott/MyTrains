//
//  LCCTransportLayerDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/04/2023.
//

import Foundation

public protocol OpenLCBTransportLayerDelegate {
  func openLCBMessageReceived(message:OpenLCBMessage)
  func transportLayerStateChanged(transportLayer:OpenLCBTransportLayer)
}
