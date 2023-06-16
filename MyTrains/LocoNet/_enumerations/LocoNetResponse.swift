//
//  LocoNetResponse.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/06/2023.
//

import Foundation

public enum LocoNetResponse : UInt16 {
  case SW_ACK_FIFOIsFull      = 0x3d00
  case SW_ACK_Accepted        = 0x3d7f
  case MOVE_SLOTS_IllegalMove = 0x3a00
  case LINK_SLOTS_Fail        = 0x3900
  case SW_REQ_Fail            = 0x3000
  case LOCO_ADR_NoFreeSlot    = 0x3f00
  case unknown                = 0xffff
  
}
