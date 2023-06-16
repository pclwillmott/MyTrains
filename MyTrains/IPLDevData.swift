//
//  IPLDevData.swift
//  MyTrains
//
//  Created by Paul Willmott on 18/12/2021.
//

import Foundation

public class IPLDevData : LocoNetMessage {
  
  // MARK: Public Properties
  
  public var productCode : ProductCode {
    
    get {
      let pc = message[5] | (message[4] & 0b00000001 != 0 ? 0b10000000 : 0b00000000)
      return ProductCode(rawValue: pc) ?? .none
    }
    
  }
  
  public var softwareVersion : Double {
    
    get {
      let sv = message[8] | (message[4] & 0b00000010 != 0 ? 0b10000000 : 0b00000000)
      return Double((sv & 0b11111000) >> 3) + Double (sv & 0b111) / 10.0
    }
    
  }
  
  public var serialNumber : Int {
    
    get {
      let sn1 = message[11] | ((message[9] & 0b00000010) != 0 ? 0b10000000 : 0b00000000)
      let sn2 = message[12] | ((message[9] & 0b00000100) != 0 ? 0b10000000 : 0b00000000)
      return Int(sn1) | Int(sn2) << 8
    }
    
  }
  
  override public var boardId : Int {
    
    get {
      return Int(message[15] | (message[14] & 0b00000001 != 0 ? 0b10000000 : 0b00000000))
    }
    
  }
  
  public var partialSerialNumberLow : Int {
    get {
      return serialNumber & 0x7f
    }
  }
  
  public var partialSerialNumberHigh : Int {
    get {
      return (serialNumber >> 8) & 0x7f
    }
  }
  
  public var throttleID : Int {
    get {
      return partialSerialNumberHigh << 8 | partialSerialNumberLow
    }
  }
  
}
