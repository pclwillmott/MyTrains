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
    
    reload()
    
    findAll()
    
  }
  
  // MARK: Private Properties
  
  private var nodes : [UInt64:OpenLCBNode] = [:]
  
  private var tableViewDS : ViewLCCNetworkTableViewDS = ViewLCCNetworkTableViewDS()
  
  private var networkLayer : OpenLCBNetworkLayer?
  
  private var nodeId : UInt64 = 0
  
  // MARK: Public Properties
  
  public var configurationTool : OpenLCBNodeConfigurationTool?
  
  // MARK: Private Methods
  
  private func findAll() {
    
    guard let networkLayer else {
      return
    }
    
    nodes.removeAll()
    
    networkLayer.sendVerifyNodeIdNumber(sourceNodeId: nodeId)

  }
  
  private func reload() {
    
    tableViewDS.dictionary = nodes
    tableView.dataSource = tableViewDS
    tableView.delegate = tableViewDS
    tableView.reloadData()
    
  }
  
  public func openLCBMessageReceived(message: OpenLCBMessage) {
    
    guard let networkLayer else {
      return
    }
    
    switch message.messageTypeIndicator {
     
    case .initializationCompleteSimpleSetSufficient, .initializationCompleteFullProtocolRequired, .verifiedNodeIDNumberSimpleSetSufficient, .verifiedNodeIDNumberFullProtocolRequired:
      
      let newNodeId = message.sourceNodeId!
      
      if !nodes.keys.contains(newNodeId) {
        nodes[newNodeId] = OpenLCBNode(nodeId: newNodeId)
        networkLayer.sendSimpleNodeInformationRequest(sourceNodeId: nodeId, destinationNodeId: newNodeId)
        networkLayer.sendProtocolSupportInquiry(sourceNodeId: nodeId, destinationNodeId: newNodeId)
        reload()
      }
      
    case .simpleNodeIdentInfoReply:
      
      if message.destinationNodeId! == nodeId, let node = nodes[message.sourceNodeId!] {
        node.encodedNodeInformation = message.payload
        reload()
      }

    case .protocolSupportReply:
      
      if message.destinationNodeId! == nodeId, let node = nodes[message.sourceNodeId!] {
        node.supportedProtocols = message.payload
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
    
    guard let networkLayer else {
      return
    }

    let node = tableViewDS.nodes[sender.tag]
    
    let x = ModalWindow.ConfigurationTool
    let wc = x.windowController
    let vc = x.viewController(windowController: wc) as! ConfigurationToolVC
    vc.configurationTool = networkLayer.getConfigurationTool()
    vc.configurationTool?.delegate = vc
    vc.node = node
    wc.showWindow(nil)

  }
  
  @IBAction func btnUpdateFirmwareAction(_ sender: NSButton) {
    
    guard let networkLayer else {
      return
    }

    let node = tableViewDS.nodes[sender.tag]
    
    let x = ModalWindow.OpenLCBFirmwareUpdate
    let wc = x.windowController
    let vc = x.viewController(windowController: wc) as! OpenLCBFirmwareUpdateVC
    vc.configurationTool = networkLayer.getConfigurationTool()
    vc.configurationTool?.delegate = vc
    vc.node = node
    wc.showWindow(nil)

  }
  
  @IBAction func btnInfoAction(_ sender: NSButton) {
    
    guard let networkLayer else {
      return
    }

    let node = tableViewDS.nodes[sender.tag]
    
    let x = ModalWindow.ViewNodeInfo
    let wc = x.windowController
    let vc = x.viewController(windowController: wc) as! ViewNodeInfoVC
    vc.configurationTool = networkLayer.getConfigurationTool()
    vc.configurationTool?.delegate = vc
    vc.node = node
    wc.showWindow(nil)

  }
    
  @IBAction func btnDeleteAction(_ sender: NSButton) {
    
    guard let networkLayer else {
      return
    }
    
    let node = tableViewDS.nodes[sender.tag]

    networkLayer.deleteNode(nodeId: node.nodeId)
    
    findAll()
    
  }
  
}

