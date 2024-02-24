//
//  OpenLCBNodeVirtual - Messages - Message Network.swift
//  MyTrains
//
//  Created by Paul Willmott on 23/02/2024.
//

import Foundation

extension OpenLCBNodeVirtual {
  
  // Indicates that the sending-node initialization is complete and, once the 
  // message is delivered, it is reachable on the network.
  // This message has two MTIs, distinguished by the modifier field, to indicate
  // whether the node requires delivery of all the messages in the full protocol,
  // or whether delivery of the Simple Protocol subset is sufficient.
  
  public func sendInitializationComplete() {
    let message = OpenLCBMessage(messageTypeIndicator: isFullProtocolRequired ? .initializationCompleteFullProtocolRequired : .initializationCompleteSimpleSetSufficient)
    message.payload = nodeId.nodeIdBigEndianData
    sendMessage(message: message)
  }

  // Issued to determine which node(s) are present and can be reached.
  
  public func sendVerifyNodeIdAddressed(destinationNodeId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDAddressed)
    message.destinationNodeId = destinationNodeId
    message.payload = destinationNodeId.nodeIdBigEndianData
    sendMessage(message: message)
  }

  public func sendVerifyNodeIdGlobal() {
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDGlobal)
    sendMessage(message: message)
  }

  public func sendVerifyNodeIdGlobal(destinationNodeId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDGlobal)
    message.destinationNodeId = destinationNodeId
    message.payload = destinationNodeId.nodeIdBigEndianData
    sendMessage(message: message)
  }

  // Reply to the Verify Node ID message.
  
  public func sendVerifiedNodeId(isSimpleSetSufficient:Bool) {
    let mti : OpenLCBMTI = isSimpleSetSufficient ? .verifiedNodeIDSimpleSetSufficient : .verifiedNodeIDFullProtocolRequired
    let message = OpenLCBMessage(messageTypeIndicator: mti)
    message.payload = nodeId.nodeIdBigEndianData
    sendMessage(message: message)
  }

  // MARK: PLACEHOLDER FOR sendOptionalInteractionRejected
  
  // This is a reply indicating failure.
  
  public func sendTerminateDueToError(destinationNodeId:UInt64, errorCode:OpenLCBErrorCode) {
    let message = OpenLCBMessage(messageTypeIndicator: .terminateDueToError)
    message.destinationNodeId = destinationNodeId
    message.payload = errorCode.bigEndianData
    sendMessage(message: message)
  }

  // Requests that the addressed node reply with an indication of which protocols
  // it supports.
  
  public func sendProtocolSupportInquiry(destinationNodeId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .protocolSupportInquiry)
    message.destinationNodeId = destinationNodeId
    sendMessage(message: message)
  }

  // Replying indicating the protocols that the node supports.
  
  public func sendProtocolSupportReply(destinationNodeId:UInt64, data:[UInt8]) {
    let message = OpenLCBMessage(messageTypeIndicator: .protocolSupportReply)
    message.destinationNodeId = destinationNodeId
    message.payload = data
    sendMessage(message: message)
  }
  
}
