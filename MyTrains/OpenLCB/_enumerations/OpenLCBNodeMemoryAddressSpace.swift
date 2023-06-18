//
//  OpenLCBNodeMemoryAddressSpace.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/04/2023.
//

import Foundation

public enum OpenLCBNodeMemoryAddressSpace : UInt8 {
  case cdi              = 0xff // 255
  case allMemory        = 0xfe // 254
  case configuration    = 0xfd // 253
  case acdiManufacturer = 0xfc // 252
  case acdiUser         = 0xfb // 251
  case fdi              = 0xfa // 250
  case functions        = 0xf9 // 249
}
