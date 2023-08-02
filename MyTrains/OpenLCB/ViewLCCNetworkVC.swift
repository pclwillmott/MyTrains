//
//  ViewLCCNetworkVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/04/2023.
//

import Foundation
import Cocoa

private enum Task {
  case getSNIP
  case getProtocols
}

class ViewLCCNetworkVC: NSViewController, NSWindowDelegate, OpenLCBConfigurationToolDelegate {
  
  // MARK: Window & View Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
    configurationTool?.delegate = nil
    networkLayer?.releaseConfigurationTool(configurationTool: configurationTool!)
    configurationTool = nil
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    networkLayer = configurationTool!.networkLayer
    
    nodeId = configurationTool!.nodeId
    
    MyTrainsVirtualNodeType.populate(comboBox: cboNewNodeType)
    
    reload()
    
    findAll()
    
  }
  
  // MARK: Private Properties
  
  private let TIMEOUT_DELAY : TimeInterval = 1.0

  private var nodes : [UInt64:OpenLCBNode] = [:]
  
  private var tasks : [(nodeId:UInt64, task:Task)] = []
  
  private var tableViewDS : ViewLCCNetworkTableViewDS = ViewLCCNetworkTableViewDS()
  
  private var timeoutTimer : Timer?
  
  private var networkLayer : OpenLCBNetworkLayer?
  
  private var nodeId : UInt64 = 0
  
  // MARK: Public Properties
  
  public var configurationTool : OpenLCBNodeConfigurationTool?
  
  // MARK: Private Methods
  
  private func findAll() {
    
    guard let networkLayer else {
      return
    }
    
    stopTimeoutTimer()
    
    nodes.removeAll()
    
    tasks.removeAll()
    
    startTimeoutTimer(timeInterval: TIMEOUT_DELAY)

    networkLayer.sendVerifyNodeIdNumber(sourceNodeId: nodeId)

  }
  
  private func reload() {
    
    tableViewDS.dictionary = nodes
    tableView.dataSource = tableViewDS
    tableView.delegate = tableViewDS
    tableView.reloadData()
    
  }
  
  func doTask() {
    
    guard let networkLayer, !tasks.isEmpty else {
      return
    }
  
    let nextTask = tasks.removeFirst()
      
    startTimeoutTimer(timeInterval: TIMEOUT_DELAY)
    
    switch nextTask.task {
    case .getSNIP:
      networkLayer.sendSimpleNodeInformationRequest(sourceNodeId: nodeId, destinationNodeId: nextTask.nodeId)
    case .getProtocols:
      networkLayer.sendProtocolSupportInquiry(sourceNodeId: nodeId, destinationNodeId: nextTask.nodeId)
    }

  }
  
  @objc func timeoutTimerAction() {
    stopTimeoutTimer()
    doTask()
  }
  
  func startTimeoutTimer(timeInterval:TimeInterval) {
    timeoutTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timeoutTimerAction), userInfo: nil, repeats: false)
    RunLoop.current.add(timeoutTimer!, forMode: .common)
  }
  
  func stopTimeoutTimer() {
    timeoutTimer?.invalidate()
    timeoutTimer = nil
  }
  
  public func openLCBMessageReceived(message: OpenLCBMessage) {
    
    switch message.messageTypeIndicator {
     
    case .initializationCompleteSimpleSetSufficient, .initializationCompleteFullProtocolRequired, .verifiedNodeIDNumberSimpleSetSufficient, .verifiedNodeIDNumberFullProtocolRequired:
      
      let nodeId = message.sourceNodeId!
      
      if !nodes.keys.contains(nodeId) {
 
        let start = tasks.isEmpty
        
        nodes[nodeId] = OpenLCBNode(nodeId: nodeId)

        tasks.append((nodeId: nodeId, task: .getSNIP))
        tasks.append((nodeId: nodeId, task: .getProtocols))
        
        reload()
        
        if start {
          doTask()
        }
        
      }
      
    case .protocolSupportReply:
      
      if message.destinationNodeId! == nodeId, let node = nodes[message.sourceNodeId!] {
        stopTimeoutTimer()
        node.supportedProtocols = message.payload
        reload()
        doTask()
      }
    
    case .simpleNodeIdentInfoReply:
      
      if message.destinationNodeId! == nodeId, let node = nodes[message.sourceNodeId!] {
        stopTimeoutTimer()
        node.encodedNodeInformation = message.payload
        reload()
        doTask()
      }

    default:
      break
    }
    
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var tableView: NSTableView!
  
  @IBAction func btnRefreshAction(_ sender: NSButton) {
    findAll()
  }
  
  @IBAction func btnConfigureAction(_ sender: NSButton) {
    
    let node = tableViewDS.nodes[sender.tag]
    
    let x = ModalWindow.ConfigureLCCNode
    let wc = x.windowController
    let vc = x.viewController(windowController: wc) as! ConfigureLCCNodeVC
    vc.node = node
    wc.showWindow(nil)

  }
  
  @IBAction func btnUpdateFirmwareAction(_ sender: NSButton) {
  }
  
  @IBAction func btnInfoAction(_ sender: NSButton) {
    
    let node = tableViewDS.nodes[sender.tag]
    
    let x = ModalWindow.ViewNodeInfo
    let wc = x.windowController
    let vc = x.viewController(windowController: wc) as! ViewNodeInfoVC
    vc.node = node
    wc.showWindow(nil)

  }
  
  @IBAction func btnCreateNewNodeAction(_ sender: NSButton) {
    
    guard let networkLayer, let virtualNodeType = MyTrainsVirtualNodeType.selected(comboBox: cboNewNodeType) else {
      return
    }
    
    let newNodeId = networkLayer.getNewNodeId(virtualNodeType: virtualNodeType)
    
    var node : OpenLCBNodeVirtual?
    
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
      break
    }

    if let node {
      node.userNodeName = node.virtualNodeType.defaultUserNodeName(nodeId: node.nodeId)
      node.saveMemorySpaces()
      networkLayer.registerNode(node: node)
    }
    
    findAll()

  }
  
  @IBOutlet weak var cboNewNodeType: NSComboBox!
  
  @IBAction func btnDeleteAction(_ sender: NSButton) {
    
    guard let networkLayer else {
      return
    }
    
    let node = tableViewDS.nodes[sender.tag]

    networkLayer.deleteNode(nodeId: node.nodeId)
    
    findAll()
    
  }
  
}

