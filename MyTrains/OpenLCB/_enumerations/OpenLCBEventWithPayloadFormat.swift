//
//  OpenLCBEventWithPayloadFormat.swift
//  MyTrains
//
//  Created by Paul Willmott on 03/09/2023.
//

import Foundation

public enum OpenLCBEventWithPayloadFormat : UInt8 {
  case dccPrimaryAddress = 1
  case dccExtendedAddress = 2
  case openLCBNodeId = 3
}

