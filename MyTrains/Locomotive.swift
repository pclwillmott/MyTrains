//
//  Locomotive.swift
//  MyTrains
//
//  Created by Paul Willmott on 07/11/2021.
//

import Foundation
import Cocoa

public typealias LocomotiveSpeed = (speed: UInt8, direction: LocomotiveDirection)

public typealias LocomotiveStateWithTimeStamp = (state: LocoNetLocomotiveState, timeStamp: TimeInterval)


public let locomotiveUpdateInterval : TimeInterval = 250.0 / 1000.0

