//
//  LocoNetIMMPacketRepeat.swift
//  MyTrains
//
//  Created by Paul Willmott on 02/12/2023.
//

import Foundation

public enum LocoNetIMMPacketRepeat : UInt8 {
  
  case repeat0 = 0x00
  case repeat1 = 0x01
  case repeat2 = 0x02
  case repeat3 = 0x03
  case repeat4 = 0x04
  case repeat5 = 0x05
  case repeat6 = 0x06
  case repeat7 = 0x07
  case repeatContinuous = 0x0f

}
