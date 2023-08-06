//
//  LocoNetProgrammingMode.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/08/2023.
//

import Foundation

public enum LocoNetProgrammingMode : UInt8 {
  
  case pagedMode          = 0b00100011
  case directModeByte     = 0b00101011
  case directModeBit      = 0b00001011
  case operationsModeByte = 0b00101111
  case operationsModeBit  = 0b00001111
  case physicalRegister   = 0b00110011

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
