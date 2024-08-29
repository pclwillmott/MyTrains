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
