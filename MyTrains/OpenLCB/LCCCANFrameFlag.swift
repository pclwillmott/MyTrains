//
//  LCCCANFrameFlag.swift
//  MyTrains
//
//  Created by Paul Willmott on 15/04/2023.
//

import Foundation

public enum LCCCANFrameFlag : UInt8 {
  
  case onlyFrame   = 0b00
  case firstFrame  = 0b01
  case lastFrame   = 0b10
  case middleFrame = 0b11
  
}
