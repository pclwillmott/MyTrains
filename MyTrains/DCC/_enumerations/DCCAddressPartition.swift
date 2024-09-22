//
//  DCCAddressPartition.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/06/2023.
//

import Foundation

public enum DCCAddressPartition : UInt8 {
  case dccBroadcast = 0
  case dccMFDPA     = 1
  case dccBAD11     = 128
  case dccMFDEA     = 192
  case dccReserved  = 232
  case dccAEPF      = 253
  case dccIdle      = 255
}

