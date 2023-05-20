//
//  LCCNetworkLayerDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 10/04/2023.
//

import Foundation

public protocol OpenLCBNetworkLayerDelegate {
  func networkLayerStateChanged(networkLayer:OpenLCBNetworkLayer)
  func openLCBMessageReceived(message:OpenLCBMessage)
}
