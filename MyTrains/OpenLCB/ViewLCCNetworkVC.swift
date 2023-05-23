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
  
  private var tasks : [(nodeId:UInt64, task:Task)] = []
  
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
      
      network.sendVerifyNodeIdNumber(sourceNodeId: network.myTrainsNode.nodeId)
      
      startPacingTimer(timeInterval: TIMEOUT_DELAY)
      
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
        
        let myTrainsNodeId = network.myTrainsNode.nodeId

        switch nextTask.task {
        case .getSNIP:
          network.sendSimpleNodeInformationRequest(sourceNodeId: myTrainsNodeId, destinationNodeId: nextTask.nodeId)
        case .getProtocols:
          network.sendProtocolSupportInquiry(sourceNodeId: myTrainsNodeId, destinationNodeId: nextTask.nodeId)
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

        tasks.append((nodeId: nodeId, task: .getSNIP))
        tasks.append((nodeId: nodeId, task: .getProtocols))
        
        taskLock.unlock()
        
        reload()
        
        startPacingTimer(timeInterval: GET_DELAY)
        
      }
      else {
        taskLock.unlock()
      }
      
    case .protocolSupportReply:
      
      if message.destinationNodeId! == networkLayer!.myTrainsNode.nodeId, let node = nodes[message.sourceNodeId!] {
        stopPacingTimer()
        node.supportedProtocols = message.payload
        reload()
        doTask()
      }
    
    case .simpleNodeIdentInfoReply:
      
      if message.destinationNodeId! == networkLayer!.myTrainsNode.nodeId, let node = nodes[message.sourceNodeId!] {
        stopPacingTimer()
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
  
}

