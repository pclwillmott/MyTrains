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
  case getConfigurationOptions
  case getAddressSpaceInfo
}
class ViewLCCNetworkVC: NSViewController, NSWindowDelegate, OpenLCBNetworkLayerDelegate {
  
  // MARK: Window & View Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
    if observerId != -1 {
      networkLayer?.removeObserver(observerId: observerId)
      observerId = -1
    }
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    networkLayer = myTrainsController.openLCBNetworkLayer
    
    if let network = self.networkLayer {
      observerId = network.addObserver(observer: self)
    }
    
    MyTrainsVirtualNodeType.populate(comboBox: cboNewNodeType)
    
    reload()
    
    findAll()
    
  }
  
  // MARK: Private Properties
  
  private let GET_DELAY : TimeInterval = 0.01
  
  private let TIMEOUT_DELAY : TimeInterval = 0.01

  private var nodes : [UInt64:OpenLCBNode] = [:]
  
  private var tasks : [(nodeId:UInt64, task:Task, addressSpace:UInt8)] = []
  
  private var taskLock : NSLock = NSLock()
  
  private var tableViewDS : ViewLCCNetworkTableViewDS = ViewLCCNetworkTableViewDS()
  
  private var networkLayer : OpenLCBNetworkLayer?
  
  private var observerId : Int = -1

  private var pacingTimer : Timer?
  
  private var spacingTimer : Timer?
  
  // MARK: Private Methods
  
  private func findAll() {
    
    if let network = networkLayer {
      
      stopPacingTimer()
      
      nodes.removeAll()
      
      taskLock.lock()
      tasks.removeAll()
      taskLock.unlock()
      
//      nodes[network.myTrainsNode!.nodeId] = network.myTrainsNode
//      nodes[network.configurationToolNode!.nodeId] = network.configurationToolNode

      startPacingTimer(timeInterval: TIMEOUT_DELAY)

      network.sendVerifyNodeIdNumber(sourceNodeId: network.configurationToolNode!.nodeId)
      
    }
    
  }
  
  private func reload() {
    
    tableViewDS.dictionary = nodes
    tableView.dataSource = tableViewDS
    tableView.delegate = tableViewDS
    tableView.reloadData()
    
  }
  
  func doTask() {
  
    stopPacingTimer()
    
    taskLock.lock()
    
    if let nextTask = tasks.first {
      
      tasks.removeFirst()
      
      taskLock.unlock()
      
      if let network = networkLayer {
        
        let configurationToolNodeId = network.configurationToolNode!.nodeId

        switch nextTask.task {
        case .getSNIP:
          network.sendSimpleNodeInformationRequest(sourceNodeId: configurationToolNodeId, destinationNodeId: nextTask.nodeId)
        case .getProtocols:
          network.sendProtocolSupportInquiry(sourceNodeId: configurationToolNodeId, destinationNodeId: nextTask.nodeId)
        case .getConfigurationOptions:
          network.sendGetConfigurationOptionsCommand(sourceNodeId: configurationToolNodeId, destinationNodeId: nextTask.nodeId)
        case .getAddressSpaceInfo:
          network.sendGetMemorySpaceInformationRequest(sourceNodeId: configurationToolNodeId, destinationNodeId: nextTask.nodeId, addressSpace: nextTask.addressSpace)
        }
        
        startPacingTimer(timeInterval: GET_DELAY)
        
      }
    }
    else {
      taskLock.unlock()
    }

  }
  
  @objc func pacingTimerAction() {
    doTask()
  }
  
  func startPacingTimer(timeInterval:TimeInterval) {
    stopPacingTimer()
    pacingTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(pacingTimerAction), userInfo: nil, repeats: false)
    RunLoop.current.add(pacingTimer!, forMode: .common)
  }
  
  func stopPacingTimer() {
    pacingTimer?.invalidate()
    pacingTimer = nil
  }
  
  @objc func spacingTimerAction() {
    
    stopSpacingTimer()

    findAll()
    
  }
  
  func startSpacingTimer() {
    
    stopSpacingTimer()
    
    let timeInterval : TimeInterval = 0.5
    
    spacingTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(spacingTimerAction), userInfo: nil, repeats: false)
    
    RunLoop.current.add(spacingTimer!, forMode: .common)
    
  }
  
  func stopSpacingTimer() {
    spacingTimer?.invalidate()
    spacingTimer = nil
  }

  
  // MARK: LCCNetworkLayerDelegate Methods
  
  func networkLayerStateChanged(networkLayer: OpenLCBNetworkLayer) {
    
  }
  
  func openLCBMessageReceived(message: OpenLCBMessage) {
    
    switch message.messageTypeIndicator {
      
    case .initializationCompleteSimpleSetSufficient, .initializationCompleteFullProtocolRequired:
      
      stopSpacingTimer()

    case .verifiedNodeIDNumberSimpleSetSufficient, .verifiedNodeIDNumberFullProtocolRequired:
      
      taskLock.lock()
      
      if !nodes.keys.contains(message.sourceNodeId!) {
 
        stopPacingTimer()
        
        let nodeId = message.sourceNodeId!
        
        nodes[nodeId] = OpenLCBNode(nodeId: nodeId)

        tasks.append((nodeId: nodeId, task: .getSNIP, addressSpace:0))
        tasks.append((nodeId: nodeId, task: .getProtocols, addressSpace:0))
        tasks.append((nodeId: nodeId, task: .getConfigurationOptions, addressSpace:0))
        tasks.append((nodeId: nodeId, task: .getAddressSpaceInfo, addressSpace:0xff))
        tasks.append((nodeId: nodeId, task: .getAddressSpaceInfo, addressSpace:0xfe))
        tasks.append((nodeId: nodeId, task: .getAddressSpaceInfo, addressSpace:0xfd))
        tasks.append((nodeId: nodeId, task: .getAddressSpaceInfo, addressSpace:0xfc))
        tasks.append((nodeId: nodeId, task: .getAddressSpaceInfo, addressSpace:0xfb))
        tasks.append((nodeId: nodeId, task: .getAddressSpaceInfo, addressSpace:0xfa))
        tasks.append((nodeId: nodeId, task: .getAddressSpaceInfo, addressSpace:0xf9))
        tasks.append((nodeId: nodeId, task: .getAddressSpaceInfo, addressSpace:0xf8))
        tasks.append((nodeId: nodeId, task: .getAddressSpaceInfo, addressSpace:0x01))

        taskLock.unlock()
        
        reload()
        
        startPacingTimer(timeInterval: GET_DELAY)
        
      }
      else {
        taskLock.unlock()
      }
      
    case .protocolSupportReply:
      
      if message.destinationNodeId! == networkLayer!.configurationToolNode!.nodeId, let node = nodes[message.sourceNodeId!] {
        stopPacingTimer()
        node.supportedProtocols = message.payload
        reload()
        doTask()
      }
    
    case .simpleNodeIdentInfoReply:
      
      if message.destinationNodeId! == networkLayer!.configurationToolNode!.nodeId, let node = nodes[message.sourceNodeId!] {
        stopPacingTimer()
        node.encodedNodeInformation = message.payload
        reload()
        doTask()
      }

    case .datagram:
      
      if let datagramType = message.datagramType {
        
        switch datagramType {
        case .getConfigurationOptionsReply:
          
          if message.destinationNodeId! == networkLayer!.configurationToolNode!.nodeId, let node = nodes[message.sourceNodeId!] {
            
            stopPacingTimer()
            
            node.configurationOptions = OpenLCBNodeConfigurationOptions(message: message)
            
            /*
            taskLock.lock()
            for space in node.configurationOptions.lowestAddressSpace ... node.configurationOptions.highestAddressSpace {
              tasks.append((nodeId: node.nodeId, task: .getAddressSpaceInfo, addressSpace:space))
            }
            taskLock.unlock()
            */
            
            reload()
            doTask()
            
          }

        case .getAddressSpaceInformationReply, .getAddressSpaceInformationReplyLowAddressPresent:
          if message.destinationNodeId! == networkLayer!.configurationToolNode!.nodeId, let node = nodes[message.sourceNodeId!] {
            stopPacingTimer()
            _ = node.addAddressSpaceInformation(message: message)
            reload()
            doTask()
          }
        default:
          break
        }
        
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
    
    if let virtualNodeType = MyTrainsVirtualNodeType.selected(comboBox: cboNewNodeType), let networkLayer = self.networkLayer {
      
      let newNodeId = networkLayer.getNewNodeId(virtualNodeType: virtualNodeType)
      
      var node : OpenLCBNodeVirtual?
      
      let number = newNodeId & 0xffff
      
      switch virtualNodeType {
      case .clockNode:
        node = OpenLCBClock(nodeId: newNodeId)
        node!.userNodeName = "Clock #\(number)"
      case .throttleNode:
        node = OpenLCBThrottle(nodeId: newNodeId)
        node!.userNodeName = "Throttle #\(number)"
      case .locoNetGatewayNode:
        node = OpenLCBLocoNetGateway(nodeId: newNodeId)
        node!.userNodeName = "LocoNet Gateway #\(number)"
      case .trainNode:
        node = OpenLCBNodeRollingStockLocoNet(nodeId: newNodeId)
        node!.userNodeName = "Train #\(number)"
      case .canGatewayNode:
        node = OpenLCBCANGateway(nodeId: newNodeId)
        node!.userNodeName = "CAN Gateway #\(number)"
      case .applicationNode:
        node = OpenLCBNodeMyTrains(nodeId: newNodeId)
        node!.userNodeName = "Application Node #\(number)"
      case .configurationToolNode:
        node = OpenLCBNodeConfigurationTool(nodeId: newNodeId)
        node!.userNodeName = "Configuration Tool #\(number)"
      case .locoNetMonitorNode:
        node = OpenLCBLocoNetMonitorNode(nodeId: newNodeId)
        node!.userNodeName = "LocoNet Monitor #\(number & 0xff)"
      case .programmerToolNode:
        node = OpenLCBProgrammerToolNode(nodeId: newNodeId)
        node!.userNodeName = "DCC Programmer Tool #\(number)"
      case .programmingTrackNode:
        node = OpenLCBProgrammingTrackNode(nodeId: newNodeId)
        node!.userNodeName = "DCC Programming Track #\(number)"
      default:
        break
      }

      node!.saveMemorySpaces()
      
      networkLayer.registerNode(node: node!)
      
      findAll()

    }
    
  }
  
  @IBOutlet weak var cboNewNodeType: NSComboBox!
  
  @IBAction func btnDeleteAction(_ sender: NSButton) {
    
    let node = tableViewDS.nodes[sender.tag]

    networkLayer?.deleteNode(nodeId: node.nodeId)
    
    startSpacingTimer()
    
  }
  
}

