//
//  LCCPacketType.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/04/2023.
//

import Foundation

public enum LCCCANFrameType {
  case openLCBMessage
  case canControlFrame
}

public enum LCCCANFrameFormat {
  case checkId7Frame
  case checkId6Frame
  case checkId5Frame
  case checkId4Frame
  case reserveIdFrame
  case aliasMapDefinitionFrame
  case aliasMappingEnquiryFrame
  case aliasMapResetFrame
  case errorInformationReport
  case unknown
}
