//
//  OpenLCBNodeAddressSpaceInformation.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/05/2023.
//

import Foundation

public typealias OpenLCBNodeAddressSpaceInformation = (
  addressSpace   : UInt8,
  lowestAddress  : UInt32,
  highestAddress : UInt32,
  size           : UInt32,
  isReadOnly     : Bool,
  description    : String
)

