//
//  DCCDecoderMode.swift
//  MyTrains
//
//  Created by Paul Willmott on 26/08/2024.
//

import Foundation

public enum DCCDecoderMode : CaseIterable {
  
  // MARK: Enumeration
  
  case operationsMode
  case serviceModeDirectAddressing
  case serviceModeAddressOnly
  case serviceModePhysicalRegister
  case serviceModePagedAddressing
  
}
