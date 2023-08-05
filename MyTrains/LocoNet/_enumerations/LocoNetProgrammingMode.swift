//
//  LocoNetProgrammingMode.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/08/2023.
//

import Foundation

public enum LocoNetProgrammingMode : UInt8 {
  
  case directModeByte                 = 0b00101011
  case directModeBit                  = 0b00001011
  case operationsModeByteNoFeedback   = 0b00100111
  case operationsModeBitNoFeedback    = 0b00000111
  case operationsModeByteWithFeedback = 0b00101111
  case operationsModeBitWithFeedback  = 0b00001111
  case pagedModeByte                  = 0b00100011
  case pagedModeBit                   = 0b00000011
  case physicalRegisterByte           = 0b00010011

  public var writeCommand : UInt8 {
    return self.rawValue | 0b01000000
  }
  
  public var readCommand : UInt8 {
    return self.rawValue | 0b00000000
  }
  
  public var isOperationsMode : Bool {
    let opsMode : Set<LocoNetProgrammingMode> = [.operationsModeBitNoFeedback, .operationsModeBitWithFeedback, .operationsModeByteNoFeedback, .operationsModeByteWithFeedback]
    return opsMode.contains(self)
  }
  
}
