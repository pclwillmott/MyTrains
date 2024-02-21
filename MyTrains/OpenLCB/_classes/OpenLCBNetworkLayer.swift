//
//  LCCNetworkLayer.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/04/2023.
//

import Foundation
import AppKit

public let networkLayerNodeId : UInt64 = 0xfdffffffffff

public class OpenLCBNetworkLayer : NSObject, MTPipeDelegate {
  
  // MARK: Constructors
  
  public init(appNodeId:UInt64?) {
 
    #if DEBUG
    debugLog(message: "init - \(Date.timeIntervalSinceReferenceDate)")
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
  
  private var rxPipe : MTPipe?
  
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
    
    rxPipe = MTPipe(name: "MyTrains Network Layer")
    rxPipe?.open(delegate: self)
    
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
//    sendGetUniqueNodeIdCommand(sourceNodeId: networkLayerNodeId, destinationNodeId: appNodeId!)
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

  public func sendMessage(message:OpenLCBMessage) {
    
    guard state == .initialized else {
      return
    }
    
    /*
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
    */
    
//    message.gatewayNodeId = gatewayNodeId
    
//    for (_, observer) in observers {
//      observer.OpenLCBMessageReceived(message: message)
//    }
    
    if let destinationNodeId = message.destinationNodeId {

      if let virtualNode = virtualNodeLookup[destinationNodeId] {
        virtualNode.openLCBMessageReceived(message: message)
      }
      else {
        for (_, virtualNode) in gatewayNodes {
          virtualNode.openLCBMessageReceived(message: message)
        }
      }
      
    }
    else {
      for virtualNode in virtualNodes {
        virtualNode.openLCBMessageReceived(message: message)
      }
    }
    
  }
  
  // MARK: MTPipeDelegate Methods
  
  public func pipe(_ pipe: MTPipe, message: OpenLCBMessage) {
    
    guard let appNodeId else {
      return
    }
    
    let postOfficeNodeId = appNodeId + 1
    
    guard !message.routing.contains(postOfficeNodeId) else {
      return
    }
    
    message.routing.insert(postOfficeNodeId)
    
    DispatchQueue.main.async {
      self.sendMessage(message: message)
    }
    
  }
  
}
