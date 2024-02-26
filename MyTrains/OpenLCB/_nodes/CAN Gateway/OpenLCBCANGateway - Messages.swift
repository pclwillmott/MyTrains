//
//  OpenLCBCANGateway - Messages.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/02/2024.
//

import Foundation

extension OpenLCBCANGateway {
  
  internal func sendVerifyNodeIdNumberAddressed(destinationNodeIdAlias:UInt16, isBackgroundThread:Bool) {
    
    guard let sourceNIDAlias = nodeIdLookup[nodeId] else {
      return
    }
      
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDAddressed)
    message.sourceNIDAlias = sourceNIDAlias
    message.destinationNIDAlias = destinationNodeIdAlias

    if let frame = LCCCANFrame(message: message) {
      send(frames: [frame], isBackgroundThread: isBackgroundThread)
    }

  }

  internal func sendVerifyNodeIdGlobalCAN(destinationNodeId:UInt64, isBackgroundThread:Bool) {
    
    guard let sourceNIDAlias = nodeIdLookup[nodeId] else {
      return
    }
      
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDGlobal)
    message.sourceNIDAlias = sourceNIDAlias
    message.payload = destinationNodeId.nodeIdBigEndianData
    
    if let frame = LCCCANFrame(message: message) {
      send(frames: [frame], isBackgroundThread: isBackgroundThread)
    }

  }

  internal func createCheckIdFrame(format:OpenLCBCANControlFrameFormat, nodeId:UInt64, alias: UInt16) -> LCCCANFrame {
    let cf = format.rawValue | UInt16((nodeId >> (((format.rawValue >> 12) - 4) * 12)) & 0x0fff)
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, contentField: cf, sourceNIDAlias: alias)
    return LCCCANFrame(header: header, data: [])
  }

  internal func sendReserveIdFrame(alias:UInt16, isBackgroundThread:Bool) {
    let cf = OpenLCBCANControlFrameFormat.reserveIdFrame.rawValue
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, contentField: cf, sourceNIDAlias: alias)
    send(frames: [LCCCANFrame(header: header, data: [])], isBackgroundThread: isBackgroundThread)
  }

  internal func sendAliasMapDefinitionFrame(nodeId:UInt64, alias:UInt16, isBackgroundThread:Bool) {
    let cf = OpenLCBCANControlFrameFormat.aliasMapDefinitionFrame.rawValue
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, contentField: cf, sourceNIDAlias: alias)
    send(frames: [LCCCANFrame(header: header, data: nodeId.nodeIdBigEndianData)], isBackgroundThread: isBackgroundThread)
  }

  internal func sendAliasMapResetFrame(nodeId:UInt64, alias:UInt16, isBackgroundThread:Bool) {
    let cf = OpenLCBCANControlFrameFormat.aliasMapResetFrame.rawValue
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, contentField: cf, sourceNIDAlias: alias)
    send(frames: [LCCCANFrame(header: header, data: nodeId.nodeIdBigEndianData)], isBackgroundThread: isBackgroundThread)
  }

  internal func sendAliasMappingEnquiryFrame(nodeId:UInt64, alias:UInt16, isBackgroundThread:Bool) {
    let cf = OpenLCBCANControlFrameFormat.aliasMappingEnquiryFrame.rawValue
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, contentField: cf, sourceNIDAlias: alias)
    send(frames: [LCCCANFrame(header: header, data: nodeId.nodeIdBigEndianData)], isBackgroundThread: isBackgroundThread)
  }

  internal func sendAliasMappingEnquiryFrame(alias:UInt16, isBackgroundThread:Bool) {
    let cf = OpenLCBCANControlFrameFormat.aliasMappingEnquiryFrame.rawValue
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, contentField: cf, sourceNIDAlias: alias)
    send(frames: [LCCCANFrame(header: header, data: [])], isBackgroundThread: isBackgroundThread)
  }

  internal func sendDuplicateNodeIdErrorFrame(alias:UInt16, isBackgroundThread:Bool) {
    let header = 0x195B4000 | UInt32(alias & 0x0fff)
    send(frames: [LCCCANFrame(header: header, data: OpenLCBWellKnownEvent.duplicateNodeIdDetected.rawValue.bigEndianData)], isBackgroundThread: isBackgroundThread)
  }

}
