//
//  ViewLCCNetworkVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/04/2023.
//

import Foundation
import Cocoa

private enum State {
  case idle
  case getNodes
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
  
  private let PACING_DELAY : TimeInterval = 0.3
  
  private var nodes : [UInt64:OpenLCBNode] = [:]
  
  private var nodesToDo : [OpenLCBNode] = []
  
  private var state : State = .idle
  
  private var tableViewDS : ViewLCCNetworkTableViewDS = ViewLCCNetworkTableViewDS()
  
  private var networkLayer : OpenLCBNetworkLayer?
  
  private var observerId : Int = -1

  private var pacingTimer : Timer?
  
  // MARK: Private Methods
  
  private func findAll() {
    
    if let network = networkLayer {
      
      nodes.removeAll()
      
      nodesToDo.removeAll()
      
      state = .getNodes
      
      nodes[network.myTrainsNode.nodeId] = network.myTrainsNode
      
      network.sendVerifyNodeIdNumber(sourceNodeId: network.myTrainsNode.nodeId)
      
      startPacingTimer(timeInterval: PACING_DELAY)
      
    }
    
  }
  
  private func reload() {
    
    tableViewDS.dictionary = nodes
    tableView.dataSource = tableViewDS
    tableView.delegate = tableViewDS
    tableView.reloadData()
    
  }
  
  @objc func pacingTimerAction() {
    stopPacingTimer()
    if !nodesToDo.isEmpty {
      if let network = networkLayer, let node = nodesToDo.first {
        let myTrainsNodeId = network.myTrainsNode.nodeId
        switch state {
        case .getNodes:
          state = .getSNIP
          network.sendSimpleNodeInformationRequest(sourceNodeId: myTrainsNodeId, destinationNodeId: node.nodeId)
        case .getSNIP:
          state = .getProtocols
          network.sendProtocolSupportInquiry(sourceNodeId: myTrainsNodeId, destinationNodeId: node.nodeId)
        case .getProtocols:
          nodesToDo.removeFirst()
          if let node = nodesToDo.first {
            state = .getSNIP
            network.sendSimpleNodeInformationRequest(sourceNodeId: myTrainsNodeId, destinationNodeId: node.nodeId)
          }
        default:
          break
        }
      }
      if !nodesToDo.isEmpty {
        startPacingTimer(timeInterval: PACING_DELAY)
      }
      else {
        state = .idle
      }
    }

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
      
      var xnode : OpenLCBNode?
      
      if let oldNode = nodes[message.sourceNodeId!] {
        xnode = oldNode
      }
      else {
        xnode = OpenLCBNode(nodeId: message.sourceNodeId!)
        nodesToDo.append(xnode!)
      }
      startPacingTimer(timeInterval: PACING_DELAY)
      if let node = xnode {
        nodes[node.nodeId] = node
        reload()
      }
      
    case .protocolSupportReply:
      
      guard message.destinationNodeId! == networkLayer!.myTrainsNode.nodeId else {
        return
      }
      
      if let node = nodes[message.sourceNodeId!] {
        node.supportedProtocols = message.payload
        reload()
        if !nodesToDo.isEmpty {
          nodesToDo.removeFirst()
          if let node = nodesToDo.first, let network = networkLayer {
            let myTrainsNodeId = network.myTrainsNode.nodeId
            state = .getSNIP
            startPacingTimer(timeInterval: PACING_DELAY)
            network.sendSimpleNodeInformationRequest(sourceNodeId: myTrainsNodeId, destinationNodeId: node.nodeId)
          }
        }
      }
    
    case .simpleNodeIdentInfoReply:
      
      guard message.destinationNodeId! == networkLayer!.myTrainsNode.nodeId else {
        return
      }
      
      if let node = nodes[message.sourceNodeId!] {
        node.encodedNodeInformation = message.payload
        reload()
        if let node = nodesToDo.first, let network = networkLayer {
          let myTrainsNodeId = network.myTrainsNode.nodeId
          state = .getProtocols
          startPacingTimer(timeInterval: PACING_DELAY)
          network.sendProtocolSupportInquiry(sourceNodeId: myTrainsNodeId, destinationNodeId: node.nodeId)
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

