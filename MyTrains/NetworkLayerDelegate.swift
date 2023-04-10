//
//  NetworkLayerDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 10/04/2023.
//

import Foundation

public protocol LCCNetworkLayerDelegate {
  func networkLayerStateChanged(networkLayer:LCCNetworkLayer)
}
