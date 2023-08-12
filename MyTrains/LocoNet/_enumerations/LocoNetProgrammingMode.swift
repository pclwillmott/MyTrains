//
//  LocoNetProgrammingMode.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/08/2023.
//

import Foundation

public enum LocoNetProgrammingMode : UInt8 {
  
  case paged            = 0b00000011
  case direct           = 0b00001011
  case operations       = 0b00001111
  case physicalRegister = 0b00010011

  public func command(isByte:Bool, isWrite:Bool) -> UInt8? {
    
    var result : UInt8 = self.rawValue | (isWrite ? 0b01000000 : 0)
    
    let allowBit : Set<LocoNetProgrammingMode> = [.direct, .operations]
    
    if isByte {
      result |= 0b00100000
    }
    else if isWrite && allowBit.contains(self) {
      if self == .operations {
        let mask : UInt8 = 0b00001000
        result &= ~mask
      }
    }
    else {
      return nil
    }
    
    return result
    
  }
  
}
