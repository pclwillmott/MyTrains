//
//  DCCPacketType.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/06/2023.
//

import Foundation

public enum DCCPacketType : UInt8 {
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
