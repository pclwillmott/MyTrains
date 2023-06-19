//
//  OpenLCBTractionListenerConfigurationType.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2023.
//

import Foundation

public enum OpenLCBTractionListenerConfigurationType : UInt8 {
  
  case attachNode = 0x01
  case detachNode = 0x02
  case queryNodes = 0x03
  
}
