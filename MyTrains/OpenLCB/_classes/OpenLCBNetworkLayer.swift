//
//  LCCNetworkLayer.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/04/2023.
//

import Foundation
import AppKit

public class OpenLCBNetworkLayer : NSObject {
  
  // MARK: Constructors & Destructors
  
  deinit {
    removeAll()
  }
  
  // MARK: Private Properties
  
  private var nodeManagers : [OpenLCBNodeManager] = []
  
  private var throttleManager = OpenLCBNodeManager()
  
  private var locoNetMonitorManager = OpenLCBNodeManager()
  
  private var programmerToolManager = OpenLCBNodeManager()
  
  private var virtualNodes : [OpenLCBNodeVirtual] = []

  private var uninitializedGateways : [UInt64:OpenLCBNodeVirtual] = [:]

  private var uninitializedNodes : [UInt64:OpenLCBNodeVirtual] = [:]

  private var gatewayNodes : [UInt64:OpenLCBNodeVirtual] = [:]

  private var nodesSimpleSetSufficient : [UInt64:OpenLCBNodeVirtual] = [:]

  private var nodesFullProtocolRequired : [UInt64:OpenLCBNodeVirtual] = [:]
  
  private var nodesInhibited : [UInt64:OpenLCBNodeVirtual] = [:]

  internal var _state : OpenLCBNetworkLayerState = .uninitialized {
    didSet {
      appDelegate.networkLayerStateHasChanged(networkLayer: self)
    }
  }
  
  private var observers : [Int:OpenLCBNetworkObserverDelegate] = [:]
  
  private var nextObserverId : Int = 0
  
  private var monitorBuffer : [MonitorItem] = []
  
  private var monitorBufferLock = NSLock()
  
  private var monitorTimer : Timer?
  
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
  
  public var state : OpenLCBNetworkLayerState {
    return _state
  }
  
  public var appNode : OpenLCBNodeMyTrains?
  
  public var fastClock : OpenLCBClock?
  
  // MARK: Private Methods
  
  private func removeAll() {
    appNode = nil
    fastClock = nil
    observers.removeAll()
    monitorTimer?.invalidate()
    monitorBuffer.removeAll()
    nodeManagers.removeAll()
    throttleManager.removeAll()
    locoNetMonitorManager.removeAll()
    programmerToolManager.removeAll()
    configurationToolManager.removeAll()
    virtualNodes.removeAll()
    virtualNodeLookup.removeAll()
    nodesSimpleSetSufficient.removeAll()
    nodesSimpleSetSufficient.removeAll()
    nodesInhibited.removeAll()
    gatewayNodes.removeAll()
    uninitializedGateways.removeAll()
    uninitializedNodes.removeAll()
    _state = .uninitialized
  }
  
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
    return virtualNodeLookup.keys.contains(nodeId)
  }
  
  public func createAppNode(newNodeId:UInt64) {

    appNodeId = newNodeId

    appMode = .master
    
    let node = OpenLCBNodeMyTrains(nodeId: newNodeId)

    start()

    node.hostAppNodeId = newNodeId

    registerNode(node: node)

//    createVirtualNode(virtualNodeType: .throttleNode, completion: dummyCompletion(node:))

//    createVirtualNode(virtualNodeType: .configurationToolNode, completion: dummyCompletion(node:))

//    createVirtualNode(virtualNodeType: .clockNode, completion: dummyCompletion(node:))

  }
  
  public func start() {
    
    removeAll()
    
    nodeManagers.append(configurationToolManager)
    nodeManagers.append(throttleManager)
    nodeManagers.append(locoNetMonitorManager)
    nodeManagers.append(programmerToolManager)
    
    virtualNodes = OpenLCBMemorySpace.getVirtualNodes()
    
    for node in virtualNodes {
      virtualNodeLookup[node.nodeId] = node
      node.networkLayer = self
      if node.isGatewayNode {
        uninitializedGateways[node.nodeId] = node
      }
      else {
        uninitializedNodes[node.nodeId] = node
      }
    }
    
    startNodes()
    
  }
  
  public func nodeInitializationComplete(node:OpenLCBNodeVirtual) {

    uninitializedGateways.removeValue(forKey: node.nodeId)
    uninitializedNodes.removeValue(forKey: node.nodeId)
    
    if node.state == .inhibited {
      nodesInhibited[node.nodeId] = node
    }
    else if node.isGatewayNode {
      gatewayNodes[node.nodeId] = node
    }
    else {
      
      switch node.virtualNodeType {
      case .applicationNode:
        appNode = node as? OpenLCBNodeMyTrains
      case .clockNode:
        fastClock = node as? OpenLCBClock
      case .configurationToolNode:
        configurationToolManager.addNode(node: node)
      case .locoNetMonitorNode:
        locoNetMonitorManager.addNode(node: node)
      case .programmerToolNode:
        programmerToolManager.addNode(node: node)
      case .throttleNode:
        throttleManager.addNode(node: node)
      default:
        break
      }

      if node.isFullProtocolRequired {
        nodesFullProtocolRequired[node.nodeId] = node
      }
      else {
        nodesSimpleSetSufficient[node.nodeId] = node
      }
      
    }
    
    startNodes()
    
  }
  
  private func startNodes() {
    
    if state == .uninitialized && !uninitializedGateways.isEmpty {
      _state = .initializingGateways
      for (_, node) in uninitializedGateways {
        node.gatewayStart()
      }
    }
    else if state != .initializingGateways && state != .initializingNodes && !uninitializedNodes.isEmpty {
      _state = .initializingNodes
      for (_, node) in uninitializedNodes {
        node.start()
      }
    }
    else if let appNode {
      _state = gatewayNodes.isEmpty ? .runningLocal : .runningNetwork
    }
    
  }
  
  public func stop() {
    
    guard state == .runningLocal || state == .runningNetwork else {
      return
    }
    
    for (_, node) in nodesSimpleSetSufficient {
      deregisterNode(node: node)
    }
    for (_, node) in nodesFullProtocolRequired {
      deregisterNode(node: node)
    }
    for (_, node) in gatewayNodes {
      deregisterNode(node: node)
    }

    _state = .stopped
    
  }
  
  public func addObserver(observer:OpenLCBNetworkObserverDelegate) -> Int {
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
    node.networkLayer = self
    
    if node.virtualNodeType == .canGatewayNode {
      uninitializedGateways[node.nodeId] = node
    }
    else {
      uninitializedNodes[node.nodeId] = node
    }
    
    startNodes()
    
  }
  
  public func nodeDidStop(node:OpenLCBNodeVirtual) {

    for nodeManager in nodeManagers {
      nodeManager.removeNode(node: node)
    }
    
    virtualNodeLookup.removeValue(forKey: node.nodeId)
    gatewayNodes.removeValue(forKey: node.nodeId)
    nodesSimpleSetSufficient.removeValue(forKey: node.nodeId)
    nodesFullProtocolRequired.removeValue(forKey: node.nodeId)

    for index in 0 ... virtualNodes.count - 1 {
      if virtualNodes[index].nodeId == node.nodeId {
        virtualNodes.remove(at: index)
        break
      }
    }
    
  }
  
  public func deregisterNode(node:OpenLCBNodeVirtual) {
    node.stop()
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
    
    guard let appNode else {
      return
    }
    
    newNodeQueue.append((virtualNodeType, completion))
    appNode.getUniqueNodeId()
    
  }
  
  public func createGatewayNode() {
    
    guard let appNode else {
      return
    }
    
    if let newNodeId = appNode.nextGatewayNodeId {
      
      let node = OpenLCBCANGateway(nodeId: newNodeId)
      
      node.hostAppNodeId = appNode.nodeId
      
      registerNode(node: node)

      if node.isConfigurationDescriptionInformationProtocolSupported {
        let vc = MyTrainsWindow.configurationTool.viewController as! ConfigurationToolVC
        vc.configurationTool = getConfigurationTool()
        vc.configurationTool?.delegate = vc
        vc.node = node
        vc.showWindow()
      }

    }
    else {
      
      let alert = NSAlert()
      
      alert.messageText = String(localized: "No available gateway node IDs")
      alert.informativeText = "Your application has run out of gateway node IDs. Increase the maximum number of gateways in the application node using the configuration tool."
      alert.addButton(withTitle: "OK")
      alert.alertStyle = .informational
      
      alert.runModal()

    }

  }
  
  public func createVirtualNode(newNodeId:UInt64) {
    
    guard !newNodeQueue.isEmpty else {
      return
    }
    
    let item = newNodeQueue.removeFirst()
    
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
      break
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

  // This is running in the main thread
  
  public func sendMessage(message:OpenLCBMessage) {
    
    guard let appNodeId else {
      return
    }
    
    let postOfficeNodeId = appNodeId + 1
    
    guard !message.routing.contains(postOfficeNodeId) else {
      return
    }
    
    message.routing.insert(postOfficeNodeId)
    
    let monitorItem = MonitorItem()
    monitorItem.message = message
    addToMonitorBuffer(item: monitorItem, isBackgroundThread: false)

    if let destinationNodeId = message.destinationNodeId {

      if let virtualNode = virtualNodeLookup[destinationNodeId] {
        if !message.routing.contains(virtualNode.nodeId) {
          virtualNode.openLCBMessageReceived(message: message)
        }
      }
      else if message.visibility.rawValue > OpenLCBNodeVisibility.visibilityPrivate.rawValue {
        for (_, virtualNode) in gatewayNodes {
          if !message.routing.contains(virtualNode.nodeId) {
            virtualNode.openLCBMessageReceived(message: message)
          }
        }
      }
      
    }
    else {
      if message.messageTypeIndicator.isSimpleProtocol {
        for (_, virtualNode) in nodesSimpleSetSufficient {
          if !message.routing.contains(virtualNode.nodeId) {
            virtualNode.openLCBMessageReceived(message: message)
          }
        }
      }
      for (_, virtualNode) in nodesFullProtocolRequired {
        if !message.routing.contains(virtualNode.nodeId) {
          virtualNode.openLCBMessageReceived(message: message)
        }
      }
      for (_, virtualNode) in gatewayNodes {
        if !message.routing.contains(virtualNode.nodeId) {
          virtualNode.openLCBMessageReceived(message: message)
        }
      }
    }
    
  }
  
  // This is running in a background thread
  
  public func canFrameReceived(gateway:OpenLCBCANGateway, frame:LCCCANFrame) {
    let monitorItem = MonitorItem()
    monitorItem.frame = frame
    monitorItem.direction = .received
    addToMonitorBuffer(item: monitorItem, isBackgroundThread: true)
  }
  
  public func canFrameSent(gateway:OpenLCBCANGateway, frame:LCCCANFrame, isBackgroundThread:Bool) {
    let monitorItem = MonitorItem()
    monitorItem.frame = frame
    monitorItem.direction = .sent
    addToMonitorBuffer(item: monitorItem, isBackgroundThread: isBackgroundThread)
  }
  
  public func clearMonitorBuffer() {
    monitorBufferLock.lock()
    monitorBuffer.removeAll()
    monitorBufferLock.unlock()
    startMonitorTimer()
  }
  
  public func addToMonitorBuffer(item:MonitorItem, isBackgroundThread:Bool) {
    
    monitorBufferLock.lock()
    monitorBuffer.append(item)
    monitorBufferLock.unlock()
    
    if isBackgroundThread {
      DispatchQueue.main.async {
        self.startMonitorTimer()
      }
    }
    else {
      startMonitorTimer()
    }
  }
  
  internal func startMonitorTimer() {
    
    guard monitorTimer == nil else {
      return
    }
    
    monitorTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(monitorTimerTick), userInfo: nil, repeats: false)
    
    RunLoop.current.add(monitorTimer!, forMode: .common)
    
  }
  
  public var isMonitorPaused = false {
    didSet {
      startMonitorTimer()
    }
  }
  
  // This is running in the main thread
  
  @objc func monitorTimerTick() {
    
    monitorBufferLock.lock()
    monitorBuffer.removeFirst(max(0, monitorBuffer.count - 10000))
    monitorBufferLock.unlock()
    
    if !isMonitorPaused && !observers.isEmpty {
      
      var text = ""
      for item in monitorBuffer {
        text += "\(item.info)\n"
      }
      
      for (_, observer) in self.observers {
        observer.updateMonitor?(text: text)
      }

    }
    
    monitorTimer = nil
    
  }

}
