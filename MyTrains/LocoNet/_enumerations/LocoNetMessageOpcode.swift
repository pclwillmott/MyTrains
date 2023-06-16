//
//  LocoNetMessageOpcode.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/06/2023.
//

import Foundation

// Constants to represent the contents of byte 0 of a LocoNet Message.

public enum LocoNetMessageOpcode : UInt8 {
  case OPC_UNKNOWN       = 0x00
  case OPC_BUSY          = 0x81
  case OPC_GPOFF         = 0x82
  case OPC_GPON          = 0x83
  case OPC_IDLE          = 0x85
  case OPC_LOCO_RESET    = 0x8A
  case OPC_LOCO_SPD      = 0xA0
  case OPC_LOCO_DIRF     = 0xA1
  case OPC_LOCO_SND      = 0xA2
  case OPC_LOCO_SND2     = 0xA3
  case OPC_SW_REQ        = 0xB0
  case OPC_SW_REP        = 0xB1
  case OPC_INPUT_REP     = 0xB2
  case OPC_LONG_ACK      = 0xB4
  case OPC_SLOT_STAT1    = 0xB5
  case OPC_CONSIST_FUNC  = 0xB6
  case OPC_UNLINK_SLOTS  = 0xB8
  case OPC_LINK_SLOTS    = 0xB9
  case OPC_MOVE_SLOTS    = 0xBA
  case OPC_RQ_SL_DATA    = 0xBB
  case OPC_SW_STATE      = 0xBC
  case OPC_SW_ACK        = 0xBD
  case OPC_LOCO_ADR_P2   = 0xBE
  case OPC_LOCO_ADR      = 0xBF
  case OPC_PR_MODE       = 0xD3
  case OPC_D0_GROUP      = 0xD0
  case OPC_D4_GROUP      = 0xD4
  case OPC_D5_GROUP      = 0xD5
  case OPC_D7_GROUP      = 0xD7
  case OPC_DF_GROUP      = 0xDF
  case OPC_PEER_XFER     = 0xE5
  case OPC_SL_RD_DATA_P2 = 0xE6
  case OPC_SL_RD_DATA    = 0xE7
  case OPC_IMM_PACKET    = 0xED
  case OPC_WR_SL_DATA_P2 = 0xEE
  case OPC_WR_SL_DATA    = 0xEF
}
