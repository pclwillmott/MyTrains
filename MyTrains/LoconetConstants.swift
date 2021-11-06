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

public enum LoconetResponse : UInt16 {
  case SW_ACK_FIFOIsFull      = 0x3d00
  case SW_ACK_Accepted        = 0x3d7f
  case MOVE_SLOTS_IllegalMove = 0x3a00
  case LINK_SLOTS_Fail        = 0x3900
  case SW_REQ_Fail            = 0x3000
  case LOCO_ADR_NoFreeSlot    = 0x3f00
  case unknown                = 0xffff
  
}

public enum LoconetSlotByte : Int {
  case slotNumber           = 0
  case slotStatus1          = 1
  case slotLocoAdr          = 2
  case slotSpeed            = 3
  case slotDirF             = 4
  case trk                  = 5
  case slotStatus2          = 6
  case slotLocoAdrHigh      = 7
  case slotSound            = 8
  case expansionReservedId1 = 9
  case expansionReservedId2 = 10
}

public enum LoconetSwitchDirection {
  case thrown
  case closed
}

public enum LoconetSwitchOutput {
  case off
  case on
}

public enum LoconetTurnoutOutput {
  case off
  case on
}

public enum LoconetSlotSpeedType : UInt8 {
  case inertialStop    = 0x00
  case emergencyStop   = 0x01
  case maxSpeed        = 0x7f
  case speedIncreasing = 0xff
}

public let loconetDecoderTypeMask : UInt8 = 0b00000111

public enum LoconetDecoderType : UInt8 {
  case type28      = 0b000 // 28 step
  case type28Tri   = 0b001 // 28 step, send Motorola Trinary
  case type14      = 0b010 // 14 step
  case type128     = 0b011 // 128 step
  case type28A     = 0b100 // 28 step, Advanced Consisting allowed
  case type128A    = 0b111 // 128 step, Advanced Consisting allowed
  case unknown     = 0xff
}

public let loconetLocoUsageMask : UInt8 = 0b00110000

public enum LoconetLocoUsage : UInt8 {
  case free    = 0b00000000
  case common  = 0b00010000
  case idle    = 0b00100000
  case inUse   = 0b00110000
  case unknown = 0xff
}

public enum LoconetLocoDirection : UInt8 {
  case forwards  = 0b00100000
  case backwards = 0b00000000
  case unknown   = 0xff
}

public let loconetTrackProgBusyMask : UInt8 = 0b00001000
public let loconetTrackMLOK1Mask    : UInt8 = 0b00000100
public let loconetTrackIdleMask     : UInt8 = 0b00000010
public let loconetTrackPowerMask    : UInt8 = 0b00000001

public let loconetDirFXCNTMask : UInt8 = 0b01000000
public let loconetDirFDirMask  : UInt8 = 0b00100000
public let loconetDirFF0       : UInt8 = 0b00010000
public let loconetDirFF4       : UInt8 = 0b00001000
public let loconetDirFF3       : UInt8 = 0b00000100
public let loconetDirFF2       : UInt8 = 0b00000010
public let loconetDirFF1       : UInt8 = 0b00000001

public let loconetSnd4 : UInt8 = 0b00001000
public let loconetSnd3 : UInt8 = 0b00000100
public let loconetSnd2 : UInt8 = 0b00000010
public let loconetSnd1 : UInt8 = 0b00000001

