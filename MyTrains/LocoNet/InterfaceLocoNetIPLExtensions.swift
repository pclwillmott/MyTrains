//
//  InterfaceLocoNetIPLExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/05/2022.
//

import Foundation

extension LocoNet {
  
  // MARK: Public Methods
  
  public func iplSetup(dmf: DMF) {
  
    var pxct1 : UInt8 = 0b01000000
    
    pxct1 |= (dmf.manufacturerCode & 0b10000000) == 0 ? 0b00000000 : 0b00000001
    pxct1 |= (dmf.productCode      & 0b10000000) == 0 ? 0b00000000 : 0b00000010
    pxct1 |= (dmf.hardwareVersion  & 0b10000000) == 0 ? 0b00000000 : 0b00000100
    pxct1 |= (dmf.softwareVersion  & 0b10000000) == 0 ? 0b00000000 : 0b00001000
    
    var pxct2 : UInt8 = 0b00000000

    pxct2 |= (dmf.options               & 0b10000000) == 0 ? 0b00000000 : 0b00000001
    pxct2 |= (dmf.numberOfBlocksToErase & 0b10000000) == 0 ? 0b00000000 : 0b00000100

    let data : [UInt8] = [
      
      LocoNetMessageOpcode.OPC_PEER_XFER.rawValue,
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
    
    let message = LocoNetMessage(data: data, appendCheckSum: true)
    
    addToQueue(message: message)
    
  }
  
  public func iplDataLoad(D1:UInt8, D2:UInt8, D3:UInt8, D4:UInt8, D5:UInt8, D6: UInt8, D7: UInt8, D8: UInt8) {
    
    var pxct1 : UInt8 = 0b01000000
    
    pxct1 |= (D1 & 0b10000000) == 0 ? 0b00000000 : 0b00000001
    pxct1 |= (D2 & 0b10000000) == 0 ? 0b00000000 : 0b00000010
    pxct1 |= (D3 & 0b10000000) == 0 ? 0b00000000 : 0b00000100
    pxct1 |= (D4 & 0b10000000) == 0 ? 0b00000000 : 0b00001000

    var pxct2 : UInt8 = 0b00100000
    
    pxct2 |= (D5 & 0b10000000) == 0 ? 0b00000000 : 0b00000001
    pxct2 |= (D6 & 0b10000000) == 0 ? 0b00000000 : 0b00000010
    pxct2 |= (D7 & 0b10000000) == 0 ? 0b00000000 : 0b00000100
    pxct2 |= (D8 & 0b10000000) == 0 ? 0b00000000 : 0b00001000

    let data : [UInt8] = [
    
      LocoNetMessageOpcode.OPC_PEER_XFER.rawValue,
      0x10,
      0x7f,
      0x7f,
      0x7f,
      pxct1,
      D1 & 0x7f,
      D2 & 0x7f,
      D3 & 0x7f,
      D4 & 0x7f,
      pxct2,
      D5 & 0x7f,
      D6 & 0x7f,
      D7 & 0x7f,
      D8 & 0x7f
    ]
    
    let message = LocoNetMessage(data: data, appendCheckSum: true)
    
    addToQueue(message: message)
    
  }
  
  public func iplEndLoad() {
    
    let pxct1 : UInt8 = 0b01000000
    
    let pxct2 : UInt8 = 0b01000000
    
    let data : [UInt8] = [
    
      LocoNetMessageOpcode.OPC_PEER_XFER.rawValue,
      0x10,
      0x7f,
      0x7f,
      0x7f,
      pxct1,
      0x00,
      0x00,
      0x00,
      0x00,
      pxct2,
      0x00,
      0x00,
      0x00,
      0x00
    ]
    
    let message = LocoNetMessage(data: data, appendCheckSum: true)
    
    addToQueue(message: message)
    
  }

  public func iplSetAddr(loadAddress: Int) {
    
    let high : UInt8 = UInt8(loadAddress >> 16)
    
    let mid : UInt8 = UInt8((loadAddress & 0x00ff00) >> 8)
    
    let low : UInt8 = UInt8(loadAddress & 0xff)
    
    var pxct1 : UInt8 = 0b01000000
    
    pxct1 |= (high & 0b10000000) == 0 ? 0b00000000 : 0b00000001
    pxct1 |= (mid  & 0b10000000) == 0 ? 0b00000000 : 0b00000010
    pxct1 |= (low  & 0b10000000) == 0 ? 0b00000000 : 0b00000100

    let pxct2 : UInt8 = 0b00010000
    
    let data : [UInt8] = [
    
      LocoNetMessageOpcode.OPC_PEER_XFER.rawValue,
      0x10,
      0x7f,
      0x7f,
      0x7f,
      pxct1,
      high & 0x7f,
      mid & 0x7f,
      low & 0x7f,
      0x00,
      pxct2,
      0x00,
      0x00,
      0x00,
      0x00
    ]
    
    let message = LocoNetMessage(data: data, appendCheckSum: true)
    
    addToQueue(message: message)
    
  }

}
