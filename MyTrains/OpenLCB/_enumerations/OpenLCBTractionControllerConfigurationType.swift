//
//  OpenLCBTractionControllerConfigurationType.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2023.
//

import Foundation

public enum OpenLCBTractionControllerConfigurationType : UInt8 {
  
  case assignController         = 0x01
  case releaseController        = 0x02
  case queryController          = 0x03
  case controllerChangingNotify = 0x04
}
