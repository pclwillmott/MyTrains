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
    
    networkLayer = networkController.openLCBNetworkLayer
    
    if let network = self.networkLayer {
      observerId = network.addObserver(observer: self)
    }
    
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
  
  // MARK: Private Methods
  
  private func findAll() {
    
    if let network = networkLayer {
      
      stopPacingTimer()
      
      nodes.removeAll()
      
      taskLock.lock()
      tasks.removeAll()
      taskLock.unlock()
      
      nodes[network.myTrainsNode.nodeId] = network.myTrainsNode
      nodes[network.configurationToolNode.nodeId] = network.configurationToolNode

      startPacingTimer(timeInterval: TIMEOUT_DELAY)

      network.sendVerifyNodeIdNumber(sourceNodeId: network.configurationToolNode.nodeId)
      
      
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
        
        let configurationToolNodeId = network.configurationToolNode.nodeId

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
  
  // MARK: LCCNetworkLayerDelegate Methods
  
  func networkLayerStateChanged(networkLayer: OpenLCBNetworkLayer) {
    
  }
  
  func openLCBMessageReceived(message: OpenLCBMessage) {
    
    switch message.messageTypeIndicator {
      
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
        tasks.append((nodeId: nodeId, task: .getAddressSpaceInfo, addressSpace:0x01))

        taskLock.unlock()
        
        reload()
        
        startPacingTimer(timeInterval: GET_DELAY)
        
      }
      else {
        taskLock.unlock()
      }
      
    case .protocolSupportReply:
      
      if message.destinationNodeId! == networkLayer!.configurationToolNode.nodeId, let node = nodes[message.sourceNodeId!] {
        stopPacingTimer()
        node.supportedProtocols = message.payload
        reload()
        doTask()
      }
    
    case .simpleNodeIdentInfoReply:
      
      if message.destinationNodeId! == networkLayer!.configurationToolNode.nodeId, let node = nodes[message.sourceNodeId!] {
        stopPacingTimer()
        node.encodedNodeInformation = message.payload
        reload()
        doTask()
      }

    case .datagram:
      
      if let datagramType = message.datagramType {
        
        switch datagramType {
        case .getConfigurationOptionsReply:
          
          if message.destinationNodeId! == networkLayer!.configurationToolNode.nodeId, let node = nodes[message.sourceNodeId!] {
            
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
          if message.destinationNodeId! == networkLayer!.configurationToolNode.nodeId, let node = nodes[message.sourceNodeId!] {
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
  
}
