//
//  ViewLCCNetworkVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/04/2023.
//

import Foundation
import Cocoa

class ViewLCCNetworkVC: NSViewController, NSWindowDelegate, LCCNetworkLayerDelegate {
  
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
    
    networkLayer = networkController.lccNetworkLayer
    
    if let network = self.networkLayer {
      observerId = network.addObserver(observer: self)
    }
    
    reload()
    
    findAll()
    
  }
  
  // MARK: Private Properties
  
  private var nodes : [UInt64:OpenLCBNode] = [:]
  
  private var tableViewDS : ViewLCCNetworkTableViewDS = ViewLCCNetworkTableViewDS()
  
  private var networkLayer : LCCNetworkLayer?
  
  private var observerId : Int = -1
  
  // MARK: Private Methods
  
  private func findAll() {
    
    if let network = networkLayer {
      
      nodes.removeAll()
      
      network.sendVerifyNodeIdNumber()
      
    }
    
  }
  
  private func reload() {
    
    tableViewDS.dictionary = nodes
    tableView.dataSource = tableViewDS
    tableView.delegate = tableViewDS
    tableView.reloadData()
    
  }
  
  // MARK: LCCNetworkLayerDelegate Methods
  
  func networkLayerStateChanged(networkLayer: LCCNetworkLayer) {
    
  }
  
  func openLCBMessageReceived(message: OpenLCBMessage) {
    
    switch message.messageTypeIndicator {
      
    case .verifiedNodeIDNumber:
      
      if let _ = nodes[message.sourceNodeId!] {
      }
      else {
        let node = OpenLCBNode(nodeId: message.sourceNodeId!)
        nodes[node.nodeId] = node
        reload()
        if let network = networkLayer {
          network.sendSimpleNodeInformationRequest(nodeId: node.nodeId)
          network.sendProtocolSupportInquiry(nodeId: node.nodeId)
        }
      }
      
    case .protocolSupportReply:
      
      if let node = nodes[message.sourceNodeId!] {
        node.supportedProtocols = message.payload
        reload()
      }
    
    case .simpleNodeIdentInfoReply:
      if let node = nodes[message.sourceNodeId!] {
        node.encodedNodeInformation = message.payload
        reload()
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

