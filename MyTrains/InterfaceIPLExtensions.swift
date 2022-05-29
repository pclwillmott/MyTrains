//
//  InterfaceIPLExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/05/2022.
//

import Foundation

extension Interface {
  
  // MARK: Public Methods
  
  public func iplSetupBL2(dmf: DMF) {
  
    var pxct1 : UInt8 = 0b01000000
    
    pxct1 |= (dmf.manufacturerCode & 0b10000000) == 0 ? 0b00000000 : 0b00000001
    pxct1 |= (dmf.productCode      & 0b10000000) == 0 ? 0b00000000 : 0b00000010
    pxct1 |= (dmf.hardwareVersion  & 0b10000000) == 0 ? 0b00000000 : 0b00000100
    pxct1 |= (dmf.softwareVersion  & 0b10000000) == 0 ? 0b00000000 : 0b00001000
    
    var pxct2 : UInt8 = 0b00000000

    pxct2 |= (dmf.options               & 0b10000000) == 0 ? 0b00000000 : 0b00000001
    pxct2 |= (dmf.numberOfBlocksToErase & 0b10000000) == 0 ? 0b00000000 : 0b00000100

    let data : [UInt8] = [
      
      NetworkMessageOpcode.OPC_PEER_XFER.rawValue,
      0x10,
      0x7f,
      0x7f,
      0x7f,
      pxct1,
      (dmf.manufacturerCode & 0x7f),
      (dmf.productCode & 0x7f),
      (dmf.hardwareVersion & 0x7f),
      (dmf.softwareVersion & 0x7f),
      pxct2,
      (dmf.options & 0x7f),
      0x00,
      (dmf.numberOfBlocksToErase & 0x7f),
      0x00
      
    ]
    
    let message = NetworkMessage(networkId: networkId, data: data, appendCheckSum: true)
    
    addToQueue(message: message, delay: dmf.setupDelayInSeconds)
    
  }
  
}
