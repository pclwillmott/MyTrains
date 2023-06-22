//
//  LocoNetLocomotiveState.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/06/2023.
//

import Foundation

public typealias LocoNetLocomotiveState = (
  speed: UInt8,
  direction: LocomotiveDirection,
  functions: UInt64,
  extendedFunctions: UInt64
)
