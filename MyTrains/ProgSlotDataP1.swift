//
//  ProgSlotDataP1.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2022.
//

import Foundation

public enum ProgStatus {
  case success
  case userAborted
  case noDecoderDetected
  case readAckNotDetected
  case writeAckNotDetected
}

public class ProgSlotDataP1 : LocoNetMessage {
  
  // MARK: Public Properties
  
  public var status : ProgStatus {
    
    get {
      
      var result : ProgStatus = .success
      
      let pstat = message[4]
      
      if pstat & 0b00000001 == 0b00000001 {
        result = .noDecoderDetected
      }
      else if pstat & 0b00000010 == 0b00000010 {
        result = .writeAckNotDetected
      }
      else if pstat & 0b00000100 == 0b00000100 {
        result = .readAckNotDetected
      }
      else if pstat & 0b00001000 == 0b00001000 {
        result = .userAborted
      }

      return result
      
    }
    
  }
  
  public var value : Int {
    get {
      var result = message[10]
      
      if message[8] & 0b00000010 == 0b00000010 {
        result |= 0b10000000
      }
      return Int(result)
    }
  }
  
}
