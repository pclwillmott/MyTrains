//
//  OpenLCBCANGateway - Messages.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/02/2024.
//

import Foundation

extension OpenLCBCANGateway {
  
  internal func sendVerifyNodeIdNumberAddressed(destinationNodeIdAlias:UInt16) {
    
    guard let sourceNIDAlias = nodeIdLookup[nodeId] else {
      return
    }
      
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDAddressed)
    message.sourceNIDAlias = sourceNIDAlias
    message.destinationNIDAlias = destinationNodeIdAlias

    if let frame = LCCCANFrame(message: message) {
      send(data: frame.message)
    }

  }

  internal func sendVerifyNodeIdGlobalCAN(destinationNodeId:UInt64) {
    
    guard let sourceNIDAlias = nodeIdLookup[nodeId] else {
      return
    }
      
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDGlobal)
    message.sourceNIDAlias = sourceNIDAlias
    message.payload = destinationNodeId.nodeIdBigEndianData
    
    if let frame = LCCCANFrame(message: message) {
      send(data: frame.message)
    }

  }

  internal func sendCheckIdFrame(format:OpenLCBCANControlFrameFormat, nodeId:UInt64, alias: UInt16) {
    let cf = format.rawValue | UInt16((nodeId >> (((format.rawValue >> 12) - 4) * 12)) & 0x0fff)
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, contentField: cf, sourceNIDAlias: alias)
    send(header: header, data: "")
  }

  internal func sendReserveIdFrame(alias:UInt16) {
    let cf = OpenLCBCANControlFrameFormat.reserveIdFrame.rawValue
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, contentField: cf, sourceNIDAlias: alias)
    send(header: header, data: "")
  }

  internal func sendAliasMapDefinitionFrame(nodeId:UInt64, alias:UInt16) {
    let cf = OpenLCBCANControlFrameFormat.aliasMapDefinitionFrame.rawValue
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, contentField: cf, sourceNIDAlias: alias)
    send(header: header, data: nodeId.toHex(numberOfDigits: 12))
  }

  internal func sendAliasMapResetFrame(nodeId:UInt64, alias:UInt16) {
    let cf = OpenLCBCANControlFrameFormat.aliasMapResetFrame.rawValue
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, contentField: cf, sourceNIDAlias: alias)
    send(header: header, data: nodeId.toHex(numberOfDigits: 12))
  }

  internal func sendAliasMappingEnquiryFrame(nodeId:UInt64, alias:UInt16) {
    let cf = OpenLCBCANControlFrameFormat.aliasMappingEnquiryFrame.rawValue
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, contentField: cf, sourceNIDAlias: alias)
    send(header: header, data: nodeId.toHex(numberOfDigits: 12))
  }

  internal func sendAliasMappingEnquiryFrame(alias:UInt16) {
    let cf = OpenLCBCANControlFrameFormat.aliasMappingEnquiryFrame.rawValue
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, contentField: cf, sourceNIDAlias: alias)
    send(header: header, data: "")
  }

  internal func sendDuplicateNodeIdErrorFrame(alias:UInt16) {
    var header = 0x195B4000 | UInt32(alias & 0x0fff)
    send(header: header.toHex(numberOfDigits: 8), data: OpenLCBWellKnownEvent.duplicateNodeIdDetected.rawValue.toHex(numberOfDigits: 16))
  }

}
