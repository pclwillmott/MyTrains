//
//  OpenLCBNetworkLayerState.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/04/2023.
//

import Foundation

public enum OpenLCBNetworkLayerState {
  case uninitialized
  case initializingGateways
  case initializingNodes
  case runningLocal
  case runningNetwork
  case stopping
  case stopped
  case rebooting
  case resetToFactoryDefaults
}
