//
//  DCCPacketType.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/06/2023.
//

import Foundation

public enum DCCPacketType {
  case dccF0F4
  case dccF5F8
  case dccF9F12
  case dccF13F20
  case dccF21F28
  case dccIdle
  case dccSetSw
  case dccSpdDirF0
  case dccSpdDir128
  case dccUnknown
  case dccUnitialized
}
