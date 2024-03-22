//
//  OpenLCBMemorySpaceDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/06/2023.
//

import Foundation

@objc public protocol OpenLCBMemorySpaceDelegate {
  @objc func memorySpaceChanged(memorySpace:OpenLCBMemorySpace, startAddress:Int, endAddress:Int)
}
