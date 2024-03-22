//
//  LCCNetworkLayerDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 10/04/2023.
//

import Foundation

@objc public protocol OpenLCBNetworkLayerDelegate {
  @objc func networkLayerStateChanged(networkLayer:OpenLCBNetworkLayer)
  @objc func openLCBMessageReceived(message:OpenLCBMessage)
}
