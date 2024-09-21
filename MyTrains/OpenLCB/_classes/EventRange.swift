//
//  EventRange.swift
//  MyTrains
//
//  Created by Paul Willmott on 14/02/2024.
//

import Foundation

public class EventRange {
  
  // MARK: Constructors
  
  init(eventId:UInt64) {
    
    self.eventId = eventId
    
    let b0 : UInt64 = 0b1
    
    let firstBit = eventId & b0
    
    var temp = eventId
    
    mask = 0
    
    while temp != 0 && (temp & b0) == firstBit {
      mask = (mask << 1) | b0
      temp >>= 1
    }
    
    startId = eventId & ~mask
    
  }
  
  init?(startId:UInt64, mask:UInt64) {
    
    // The rather complicated math is to check that the mask is an integer power of 2 minus 1
    guard mask != 0 && (log10(Double(mask + 1)) / log10(2.0)).truncatingRemainder(dividingBy: 1) == 0.0 else {
      #if DEBUG
      debugLog("EventRange.init: mask - 0x\(mask.hex(numberOfBytes: 8)!) remainder - \((log10(Double(mask + 1)) / log10(2.0)).truncatingRemainder(dividingBy: 1))")
      #endif
      return nil
    }
    
    self.startId = startId
    
    self.mask = mask
    
    var firstBitOfBase : UInt64 = 0b1
    while (mask & firstBitOfBase) != 0 {
      firstBitOfBase <<= 1
    }
    
    let invert = (startId & firstBitOfBase) != 0
    
    eventId = startId | (invert ? 0 : mask)
   
  }
  
  // MARK: Public Properties
  
  public var startId : UInt64
  
  public var mask : UInt64
  
  public var eventId : UInt64
  
  public var endId : UInt64 {
    return startId | mask
  }
  
}
