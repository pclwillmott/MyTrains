//
//  InterfaceLocoNetExtensionsUnused.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/06/2023.
//

import Foundation

extension LocoNet {
  
  // MARK: Public Methods
 
  // MARK: COMMAND STATION COMMANDS
  
  
  
  
  
  // MARK: HELPER COMMANDS
  
  
  // MARK: LOCOMOTIVE CONTROL COMMANDS
  /*
  public func getLocoSlotDataP1(forAddress: UInt16, timeoutCode: TimeoutCode) {
    
    let lo = UInt8(forAddress & 0x7f)
    
    let hi = UInt8(forAddress >> 7)
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_LOCO_ADR.rawValue, hi, lo], appendCheckSum: true)
    
    addToQueue(message: message)

  }
  */
  public func getLocoSlotDataP2(forAddress: UInt16, timeoutCode: TimeoutCode) {
    
    let lo = UInt8(forAddress & 0x7f)
    
    let hi = UInt8(forAddress >> 7)
    
    let message = LocoNetMessage(data: [LocoNetMessageOpcode.OPC_LOCO_ADR_P2.rawValue, hi, lo], appendCheckSum: true)
    
    addToQueue(message: message)

  }
  
  
   
  
  

  
  
  
  
  
  
  










}

