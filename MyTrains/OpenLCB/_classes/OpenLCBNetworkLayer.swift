//
//  LCCNetworkLayer.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/04/2023.
//

import Foundation
import AppKit

public let networkLayerNodeId : UInt64 = 0xfdffffffffff

public class OpenLCBNetworkLayer : NSObject {
  
  // MARK: Constructors
  
  public init(appNodeId:UInt64?) {
 
#if DEBUG
    print("OpenLCBNetworkLayer: init - \(Date.timeIntervalSinceReferenceDate)")
#endif

    super.init()

  }
  
  // MARK: Private Properties
  
  internal var _state : OpenLCBNetworkLayerState = .uninitialized
  
  private var virtualNodes : [OpenLCBNodeVirtual] = []

  private var gatewayNodes : [UInt64:OpenLCBNodeVirtual] = [:]

  private var regularNodes : [UInt64:OpenLCBNodeVirtual] = [:]

  private var nodeManagers : [OpenLCBNodeManager] = []
  
  private var throttleManager = OpenLCBNodeManager()
  
  private var locoNetMonitorManager = OpenLCBNodeManager()
  
  private var programmerToolManager = OpenLCBNodeManager()
  
  private var observers : [Int:OpenLCBCANDelegate] = [:]
  
  private var nextObserverId : Int = 1
  
  // MARK: Public Properties

  public var configurationToolManager = OpenLCBNodeManager()
  
  public var virtualNodeLookup : [UInt64:OpenLCBNodeVirtual] = [:]
  
  public var layoutNodeId : UInt64? {
    get {
      return appLayoutId
    }
    set(id) {
      if id != layoutNodeId {
        appLayoutId = id
        if let id {
          appMode = isInternalVirtualNode(nodeId: id) ? .master : .delegate
        }
        else {
          appMode = .master
        }
        updateVirtualNodeList()
      }
    }
  }
  
  public var defaultCANGateway : OpenLCBCANGateway? {
  
    for node in virtualNodes {
      if node.virtualNodeType == .canGatewayNode {
        return node as? OpenLCBCANGateway
      }
    }
    
    return nil
    
  }
  
  public var state : OpenLCBNetworkLayerState {
    return _state
  }
  
  public var myTrainsNode : OpenLCBNodeMyTrains?
  
  public var fastClock : OpenLCBClock?
  
  // MARK: Private Methods
  
  private func updateVirtualNodeList() {
    
    let list = virtualNodes
    
    for node in list {
      switch node.virtualNodeType {
      case .layoutNode:
        (node as? LayoutNode)?.layoutState = node.nodeId == layoutNodeId ? .activated : .deactivated
      case .switchboardItemNode:
        deregisterNode(node: node)
      default:
        break
      }
    }
    
    if let layoutNodeId {
      
      switch appMode {
        
      case .master:
        for node in OpenLCBMemorySpace.getVirtualNodes() {
          if node.virtualNodeType == .switchboardItemNode && node.layoutNodeId == layoutNodeId {
            registerNode(node: node)
          }
        }
        
      case .delegate:
        break // MARK: TODO Add the delegate switchboard items
        
      default:
        break
      }
      
    }
    
  }
  
  // MARK: Public Methods
  
  public func isInternalVirtualNode(nodeId:UInt64) -> Bool {
    return virtualNodeLookup[nodeId] != nil
  }
  
  public func createAppNode(newNodeId:UInt64) {

    appNodeId = newNodeId

    appMode = .master
    
    let node = OpenLCBNodeMyTrains(nodeId: newNodeId)

    start()

    node.hostAppNodeId = newNodeId

    registerNode(node: node)

    createVirtualNode(virtualNodeType: .throttleNode, completion: dummyCompletion(node:))

    createVirtualNode(virtualNodeType: .configurationToolNode, completion: dummyCompletion(node:))

    createVirtualNode(virtualNodeType: .clockNode, completion: dummyCompletion(node:))

  }
  
  public func initialStart() {
    
    nodeManagers.append(throttleManager)
    nodeManagers.append(locoNetMonitorManager)
    nodeManagers.append(programmerToolManager)
    nodeManagers.append(configurationToolManager)

    if appNodeId != nil {
      start()
    }
    
  }
  
  public func start() {
    
    guard state == .uninitialized else {
      return
    }
    
    _state = .initialized
    
    for node in OpenLCBMemorySpace.getVirtualNodes() {
      registerNode(node: node)
    }

    updateVirtualNodeList()
    
  }
  
  public func stop() {
    
    guard state == .initialized else {
      return
    }
    
    for node in virtualNodes {
      deregisterNode(node: node)
    }
    
    _state = .uninitialized
    
    menuUpdate()
    
  }
  
  public func addObserver(observer:OpenLCBCANDelegate) -> Int {
    let id = nextObserverId
    nextObserverId += 1
    observers[id] = observer
    return id
  }
  
  public func removeObserver(id:Int) {
    observers.removeValue(forKey: id)
  }
  
  public func removeAlias(nodeId:UInt64) {
/*    for (_, layer) in transportLayers {
      layer.removeAlias(nodeId: nodeId)
    } */
  }

  public func registerNode(node:OpenLCBNodeVirtual) {
    
    virtualNodes.append(node)
    
    virtualNodeLookup[node.nodeId] = node
    
    virtualNodes.sort {$0.virtualNodeType.startupOrder > $1.virtualNodeType.startupOrder}
    
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
    case .layoutNode:
      break
    case .switchboardPanelNode:
      break
    case .switchboardItemNode:
      break
    }
    
    if node.virtualNodeType == .canGatewayNode {
      gatewayNodes[node.nodeId] = node
    }
    else {
      regularNodes[node.nodeId] = node
    }
    
    node.start()
    
  }
  
  public func deregisterNode(node:OpenLCBNodeVirtual) {
    
    for nodeManager in nodeManagers {
      nodeManager.removeNode(node: node)
    }
    
    node.stop()
    node.networkLayer = nil

    virtualNodeLookup.removeValue(forKey: node.nodeId)
        
    for index in 0 ... virtualNodes.count - 1 {
      if virtualNodes[index].nodeId == node.nodeId {
        virtualNodes.remove(at: index)
        break
      }
    }
    
  }
  
  public func deleteNode(nodeId:UInt64) {
    if let virtualNode = virtualNodeLookup[nodeId] {
      virtualNode.willDelete()
      deregisterNode(node: virtualNode)
      OpenLCBMemorySpace.deleteAllMemorySpaces(forNodeId: nodeId)
    }
  }
  
  public func getThrottle() -> OpenLCBThrottle? {
    
    let result = throttleManager.getNode() as? OpenLCBThrottle
    
    if throttleManager.numberOfFreeNodes == 0 {
      createVirtualNode(virtualNodeType: .throttleNode, completion: dummyCompletion(node:))
    }
    
    return result
    
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
  
  private func dummyCompletion(node:OpenLCBNodeVirtual) {
  }
  
  public func getConfigurationTool(exclusive:Bool = false) -> OpenLCBNodeConfigurationTool? {
    
    if let result = configurationToolManager.getNode(exclusive: exclusive) as? OpenLCBNodeConfigurationTool {
      
      if configurationToolManager.numberOfFreeNodes == 0 {
        createVirtualNode(virtualNodeType: .configurationToolNode, completion: dummyCompletion(node:))
      }
      
      return result
      
    }
    
    return nil
    
  }
  
  public func releaseConfigurationTool(configurationTool:OpenLCBNodeConfigurationTool) {
    configurationToolManager.releaseNode(node: configurationTool)
  }
  
  public var newNodeQueue : [(virtualNodeType:MyTrainsVirtualNodeType, completion:(OpenLCBNodeVirtual) -> Void)] = []
  
  public func createVirtualNode(virtualNodeType:MyTrainsVirtualNodeType, completion: @escaping (OpenLCBNodeVirtual) -> Void) {
    newNodeQueue.append((virtualNodeType, completion))
    sendGetUniqueNodeIdCommand(sourceNodeId: networkLayerNodeId, destinationNodeId: appNodeId!)
  }
  
  public func createVirtualNode(message:OpenLCBMessage) {
    
    guard !newNodeQueue.isEmpty else {
      return
    }
    
    let item = newNodeQueue.removeFirst()
    
    let newNodeId = UInt64(bigEndianData: message.payload)! & 0x0000ffffffffffff
    
    var node : OpenLCBNodeVirtual?
    
    switch item.virtualNodeType {
    case .clockNode:
      node = OpenLCBClock(nodeId: newNodeId)
    case .throttleNode:
      node = OpenLCBThrottle(nodeId: newNodeId)
    case .locoNetGatewayNode:
      node = OpenLCBLocoNetGateway(nodeId: newNodeId)
    case .trainNode:
      node = OpenLCBNodeRollingStockLocoNet(nodeId: newNodeId)
    case .canGatewayNode:
      node = OpenLCBCANGateway(nodeId: newNodeId)
    case .applicationNode:
      node = OpenLCBNodeMyTrains(nodeId: newNodeId)
    case .configurationToolNode:
      node = OpenLCBNodeConfigurationTool(nodeId: newNodeId)
    case .locoNetMonitorNode:
      node = OpenLCBLocoNetMonitorNode(nodeId: newNodeId)
    case .programmerToolNode:
      node = OpenLCBProgrammerToolNode(nodeId: newNodeId)
    case .programmingTrackNode:
      node = OpenLCBProgrammingTrackNode(nodeId: newNodeId)
    case .genericVirtualNode:
      break
    case .digitraxBXP88Node:
      node = OpenLCBDigitraxBXP88Node(nodeId: newNodeId)
    case .layoutNode:
      node = LayoutNode(nodeId: newNodeId)
    case .switchboardPanelNode:
      if let layoutNodeId {
        node = SwitchboardPanelNode(nodeId: newNodeId, layoutNodeId: layoutNodeId)
      }
    case .switchboardItemNode:
      if let layoutNodeId {
        node = SwitchboardItemNode(nodeId: newNodeId, layoutNodeId: layoutNodeId)
      }
      node?.layoutNodeId = layoutNodeId!
    }

    if let node {
      node.hostAppNodeId = appNodeId!
      registerNode(node: node)
      item.completion(node)
    }

  }
  
  // MARK: Messages

  public func sendMessage(gatewayNodeId:UInt64, message:OpenLCBMessage) {
    
    guard state == .initialized else {
      return
    }
    
    if let destinationNodeId = message.destinationNodeId, destinationNodeId == networkLayerNodeId {
      
      switch message.messageTypeIndicator {
      case .datagram:
        switch message.datagramType {
        case .getUniqueNodeIDReply:
          createVirtualNode(message: message)
          return
        default:
          break
        }
      default:
        break
      }
      
    }
    
    message.gatewayNodeId = gatewayNodeId
    
    for (_, observer) in observers {
      observer.OpenLCBMessageReceived(message: message)
    }
    
    if let sourceNodeId = message.sourceNodeId, let sourceNode = virtualNodeLookup[sourceNodeId] {
      
      if let destinationNodeId = message.destinationNodeId {
        if let virtualNode = regularNodes[destinationNodeId] {
          virtualNode.openLCBMessageReceived(message: message)
        }
        else if sourceNode.visibility == .visibilityPublic {
          for (virtualNodeId, virtualNode) in gatewayNodes {
            if virtualNodeId != message.gatewayNodeId {
              virtualNode.openLCBMessageReceived(message: message)
            }
          }
        }
      }
      else {
        for (virtualNodeId, virtualNode) in regularNodes {
          if virtualNode.nodeId != message.gatewayNodeId {
            virtualNode.openLCBMessageReceived(message: message)
          }
        }
        if sourceNode.visibility == .visibilityPublic {
          for (virtualNodeId, virtualNode) in gatewayNodes {
            if virtualNodeId != message.gatewayNodeId {
              virtualNode.openLCBMessageReceived(message: message)
            }
          }
        }
      }

    }
    else {
      
      if let destinationNodeId = message.destinationNodeId {
        if let virtualNode = regularNodes[destinationNodeId] {
          virtualNode.openLCBMessageReceived(message: message)
        }
        else {
          for (virtualNodeId, virtualNode) in gatewayNodes {
            if virtualNodeId != message.gatewayNodeId {
              virtualNode.openLCBMessageReceived(message: message)
            }
          }
        }
      }
      else {
        for (virtualNodeId, virtualNode) in regularNodes {
          if virtualNode.nodeId != message.gatewayNodeId {
            virtualNode.openLCBMessageReceived(message: message)
          }
        }
        for (virtualNodeId, virtualNode) in gatewayNodes {
          if virtualNodeId != message.gatewayNodeId {
            virtualNode.openLCBMessageReceived(message: message)
          }
        }
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

  public func sendLocoNetMessageReceived(sourceNode:OpenLCBNodeVirtual, locoNetMessage:[UInt8]) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .producerConsumerEventReport)
    
    message.sourceNodeId = sourceNode.nodeId
    
    var data = [UInt8](OpenLCBWellKnownEvent.locoNetMessage.rawValue.bigEndianData.prefix(2))
    
    data.append(contentsOf: locoNetMessage)
    
    var numberOfPaddingBytes = 8 - data.count
    
    while numberOfPaddingBytes > 0 {
      data.append(0xff)
      numberOfPaddingBytes -= 1
    }
    
    let eventId = UInt64(bigEndianData: [UInt8](data.prefix(8)))!
    
    data.removeFirst(8)
    
    sendEvent(sourceNode: sourceNode, eventId: eventId, payload: data)
    
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
  
  public func sendLocationServiceEvent(sourceNode:OpenLCBNodeVirtual, eventId:UInt64, trainNodeId:UInt64, entryExit:OpenLCBLocationServiceFlagEntryExit, motionRelative:OpenLCBLocationServiceFlagDirectionRelative, motionAbsolute:OpenLCBLocationServiceFlagDirectionAbsolute, contentFormat:OpenLCBLocationServiceFlagContentFormat, content: [OpenLCBLocationServicesContentBlock]? ) {
    
    var payload : [UInt8] = []
    
    var flags : UInt16 = 0
    
    flags |= entryExit.rawValue
    
    flags |= motionRelative.rawValue
    
    flags |= motionAbsolute.rawValue
    
    flags |= contentFormat.rawValue
    
    payload.append(contentsOf: flags.bigEndianData)

    payload.append(contentsOf: trainNodeId.bigEndianData.suffix(6))
    
    if contentFormat == .standardContentForm, let content {
      
      payload.append(UInt8(1 + content.count))
      
      for block in content {
        payload.append(UInt8(block.content.count + 1))
        payload.append(block.blockType.rawValue)
        payload.append(contentsOf: block.content)
      }
      
    }
    
    sendEvent(sourceNode: sourceNode, eventId: eventId, payload: payload)
    
  }

  public func sendEvent(sourceNode:OpenLCBNodeVirtual, eventId:UInt64, payload:[UInt8] = []) {
    
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
    
    let message = OpenLCBMessage(messageTypeIndicator: .producerConsumerEventReport)
    message.sourceNodeId = sourceNode.nodeId
    message.eventId = eventId
    message.payload = payload
    sendMessage(message: message)
    
  }

  public func sendWellKnownEvent(sourceNode:OpenLCBNodeVirtual, eventId:OpenLCBWellKnownEvent, payload:[UInt8] = []) {
    sendEvent(sourceNode: sourceNode, eventId: eventId.rawValue, payload: payload)
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
  
  public func sendVerifyNodeIdNumberAddressed(sourceNodeId:UInt64, destinationNodeId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDAddressed)

    message.sourceNodeId = sourceNodeId
    
    message.destinationNodeId = destinationNodeId

    var data = destinationNodeId.bigEndianData
    data.removeFirst(2)

    message.payload = data

    sendMessage(message: message)
    
  }

  public func sendVerifyNodeIdNumber(sourceNodeId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDGlobal)

    message.sourceNodeId = sourceNodeId
    
    sendMessage(message: message)
    
  }

  public func sendVerifyNodeIdNumber(sourceNodeId:UInt64, destinationNodeId:UInt64) {
    
    let message = OpenLCBMessage(messageTypeIndicator: .verifyNodeIDGlobal)

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

  public func sendFreezeCommand(sourceNodeId:UInt64, destinationNodeId:UInt64) {
    
    var payload : [UInt8] = []

    payload.append(contentsOf: OpenLCBDatagramType.freezeCommand.rawValue.bigEndianData)
    
    payload.append(OpenLCBNodeMemoryAddressSpace.firmware.rawValue)
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: payload)

  }
  
  public func sendUnfreezeCommand(sourceNodeId:UInt64, destinationNodeId:UInt64) {
    
    var payload : [UInt8] = []

    payload.append(contentsOf: OpenLCBDatagramType.unfreezeCommand.rawValue.bigEndianData)
    
    payload.append(OpenLCBNodeMemoryAddressSpace.firmware.rawValue)
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: payload)

  }
  
  public func sendUpdateCompleteCommand(sourceNodeId:UInt64, destinationNodeId:UInt64) {
    
    var payload : [UInt8] = []

    payload.append(contentsOf: OpenLCBDatagramType.updateCompleteCommand.rawValue.bigEndianData)
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: payload)

  }
  
  public func sendGetUniqueNodeIdCommand(sourceNodeId:UInt64, destinationNodeId:UInt64) {
    
    var payload : [UInt8] = []

    payload.append(contentsOf: OpenLCBDatagramType.getUniqueNodeIDCommand.rawValue.bigEndianData)
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: payload)

  }
  
  public func sendGetUniqueNodeIdReply(sourceNodeId:UInt64, destinationNodeId:UInt64, newNodeId:UInt64) {
    
    var payload : [UInt8] = []
    
    payload.append(contentsOf: OpenLCBDatagramType.getUniqueNodeIDReply.rawValue.bigEndianData)
    
    var id = newNodeId.bigEndianData
    id.removeFirst(2)
    
    payload.append(contentsOf: id)

    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: payload)

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
      #if DEBUG
      print("sendNodeMemoryReadRequest: invalid number of bytes to read - \(numberOfBytesToRead)")
      #endif
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

  public func sendGetUniqueEventIdCommand(sourceNodeId:UInt64, destinationNodeId:UInt64, numberOfEventIds:UInt8) {
    
    guard numberOfEventIds >= 0 && numberOfEventIds < 8 else {
      #if DEBUG
      print("sendGetUniqueEventIdCommand: invalid number of event ids to get - \(numberOfEventIds)")
      #endif
      return
    }
    
    var data = OpenLCBDatagramType.getUniqueEventIDCommand.bigEndianData
    
    data.append(numberOfEventIds & 0x07)
        
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data)
    
  }

  public func sendNodeMemoryWriteRequest(sourceNodeId:UInt64, destinationNodeId:UInt64, addressSpace:UInt8, startAddress:Int, dataToWrite: [UInt8]) {
    
    guard dataToWrite.count > 0 && dataToWrite.count <= 64 else {
      #if DEBUG
      print("sendNodeMemoryWriteRequest: invalid number of bytes to write - \(dataToWrite.count)")
      #endif
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

    var data = node.configurationOptions.encodedOptions
    
    if node.isSwitchboardNode && !isInternalVirtualNode(nodeId: destinationNodeId) && OpenLCBNodeMemoryAddressSpace.cdi.rawValue == data[5] {
      data[5] = OpenLCBNodeMemoryAddressSpace.acdiManufacturer.rawValue
    }
    
    sendDatagram(sourceNodeId: sourceNodeId, destinationNodeId: destinationNodeId, data: data )
    
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
