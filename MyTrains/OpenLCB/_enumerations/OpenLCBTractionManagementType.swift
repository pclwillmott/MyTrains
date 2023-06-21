//
//  OpenLCBTractionManagementType.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/06/2023.
//

import Foundation

public enum OpenLCBTractionManagementType : UInt8 {
  
  case reserve                = 0x01
  case release                = 0x02
  case noopOrHeartbeatRequest = 0x03
  
}
