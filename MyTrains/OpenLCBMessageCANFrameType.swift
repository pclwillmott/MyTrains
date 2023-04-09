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
  
}
