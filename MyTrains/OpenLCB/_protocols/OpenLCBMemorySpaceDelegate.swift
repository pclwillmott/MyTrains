//
//  OpenLCBMemorySpaceDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/06/2023.
//

import Foundation

public protocol OpenLCBMemorySpaceDelegate {
  func memorySpaceChanged(memorySpace:OpenLCBMemorySpace, startAddress:Int, endAddress:Int)
}
