//
//  LCCNetworkLayer.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/04/2023.
//

import Foundation
import AppKit

public class OpenLCBNetworkLayer : NSObject, MTSerialPortManagerDelegate {
  
  // MARK: Constructors & Destructors
  
  public override init() {
    super.init()
    addInit()
  }
  
  deinit {
    removeAll()
    addDeinit()
    showInstances()
    exit(0)
  }
  
  // MARK: Private Properties
  
  private var nodeManagers : [OpenLCBNodeManager] = []
  
  private var throttleManager : OpenLCBNodeManager? = OpenLCBNodeManager()
  
  private var locoNetMonitorManager : OpenLCBNodeManager? = OpenLCBNodeManager()
  
  private var programmerToolManager : OpenLCBNodeManager? = OpenLCBNodeManager()
  
  private var initializationLevel = 0
  
  private var isCreatingANode = false
  
  private var isDeletingANode = false
  
  private var startupGroup : [Int:StartupGroup] = [:]
  
  public var gatewayNodes : [UInt64:OpenLCBNodeVirtual] = [:]

  private var nodesSimpleSetSufficient : [UInt64:OpenLCBNodeVirtual] = [:]

  private var nodesFullProtocolRequired : [UInt64:OpenLCBNodeVirtual] = [:]
  
  private var nodesInhibited : [UInt64:OpenLCBNodeVirtual] = [:]

  internal var _state : OpenLCBNetworkLayerState = .uninitialized
  
  private var observers : [Int:OpenLCBNetworkObserverDelegate] = [:]
  
  private var nextObserverId : Int = 0
  
  private var monitorBuffer : [MonitorItem] = []
  
  private var monitorBufferLock = NSLock()
  
  private var monitorTimer : Timer?
  
  private var serialPortManagerObserverId : Int = -1
  
  // MARK: Public Properties

  public var configurationToolManager : OpenLCBConfigurationToolManager? = OpenLCBConfigurationToolManager()
  
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
  //      updateVirtualNodeList()
      }
    }
  }
  
  public var state : OpenLCBNetworkLayerState {
    get {
      return _state
    }
    set(value) {
      if value != _state {
        _state = value
        appDelegate.networkLayerStateHasChanged(networkLayer: self)
      }
    }
  }
  
  public weak var appNode : OpenLCBNodeMyTrains?
  
  public weak var fastClock : OpenLCBClock?
  
  public var numberOfGatewayNodes : Int = 0
  
  // MARK: Private Methods
  
  private func removeAll() {
    for (_, group) in startupGroup {
      group.removeAll()
    }
    startupGroup.removeAll()
    virtualNodeLookup.removeAll()
    nodesSimpleSetSufficient.removeAll()
    nodesSimpleSetSufficient.removeAll()
    nodesInhibited.removeAll()
    gatewayNodes.removeAll()
    appNode = nil
    fastClock = nil
    observers.removeAll()
    monitorTimer?.invalidate()
    monitorBuffer.removeAll()
    nodeManagers.removeAll()
    throttleManager?.removeAll()
    throttleManager = nil
    locoNetMonitorManager?.removeAll()
    locoNetMonitorManager = nil
    programmerToolManager?.removeAll()
    programmerToolManager = nil
    configurationToolManager?.removeAll()
    configurationToolManager = nil
    initializationLevel = 0
    state = .uninitialized
  }
  
  /*
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
  */
  
  // MARK: Public Methods
  
  public func isInternalVirtualNode(nodeId:UInt64) -> Bool {
    return virtualNodeLookup.keys.contains(nodeId)
  }
  
  public func createAppNode(newNodeId:UInt64) {

    appMode = .master
    let node = OpenLCBNodeMyTrains(nodeId: newNodeId)
    node.hostAppNodeId = newNodeId
    
    appDelegate.createAppNodeComplete()

  }
  
  public func start() {
    
    serialPortManagerObserverId = MTSerialPortManager.addObserver(observer: self)
    
    initializationLevel = 0
    
    state = .uninitialized

    if startupGroup.isEmpty {
      
      nodeManagers.append(configurationToolManager!)
      nodeManagers.append(throttleManager!)
      nodeManagers.append(locoNetMonitorManager!)
      nodeManagers.append(programmerToolManager!)
      
      for group in 0 ... MyTrainsVirtualNodeType.numberOfStartupGroups + 1 {
        startupGroup[group] = StartupGroup()
      }
      
      for node in OpenLCBMemorySpace.getVirtualNodes() {
        if let group = startupGroup[node.virtualNodeType.startupGroup] {
          group.add(node)
        }
      }
      
    }
    
    numberOfGatewayNodes = 0
    
    state = .initializing
    
    startNodes()
    
  }
  
  public func stop() {
    stopNodes()
  }
  
  private func startNodes() {
    
    guard state != .runningLocal && state != .runningNetwork else {
      return
    }

    while initializationLevel <= MyTrainsVirtualNodeType.numberOfStartupGroups, let group = startupGroup[initializationLevel] {
      
      if !group.uninitializedIsEmpty {
        break
      }
      
      initializationLevel += 1

      if let group = startupGroup[initializationLevel], !group.uninitializedIsEmpty {
        for node in group.uninitializedNodes {
          virtualNodeLookup[node.nodeId] = node
          node.start()
        }
        return
      }

    }
    
    if initializationLevel > MyTrainsVirtualNodeType.numberOfStartupGroups {
      if let appNode {
        state = gatewayNodes.isEmpty ? .runningLocal : .runningNetwork
        appNode.updateNodeIdCache()
      }
      else {
        initializationLevel = 0
        state = .uninitialized
      }
    }
    
  }
  
  public func stopNodes() {
    
    guard state == .runningLocal || state == .runningNetwork else {
      return
    }

    while initializationLevel > 0, let group = startupGroup[initializationLevel] {
      
      if !group.initializedIsEmpty {
        break
      }
      
      initializationLevel -= 1
      
      if let group = startupGroup[initializationLevel], !group.initializedIsEmpty {
        for node in group.initializedNodes {
          node.stop()
        }
        return
      }

    }
    
    if initializationLevel == 0 {
      MTSerialPortManager.removeObserver(observerId: serialPortManagerObserverId)
      serialPortManagerObserverId = -1
      for (_, group) in startupGroup {
        group.delete(type: .configurationToolNode)
        group.delete(type: .throttleNode)
        group.delete(type: .programmerToolNode)
        group.delete(type: .locoNetMonitorNode)
      }
      state = .stopped
      appNode = nil
      fastClock = nil
    }
    
  }

  public func nodeDidStart(node:OpenLCBNodeVirtual) {
    if !isCreatingANode {
      startNodes()
    }
    isCreatingANode = false
  }

  public func nodeDidInitialize(node:OpenLCBNodeVirtual) {

    startupGroup[node.virtualNodeType.startupGroup]?.initialize(node)
    
    if node.state == .inhibited {
      nodesInhibited[node.nodeId] = node
      appDelegate.refreshRequired()
    }
    else if node.isGatewayNode {
      gatewayNodes[node.nodeId] = node
      (node as? OpenLCBCANGateway)?.gatewayNumber = numberOfGatewayNodes
      numberOfGatewayNodes += 1
    }
    else {
      
      switch node.virtualNodeType {
      case .applicationNode:
        appNode = node as? OpenLCBNodeMyTrains
      case .clockNode:
        fastClock = node as? OpenLCBClock
      case .configurationToolNode:
        configurationToolManager?.addNode(node: node)
      case .locoNetMonitorNode:
        locoNetMonitorManager?.addNode(node: node)
      case .programmerToolNode:
        programmerToolManager?.addNode(node: node)
      case .throttleNode:
        throttleManager?.addNode(node: node)
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
    
  }
  
  public func nodeDidStop(node:OpenLCBNodeVirtual) {

    for nodeManager in nodeManagers {
      nodeManager.removeNode(node: node)
    }
    
    virtualNodeLookup.removeValue(forKey: node.nodeId)
    gatewayNodes.removeValue(forKey: node.nodeId)
    nodesSimpleSetSufficient.removeValue(forKey: node.nodeId)
    nodesFullProtocolRequired.removeValue(forKey: node.nodeId)
    nodesInhibited.removeValue(forKey: node.nodeId)

    startupGroup[node.virtualNodeType.startupGroup]?.uninitialize(node)
    
    if isDeletingANode {
      startupGroup[node.virtualNodeType.startupGroup]?.remove(node)
      OpenLCBMemorySpace.deleteAllMemorySpaces(forNodeId: node.nodeId)
      isDeletingANode = false
      appDelegate.rebootRequest()
    }
    else {
      stopNodes()
    }

  }

  public func nodeDidDetach(node:OpenLCBNodeVirtual) {

    for nodeManager in nodeManagers {
      nodeManager.removeNode(node: node)
    }
    
    gatewayNodes.removeValue(forKey: node.nodeId)
    nodesSimpleSetSufficient.removeValue(forKey: node.nodeId)
    nodesFullProtocolRequired.removeValue(forKey: node.nodeId)
    nodesInhibited[node.nodeId] = node

    if node.virtualNodeType == .canGatewayNode || node.virtualNodeType == .locoNetGatewayNode {
      appDelegate.rebootRequest()
    }
    
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
  
  public func registerNode(node:OpenLCBNodeVirtual) {
    
    if let group = startupGroup[node.virtualNodeType.startupGroup] {
      virtualNodeLookup[node.nodeId] = node
      group.add(node)
      node.start()
    }

  }
  
  public func deregisterNode(node:OpenLCBNodeVirtual) {
    node.stop()
  }
  
  public func deleteNode(nodeId:UInt64) {
    if let virtualNode = virtualNodeLookup[nodeId] {
      virtualNode.willDelete()
      isDeletingANode = true
      deregisterNode(node: virtualNode)
    }
  }
  
  public func getConfigurationTool(exclusive:Bool = false) -> OpenLCBNodeConfigurationTool? {
    let tool = configurationToolManager!.getNode(virtualNodeType: .configurationToolNode, exclusive: exclusive) as? OpenLCBNodeConfigurationTool
    return tool
  }
  
  public func releaseConfigurationTool(configurationTool:OpenLCBNodeConfigurationTool) {
    configurationToolManager?.releaseNode(node: configurationTool)
  }
  
  public func getThrottle() -> OpenLCBThrottle? {
    return throttleManager!.getNode(virtualNodeType: .throttleNode) as? OpenLCBThrottle
  }
  
  public func releaseThrottle(throttle:OpenLCBThrottle) {
    throttle.delegate = nil
    throttleManager?.releaseNode(node: throttle)
  }
  
  public func getLocoNetMonitor() -> OpenLCBLocoNetMonitorNode? {
    return locoNetMonitorManager!.getNode(virtualNodeType: .locoNetMonitorNode) as? OpenLCBLocoNetMonitorNode
  }
  
  public func releaseLocoNetMonitor(monitor:OpenLCBLocoNetMonitorNode) {
    locoNetMonitorManager?.releaseNode(node: monitor)
  }
  
  public func getProgrammerTool() -> OpenLCBProgrammerToolNode? {
    return programmerToolManager!.getNode(virtualNodeType: .programmerToolNode) as? OpenLCBProgrammerToolNode
  }
  
  public func releaseProgrammerTool(programmerTool:OpenLCBProgrammerToolNode) {
    programmerToolManager?.releaseNode(node: programmerTool)
  }
  
  private func dummyCompletion(node:OpenLCBNodeVirtual) {
  }
  
  public func nodeIdCacheCompleted() {
    appDelegate.openWindows()
  }
  
  public func createGatewayNode() {
    
    guard let appNode else {
      return
    }
    
    if let newNodeId = appNode.nextGatewayNodeId {
      
      isCreatingANode = true
      
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
      alert.informativeText = String(localized: "Your application has run out of gateway node IDs. Increase the maximum number of gateways in the application node using the configuration tool.")
      alert.addButton(withTitle: String(localized: "OK"))
      alert.alertStyle = .informational
      
      alert.runModal()

    }

  }
  
  public func createVirtualNode(virtualNodeType:MyTrainsVirtualNodeType) -> OpenLCBNodeVirtual {
    
    let newNodeId = appNode!.getUniqueNodeId()
    
    var node : OpenLCBNodeVirtual
    
    switch virtualNodeType {
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
      node = OpenLCBNodeVirtual(nodeId: newNodeId)
    case .digitraxBXP88Node:
      node = OpenLCBDigitraxBXP88Node(nodeId: newNodeId)
    case .layoutNode:
      node = LayoutNode(nodeId: newNodeId)
    case .switchboardPanelNode:
      node = SwitchboardPanelNode(nodeId: newNodeId, layoutNodeId: layoutNodeId!)
    case .switchboardItemNode:
      node = SwitchboardItemNode(nodeId: newNodeId, layoutNodeId: layoutNodeId!)
    }

    node.hostAppNodeId = appNode!.nodeId

    registerNode(node: node)

    return node
    
  }
  
  // MARK: Messages

  // This is running in the main thread
  
  public var postOfficeNodeId : UInt64 {
    return appNode!.nodeId + 1
  }
  
  public func sendMessage(message:OpenLCBMessage) {
    
    guard appNode != nil else {
      return
    }
    
    guard !message.routing.contains(postOfficeNodeId) else {
      return
    }
    
    message.routing.insert(postOfficeNodeId)
    
    let monitorItem = MonitorItem()
    monitorItem.message = message
    addToMonitorBuffer(item: monitorItem, isBackgroundThread: false)

    var tx = false

    if let destinationNodeId = message.destinationNodeId {

      if let virtualNode = virtualNodeLookup[destinationNodeId] {
        virtualNode.openLCBMessageReceived(message: message)
        tx = true
      }
      else if message.visibility.rawValue > OpenLCBNodeVisibility.visibilityPrivate.rawValue {
        tx = true
        for (_, virtualNode) in gatewayNodes {
          virtualNode.openLCBMessageReceived(message: message)
        }
      }
      
    }
    else {
      if message.messageTypeIndicator.isSimpleProtocol {
        for (_, virtualNode) in nodesSimpleSetSufficient {
          if !message.routing.contains(virtualNode.nodeId) {
            virtualNode.openLCBMessageReceived(message: message)
            tx = true
          }
        }
      }
      for (_, virtualNode) in nodesFullProtocolRequired {
        if !message.routing.contains(virtualNode.nodeId) {
          virtualNode.openLCBMessageReceived(message: message)
          tx = true
        }
      }
      for (_, virtualNode) in gatewayNodes {
        virtualNode.openLCBMessageReceived(message: message)
        tx = true
      }
      for (_, virtualNode) in nodesInhibited {
        if !message.routing.contains(virtualNode.nodeId) {
          virtualNode.openLCBMessageReceived(message: message)
          tx = true
        }
      }
    }
    
    for (_, observer) in observers {
      observer.postOfficeRXMessage?()
      if tx {
        observer.postOfficeTXMessage?()
      }
    }

  }
  
  // This is running in a background thread
  
  public func canFrameReceived(gateway:OpenLCBCANGateway, frame:LCCCANFrame) {
    let monitorItem = MonitorItem()
    monitorItem.frame = frame
    monitorItem.direction = .received
    monitorItem.gatewayNumber = gateway.gatewayNumber + 1
    addToMonitorBuffer(item: monitorItem, isBackgroundThread: true)
    for (_, observer) in observers {
      observer.gatewayRXPacket?(gateway: gateway.gatewayNumber)
    }
  }
  
  public func canFrameSent(gateway:OpenLCBCANGateway, frame:LCCCANFrame, isBackgroundThread:Bool) {
    let monitorItem = MonitorItem()
    monitorItem.frame = frame
    monitorItem.direction = .sent
    monitorItem.gatewayNumber = gateway.gatewayNumber + 1
    addToMonitorBuffer(item: monitorItem, isBackgroundThread: isBackgroundThread)
    for (_, observer) in observers {
      observer.gatewayTXPacket?(gateway: gateway.gatewayNumber)
    }
  }
  
  public func clearMonitorBuffer() {
    
    monitorBufferLock.lock()
    monitorBuffer.removeAll()
    monitorBufferLock.unlock()
    
    for (_, observer) in self.observers {
      observer.updateMonitor?(text: "")
    }
    
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
    monitorBuffer.removeFirst(max(0, monitorBuffer.count - 100000))
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

  // MARK: MTSerialPortManagerDelegate Methods
  
  @objc public func serialPortWasAdded(path:String) {
    
    var reboot = false
    
    for (_, node) in nodesInhibited {
      if let gateway = node as? OpenLCBCANGateway, path == gateway.devicePath {
        reboot = true
        break
      }
      else if let locoNetGateway = node as? OpenLCBLocoNetGateway, path == locoNetGateway.devicePath {
        reboot = true
        break
      }
    }
    
    if reboot {
      appDelegate.rebootRequest()
    }
    
  }

}

class StartupGroup {
  
  // MARK: Destructors
  
  deinit {
    removeAll()
  }
  
  // MARK: Private Properties
  
  private var nodes : [UInt64:OpenLCBNodeVirtual] = [:]
  
  private var initialized : Set<UInt64> = []
  
  private var uninitialized : Set<UInt64> = []
  
  // MARK: Public Properties
  
  public var isEmpty : Bool {
    return nodes.isEmpty
  }
  
  public var uninitializedIsEmpty : Bool {
    return uninitialized.isEmpty
  }
  
  public var initializedIsEmpty : Bool {
    return initialized.isEmpty
  }
  
  public var uninitializedNodes : [OpenLCBNodeVirtual] {
    var result : [OpenLCBNodeVirtual] = []
    for nodeId in uninitialized {
      result.append(nodes[nodeId]!)
    }
    return result
  }
  
  public var initializedNodes : [OpenLCBNodeVirtual] {
    var result : [OpenLCBNodeVirtual] = []
    for nodeId in initialized {
      result.append(nodes[nodeId]!)
    }
    return result
  }
  
  // MARK: Public Methods
  
  public func add(_ node:OpenLCBNodeVirtual) {
    nodes[node.nodeId] = node
    uninitialized.insert(node.nodeId)
  }
  
  public func remove(type:MyTrainsVirtualNodeType) {
    for (_, node) in nodes {
      if node.virtualNodeType == type {
        remove(node)
      }
    }
  }
  
  public func delete(type:MyTrainsVirtualNodeType) {
    for (_, node) in nodes {
      if node.virtualNodeType == type {
        remove(node)
        OpenLCBMemorySpace.deleteAllMemorySpaces(forNodeId: node.nodeId)
      }
    }
  }
  
  public func remove(_ node:OpenLCBNodeVirtual) {
    nodes.removeValue(forKey: node.nodeId)
    initialized.remove(node.nodeId)
    uninitialized.remove(node.nodeId)
  }
  
  public func removeAll() {
    nodes.removeAll()
    initialized.removeAll()
    uninitialized.removeAll()
  }
  
  public func initialize(_ node:OpenLCBNodeVirtual) {
    uninitialized.remove(node.nodeId)
    initialized.insert(node.nodeId)
  }
  
  public func uninitialize(_ node:OpenLCBNodeVirtual) {
    initialized.remove(node.nodeId)
    uninitialized.insert(node.nodeId)
  }
  
}
