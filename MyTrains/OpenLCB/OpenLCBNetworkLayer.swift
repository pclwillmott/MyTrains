//
//  LCCNetworkLayer.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/04/2023.
//

import Foundation

public class OpenLCBNetworkLayer : NSObject {
  
  // MARK: Constructors
  
  public init(nodeId: UInt64) {
    
    super.init()

    _state = .initialized
    
    nodeManagers.append(throttleManager)
    nodeManagers.append(locoNetMonitorManager)
    nodeManagers.append(programmerToolManager)
    nodeManagers.append(configurationToolManager)

    var virtualNodes = OpenLCBMemorySpace.getVirtualNodes()
    
    if virtualNodes.isEmpty {
      
      let defaultNodes : [(type:MyTrainsVirtualNodeType, number:Int)] = [
        (type:.applicationNode, number: 1),
        (type:.clockNode, number: 1),
        (type:.configurationToolNode, number: 1),
        (type:.programmerToolNode, number: 1),
        (type:.throttleNode, number: 4),
      ]
      
      for nodeDef in defaultNodes {
        
        for _ in 1...nodeDef.number {
          
          let newNodeId = getNewNodeId(virtualNodeType: nodeDef.type)
          
          var node : OpenLCBNodeVirtual?
          
          switch nodeDef.type {
          case .applicationNode:
            node = OpenLCBNodeMyTrains(nodeId: newNodeId)
          case .canGatewayNode:
            node = OpenLCBCANGateway(nodeId: newNodeId)
          case .clockNode:
            node = OpenLCBClock(nodeId: newNodeId)
          case .configurationToolNode:
            node = OpenLCBNodeConfigurationTool(nodeId: newNodeId)
          case .genericVirtualNode:
            break
          case .locoNetGatewayNode:
            node = OpenLCBLocoNetGateway(nodeId: newNodeId)
          case .locoNetMonitorNode:
            node = OpenLCBLocoNetMonitorNode(nodeId: newNodeId)
          case .programmerToolNode:
            node = OpenLCBProgrammerToolNode(nodeId: newNodeId)
          case .programmingTrackNode:
            node = OpenLCBProgrammingTrackNode(nodeId: newNodeId)
          case .throttleNode:
            node = OpenLCBThrottle(nodeId: newNodeId)
          case .trainNode:
            node = OpenLCBNodeRollingStockLocoNet(nodeId: newNodeId)
          case .digitraxBXP88Node:
            node = OpenLCBDigitraxBXP88Node(nodeId: newNodeId)
          }
          
          if let node {
            
            node.userNodeName = nodeDef.type.defaultUserNodeName(nodeId: newNodeId)
            
            node.saveMemorySpaces()
            
            virtualNodes.append(node)
            
          }
          
        }
        
      }
      
      virtualNodes.sort { $0.nodeId < $1.nodeId }
      
    }
    
    for node in virtualNodes {
      registerNode(node: node)
    }
    
  }
  
  // MARK: Private Properties
  
  internal var _state : OpenLCBNetworkLayerState = .uninitialized
  
  private var virtualNodes : [UInt64:OpenLCBNodeVirtual] = [:]
  
  private var nodeManagers : [OpenLCBNodeManager] = []
  
  private var throttleManager = OpenLCBNodeManager()
  
  private var locoNetMonitorManager = OpenLCBNodeManager()
  
  private var programmerToolManager = OpenLCBNodeManager()
  
  private var configurationToolManager = OpenLCBNodeManager()
  
  // MARK: Public Properties
  
  public var state : OpenLCBNetworkLayerState {
    get {
      return _state
    }
  }
  
  public var myTrainsNode : OpenLCBNodeMyTrains?
  
  public var fastClock : OpenLCBClock?
  
//  public var transportLayers : [ObjectIdentifier:OpenLCBTransportLayer] = [:]
  
  // MARK: Public Methods
  
  public func start() {
    
    guard state == .uninitialized else {
      return
    }
    
  }
  
  public func stop() {
    
    guard state == .initialized else {
      return
    }
    
  }
  
  public func removeAlias(nodeId:UInt64) {
/*    for (_, layer) in transportLayers {
      layer.removeAlias(nodeId: nodeId)
    } */
  }

  public func registerNode(node:OpenLCBNodeVirtual) {
    
    virtualNodes[node.nodeId] = node
    
    node.networkLayer = self
    
    switch node.virtualNodeType {
    case .applicationNode:
      myTrainsNode = node as? OpenLCBNodeMyTrains
    case .canGatewayNode:
      break
    case .clockNode:
      fastClock = node as? OpenLCBClock
    case .configurationToolNode:
      configurationToolManager.addNode(node: node)
    case .genericVirtualNode:
      break
    case .locoNetGatewayNode:
      break
    case .locoNetMonitorNode:
      locoNetMonitorManager.addNode(node: node)
    case .programmerToolNode:
      programmerToolManager.addNode(node: node)
    case .programmingTrackNode:
      break
    case .throttleNode:
      throttleManager.addNode(node: node)
    case .trainNode:
      break
    case .digitraxBXP88Node:
      break
    }
    
    node.start()
    
  }
  
  public func deregisterNode(node:OpenLCBNodeVirtual) {
    
    for nodeManager in nodeManagers {
      nodeManager.removeNode(node: node)
    }
    
    virtualNodes.removeValue(forKey: node.nodeId)
    node.networkLayer = nil
    
  }
  
  public func deleteNode(nodeId:UInt64) {
    
    for (_, virtualNode) in virtualNodes {
      if virtualNode.nodeId == nodeId {
        deregisterNode(node: virtualNode)
        OpenLCBMemorySpace.deleteAllMemorySpaces(forNodeId: nodeId)
      }
    }
    
  }
  
  public func getThrottle() -> OpenLCBThrottle? {
    return throttleManager.getNode() as? OpenLCBThrottle
  }
  
  public func releaseThrottle(throttle:OpenLCBThrottle) {
    throttle.delegate = nil
    throttleManager.releaseNode(node: throttle)
  }
  
  public func getLocoNetMonitor() -> OpenLCBLocoNetMonitorNode? {
    return locoNetMonitorManager.getNode() as? OpenLCBLocoNetMonitorNode
  }
  
  public func releaseLocoNetMonitor(monitor:OpenLCBLocoNetMonitorNode) {
    locoNetMonitorManager.releaseNode(node: monitor)
  }
  
  public func getProgrammerTool() -> OpenLCBProgrammerToolNode? {
    return programmerToolManager.getNode() as? OpenLCBProgrammerToolNode
  }
  
  public func releaseProgrammerTool(programmerTool:OpenLCBProgrammerToolNode) {
    programmerToolManager.releaseNode(node: programmerTool)
  }
  
  public func getConfigurationTool() -> OpenLCBNodeConfigurationTool {
    
    if let configurationTool = configurationToolManager.getNode() as? OpenLCBNodeConfigurationTool {
      return configurationTool
    }
    
    let newNodeId = getNewNodeId(virtualNodeType: .configurationToolNode)
    
    let node = OpenLCBNodeConfigurationTool(nodeId: newNodeId)
      
    node.userNodeName = node.virtualNodeType.defaultUserNodeName(nodeId: newNodeId)
    
    node.saveMemorySpaces()
    
    registerNode(node: node)
    
    return node

  }
  
  public func releaseConfigurationTool(configurationTool:OpenLCBNodeConfigurationTool) {
    configurationToolManager.releaseNode(node: configurationTool)
  }
  
  public func getNewNodeId(virtualNodeType:MyTrainsVirtualNodeType) -> UInt64 {
    
    var newNodeId = virtualNodeType.baseNodeId
      
    while true {
      if Database.codeExists(tableName: TABLE.MEMORY_SPACE, primaryKey: MEMORY_SPACE.NODE_ID, code: newNodeId) {
        newNodeId += 1
      }
      else {
        return newNodeId
      }
    }

  }

  // MARK: Messages

  public func sendMessage(gatewayNodeId:UInt64, message:OpenLCBMessage) {
    
    guard state == .initialized else {
      return
    }
    
    message.gatewayNodeId = gatewayNodeId
    
    for (_, virtualNode) in virtualNodes {
      if virtualNode.nodeId != message.gatewayNodeId {
        virtualNode.openLCBMessageReceived(message: message)
      }
    }

  }
  
  internal func sendMessage(message:OpenLCBMessage) {
    sendMessage(gatewayNodeId: message.sourceNodeId!, message: message)
  }
  
  public func sendInitializationComplete(sourceNodeId:UInt64, isSimpleSetSufficient:Bool) {
    
    let mti : OpenLCBMTI = isSimpleSetSufficient ? .initializationCompleteSimpleSetSufficient : .initializationCompleteFullProtocolRequired
    
    let message = OpenLCBMessage(messageTypeIndicator: mti)
    
    message.sourceNodeId = sourceNodeId
    
    var data = sourceNodeId.bigEndianData
    data.removeFirst(2)
    
    message.payload = data
    
    sendMessage(message: message)
 
  }

  public func sendClockQuery(sourceNodeId:UInt64, baseEventId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .producerConsumerEventReport)
    
    message.sourceNodeId = sourceNodeId
    
    message.eventId = baseEventId | 0xf000
    
    sendMessage(message: message)
    
  }

  public func sendLocoNetMessageReceived(sourceNodeId:UInt64, locoNetMessage:[UInt8]) {
    
    let numberOfFrames = 1 + (locoNetMessage.count - 1) / 8
    
    if numberOfFrames == 1 {
      let message = OpenLCBMessage(messageTypeIndicator: .locoNetMessageReceivedOnlyFrame)
      message.sourceNodeId = sourceNodeId
      message.payload = locoNetMessage
      sendMessage(message: message)
    }
    else {
      
      var buffer = locoNetMessage

      for frameNumber in 1 ... numberOfFrames {
        
        var flags : OpenLCBMTI = .locoNetMessageReceivedMiddleFrame
        if frameNumber == 1 {
          flags = .locoNetMessageReceivedFirstFrame
        }
        else if frameNumber == numberOfFrames {
          flags = .locoNetMessageReceivedLastFrame
        }
        
        let message = OpenLCBMessage(messageTypeIndicator: flags)
        
        message.sourceNodeId = sourceNodeId
        
        message.payload.append(contentsOf: buffer.prefix(8))
        
        buffer.removeFirst(message.payload.count)
        
        sendMessage(message: message)
        
      }
      
    }
    
  }

  public func sendLocoNetMessage(sourceNodeId:UInt64, destinationNodeId:UInt64, locoNetMessage:LocoNetMessage) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .datagram)
    
    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = OpenLCBDatagramType.sendlocoNetMessage.bigEndianData
    
    message.payload.append(contentsOf: locoNetMessage.message)
    
    sendMessage(message: message)
    
  }

  public func sendLocoNetMessageReply(sourceNodeId:UInt64, destinationNodeId:UInt64, errorCode:OpenLCBErrorCode) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .sendLocoNetMessageReply)
    
    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = errorCode.bigEndianData
    
    sendMessage(message: message)
    
  }

  public func makeTrainSearchEventId(searchString : String, searchType:OpenLCBSearchType, searchMatchType:OpenLCBSearchMatchType, searchMatchTarget:OpenLCBSearchMatchTarget, trackProtocol:OpenLCBTrackProtocol) -> UInt64 {
    
    var eventId : UInt64 = 0x090099ff00000000
    
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
  
  public func sendEvent(sourceNodeId:UInt64, eventId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .producerConsumerEventReport)
    message.sourceNodeId = sourceNodeId
    message.eventId = eventId
    sendMessage(message: message)
  }

  public func sendEventWithPayload(sourceNodeId:UInt64, eventId:UInt64, payload:[UInt8]) {
    let message = OpenLCBMessage(messageTypeIndicator: .producerConsumerEventReport)
    message.sourceNodeId = sourceNodeId
    message.eventId = eventId
    message.payload = payload
    sendMessage(message: message)
  }

  public func sendWellKnownEvent(sourceNodeId:UInt64, eventId:OpenLCBWellKnownEvent) {
    sendEvent(sourceNodeId: sourceNodeId, eventId: eventId.rawValue)
  }
    
  public func sendIdentifyProducer(sourceNodeId:UInt64, eventId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .identifyProducer)
    message.sourceNodeId = sourceNodeId
    message.eventId = eventId
    sendMessage(message: message)
  }

  public func sendIdentifyProducer(sourceNodeId:UInt64, event:OpenLCBWellKnownEvent) {
    sendIdentifyProducer(sourceNodeId: sourceNodeId, eventId: event.rawValue)
  }
  
  public func sendProducerIdentified(sourceNodeId:UInt64, eventId:UInt64, validity:OpenLCBValidity) {
    let message = OpenLCBMessage(messageTypeIndicator: validity.producerMTI)
    message.sourceNodeId = sourceNodeId
    message.eventId = eventId
    sendMessage(message: message)
  }

  public func sendProducerIdentified(sourceNodeId:UInt64, wellKnownEvent: OpenLCBWellKnownEvent, validity:OpenLCBValidity) {
    sendProducerIdentified(sourceNodeId: sourceNodeId, eventId: wellKnownEvent.rawValue, validity: validity)
  }

  public func sendProducerRangeIdentified(sourceNodeId:UInt64, eventId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .producerRangeIdentified)
    message.sourceNodeId = sourceNodeId
    message.eventId = eventId
    sendMessage(message: message)
  }

  public func sendIdentifyConsumer(sourceNodeId:UInt64, eventId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .identifyConsumer)
    message.sourceNodeId = sourceNodeId
    message.eventId = eventId
    sendMessage(message: message)
  }

  public func sendIdentifyConsumer(sourceNodeId:UInt64, event:OpenLCBWellKnownEvent) {
    sendIdentifyConsumer(sourceNodeId: sourceNodeId, eventId: event.rawValue)
  }
  
  public func sendConsumerIdentified(sourceNodeId:UInt64, eventId:UInt64, validity:OpenLCBValidity) {
    let message = OpenLCBMessage(messageTypeIndicator: validity.consumerMTI)
    message.sourceNodeId = sourceNodeId
    message.eventId = eventId
    sendMessage(message: message)
  }

  public func sendConsumerIdentified(sourceNodeId:UInt64, wellKnownEvent: OpenLCBWellKnownEvent, validity:OpenLCBValidity) {
    sendConsumerIdentified(sourceNodeId: sourceNodeId, eventId: wellKnownEvent.rawValue, validity: validity)
  }

  public func sendConsumerRangeIdentified(sourceNodeId:UInt64, eventId:UInt64) {
    let message = OpenLCBMessage(messageTypeIndicator: .consumerRangeIdentified)
    message.sourceNodeId = sourceNodeId
    message.eventId = eventId
    sendMessage(message: message)
  }
  
  public func sendVerifyNodeIdNumber(sourceNodeId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDNumberGlobal)

    message.sourceNodeId = sourceNodeId
    
    sendMessage(message: message)
    
  }

  public func sendVerifyNodeIdNumber(sourceNodeId:UInt64, destinationNodeId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDNumberGlobal)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId

    var data = destinationNodeId.bigEndianData
    data.removeFirst(2)

    message.payload = data

    sendMessage(message: message)
    
  }

  public func sendVerifiedNodeIdNumber(sourceNodeId:UInt64, isSimpleSetSufficient:Bool) {
    
    let mti : OpenLCBMTI = isSimpleSetSufficient ? .verifiedNodeIDNumberSimpleSetSufficient : .verifiedNodeIDNumberFullProtocolRequired
    
    let message = OpenLCBMessage(messageTypeIndicator: mti)

    message.sourceNodeId = sourceNodeId
    
    var data = sourceNodeId.bigEndianData
    data.removeFirst(2)

    message.payload = data

    sendMessage(message: message)
    
  }

  public func sendGetMemorySpaceInformationRequest(sourceNodeId:UInt64, destinationNodeId:UInt64,addressSpace:UInt8) {
    var data = OpenLCBDatagramType.getAddressSpaceInformationCommand.bigEndianData
    data.append(addressSpace)
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data)
  }
  
  public func sendGetMemorySpaceInformationRequest(sourceNodeId:UInt64, destinationNodeId:UInt64,wellKnownAddressSpace:OpenLCBNodeMemoryAddressSpace) {
    sendGetMemorySpaceInformationRequest(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, addressSpace: wellKnownAddressSpace.rawValue)
  }
  
  public func sendDatagramReceivedOK(sourceNodeId:UInt64, destinationNodeId:UInt64, timeOut: OpenLCBDatagramTimeout) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .datagramReceivedOK)
    
    message.destinationNodeId = destinationNodeId
    
    message.sourceNodeId = sourceNodeId

    var data : [UInt8] = []
    
    if timeOut != .ok {
      data.append(timeOut.rawValue)
    }
    
    message.payload = data
    
    sendMessage(message: message)
    
  }

  public func sendDatagram(sourceNodeId:UInt64, destinationNodeId:UInt64, data: [UInt8]) {

    guard data.count >= 0 && data.count <= 72 else {
      print("sendDatagram: invalid number of bytes - \(data.count)")
      return
    }
    
    let message = OpenLCBMessage(messageTypeIndicator: .datagram)
    
    message.destinationNodeId = destinationNodeId
    
    message.sourceNodeId = sourceNodeId
    
    message.payload = data
    
    sendMessage(message: message)

  }

  public func sendLockReserveReply(sourceNodeId:UInt64, destinationNodeId:UInt64, reservedNodeId:UInt64) {

    var data : [UInt8] = reservedNodeId.bigEndianData
    data.removeFirst(2)
    
    data.insert(0x8a, at: 0)
    data.insert(0x20, at: 0)
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data)

  }
  
  public func sendReadReply(sourceNodeId:UInt64, destinationNodeId:UInt64, addressSpace:UInt8, startAddress:UInt32, data:[UInt8]) {

    var payload : [UInt8] = []
    
    var addAddressSpace = false
    
    switch addressSpace {
    case 0xff:
      payload.append(contentsOf: OpenLCBDatagramType.readReply0xFF.rawValue.bigEndianData)
    case 0xfe:
      payload.append(contentsOf: OpenLCBDatagramType.readReply0xFE.rawValue.bigEndianData)
    case 0xfd:
      payload.append(contentsOf: OpenLCBDatagramType.readReply0xFD.rawValue.bigEndianData)
    default:
      payload.append(contentsOf: OpenLCBDatagramType.readReplyGeneric.rawValue.bigEndianData)
      addAddressSpace = true
    }
    
    payload.append(contentsOf: startAddress.bigEndianData)
    
    if addAddressSpace {
      payload.append(addressSpace)
    }
    
    payload.append(contentsOf: data)
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: payload)

  }

  public func sendReadReplyFailure(sourceNodeId:UInt64, destinationNodeId:UInt64, addressSpace:UInt8, startAddress:UInt32, errorCode:OpenLCBErrorCode) {

    var payload : [UInt8] = []
    
    var addAddressSpace = false
    
    switch addressSpace {
    case 0xff:
      payload.append(contentsOf: OpenLCBDatagramType.readReplyFailure0xFF.rawValue.bigEndianData)
    case 0xfe:
      payload.append(contentsOf: OpenLCBDatagramType.readReplyFailure0xFE.rawValue.bigEndianData)
    case 0xfd:
      payload.append(contentsOf: OpenLCBDatagramType.readReplyFailure0xFD.rawValue.bigEndianData)
    default:
      payload.append(contentsOf: OpenLCBDatagramType.readReplyFailureGeneric.rawValue.bigEndianData)
      addAddressSpace = true
    }
    
    payload.append(contentsOf: startAddress.bigEndianData)
    
    if addAddressSpace {
      payload.append(addressSpace)
    }
    
    payload.append(contentsOf: errorCode.bigEndianData)
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: payload)

  }

  public func sendWriteReply(sourceNodeId:UInt64, destinationNodeId:UInt64, addressSpace:UInt8, startAddress:UInt32) {

    var payload : [UInt8] = []
    
    var addAddressSpace = false
    
    switch addressSpace {
    case 0xff:
      payload.append(contentsOf: OpenLCBDatagramType.writeReply0xFF.rawValue.bigEndianData)
    case 0xfe:
      payload.append(contentsOf: OpenLCBDatagramType.writeReply0xFE.rawValue.bigEndianData)
    case 0xfd:
      payload.append(contentsOf: OpenLCBDatagramType.writeReply0xFD.rawValue.bigEndianData)
    default:
      payload.append(contentsOf: OpenLCBDatagramType.writeReplyGeneric.rawValue.bigEndianData)
      addAddressSpace = true
    }
    
    payload.append(contentsOf: startAddress.bigEndianData)
    
    if addAddressSpace {
      payload.append(addressSpace)
    }
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: payload)

  }

  public func sendWriteReplyFailure(sourceNodeId:UInt64, destinationNodeId:UInt64, addressSpace:UInt8, startAddress:UInt32, errorCode:OpenLCBErrorCode) {

    var payload : [UInt8] = []
    
    var addAddressSpace = false
    
    switch addressSpace {
    case 0xff:
      payload.append(contentsOf: OpenLCBDatagramType.writeReplyFailure0xFF.rawValue.bigEndianData)
    case 0xfe:
      payload.append(contentsOf: OpenLCBDatagramType.writeReplyFailure0xFE.rawValue.bigEndianData)
    case 0xfd:
      payload.append(contentsOf: OpenLCBDatagramType.writeReplyFailure0xFD.rawValue.bigEndianData)
    default:
      payload.append(contentsOf: OpenLCBDatagramType.writeReplyFailureGeneric.rawValue.bigEndianData)
      addAddressSpace = true
    }
    
    payload.append(contentsOf: startAddress.bigEndianData)
    
    if addAddressSpace {
      payload.append(addressSpace)
    }
    
    payload.append(contentsOf: errorCode.bigEndianData)
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: payload)

  }

  public func sendGetAddressSpaceInformationReply(sourceNodeId:UInt64, destinationNodeId:UInt64, memorySpace:OpenLCBMemorySpace) {

    var data : [UInt8] = [0x20, 0x87]
    
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
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data)

  }
  
  public func sendDatagramRejected(sourceNodeId:UInt64, destinationNodeId:UInt64, errorCode:OpenLCBErrorCode) {

    let message = OpenLCBMessage(messageTypeIndicator: .datagramRejected)
    
    message.destinationNodeId = destinationNodeId
    
    message.sourceNodeId = sourceNodeId
    
    var data = errorCode.rawValue.bigEndianData
    
    if data[1] == 0 {
      data.removeLast()
    }
    message.payload = data
    
    sendMessage(message: message)

  }
  
  public func sendNodeMemoryReadRequest(sourceNodeId:UInt64, destinationNodeId:UInt64, addressSpace:UInt8, startAddress:Int, numberOfBytesToRead: UInt8) {
    
    guard numberOfBytesToRead > 0 && numberOfBytesToRead <= 64 else {
      print("sendNodeMemoryReadRequest: invalid number of bytes to read - \(numberOfBytesToRead)")
      return
    }
    
    var data : [UInt8] = [0x20]
    
    var addByte6 = false
    
    switch addressSpace {
    case 0xff:
      data.append(0x43)
    case 0xfe:
      data.append(0x42)
    case 0xfd:
      data.append(0x41)
    default:
      data.append(0x40)
      addByte6 = true
    }
    
    var mask : UInt32 = 0xff000000
    for index in (0...3).reversed() {
      data.append(UInt8((UInt32(startAddress) & mask) >> (index * 8)))
      mask >>= 8
    }
    
    if addByte6 {
      data.append(addressSpace)
    }
    
    data.append(numberOfBytesToRead)
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data)
    
  }
  
  public func sendNodeMemoryWriteRequest(sourceNodeId:UInt64, destinationNodeId:UInt64, addressSpace:UInt8, startAddress:Int, dataToWrite: [UInt8]) {
    
    guard dataToWrite.count > 0 && dataToWrite.count <= 64 else {
      print("sendNodeMemoryWriteRequest: invalid number of bytes to write - \(dataToWrite.count)")
      return
    }
    
    var data : [UInt8] = [0x20]
    
    var addByte6 = false
    
    switch addressSpace {
    case 0xff:
      data.append(0x03)
    case 0xfe:
      data.append(0x02)
    case 0xfd:
      data.append(0x01)
    default:
      data.append(0x00)
      addByte6 = true
    }
    
    var mask : UInt32 = 0xff000000
    for index in (0...3).reversed() {
      data.append(UInt8((UInt32(startAddress) & mask) >> (index * 8)))
      mask >>= 8
    }
    
    if addByte6 {
      data.append(addressSpace)
    }
    
    data.append(contentsOf: dataToWrite)
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data)
    
  }
  
  public func sendLockCommand(sourceNodeId:UInt64, destinationNodeId:UInt64) {

    var data = sourceNodeId.bigEndianData
    data.removeFirst(2)

    data.insert(contentsOf: OpenLCBDatagramType.LockReserveCommand.rawValue.bigEndianData, at: 0)
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data)
    
  }

  public func sendUnLockCommand(sourceNodeId:UInt64, destinationNodeId:UInt64) {

    var data = OpenLCBDatagramType.LockReserveCommand.rawValue.bigEndianData
    data.append(contentsOf: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data)
    
  }

  public func sendRebootCommand(sourceNodeId:UInt64, destinationNodeId:UInt64) {

    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: OpenLCBDatagramType.resetRebootCommand.rawValue.bigEndianData)
    
    removeAlias(nodeId: destinationNodeId)
    
  }

  public func sendGetConfigurationOptionsCommand(sourceNodeId:UInt64, destinationNodeId:UInt64) {

    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: OpenLCBDatagramType.getConfigurationOptionsCommand.rawValue.bigEndianData)
    
  }

  public func sendGetConfigurationOptionsReply(sourceNodeId:UInt64, destinationNodeId:UInt64, node:OpenLCBNodeVirtual) {

    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: node.configurationOptions.encodedOptions )
    
  }

  public func sendResetToDefaults(sourceNodeId:UInt64, destinationNodeId:UInt64) {

    var data = destinationNodeId.bigEndianData
    data.removeFirst(2)

    data.insert(contentsOf: OpenLCBDatagramType.reinitializeFactoryResetCommand.rawValue.bigEndianData, at: 0)

    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data)
    
    removeAlias(nodeId: destinationNodeId)
    
  }

  public func sendSimpleNodeInformationRequest(sourceNodeId:UInt64, destinationNodeId:UInt64) {

    let message = OpenLCBMessage(messageTypeIndicator: .simpleNodeIdentInfoRequest)
    
    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    sendMessage(message: message)

  }
  
  public func sendSimpleNodeInformationReply(sourceNodeId:UInt64, destinationNodeId:UInt64, data:[UInt8]) {

    let message = OpenLCBMessage(messageTypeIndicator: .simpleNodeIdentInfoReply)
    
    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = data
    
    sendMessage(message: message)

  }

  public func sendProtocolSupportInquiry(sourceNodeId:UInt64, destinationNodeId:UInt64) {

    let message = OpenLCBMessage(messageTypeIndicator: .protocolSupportInquiry)
    
    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    sendMessage(message: message)

  }

  public func sendProtocolSupportReply(sourceNodeId:UInt64, destinationNodeId:UInt64, data:[UInt8]) {

    let message = OpenLCBMessage(messageTypeIndicator: .protocolSupportReply)
    
    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = data
    
    sendMessage(message: message)

  }
  
  public func sendQueryControllerReply(sourceNodeId:UInt64, destinationNodeId:UInt64, activeController:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.controllerConfiguration.rawValue,
      OpenLCBTractionControllerConfigurationType.queryController.rawValue,
      0x00
    ]
    
    var ac = activeController.bigEndianData
    ac.removeFirst(2)
    
    message.payload.append(contentsOf: ac)
    
//    message.payload.append(contentsOf: [0x00, 0x00])
    
    sendMessage(message: message)
    
  }

  public func sendControllerChangedNotify(sourceNodeId:UInt64, destinationNodeId:UInt64, newController:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.controllerConfiguration.rawValue,
      OpenLCBTractionControllerConfigurationType.controllerChangingNotify.rawValue,
      0x00
    ]
    
    var ac = newController.bigEndianData
    ac.removeFirst(2)
    
    message.payload.append(contentsOf: ac)
    
    sendMessage(message: message)
    
  }

  public func sendControllerChangedNotifyReply(sourceNodeId:UInt64, destinationNodeId:UInt64, reject:Bool) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.controllerConfiguration.rawValue,
      OpenLCBTractionControllerConfigurationType.controllerChangingNotify.rawValue,
      reject ? 0x01 : 0x00
    ]
    
    sendMessage(message: message)
    
  }

  public func sendAssignControllerCommand(sourceNodeId:UInt64, destinationNodeId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.controllerConfiguration.rawValue,
      OpenLCBTractionControllerConfigurationType.assignController.rawValue,
      0x00
    ]
    
    var nodeId = sourceNodeId.bigEndianData
    nodeId.removeFirst(2)
    
    message.payload.append(contentsOf: nodeId)
    
    sendMessage(message: message)
    
  }

  public func sendAssignControllerReply(sourceNodeId:UInt64, destinationNodeId:UInt64, result:UInt8) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.controllerConfiguration.rawValue,
      OpenLCBTractionControllerConfigurationType.assignController.rawValue,
      result,
/*    0x00,
      0x00,
      0x00,
      0x00,
      0x00,
      0x00, */
    ]
    
    sendMessage(message: message)
    
  }

  public func sendReleaseControllerCommand(sourceNodeId:UInt64, destinationNodeId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.controllerConfiguration.rawValue,
      OpenLCBTractionControllerConfigurationType.releaseController.rawValue,
      0x00
    ]
    
    var nodeId = sourceNodeId.bigEndianData
    nodeId.removeFirst(2)
    
    message.payload.append(contentsOf: nodeId)
    
    sendMessage(message: message)
    
  }


  public func sendQueryFunctionCommand(sourceNodeId:UInt64, destinationNodeId:UInt64, address:UInt32) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.queryFunction.rawValue
    ]
    
    var bed = address.bigEndianData
    bed.removeFirst()
    
    message.payload.append(contentsOf: bed)
    
    sendMessage(message: message)
    
  }

  public func sendQueryFunctionReply(sourceNodeId:UInt64, destinationNodeId:UInt64, address:UInt32, value:UInt16) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)

    message.sourceNodeId = sourceNodeId
    
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

  public func sendTerminateDueToError(sourceNodeId:UInt64, destinationNodeId:UInt64, errorCode:OpenLCBErrorCode) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .terminateDueToError)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = errorCode.bigEndianData
    
    sendMessage(message: message)
    
  }

  public func sendQuerySpeedReply(sourceNodeId:UInt64, destinationNodeId:UInt64, setSpeed:Float, commandedSpeed:Float, emergencyStop:Bool) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.querySpeeds.rawValue
    ]
    
    message.payload.append(contentsOf: setSpeed.float16.v.bigEndianData)
    message.payload.append(emergencyStop ? 0x01 : 0x00)
    message.payload.append(contentsOf: commandedSpeed.float16.v.bigEndianData)
    message.payload.append(contentsOf: [0xff, 0xff])
//  message.payload.append(contentsOf: [0x00, 0x00, 0x00])
    
    sendMessage(message: message)
    
  }

  public func sendQuerySpeedCommand(sourceNodeId:UInt64, destinationNodeId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.querySpeeds.rawValue
    ]
    
    sendMessage(message: message)
    
  }

  public func sendSetSpeedDirection(sourceNodeId:UInt64, destinationNodeId:UInt64, setSpeed:Float, isForwarded: Bool) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.setSpeedDirection.rawValue | (isForwarded ? 0x80 : 0x00)
    ]
    
    message.payload.append(contentsOf: setSpeed.float16.v.bigEndianData)

//  message.payload.append(contentsOf: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
    
    sendMessage(message: message)
    
  }

  public func sendSetMoveCommand(sourceNodeId:UInt64, destinationNodeId:UInt64, distance:Float, cruiseSpeed:Float, finalSpeed:Float) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.setMove.rawValue
    ]
    
    message.payload.append(contentsOf: cruiseSpeed.float16.v.bigEndianData)

    message.payload.append(contentsOf: finalSpeed.float16.v.bigEndianData)

    sendMessage(message: message)
    
  }

  public func sendStartMoveCommand(sourceNodeId:UInt64, destinationNodeId:UInt64, isStealAllowed:Bool, isPositionUpdateRequired:Bool) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.startMove.rawValue
    ]
    
    var options : UInt8 = 0
    
    options |= isStealAllowed ? 0b00000001 : 0
    options |= isPositionUpdateRequired ? 0b00000010 : 0

    if options != 0 {
      message.payload.append(options)
    }
    
    sendMessage(message: message)
    
  }

  public func sendStopMoveCommand(sourceNodeId:UInt64, destinationNodeId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.stopMove.rawValue
    ]
    
    sendMessage(message: message)
    
  }

  public func sendSetFunction(sourceNodeId:UInt64, destinationNodeId:UInt64, address:UInt32, value:UInt16, isForwarded: Bool) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.setFunction.rawValue | (isForwarded ? 0x80 : 0x00)
    ]
    
    var adr = address.bigEndianData
    adr.removeFirst()
    
    message.payload.append(contentsOf: adr)
    
    message.payload.append(contentsOf: value.bigEndianData)

//  message.payload.append(contentsOf: [0x00, 0x00, 0x00])
    
    sendMessage(message: message)
    
  }

  public func sendEmergencyStop(sourceNodeId:UInt64, destinationNodeId:UInt64, isForwarded: Bool) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.emergencyStop.rawValue | (isForwarded ? 0x80 : 0x00)
    ]
    
    sendMessage(message: message)
    
  }

  public func sendAttachListenerReply(sourceNodeId:UInt64, destinationNodeId:UInt64, listenerNodeId:UInt64, replyCode:OpenLCBErrorCode) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.listenerConfiguration.rawValue,
      OpenLCBTractionListenerConfigurationType.attachNode.rawValue,
    ]
    
    var ln = listenerNodeId.bigEndianData
    ln.removeFirst(2)
    
    message.payload.append(contentsOf: ln)
    
    message.payload.append(contentsOf: replyCode.rawValue.bigEndianData)
    
    sendMessage(message: message)
    
  }

  public func sendAttachListenerCommand(sourceNodeId:UInt64, destinationNodeId:UInt64, listenerNodeId:UInt64, flags:UInt8) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.listenerConfiguration.rawValue,
      OpenLCBTractionListenerConfigurationType.attachNode.rawValue,
      flags,
    ]
    
    var ln = listenerNodeId.bigEndianData
    ln.removeFirst(2)
    
    message.payload.append(contentsOf: ln)
    
    sendMessage(message: message)
    
  }

  public func sendDetachListenerCommand(sourceNodeId:UInt64, destinationNodeId:UInt64, listenerNodeId:UInt64, flags:UInt8) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.listenerConfiguration.rawValue,
      OpenLCBTractionListenerConfigurationType.detachNode.rawValue,
      flags,
    ]
    
    var ln = listenerNodeId.bigEndianData
    ln.removeFirst(2)
    
    message.payload.append(contentsOf: ln)
    
    sendMessage(message: message)
    
  }

  public func sendListenerQueryNodeReply(sourceNodeId:UInt64, destinationNodeId:UInt64, nodeCount:Int, nodeIndex:Int, flags:UInt8, listenerNodeId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    let nc = UInt8(min(0xff, nodeCount) & 0xff)
    
    message.payload = [
      OpenLCBTractionControlInstructionType.listenerConfiguration.rawValue,
      OpenLCBTractionListenerConfigurationType.queryNodes.rawValue,
      nc,
      UInt8(nodeIndex),
      flags
    ]
    
    var ln = listenerNodeId.bigEndianData
    ln.removeFirst(2)
    
    message.payload.append(contentsOf: ln)
    
    sendMessage(message: message)
    
  }

  public func sendListenerQueryNodeReplyShort(sourceNodeId:UInt64, destinationNodeId:UInt64, nodeCount:Int) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    let nc = UInt8(min(0xff, nodeCount) & 0xff)
    
    message.payload = [
      OpenLCBTractionControlInstructionType.listenerConfiguration.rawValue,
      OpenLCBTractionListenerConfigurationType.queryNodes.rawValue,
      nc,
    ]
    
    sendMessage(message: message)
    
  }
  
  public func sendHeartbeatRequest(sourceNodeId:UInt64, destinationNodeId:UInt64, timeout:UInt8) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlReply)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.tractionManagement.rawValue,
      OpenLCBTractionManagementType.noopOrHeartbeatRequest.rawValue,
      timeout
    ]
    
    sendMessage(message: message)
    
  }

  public func sendTractionManagementNoOp(sourceNodeId:UInt64, destinationNodeId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.tractionManagement.rawValue,
      OpenLCBTractionManagementType.noopOrHeartbeatRequest.rawValue,
    ]
    
    sendMessage(message: message)
    
  }

  public func sendEmergencyStop(sourceNodeId:UInt64, destinationNodeId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .tractionControlCommand)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId
    
    message.payload = [
      OpenLCBTractionControlInstructionType.emergencyStop.rawValue
    ]
    
    sendMessage(message: message)
    
  }


}
