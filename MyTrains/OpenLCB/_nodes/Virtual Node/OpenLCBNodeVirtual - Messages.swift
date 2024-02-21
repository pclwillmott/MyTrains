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
    if let appNodeId, message.messageTypeIndicator == .producerConsumerEventReport {
      message.sourceNodeId = visibility == .visibilityPublic ? nodeId : appNodeId
    }
    else {
      message.sourceNodeId = nodeId
    }
    message.routing.insert(nodeId)
    message.timeStamp = Date.timeIntervalSinceReferenceDate
    txPipe!.sendOpenLCBMessage(message: message)
  }
  
  internal func sendMessage(gatewayNodeId: UInt64, message: OpenLCBMessage) {
    message.routing.insert(gatewayNodeId)
    txPipe!.sendOpenLCBMessage(message: message)
  }

  public func sendInitializationComplete(isSimpleSetSufficient:Bool) {
    let mti : OpenLCBMTI = isSimpleSetSufficient ? .initializationCompleteSimpleSetSufficient : .initializationCompleteFullProtocolRequired
    let message = OpenLCBMessage(messageTypeIndicator: mti)
    message.payload = nodeId.nodeIdBigEndianData
    sendMessage(message: message)
  }

  public func sendClockQuery(baseEventId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .producerConsumerEventReport)
    message.eventId = baseEventId | 0xf000
    sendMessage(message: message)
  }

  public func sendLocoNetMessageReceived(locoNetMessage:[UInt8]) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .producerConsumerEventReport)
    
    var data = [UInt8](OpenLCBWellKnownEvent.locoNetMessage.rawValue.bigEndianData.prefix(2))
    
    data.append(contentsOf: locoNetMessage)
    
    var numberOfPaddingBytes = 8 - data.count
    
    while numberOfPaddingBytes > 0 {
      data.append(0xff)
      numberOfPaddingBytes -= 1
    }
    
    let eventId = UInt64(bigEndianData: [UInt8](data.prefix(8)))!
    
    data.removeFirst(8)
    
    sendEvent(eventId: eventId, payload: data)
    
  }

  public func sendLocoNetMessage(destinationNodeId:UInt64, locoNetMessage:LocoNetMessage) {
    let message = OpenLCBMessage(messageTypeIndicator: .datagram)
    message.destinationNodeId = destinationNodeId
    message.payload = OpenLCBDatagramType.sendlocoNetMessage.bigEndianData
    message.payload.append(contentsOf: locoNetMessage.message)
    sendMessage(message: message)
  }

  public func sendLocoNetMessageReply(destinationNodeId:UInt64, errorCode:OpenLCBErrorCode) {
    let message = OpenLCBMessage(messageTypeIndicator: .sendLocoNetMessageReply)
    message.destinationNodeId = destinationNodeId
    message.payload = errorCode.bigEndianData
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

  public func sendEvent(eventId:UInt64, payload:[UInt8] = []) {
    
    /*
    #if DEBUG
    
    if !OpenLCBWellKnownEvent.isAutomaticallyRouted(eventId: eventId) && !sourceNode.eventsProduced.union(sourceNode.userConfigEventsProduced).contains(eventId) {
      
      var found = false
      
      for eventRange in sourceNode.eventRangesProduced {
        if eventId >= eventRange.startId && eventId <= eventRange.endId {
          found = true
          break
        }
      }
      
      if !found {
        
        let alert = NSAlert()
        
        alert.messageText = String(localized: "Sending unadvertised event")
        alert.informativeText = String(localized: "The node \"\(sourceNode.userNodeName)\" (\(sourceNode.nodeId.toHexDotFormat(numberOfBytes: 6))) is attempting to send the unadvertised event: \(eventId.toHexDotFormat(numberOfBytes: 8))")
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .informational
        
        alert.runModal()
        
      }
      
    }
    
    #endif
    */
    
    let message = OpenLCBMessage(messageTypeIndicator: .producerConsumerEventReport)
    message.eventId = eventId
    message.payload = payload
    sendMessage(message: message)
    
  }

  public func sendWellKnownEvent(eventId:OpenLCBWellKnownEvent, payload:[UInt8] = []) {
    sendEvent(eventId: eventId.rawValue, payload: payload)
  }
    
  public func sendIdentifyProducer(eventId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .identifyProducer)
    message.eventId = eventId
    sendMessage(message: message)
  }

  public func sendIdentifyProducer(event:OpenLCBWellKnownEvent) {
    sendIdentifyProducer(eventId: event.rawValue)
  }
  
  public func sendProducerIdentified(eventId:UInt64, validity:OpenLCBValidity) {
    let message = OpenLCBMessage(messageTypeIndicator: validity.producerMTI)
    message.eventId = eventId
    sendMessage(message: message)
  }

  public func sendProducerIdentified(wellKnownEvent: OpenLCBWellKnownEvent, validity:OpenLCBValidity) {
    sendProducerIdentified(eventId: wellKnownEvent.rawValue, validity: validity)
  }

  public func sendProducerRangeIdentified(eventId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .producerRangeIdentified)
    message.eventId = eventId
    sendMessage(message: message)
  }

  public func sendIdentifyConsumer(eventId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .identifyConsumer)
    message.eventId = eventId
    sendMessage(message: message)
  }

  public func sendIdentifyConsumer(event:OpenLCBWellKnownEvent) {
    sendIdentifyConsumer(eventId: event.rawValue)
  }
  
  public func sendConsumerIdentified(eventId:UInt64, validity:OpenLCBValidity) {
    let message = OpenLCBMessage(messageTypeIndicator: validity.consumerMTI)
    message.eventId = eventId
    sendMessage(message: message)
  }

  public func sendConsumerIdentified(wellKnownEvent: OpenLCBWellKnownEvent, validity:OpenLCBValidity) {
    sendConsumerIdentified(eventId: wellKnownEvent.rawValue, validity: validity)
  }

  public func sendConsumerRangeIdentified(eventId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .consumerRangeIdentified)
    message.eventId = eventId
    sendMessage(message: message)
  }
  
  public func sendVerifyNodeIdNumberAddressed(destinationNodeId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDAddressed)
    message.destinationNodeId = destinationNodeId
    message.payload = destinationNodeId.nodeIdBigEndianData
    sendMessage(message: message)
  }

  public func sendVerifyNodeIdNumber() {
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDGlobal)
    sendMessage(message: message)
  }

  public func sendVerifyNodeIdNumber(destinationNodeId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDGlobal)
    message.destinationNodeId = destinationNodeId
    message.payload = destinationNodeId.nodeIdBigEndianData
    sendMessage(message: message)
  }

  public func sendVerifiedNodeIdNumber(isSimpleSetSufficient:Bool) {
    let mti : OpenLCBMTI = isSimpleSetSufficient ? .verifiedNodeIDSimpleSetSufficient : .verifiedNodeIDFullProtocolRequired
    let message = OpenLCBMessage(messageTypeIndicator: mti)
    message.payload = nodeId.nodeIdBigEndianData
    sendMessage(message: message)
  }

  public func sendGetMemorySpaceInformationRequest(destinationNodeId:UInt64,addressSpace:UInt8) {
    var data = OpenLCBDatagramType.getAddressSpaceInformationCommand.bigEndianData
    data.append(addressSpace)
    sendDatagram(destinationNodeId: destinationNodeId, data: data)
  }
  
  public func sendGetMemorySpaceInformationRequest(destinationNodeId:UInt64,wellKnownAddressSpace:OpenLCBNodeMemoryAddressSpace) {
    sendGetMemorySpaceInformationRequest(destinationNodeId: destinationNodeId, addressSpace: wellKnownAddressSpace.rawValue)
  }
  
  public func sendDatagramReceivedOK(destinationNodeId:UInt64, timeOut: OpenLCBDatagramTimeout) {
    let message = OpenLCBMessage(messageTypeIndicator: .datagramReceivedOK)
    message.destinationNodeId = destinationNodeId
    message.payload = timeOut != .ok ? [timeOut.rawValue] : []
    sendMessage(message: message)
  }

  public func sendFreezeCommand(destinationNodeId:UInt64) {
    var payload = OpenLCBDatagramType.freezeCommand.bigEndianData
    payload.append(OpenLCBNodeMemoryAddressSpace.firmware.rawValue)
    sendDatagram(destinationNodeId: destinationNodeId, data: payload)
  }
  
  public func sendUnfreezeCommand(destinationNodeId:UInt64) {
    var payload = OpenLCBDatagramType.unfreezeCommand.bigEndianData
    payload.append(OpenLCBNodeMemoryAddressSpace.firmware.rawValue)
    sendDatagram(destinationNodeId: destinationNodeId, data: payload)
  }
  
  public func sendUpdateCompleteCommand(destinationNodeId:UInt64) {
    let payload = OpenLCBDatagramType.updateCompleteCommand.bigEndianData
    sendDatagram(destinationNodeId: destinationNodeId, data: payload)
  }
  
  public func sendGetUniqueNodeIdCommand(destinationNodeId:UInt64) {
    let payload = OpenLCBDatagramType.getUniqueNodeIDCommand.bigEndianData
    sendDatagram(destinationNodeId: destinationNodeId, data: payload)
  }
  
  public func sendGetUniqueNodeIdReply(destinationNodeId:UInt64, newNodeId:UInt64) {
    var payload = OpenLCBDatagramType.getUniqueNodeIDReply.bigEndianData
    payload.append(contentsOf: newNodeId.nodeIdBigEndianData)
    sendDatagram(destinationNodeId: destinationNodeId, data: payload)
  }

  public func sendDatagram(destinationNodeId:UInt64, data: [UInt8]) {

    #if DEBUG
    guard data.count >= 0 && data.count <= 72 else {
      debugLog(message:"invalid number of bytes - \(data.count)")
      return
    }
    #endif
    
    let message = OpenLCBMessage(messageTypeIndicator: .datagram)
    message.destinationNodeId = destinationNodeId
    message.payload = data
    sendMessage(message: message)

  }

  public func sendLockReserveReply(destinationNodeId:UInt64, reservedNodeId:UInt64) {
    var data = OpenLCBDatagramType.LockReserveReply.bigEndianData
    data.append(contentsOf: reservedNodeId.nodeIdBigEndianData)
    sendDatagram(destinationNodeId: destinationNodeId, data: data)
  }
  
  public func sendReadReply(destinationNodeId:UInt64, addressSpace:UInt8, startAddress:UInt32, data:[UInt8]) {

    var payload : [UInt8]
    
    switch addressSpace {
    case 0xff:
      payload = OpenLCBDatagramType.readReply0xFF.bigEndianData
    case 0xfe:
      payload = OpenLCBDatagramType.readReply0xFE.bigEndianData
    case 0xfd:
      payload = OpenLCBDatagramType.readReply0xFD.bigEndianData
    default:
      payload = OpenLCBDatagramType.readReplyGeneric.bigEndianData
    }
    
    payload.append(contentsOf: startAddress.bigEndianData)
    
    if addressSpace < 0xfd {
      payload.append(addressSpace)
    }
    
    payload.append(contentsOf: data)
    
    sendDatagram(destinationNodeId: destinationNodeId, data: payload)

  }

  public func sendReadReplyFailure(destinationNodeId:UInt64, addressSpace:UInt8, startAddress:UInt32, errorCode:OpenLCBErrorCode) {

    var payload : [UInt8]
    
    switch addressSpace {
    case 0xff:
      payload = OpenLCBDatagramType.readReplyFailure0xFF.bigEndianData
    case 0xfe:
      payload = OpenLCBDatagramType.readReplyFailure0xFE.bigEndianData
    case 0xfd:
      payload = OpenLCBDatagramType.readReplyFailure0xFD.bigEndianData
    default:
      payload = OpenLCBDatagramType.readReplyFailureGeneric.bigEndianData
    }
    
    payload.append(contentsOf: startAddress.bigEndianData)
    
    if addressSpace < 0xfd {
      payload.append(addressSpace)
    }
    
    payload.append(contentsOf: errorCode.bigEndianData)
    
    sendDatagram(destinationNodeId: destinationNodeId, data: payload)

  }

  public func sendWriteReply(destinationNodeId:UInt64, addressSpace:UInt8, startAddress:UInt32) {

    var payload : [UInt8]
    
    switch addressSpace {
    case 0xff:
      payload = OpenLCBDatagramType.writeReply0xFF.bigEndianData
    case 0xfe:
      payload = OpenLCBDatagramType.writeReply0xFE.bigEndianData
    case 0xfd:
      payload = OpenLCBDatagramType.writeReply0xFD.bigEndianData
    default:
      payload = OpenLCBDatagramType.writeReplyGeneric.bigEndianData
    }
    
    payload.append(contentsOf: startAddress.bigEndianData)
    
    if addressSpace < 0xfd {
      payload.append(addressSpace)
    }
    
    sendDatagram(destinationNodeId: destinationNodeId, data: payload)

  }

  public func sendWriteReplyFailure(destinationNodeId:UInt64, addressSpace:UInt8, startAddress:UInt32, errorCode:OpenLCBErrorCode) {

    var payload : [UInt8]
    
    switch addressSpace {
    case 0xff:
      payload = OpenLCBDatagramType.writeReplyFailure0xFF.bigEndianData
    case 0xfe:
      payload = OpenLCBDatagramType.writeReplyFailure0xFE.bigEndianData
    case 0xfd:
      payload = OpenLCBDatagramType.writeReplyFailure0xFD.bigEndianData
    default:
      payload = OpenLCBDatagramType.writeReplyFailureGeneric.bigEndianData
    }
    
    payload.append(contentsOf: startAddress.bigEndianData)
    
    if addressSpace < 0xfd {
      payload.append(addressSpace)
    }
    
    payload.append(contentsOf: errorCode.bigEndianData)
    
    sendDatagram(destinationNodeId: destinationNodeId, data: payload)

  }

  public func sendGetAddressSpaceInformationReply(destinationNodeId:UInt64, memorySpace:OpenLCBMemorySpace) {

    var data = OpenLCBDatagramType.getAddressSpaceInformationReplyLowAddressPresent.rawValue.bigEndianData
    
    let info = memorySpace.addressSpaceInformation
    
    data.append(info.addressSpace)
    
    data.append(contentsOf: info.highestAddress.bigEndianData)
    
    var flags : UInt8 = 0b10
    flags |= info.isReadOnly ? 0b01 : 0b00
    
    data.append(flags)
    
    data.append(contentsOf: info.lowestAddress.bigEndianData)
    
    if !info.description.isEmpty {
      for byte in info.description.utf8 {
        data.append(byte)
      }
      data.append(0)
    }
    
    sendDatagram(destinationNodeId: destinationNodeId, data: data)

  }
  
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
  
  public func sendNodeMemoryReadRequest(destinationNodeId:UInt64, addressSpace:UInt8, startAddress:Int, numberOfBytesToRead: UInt8) {
    
    #if DEBUG
    guard numberOfBytesToRead > 0 && numberOfBytesToRead <= 64 else {
      debugLog(message:"invalid number of bytes to read - \(numberOfBytesToRead)")
      return
    }
    #endif

    var payload : [UInt8]
    
    switch addressSpace {
    case 0xff:
      payload = OpenLCBDatagramType.readCommand0xFF.bigEndianData
    case 0xfe:
      payload = OpenLCBDatagramType.readCommand0xFE.bigEndianData
    case 0xfd:
      payload = OpenLCBDatagramType.readCommand0xFD.bigEndianData
    default:
      payload = OpenLCBDatagramType.readCommandGeneric.bigEndianData
    }
    
    var mask : UInt32 = 0xff000000
    for index in (0...3).reversed() {
      payload.append(UInt8((UInt32(startAddress) & mask) >> (index * 8)))
      mask >>= 8
    }
    
    if addressSpace < 0xfd {
      payload.append(addressSpace)
    }
    
    payload.append(numberOfBytesToRead)
    
    sendDatagram(destinationNodeId: destinationNodeId, data: payload)
    
  }

  public func sendGetUniqueEventIdCommand(destinationNodeId:UInt64, numberOfEventIds:UInt8) {
    
    #if DEBUG
    guard numberOfEventIds >= 0 && numberOfEventIds < 8 else {
      debugLog(message:"invalid number of event ids to get - \(numberOfEventIds)")
      return
    }
    #endif

    var payload = OpenLCBDatagramType.getUniqueEventIDCommand.bigEndianData
    
    payload.append(numberOfEventIds & 0x07)
        
    sendDatagram(destinationNodeId: destinationNodeId, data: payload)
    
  }

  public func sendNodeMemoryWriteRequest(destinationNodeId:UInt64, addressSpace:UInt8, startAddress:Int, dataToWrite: [UInt8]) {
    
    #if DEBUG
    guard dataToWrite.count > 0 && dataToWrite.count <= 64 else {
      debugLog(message: "invalid number of bytes to write - \(dataToWrite.count)")
      return
    }
    #endif

    var payload : [UInt8]
    
    switch addressSpace {
    case 0xff:
      payload = OpenLCBDatagramType.writeCommand0xFF.bigEndianData
    case 0xfe:
      payload = OpenLCBDatagramType.writeCommand0xFE.bigEndianData
    case 0xfd:
      payload = OpenLCBDatagramType.writeCommand0xFD.bigEndianData
    default:
      payload = OpenLCBDatagramType.writeCommandGeneric.bigEndianData
    }
    
    var mask : UInt32 = 0xff000000
    for index in (0...3).reversed() {
      payload.append(UInt8((UInt32(startAddress) & mask) >> (index * 8)))
      mask >>= 8
    }
    
    if addressSpace < 0xfd {
      payload.append(addressSpace)
    }
    
    payload.append(contentsOf: dataToWrite)
    
    sendDatagram(destinationNodeId: destinationNodeId, data: payload)
    
  }
  
  public func sendLockCommand(destinationNodeId:UInt64) {
    var data = OpenLCBDatagramType.LockReserveCommand.bigEndianData
    data.append(contentsOf: nodeId.nodeIdBigEndianData)
    sendDatagram(destinationNodeId: destinationNodeId, data: data)
  }

  public func sendUnLockCommand(destinationNodeId:UInt64) {
    var data = OpenLCBDatagramType.LockReserveCommand.bigEndianData
    data.append(contentsOf: UInt64(0).nodeIdBigEndianData)
    sendDatagram(destinationNodeId: destinationNodeId, data: data)
  }

  public func sendRebootCommand(destinationNodeId:UInt64) {
    sendDatagram(destinationNodeId: destinationNodeId, data: OpenLCBDatagramType.resetRebootCommand.bigEndianData)
  }

  public func sendGetConfigurationOptionsCommand(destinationNodeId:UInt64) {
    sendDatagram(destinationNodeId: destinationNodeId, data: OpenLCBDatagramType.getConfigurationOptionsCommand.bigEndianData)
  }

  public func sendGetConfigurationOptionsReply(destinationNodeId:UInt64, node:OpenLCBNodeVirtual) {
    sendDatagram(destinationNodeId: destinationNodeId, data: node.configurationOptions.encodedOptions)
  }

  public func sendResetToDefaults(destinationNodeId:UInt64) {
    var data = OpenLCBDatagramType.reinitializeFactoryResetCommand.bigEndianData
    data.append(contentsOf: destinationNodeId.nodeIdBigEndianData)
    sendDatagram(destinationNodeId: destinationNodeId, data: data)
  }

  public func sendSimpleNodeInformationRequest(destinationNodeId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .simpleNodeIdentInfoRequest)
    message.destinationNodeId = destinationNodeId
    sendMessage(message: message)
  }
  
  public func sendSimpleNodeInformationReply(destinationNodeId:UInt64, data:[UInt8]) {
    let message = OpenLCBMessage(messageTypeIndicator: .simpleNodeIdentInfoReply)
    message.destinationNodeId = destinationNodeId
    message.payload = data
    sendMessage(message: message)
  }

  public func sendProtocolSupportInquiry(destinationNodeId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .protocolSupportInquiry)
    message.destinationNodeId = destinationNodeId
    sendMessage(message: message)
  }

  public func sendProtocolSupportReply(destinationNodeId:UInt64, data:[UInt8]) {
    let message = OpenLCBMessage(messageTypeIndicator: .protocolSupportReply)
    message.destinationNodeId = destinationNodeId
    message.payload = data
    sendMessage(message: message)
  }
  
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


  public func sendQueryFunctionCommand(destinationNodeId:UInt64, address:UInt32) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)

    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.queryFunction.rawValue
    ]
    
    var bed = address.bigEndianData
    bed.removeFirst()
    
    message.payload.append(contentsOf: bed)
    
    sendMessage(message: message)
    
  }

  public func sendQueryFunctionReply(destinationNodeId:UInt64, address:UInt32, value:UInt16) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)

    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.queryFunction.rawValue
    ]
    
    var bed = address.bigEndianData
    bed.removeFirst()
    
    message.payload.append(contentsOf: bed)
    
    message.payload.append(contentsOf: value.bigEndianData)
    
    sendMessage(message: message)
    
  }

  public func sendTerminateDueToError(destinationNodeId:UInt64, errorCode:OpenLCBErrorCode) {
    let message = OpenLCBMessage(messageTypeIndicator: .terminateDueToError)
    message.destinationNodeId = destinationNodeId
    message.payload = errorCode.bigEndianData
    sendMessage(message: message)
  }

  public func sendQuerySpeedReply(destinationNodeId:UInt64, setSpeed:Float, commandedSpeed:Float, emergencyStop:Bool) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)

    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.querySpeeds.rawValue
    ]
    
    message.payload.append(contentsOf: setSpeed.float16.v.bigEndianData)
    message.payload.append(emergencyStop ? 0x01 : 0x00)
    message.payload.append(contentsOf: commandedSpeed.float16.v.bigEndianData)
    message.payload.append(contentsOf: [0xff, 0xff])
    
    sendMessage(message: message)
    
  }

  public func sendQuerySpeedCommand(destinationNodeId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)
    message.destinationNodeId = destinationNodeId
    message.payload = [OpenLCBTractionControlInstructionType.querySpeeds.rawValue]
    sendMessage(message: message)
  }

  public func sendSetSpeedDirection(destinationNodeId:UInt64, setSpeed:Float, isForwarded: Bool) {
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)
    message.destinationNodeId = destinationNodeId
    message.payload = [OpenLCBTractionControlInstructionType.setSpeedDirection.rawValue | (isForwarded ? 0x80 : 0x00)]
    message.payload.append(contentsOf: setSpeed.float16.v.bigEndianData)
    sendMessage(message: message)
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

  public func sendEmergencyStop(destinationNodeId:UInt64, isForwarded: Bool) {
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)
    message.destinationNodeId = destinationNodeId
    message.payload = [OpenLCBTractionControlInstructionType.emergencyStop.rawValue | (isForwarded ? 0x80 : 0x00)]
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
    
    message.payload.append(contentsOf: replyCode.rawValue.bigEndianData)
    
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
    
    let nc = UInt8(min(0xff, nodeCount) & 0xff)
    
    message.payload = [
      OpenLCBTractionControlInstructionType.listenerConfiguration.rawValue,
      OpenLCBTractionListenerConfigurationType.queryNodes.rawValue,
      nc,
      UInt8(nodeIndex),
      flags
    ]
    
    message.payload.append(contentsOf: listenerNodeId.nodeIdBigEndianData)
    
    sendMessage(message: message)
    
  }

  public func sendListenerQueryNodeReplyShort(destinationNodeId:UInt64, nodeCount:Int) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)

    message.destinationNodeId = destinationNodeId
    
    let nc = UInt8(min(0xff, nodeCount) & 0xff)
    
    message.payload = [
      OpenLCBTractionControlInstructionType.listenerConfiguration.rawValue,
      OpenLCBTractionListenerConfigurationType.queryNodes.rawValue,
      nc,
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

  public func sendTractionManagementNoOp(destinationNodeId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)

    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.tractionManagement.rawValue,
      OpenLCBTractionManagementType.noopOrHeartbeatRequest.rawValue,
    ]
    
    sendMessage(message: message)
    
  }

  public func sendEmergencyStop(destinationNodeId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)
    message.destinationNodeId = destinationNodeId
    message.payload = [OpenLCBTractionControlInstructionType.emergencyStop.rawValue]
    sendMessage(message: message)
  }

}
