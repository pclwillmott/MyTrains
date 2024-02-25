//
//  OpenLCBMessageCANFrameType.swift
//  MyTrains
//
//  Created by Paul Willmott on 09/04/2023.
//

import Foundation

public enum OpenLCBMessageCANFrameType : UInt32 {
  
  case reserved1 = 0
  case globalAndAddressedMTI = 1
  case datagramCompleteInFrame = 2
  case datagramFirstFrame = 3
  case datagramMiddleFrame = 4
  case datagramFinalFrame = 5
  case reserved2 = 6
  case streamData = 7
  
  // MARK: Public Properties
  
  public var title : String {
    return OpenLCBMessageCANFrameType.titles[self]!
  }
  
  // MARK: Private Class Methods
  
  private static let titles : [OpenLCBMessageCANFrameType:String] = [
    .reserved1 : String(localized: "Reserved 1"),
    .globalAndAddressedMTI : String(localized: "Global And Addressed MTI"),
    .datagramCompleteInFrame : String(localized: "Datagram Complete In Frame"),
    .datagramFirstFrame : String(localized: "Datagram First Frame"),
    .datagramMiddleFrame : String(localized: "Datagram Middle Frame"),
    .datagramFinalFrame : String(localized: "Datagram Final Frame"),
    .reserved2 : String(localized: "Reserved 2"),
    .streamData : String(localized: "Stream Data"),
  ]
}
