//
//  OpenLCBNodeAddressSpaceInformation.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/05/2023.
//

import Foundation

public typealias OpenLCBNodeAddressSpaceInformation = (
  addressSpace   : UInt8,
  lowestAddress  : Int,
  highestAddress : Int,
  isReadOnly     : Bool,
  description    : String
)

