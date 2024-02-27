//
//  OpenLCBCANGateway - Messages.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/02/2024.
//

import Foundation

extension OpenLCBCANGateway {
  
  internal func createVerifyNodeIdAddressedCANFrame(destinationNodeIdAlias:UInt16) -> [LCCCANFrame] {
    
    guard let sourceNIDAlias = nodeIdLookup[nodeId] else {
      #if DEBUG
      debugLog("the gateway \"\(userNodeName)\" has no alias")
      #endif
      return []
    }

    var frames : [LCCCANFrame] = []
      
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDAddressed)
    message.sourceNIDAlias = sourceNIDAlias
    message.destinationNIDAlias = destinationNodeIdAlias

    if let frame = LCCCANFrame(message: message) {
      frames.append(frame)
    }

    return frames

  }

  internal func createVerifyNodeIdGlobalCANFrame(destinationNodeId:UInt64) -> [LCCCANFrame] {
    
    guard let sourceNIDAlias = nodeIdLookup[nodeId] else {
      #if DEBUG
      debugLog("the gateway \"\(userNodeName)\" has no alias")
      #endif
      return []
    }
    
    var frames : [LCCCANFrame] = []
      
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDGlobal)
    message.sourceNIDAlias = sourceNIDAlias
    message.payload = destinationNodeId.nodeIdBigEndianData
    
    if let frame = LCCCANFrame(message: message) {
      frames.append(frame)
    }

    return frames
    
  }

  internal func createCheckIdFrame(format:OpenLCBCANControlFrameFormat, nodeId:UInt64, alias: UInt16) -> LCCCANFrame {
    let cf = format.rawValue | UInt16((nodeId >> (((format.rawValue >> 12) - 4) * 12)) & 0x0fff)
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, contentField: cf, sourceNIDAlias: alias)
    return LCCCANFrame(header: header, data: [])
  }

  internal func createReserveIdFrame(alias:UInt16) -> [LCCCANFrame] {
    let cf = OpenLCBCANControlFrameFormat.reserveIdFrame.rawValue
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, contentField: cf, sourceNIDAlias: alias)
    return [LCCCANFrame(header: header, data: [])]
  }

  internal func createAliasMapDefinitionFrame(nodeId:UInt64, alias:UInt16) -> [LCCCANFrame] {
    let cf = OpenLCBCANControlFrameFormat.aliasMapDefinitionFrame.rawValue
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, contentField: cf, sourceNIDAlias: alias)
    return [LCCCANFrame(header: header, data: nodeId.nodeIdBigEndianData)]
  }

  internal func createAliasMapResetFrame(nodeId:UInt64, alias:UInt16) -> [LCCCANFrame] {
    let cf = OpenLCBCANControlFrameFormat.aliasMapResetFrame.rawValue
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, contentField: cf, sourceNIDAlias: alias)
    return [LCCCANFrame(header: header, data: nodeId.nodeIdBigEndianData)]
  }

  internal func createAliasMappingEnquiryFrame(nodeId:UInt64, alias:UInt16) -> [LCCCANFrame] {
    let cf = OpenLCBCANControlFrameFormat.aliasMappingEnquiryFrame.rawValue
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, contentField: cf, sourceNIDAlias: alias)
    return [LCCCANFrame(header: header, data: nodeId.nodeIdBigEndianData)]
  }

  internal func createAliasMappingEnquiryFrame(alias:UInt16) -> [LCCCANFrame] {
    let cf = OpenLCBCANControlFrameFormat.aliasMappingEnquiryFrame.rawValue
    let header = LCCCANFrame.createFrameHeader(frameType: .canControlFrame, contentField: cf, sourceNIDAlias: alias)
    return [LCCCANFrame(header: header, data: [])]
  }

  internal func createDuplicateNodeIdErrorFrame(alias:UInt16) -> [LCCCANFrame] {
    let header = 0x195B4000 | UInt32(alias & 0x0fff)
    return [LCCCANFrame(header: header, data: OpenLCBWellKnownEvent.duplicateNodeIdDetected.rawValue.bigEndianData)]
  }

}
