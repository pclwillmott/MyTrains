//
//  NetworkConstants.swift
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
  case OPC_LOCO_SND2    = 0xA3
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
  case OPC_PEER_XFER    = 0xE5
  case OPC_SL_RD_DATA   = 0xE7
  case OPC_WR_SL_DATA   = 0xEF
}

/*
     OPC_EXP_REQ_SLOT = 0xbe;
     OPC_EXP_SLOT_MOVE = 0xd4;
     OPC_EXP_RD_SL_DATA = 0xe6;
     OPC_EXP_WR_SL_DATA = 0xee;
     OPC_EXP_SEND_SUB_CODE_MASK_SPEED               = 0b11110000;
     OPC_EXP_SEND_SUB_CODE_MASK_FUNCTION            = 0b11111000;
     OPC_EXP_SEND_FUNCTION_OR_SPEED_AND_DIR = 0xd5;
     OPC_EXP_SEND_SPEED_AND_DIR_MASK                = 0b00010000;
     OPC_EXP_SEND_FUNCTION_GROUP_F0F6_MASK          = 0b00010000;
     OPC_EXP_SEND_FUNCTION_GROUP_F7F13_MASK         = 0b00011000;
     OPC_EXP_SEND_FUNCTION_GROUP_F14F20_MASK        = 0b00100000;
     OPC_EXP_SEND_FUNCTION_GROUP_F21F28_F28OFF_MASK = 0b00101000;
     OPC_EXP_SEND_FUNCTION_GROUP_F21F28_F28ON_MASK  = 0b00110000;
 
 OPC_UNKNOWN BE
 message Length = 4
 be 00 0b 4a

 OPC_UNKNOWN E6
 message Length = 21
 e6 15 00 04 33 0b 00 47 00 00 00 01 00 00 00 00 00 00 00 00 76
 
 OPC_LOCO_SND2
 a3 04 06 5e
 OPC_LOCO_SND2
 a3 04 04 5c
 OPC_LOCO_SND2
 a3 04 00 58
 OPC_LOCO_SND2
 a3 04 02 5a
 */

/** This slot communicates with the programming track   */
//   public final static int PRG_SLOT = 0x7c;

   /** This slot holds extended configuration bits for some command stations */
//   public final static int CFG_EXT_SLOT = 0x7e;

   /** This slot holds configuration bits                   */
//   public final static int CFG_SLOT = 0x7f;

/*
// Expanded slot index values
    public final static int EXP_MAST = 0;
    public final static int EXP_SLOT = 0x01;
    public final static int EXPD_LENGTH = 16;
//offsets into message
    public final static int EXPD_STAT = 0;
    public final static int EXPD_ADRL = 1;
    public final static int EXPD_ADRH = 2;
    public final static int EXPD_FLAGS = 3;
    public final static int EXPD_SPD = 4;
    public final static int EXPD_F28F20F12 = 5;
    public final static int EXPD_DIR_F0F4_F1 = 6;
    public final static int EXPD_F11_F5 = 7;
    public final static int EXPD_F19_F13 = 8;
    public final static int EXPD_F27_F21 = 9;
*/

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
