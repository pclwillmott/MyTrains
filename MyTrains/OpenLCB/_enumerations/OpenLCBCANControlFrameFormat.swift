//
//  OpenLCBCANFrameType.swift
//  MyTrains
//
//  Created by Paul Willmott on 09/04/2023.
//

import Foundation

public enum OpenLCBCANControlFrameFormat : UInt16 {
  
  case unknown                  = 0xffff
  case reserveIdFrame           = 0x0700
  case aliasMapDefinitionFrame  = 0x0701
  case aliasMappingEnquiryFrame = 0x0702
  case aliasMapResetFrame       = 0x0703
  case errorInformationReport0  = 0x0710
  case errorInformationReport1  = 0x0711
  case errorInformationReport2  = 0x0712
  case errorInformationReport3  = 0x0713
  case checkId7Frame            = 0x7000
  case checkId6Frame            = 0x6000
  case checkId5Frame            = 0x5000
  case checkId4Frame            = 0x4000

  public var isCheckIdFrame : Bool {
    get {
      return (self.rawValue & 0x7000) != 0 && self != .unknown
    }
  }
}
