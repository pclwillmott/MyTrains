//
//  OpenLCBNodeVirtual - Messages - Datagram Transport.swift
//  MyTrains
//
//  Created by Paul Willmott on 23/02/2024.
//

import Foundation

extension OpenLCBNodeVirtual {
  
  // The first byte of the data content defines the datagram type and is 
  // designated the Datagram Content ID. The values for that byte are documented
  // in the Standard for the protocol that defines the type.
  
  public func sendDatagram(destinationNodeId:UInt64, data: [UInt8]) {

    #if DEBUG
    guard data.count >= 0 && data.count <= 72 else {
      debugLog("invalid number of bytes - \(data.count)")
      return
    }
    #endif
    
    let message = OpenLCBMessage(messageTypeIndicator: .datagram)
    message.destinationNodeId = destinationNodeId
    message.payload = data
    sendMessage(message: message)

  }

  // The flag bits are defined as:
  // • MSB 0x80 – Reply Pending – Use is defined by higher-level protocols.
  // • Low four bits 0x0F – Timeout Value – Zero indicates no timeout value. A 
  //   value N of 0x01 through 0x0F indicates that the pending reply will be
  //    transmitted before 2^N seconds have elapsed; if not, an error has occurred.
  // • All others are reserved, shall be sent as zero and ignored upon receipt.
  // Datagram Received OK messages without a Flags byte shall be treated as if 
  // they contained a byte with a zero value.
  
  public func sendDatagramReceivedOK(destinationNodeId:UInt64, timeOut: OpenLCBDatagramTimeout) {
    let message = OpenLCBMessage(messageTypeIndicator: .datagramReceivedOK)
    message.destinationNodeId = destinationNodeId
    message.payload = timeOut != .ok ? [timeOut.rawValue] : []
    sendMessage(message: message)
  }

  // The data contents are, in order:
  // • Two bytes of error code.
  // • Any extra bytes that the node wishes to include. There can be zero or
  //   more of these, to a maximum of 64 bytes. These shall be described in
  //   the node documentation.
  //
  // Nodes shall accept and process Datagram Rejected messages that do not contain
  // the full error code. Missing error code bits are to be interpreted as zero.
  
  public func sendDatagramRejected(destinationNodeId:UInt64, errorCode:OpenLCBErrorCode) {

    let message = OpenLCBMessage(messageTypeIndicator: .datagramRejected)
    message.destinationNodeId = destinationNodeId
    
    var payload = errorCode.bigEndianData
    
    if payload[1] == 0 {
      payload.removeLast()
    }
    
    message.payload = payload
    sendMessage(message: message)

  }
  
}
