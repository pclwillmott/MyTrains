//
//  OpenLCBNodeVirtual - Messages - Simple Node Information Protocol.swift
//  MyTrains
//
//  Created by Paul Willmott on 23/02/2024.
//

import Foundation

extension OpenLCBNodeVirtual {
  
  // This message requests the destination node to send the Simple Node Information
  // data to the source node.
  
  public func sendSimpleNodeInformationRequest(destinationNodeId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .simpleNodeIdentInfoRequest)
    message.destinationNodeId = destinationNodeId
    sendMessage(message: message)
  }
  
  // This reply carries the Simple Node Information payload from the target node
  // to the requesting node.
  
  public func sendSimpleNodeInformationReply(destinationNodeId:UInt64, data:[UInt8]) {
    let message = OpenLCBMessage(messageTypeIndicator: .simpleNodeIdentInfoReply)
    message.destinationNodeId = destinationNodeId
    message.payload = data
    sendMessage(message: message)
  }
  
}
