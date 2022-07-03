//
//  TimeoutCode.swift
//  MyTrains
//
//  Created by Paul Willmott on 14/05/2022.
//

import Foundation

public enum TimeoutCode : UInt8 {
  case none = 0
  case readCV = 1
  case writeCV = 2
  case resetQuerySlot4 = 3
  case getInterfaceData = 4
  case getLocoSlotData = 5
  case setLocoSlotData = 6
  case moveSlots = 7
  case getSwState = 8
}
