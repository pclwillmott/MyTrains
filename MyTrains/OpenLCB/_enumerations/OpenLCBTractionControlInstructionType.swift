//
//  OpenLCBTractionControlInstructionType.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2023.
//

import Foundation

public enum OpenLCBTractionControlInstructionType : UInt8 {
  
  case setSpeedDirection       = 0x00
  case setFunction             = 0x01
  case emergencyStop           = 0x02
  case setMove                 = 0x03
  case startMove               = 0x04
  case stopMove                = 0x05
  case querySpeeds             = 0x10
  case queryFunction           = 0x11
  case controllerConfiguration = 0x20
  case listenerConfiguration   = 0x30
  case tractionManagement      = 0x40
  
}
