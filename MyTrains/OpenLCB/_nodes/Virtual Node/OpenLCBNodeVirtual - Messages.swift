//
//  OpenLCBNodeVirtual - Messages.swift
//  MyTrains
//
//  Created by Paul Willmott on 18/02/2024.
//

import Foundation
import AppKit

extension OpenLCBNodeVirtual {

  // This is used by new messages sent by this node
  internal func sendMessage(message:OpenLCBMessage) {
    message.timeStamp = Date.timeIntervalSinceReferenceDate
    message.sourceNodeId = nodeId
    message.routing.insert(nodeId)
    message.visibility = visibility
    appDelegate.networkLayer?.sendMessage(message: message)
  }
  
  internal func sendMessage(gatewayNodeId: UInt64, message: OpenLCBMessage) {
    message.routing.insert(gatewayNodeId)
    appDelegate.networkLayer?.sendMessage(message: message)
  }

  public func sendClockQuery(baseEventId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .producerConsumerEventReport)
    message.eventId = baseEventId | 0xf000
    sendMessage(message: message)
  }

  public func sendLocationServiceEvent(eventId:UInt64, trainNodeId:UInt64, entryExit:OpenLCBLocationServiceFlagEntryExit, motionRelative:OpenLCBLocationServiceFlagDirectionRelative, motionAbsolute:OpenLCBLocationServiceFlagDirectionAbsolute, contentFormat:OpenLCBLocationServiceFlagContentFormat, content: [OpenLCBLocationServicesContentBlock]? ) {
    
    var payload : [UInt8] = []
    
    var flags : UInt16 = 0
    
    flags |= entryExit.rawValue
    
    flags |= motionRelative.rawValue
    
    flags |= motionAbsolute.rawValue
    
    flags |= contentFormat.rawValue
    
    payload.append(contentsOf: flags.bigEndianData)

    payload.append(contentsOf: trainNodeId.nodeIdBigEndianData)
    
    if contentFormat == .standardContentForm, let content {
      
      payload.append(UInt8(1 + content.count))
      
      for block in content {
        payload.append(UInt8(block.content.count + 1))
        payload.append(block.blockType.rawValue)
        payload.append(contentsOf: block.content)
      }
      
    }
    
    sendEvent(eventId: eventId, payload: payload)
    
  }

  public func sendSetMoveCommand(destinationNodeId:UInt64, distance:Float, cruiseSpeed:Float, finalSpeed:Float) {
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)
    message.destinationNodeId = destinationNodeId
    message.payload = [OpenLCBTractionControlInstructionType.setMove.rawValue]
    message.payload.append(contentsOf: cruiseSpeed.float16.v.bigEndianData)
    message.payload.append(contentsOf: finalSpeed.float16.v.bigEndianData)
    sendMessage(message: message)
  }

  public func sendStartMoveCommand(destinationNodeId:UInt64, isStealAllowed:Bool, isPositionUpdateRequired:Bool) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)

    message.destinationNodeId = destinationNodeId
    
    message.payload = [OpenLCBTractionControlInstructionType.startMove.rawValue]
    
    var options : UInt8 = 0
    
    options |= isStealAllowed ? 0b00000001 : 0
    options |= isPositionUpdateRequired ? 0b00000010 : 0

    if options != 0 {
      message.payload.append(options)
    }
    
    sendMessage(message: message)
    
  }

  public func sendStopMoveCommand(destinationNodeId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)
    message.destinationNodeId = destinationNodeId
    message.payload = [OpenLCBTractionControlInstructionType.stopMove.rawValue]
    sendMessage(message: message)
  }

}
