//
//  OpenLCBNodeVirtual - Messages - Memory Configuration.swift
//  MyTrains
//
//  Created by Paul Willmott on 23/02/2024.
//

import Foundation

extension OpenLCBNodeVirtual {
  
  // In reply to the datagram containing a Read command, the receiving node shall
  // set the Reply Pending bit in the Datagram Received OK message. The receiving
  // node may, but is not required to, include a specific timeout interval in the
  // Datagram Received OK message. If the interval is provided and has elapsed
  // without a Read Reply message being returned, the node requesting the Read
  // operation may, but is not required to, repeat the request.
  
  public func sendReadCommand(destinationNodeId:UInt64, addressSpace:UInt8, startAddress:Int, numberOfBytesToRead: UInt8) {
    
#if DEBUG
    guard numberOfBytesToRead > 0 && numberOfBytesToRead <= 64 else {
      debugLog("invalid number of bytes to read - \(numberOfBytesToRead)")
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
  
  // In general, a read reply may provide less than the requested data, but always
  // at least one byte if it's a valid read. The maximum read request is 64 bytes
  // when reading via datagrams. Reading at least one byte, but less
  // than the requested amount, due to the length of the address space is not
  // considered an error.
  
  public func sendReadReply(destinationNodeId:UInt64, addressSpace:UInt8, startAddress:UInt32, data:[UInt8]) {
    
#if DEBUG
    guard data.count > 0 else {
      debugLog("no bytes returned")
      return
    }
#endif
    
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
  
  // If the full number of bytes cannot be read for any reason other than the
  // size of the address space, or if no bytes can be read, the Read Reply shall
  // have the Fail bit set and include an error code instead of the requested data.
    
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

  // MARK: PLACEHOLDER FOR sendReadStreamCommand
  
  // MARK: PLACEHOLDER FOR sendReadStreamReply
  
  // MARK: PLACEHOLDER FOR sendReadStreamReplyFailure
  
  // If the write operation can be done immediately and succeeds, only the
  // Datagram Received OK message reply to the Write Command datagram is returned.
  // The Reply Pending bit is not set in the Datagram Received OK reply.
  // If the write operation takes time, or fails immediately, the Datagram
  // Received OK message reply to the Write Command datagram shall carry the
  // Reply Pending bit set. The receiving node may, but is not required to,
  // include a specific timeout interval in the Datagram Received OK message.
  // This is followed later by the receiving node sending a Write Reply datagram
  // with either OK or Fail set. If Fail is set, the error code shall be included.
  // The optional message string may be, but is not required to be, included.
  // If a timeout interval was provided and has elapsed without a Write Reply
  // message being returned, the node requesting the Write operation may, but
  // is not required to, repeat the request.
  
  public func sendWriteCommand(destinationNodeId:UInt64, addressSpace:UInt8, startAddress:Int, dataToWrite: [UInt8]) {
    
#if DEBUG
    guard dataToWrite.count > 0 && dataToWrite.count <= 64 else {
      debugLog("invalid number of bytes to write - \(dataToWrite.count)")
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
  
  // This message is sent in only if the Reply Pending bit in the Datagram OK
  // message reply to a previous Write Command is set and the write succeeds.
  
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
  
  // This message is sent in only if the Reply Pending bit in the Datagram OK
  // message reply to a previous Write Command is set. If the write fails, a
  // Failure Status reply is sent with the Error Code set appropriately.
  
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
  
  // MARK: PLACEHOLDER FOR sendWriteUnderMaskCommand
  
  // MARK: PLACEHOLDER FOR sendWriteStreamCommand
  
  // MARK: PLACEHOLDER FOR sendWriteStreamReply
  
  // MARK: PLACEHOLDER FOR sendWriteStreamReplyFailure
  
  public func sendGetConfigurationOptionsCommand(destinationNodeId:UInt64) {
    sendDatagram(destinationNodeId: destinationNodeId, data: OpenLCBDatagramType.getConfigurationOptionsCommand.bigEndianData)
  }

  public func sendGetConfigurationOptionsReply(destinationNodeId:UInt64, node:OpenLCBNodeVirtual) {
    sendDatagram(destinationNodeId: destinationNodeId, data: node.configurationOptions.encodedOptions)
  }

  public func sendGetMemorySpaceInformationCommand(destinationNodeId:UInt64, addressSpace:UInt8) {
    var data = OpenLCBDatagramType.getAddressSpaceInformationCommand.bigEndianData
    data.append(addressSpace)
    sendDatagram(destinationNodeId: destinationNodeId, data: data)
  }
  
  public func sendGetMemorySpaceInformationCommand(destinationNodeId:UInt64, wellKnownAddressSpace:OpenLCBNodeMemoryAddressSpace) {
    sendGetMemorySpaceInformationCommand(destinationNodeId: destinationNodeId, addressSpace: wellKnownAddressSpace.rawValue)
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
  
  // At the start of configuration, a configuring node sends a Lock message with
  // its NodeID. If no node has locked this node, indicated by zero content in
  // the lock memory, the incoming NodeID is placed in the lock memory. If a node
  // has locked this node, the non-zero NodeID in the lock memory is not changed.
  // In either case, the content of the lock memory is returned in the reply.
  // This acts as a test and set operation, and informs the requesting node
  // whether it successfully reserved the node. 
  
  public func sendLockReserveCommand(destinationNodeId:UInt64) {
    var data = OpenLCBDatagramType.lockReserveCommand.bigEndianData
    data.append(contentsOf: nodeId.nodeIdBigEndianData)
    sendDatagram(destinationNodeId: destinationNodeId, data: data)
  }

  public func sendLockReserveReply(destinationNodeId:UInt64, reservedNodeId:UInt64) {
    var data = OpenLCBDatagramType.lockReserveReply.bigEndianData
    data.append(contentsOf: reservedNodeId.nodeIdBigEndianData)
    sendDatagram(destinationNodeId: destinationNodeId, data: data)
  }
  
  // To release the node, repeat the lock operation with a zero Node ID. The
  // lock memory is set to zero when the node is reset. Note that this is a
  // voluntary protocol in the configuring nodes only; the node being configured
  // does not change it's response to configuration operations when locked or
  // unlocked.
  
  public func sendUnLockCommand(destinationNodeId:UInt64) {
    var data = OpenLCBDatagramType.lockReserveCommand.bigEndianData
    data.append(contentsOf: UInt64(0).nodeIdBigEndianData)
    sendDatagram(destinationNodeId: destinationNodeId, data: data)
  }

  // Nodes maintain a list of unique Event IDs for use in configuration. These
  // are allocated based on the node's unique Node ID. This command allows a
  // configuration tool to get new unique Event IDs from the node's pool, for
  // example to interact with the Blue/Gold configuration process. Each request
  // must provide a different Event ID, without repeat, even through node resets
  // and factory resets.
  
  public func sendGetUniqueIDCommand(destinationNodeId:UInt64, numberOfEventIds:UInt8) {
    
    #if DEBUG
    guard numberOfEventIds >= 0 && numberOfEventIds < 8 else {
      debugLog("invalid number of event ids to get - \(numberOfEventIds)")
      return
    }
    #endif

    var payload = OpenLCBDatagramType.getUniqueEventIDCommand.bigEndianData
    payload.append(numberOfEventIds & 0x07)
    sendDatagram(destinationNodeId: destinationNodeId, data: payload)
    
  }

  // MARK: PLACEHOLDER FOR GetUniqueIDReply

  // This command is used in conjunction with the Freeze Command if, only if, 
  // and as required by a higher-level protocol specification. An example of
  // such protocol specification is the Firmware Upgrade Standard.
  // The receiving node may acknowledge this and the Freeze Command either with
  // a Node Initialization Complete or a Datagram Received OK response.
  
  public func sendUnfreezeCommand(destinationNodeId:UInt64) {
    var payload = OpenLCBDatagramType.unfreezeCommand.bigEndianData
    payload.append(OpenLCBNodeMemoryAddressSpace.firmware.rawValue)
    sendDatagram(destinationNodeId: destinationNodeId, data: payload)
  }
  
  public func sendFreezeCommand(destinationNodeId:UInt64) {
    var payload = OpenLCBDatagramType.freezeCommand.bigEndianData
    payload.append(OpenLCBNodeMemoryAddressSpace.firmware.rawValue)
    sendDatagram(destinationNodeId: destinationNodeId, data: payload)
  }
  
  // This command notifies the target node that the configuration update 
  // operation sequence has completed. Nodes do not have to require this
  // operation, but receiving it must be permitted. Configuration tools
  // should send it at the end of operations. Nodes may, but are not required
  // to, reset as part of the processing of this message. The receiving node
  // may acknowledge this command with a Node Initialization Complete instead
  // of a Datagram Received OK response.
  
  public func sendUpdateCompleteCommand(destinationNodeId:UInt64) {
    let payload = OpenLCBDatagramType.updateCompleteCommand.bigEndianData
    sendDatagram(destinationNodeId: destinationNodeId, data: payload)
  }

  // After successfully processing this command, the receiving node shall 
  // reset/reboot into its power on reset state, as if it has been put through
  // a power cycle. The receiving node may acknowledge this command with a Node
  // Initialization Complete instead of a Datagram Received OK response.
  
  public func sendResetRebootCommand(destinationNodeId:UInt64) {
    sendDatagram(destinationNodeId: destinationNodeId, data: OpenLCBDatagramType.resetRebootCommand.bigEndianData)
  }

  // “Reinitialize/Factory Reset” restores the node's configuration as if factory 
  // reset. Node ID shall carry the destination Node ID for redundancy.
  // The receiving node may acknowledge this command with a Node Initialization
  // Complete instead of a Datagram Received OK response.
  
  public func sendReinitializeFactoryResetCommand(destinationNodeId:UInt64) {
    var data = OpenLCBDatagramType.reinitializeFactoryResetCommand.bigEndianData
    data.append(contentsOf: destinationNodeId.nodeIdBigEndianData)
    sendDatagram(destinationNodeId: destinationNodeId, data: data)
  }

}
