//
//  LoconetConstants.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/10/2021.
//

import Foundation

public enum LoconetOpcode : UInt8 {
  case OPC_UNKNOWN      = 0x00
  case OPC_BUSY         = 0x81
  case OPC_GPOFF        = 0x82
  case OPC_GPON         = 0x83
  case OPC_IDLE         = 0x85
  case OPC_LOCO_SPD     = 0xA0
  case OPC_LOCO_DIRF    = 0xA1
  case OPC_LOCO_SND     = 0xA2
  case OPC_SW_REQ       = 0xB0
  case OPC_SW_REP       = 0xB1
  case OPC_INPUT_REP    = 0xB2
  case OPC_LONG_ACK     = 0xB4
  case OPC_SLOT_STAT1   = 0xB5
  case OPC_CONSIST_FUNC = 0xB6
  case OPC_UNLINK_SLOTS = 0xB8 
  case OPC_LINK_SLOTS   = 0xB9
  case OPC_MOVE_SLOTS   = 0xBA
  case OPC_RQ_SL_DATA   = 0xBB
  case OPC_SW_STATE     = 0xBC
  case OPC_SW_ACK       = 0xBD
  case OPC_LOCO_ADR     = 0xBF
  case OPC_SL_RD_DATA   = 0xE7
  case OPC_WR_SL_DATA   = 0xEF
}

public enum LoconetSwitchDirection {
  case thrown
  case closed
}

public enum LoconetSwitchOutput {
  case off
  case on
}

public enum LoconetSlotSpeedType : UInt8 {
  case inertialStop = 0x00
  case emergencyStop = 0x01
  case maxSpeed = 0x7f
  case speedIncreasing = 0xff
}

public enum LoconetDecoderType : UInt8 {
  case type128A    = 0b111 // 128 step, Advanced Consisting allowed
  case type128     = 0b011 // 128 step
  case type28A     = 0b100 // 28 step, Advanced Consisting allowed
  case type28      = 0b000 // 28 step
  case type28Tri   = 0b001 // 28 step, send Motorola Trinary
  case type14      = 0b010 // 14 step
  case unknown = 0xff
}

public enum LoconetLocoUsage : UInt8 {
  case inUse   = 0b00110000
  case idle    = 0b00100000
  case common  = 0b00010000
  case free    = 0b00000000
  case unknown = 0xff
 }

public enum LoconetLocoDirection : UInt8 {
  case forwards  = 0b00100000
  case backwards = 0b00000000
  case unknown   = 0xff
}

  

