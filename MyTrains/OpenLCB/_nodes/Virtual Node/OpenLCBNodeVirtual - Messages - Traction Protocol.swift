//
//  OpenLCBNodeVirtual - Messages - Traction Protocol.swift
//  MyTrains
//
//  Created by Paul Willmott on 23/02/2024.
//

import Foundation

extension OpenLCBNodeVirtual {
  
  public func sendSetSpeedDirection(destinationNodeId:UInt64, setSpeed:Float, isForwarded: Bool) {
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)
    message.destinationNodeId = destinationNodeId
    message.payload = [OpenLCBTractionControlInstructionType.setSpeedDirection.rawValue | (isForwarded ? 0x80 : 0x00)]
    message.payload.append(contentsOf: setSpeed.float16.v.bigEndianData)
    sendMessage(message: message)
  }

  public func sendSetFunction(destinationNodeId:UInt64, address:UInt32, value:UInt16, isForwarded: Bool) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)
    message.destinationNodeId = destinationNodeId
    message.payload = [OpenLCBTractionControlInstructionType.setFunction.rawValue | (isForwarded ? 0x80 : 0x00)]
    
    var adr = address.bigEndianData
    adr.removeFirst()
    
    message.payload.append(contentsOf: adr)
    message.payload.append(contentsOf: value.bigEndianData)
    sendMessage(message: message)
    
  }

  public func sendEmergencyStop(destinationNodeId:UInt64, isForwarded: Bool = false) {
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)
    message.destinationNodeId = destinationNodeId
    message.payload = [OpenLCBTractionControlInstructionType.emergencyStop.rawValue | (isForwarded ? 0x80 : 0x00)]
    sendMessage(message: message)
  }

  public func sendQuerySpeedsCommand(destinationNodeId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)
    message.destinationNodeId = destinationNodeId
    message.payload = [OpenLCBTractionControlInstructionType.querySpeeds.rawValue]
    sendMessage(message: message)
  }

  public func sendQuerySpeedsReply(destinationNodeId:UInt64, setSpeed:Float, commandedSpeed:Float, emergencyStop:Bool) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)
    message.destinationNodeId = destinationNodeId
    
    message.payload = [OpenLCBTractionControlInstructionType.querySpeeds.rawValue]
    
    message.payload.append(contentsOf: setSpeed.float16.v.bigEndianData)
    message.payload.append(emergencyStop ? 0x01 : 0x00)
    message.payload.append(contentsOf: commandedSpeed.float16.v.bigEndianData)
    message.payload.append(contentsOf: [0xff, 0xff])
    
    sendMessage(message: message)
    
  }


  public func sendQueryFunctionCommand(destinationNodeId:UInt64, address:UInt32) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)
    message.destinationNodeId = destinationNodeId
    message.payload = [OpenLCBTractionControlInstructionType.queryFunction.rawValue]
    
    var bed = address.bigEndianData
    bed.removeFirst()
    
    message.payload.append(contentsOf: bed)
    sendMessage(message: message)
    
  }

  public func sendQueryFunctionReply(destinationNodeId:UInt64, address:UInt32, value:UInt16) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)
    message.destinationNodeId = destinationNodeId
    message.payload = [OpenLCBTractionControlInstructionType.queryFunction.rawValue]
    
    var bed = address.bigEndianData
    bed.removeFirst()
    
    message.payload.append(contentsOf: bed)
    message.payload.append(contentsOf: value.bigEndianData)
    sendMessage(message: message)
    
  }

  public func sendAssignControllerCommand(destinationNodeId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.controllerConfiguration.rawValue,
      OpenLCBTractionControllerConfigurationType.assignController.rawValue,
      0x00
    ]
    
    message.payload.append(contentsOf: nodeId.nodeIdBigEndianData)
    sendMessage(message: message)
    
  }

  public func sendAssignControllerReply(destinationNodeId:UInt64, result:UInt8) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.controllerConfiguration.rawValue,
      OpenLCBTractionControllerConfigurationType.assignController.rawValue,
      result,
    ]
    
    sendMessage(message: message)
    
  }
  
  public func sendReleaseControllerCommand(destinationNodeId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.controllerConfiguration.rawValue,
      OpenLCBTractionControllerConfigurationType.releaseController.rawValue,
      0x00
    ]
    
    message.payload.append(contentsOf: nodeId.nodeIdBigEndianData)
    sendMessage(message: message)
    
  }

  // MARK: PLACEHOLDER FOR sendQueryControllerCommand

  public func sendQueryControllerReply(destinationNodeId:UInt64, activeController:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.controllerConfiguration.rawValue,
      OpenLCBTractionControllerConfigurationType.queryController.rawValue,
      0x00
    ]
    
    message.payload.append(contentsOf: activeController.nodeIdBigEndianData)
    sendMessage(message: message)
    
  }

  public func sendControllerChangedNotify(destinationNodeId:UInt64, newController:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.controllerConfiguration.rawValue,
      OpenLCBTractionControllerConfigurationType.controllerChangingNotify.rawValue,
      0x00
    ]
    
    message.payload.append(contentsOf: newController.nodeIdBigEndianData)
    sendMessage(message: message)
    
  }

  public func sendControllerChangedNotifyReply(destinationNodeId:UInt64, reject:Bool) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.controllerConfiguration.rawValue,
      OpenLCBTractionControllerConfigurationType.controllerChangingNotify.rawValue,
      reject ? 0x01 : 0x00
    ]
    
    sendMessage(message: message)
    
  }
  
  public func sendAttachListenerCommand(destinationNodeId:UInt64, listenerNodeId:UInt64, flags:UInt8) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.listenerConfiguration.rawValue,
      OpenLCBTractionListenerConfigurationType.attachNode.rawValue,
      flags,
    ]
    
    message.payload.append(contentsOf: listenerNodeId.nodeIdBigEndianData)
    sendMessage(message: message)
    
  }

  public func sendAttachListenerReply(destinationNodeId:UInt64, listenerNodeId:UInt64, replyCode:OpenLCBErrorCode) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.listenerConfiguration.rawValue,
      OpenLCBTractionListenerConfigurationType.attachNode.rawValue,
    ]
    
    message.payload.append(contentsOf: listenerNodeId.nodeIdBigEndianData)
    message.payload.append(contentsOf: replyCode.bigEndianData)
    sendMessage(message: message)
    
  }

  public func sendDetachListenerCommand(destinationNodeId:UInt64, listenerNodeId:UInt64, flags:UInt8) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.listenerConfiguration.rawValue,
      OpenLCBTractionListenerConfigurationType.detachNode.rawValue,
      flags,
    ]
    
    message.payload.append(contentsOf: listenerNodeId.nodeIdBigEndianData)
    sendMessage(message: message)
    
  }

  public func sendListenerQueryNodeReply(destinationNodeId:UInt64, nodeCount:Int, nodeIndex:Int, flags:UInt8, listenerNodeId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.listenerConfiguration.rawValue,
      OpenLCBTractionListenerConfigurationType.queryNodes.rawValue,
      UInt8(min(0xff, nodeCount) & 0xff),
      UInt8(nodeIndex),
      flags
    ]
    
    message.payload.append(contentsOf: listenerNodeId.nodeIdBigEndianData)
    sendMessage(message: message)
    
  }

  public func sendListenerQueryNodeReplyShort(destinationNodeId:UInt64, nodeCount:Int) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)

    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.listenerConfiguration.rawValue,
      OpenLCBTractionListenerConfigurationType.queryNodes.rawValue,
      UInt8(min(0xff, nodeCount) & 0xff),
    ]
    
    sendMessage(message: message)
    
  }

  public func sendTractionManagementNoOp(destinationNodeId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.tractionManagement.rawValue,
      OpenLCBTractionManagementType.noopOrHeartbeatRequest.rawValue,
    ]
    
    sendMessage(message: message)
    
  }

  public func sendHeartbeatRequest(destinationNodeId:UInt64, timeout:UInt8) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.tractionManagement.rawValue,
      OpenLCBTractionManagementType.noopOrHeartbeatRequest.rawValue,
      timeout
    ]
    
    sendMessage(message: message)
    
  }

  public func makeTrainSearchEventId(searchString : String, searchType:OpenLCBSearchType, searchMatchType:OpenLCBSearchMatchType, searchMatchTarget:OpenLCBSearchMatchTarget, trackProtocol:OpenLCBTrackProtocol) -> UInt64 {
    
    var eventId : UInt64 = OpenLCBWellKnownEvent.trainSearchEvent.rawValue // 0x090099ff00000000
    
    var numbers : [String] = []
    var temp : String = ""
    for char in searchString {
      switch char {
      case "0"..."9":
        temp += String(char)
      default:
        if !temp.isEmpty {
          numbers.append(temp)
          temp = ""
        }
      }
    }
    if !temp.isEmpty {
      numbers.append(temp)
    }
    
    var nibbles : [UInt8] = []
    
    for number in numbers {
      for digit in number {
        nibbles.append(UInt8(String(digit))!)
      }
      nibbles.append(0x0f)
    }
    
    while nibbles.count < 6 {
      nibbles.append(0x0f)
    }
    
    while nibbles.count > 6 {
      nibbles.removeLast()
    }
    
    var shift = 28
    for nibble in nibbles {
      eventId |= UInt64(nibble) << shift
      shift -= 4
    }

    eventId |= (UInt64(searchType.rawValue | searchMatchType.rawValue | searchMatchTarget.rawValue | trackProtocol.rawValue))

    return eventId
    
  }
  
}
