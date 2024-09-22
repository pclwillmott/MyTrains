//
//  DCCPacketType.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/06/2023.
//

import Foundation

public enum DCCPacketTypeNew : CaseIterable {
  
  // MARK: Enumeration
  
  case directModeWriteBit
  case directModeVerifyBit
  case directModeWriteByte
  case directModeVerifyByte
  case addressOnlyVerifyAddress
  case addressOnlyWriteAddress
  case physicalRegisterVerifyByte
  case physicalRegisterWriteByte
  case pagedModeVerifyByte
  case pagedModeWriteByte
  case pagePresetInstruction
  case digitalDecoderResetPacket
  case digitalDecoderIdlePacket
  case speedAndDirectionPacket
  case speedStepControl128
  case analogFunctionGroup
  case functionFLF1F4
  case functionF5F8
  case functionF9F12
  case binaryStateControlLongForm
  case timeAndDateCommand
  case systemTime
  case binaryStateControlShortForm
  case functionF13F20
  case functionF21F28
  case functionF29F36
  case functionF37F44
  case functionF45F52
  case functionF53F60
  case functionF61F68
  case cvAccessAccelerationAdjustment
  case cvAccessDeclerationAdjustment
  case cvAccessLongAddress
  case cvAccessIndexedCVs
  case cvAccessVerifyByte
  case cvAccessWriteByte
  case cvAccessVerifyBit
  case cvAccessWriteBit
  case unknown
  
  // MARK: Public Properties
  
  public var title : String {
    return DCCPacketTypeNew.titles[self] ?? DCCPacketTypeNew.unknown.title
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [DCCPacketTypeNew:String] = [
    .directModeWriteBit             : String(localized: "Direct Mode Write Bit"),
    .directModeVerifyBit            : String(localized: "Direct Mode Verify Bit"),
    .directModeWriteByte            : String(localized: "Direct Mode Write Byte"),
    .directModeVerifyByte           : String(localized: "Direct Mode Verify Byte"),
    .addressOnlyVerifyAddress       : String(localized: "Address Only Verify Address"),
    .addressOnlyWriteAddress        : String(localized: "Address Only Write Address"),
    .physicalRegisterVerifyByte     : String(localized: "Physical Register Verify Byte"),
    .physicalRegisterWriteByte      : String(localized: "Physical Register Write Byte"),
    .pagedModeVerifyByte            : String(localized: "Paged Mode Verify Byte"),
    .pagedModeWriteByte             : String(localized: "Paged Mode Write Byte"),
    .pagePresetInstruction          : String(localized: "Page Preset Instruction"),
    .digitalDecoderResetPacket      : String(localized: "Digital Decoder Reset Packet"),
    .digitalDecoderIdlePacket       : String(localized: "Digital Decoder Idle Packet"),
    .speedAndDirectionPacket        : String(localized: "Speed and Direction Packet"),
    .speedStepControl128            : String(localized: "Speed Step Control 128"),
    .analogFunctionGroup            : String(localized: "Analog Function Group"),
    .functionFLF1F4                 : String(localized: "Functions FL, F1 to F4"),
    .functionF5F8                   : String(localized: "Functions F5 to F8"),
    .functionF9F12                  : String(localized: "Functions F9 to F12"),
    .binaryStateControlLongForm     : String(localized: "Binary State Control Long Form"),
    .timeAndDateCommand             : String(localized: "Time and Date Command"),
    .systemTime                     : String(localized: "System Time"),
    .binaryStateControlShortForm    : String(localized: "Binary State Control Short Form"),
    .functionF13F20                 : String(localized: "Functions F13 to F20"),
    .functionF21F28                 : String(localized: "Functions F21 to F28"),
    .functionF29F36                 : String(localized: "Functions F29 to F36"),
    .functionF37F44                 : String(localized: "Functions F37 to F44"),
    .functionF45F52                 : String(localized: "Functions F45 to F52"),
    .functionF53F60                 : String(localized: "Functions F53 to F60"),
    .functionF61F68                 : String(localized: "Functions F61 to F68"),
    .cvAccessAccelerationAdjustment : String(localized: "CV Access Acceleration Adjustment"),
    .cvAccessDeclerationAdjustment  : String(localized: "CV Access Decleration Adjustment"),
    .cvAccessLongAddress            : String(localized: "CV Access Long Address"),
    .cvAccessIndexedCVs             : String(localized: "CV Access Indexed CVs"),
    .cvAccessVerifyByte             : String(localized: "CV Access Verify Byte"),
    .cvAccessWriteByte              : String(localized: "CV Access Write Byte"),
    .cvAccessVerifyBit              : String(localized: "CV Access Verify Bit"),
    .cvAccessWriteBit               : String(localized: "CV Access Write Bit"),
    .unknown                        : String(localized: "Unknown"),
]
  
}


public enum DCCPacketType : UInt8 {
  
  // MARK: Enumeration
  
  // MARK: Deprecated
  
  case dccF0F4             = 0b10000000
  case dccF5F8             = 0b10110000
  case dccF9F12            = 0b10100000
  case dccF13F20           = 0b11011110
  case dccF21F28           = 0b11011111
  case dccF29F36           = 0b11011000
  case dccF37F44           = 0b11011001
  case dccF45F52           = 0b11011010
  case dccF53F60           = 0b11011011
  case dccF61F68           = 0b11011100
  case dccIdle             = 0b00000000
  case dccBinaryStateLong  = 0b11000000
  case dccBinaryStateShort = 0b11011101
  case dccAnalogFunction   = 0b00111101
//  case dccSetSw
//  case dccSpdDirF0
//  case dccSpdDir128
//  case dccUnknown
//  case dccUnitialized

}

