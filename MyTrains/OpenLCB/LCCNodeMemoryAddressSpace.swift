//
//  LCCNodeMemoryAddressSpace.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/04/2023.
//

import Foundation

public enum LCCNodeMemoryAddressSpace : UInt8 {
  case CDI = 0xff
  case AllMemory = 0xfe
  case Configuration = 0xfd
}
