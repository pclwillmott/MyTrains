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

class ViewLCCNetworkVC: MyTrainsViewController, OpenLCBConfigurationToolDelegate {
  
  // MARK: Window & View Methods
  
  override func windowWillClose(_ notification: Notification) {
    configurationTool?.delegate = nil
    configurationTool?.networkLayer?.releaseConfigurationTool(configurationTool: configurationTool!)
    configurationTool = nil
    super.windowWillClose(notification)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewType = .openLCBNetworkView
  }
  
  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    configurationTool!.delegate = self
    
    tableView.dataSource = tableViewDS
    tableView.delegate = tableViewDS
    reload()

    findAll()
    
  }
  
  // MARK: Private Properties
  
  private var nodes : [UInt64:OpenLCBNode] = [:]
  
  private var tableViewDS : ViewLCCNetworkTableViewDS = ViewLCCNetworkTableViewDS()
  
  // MARK: Public Properties
  
  public var configurationTool : OpenLCBNodeConfigurationTool?
  
  // MARK: Private Methods
  
  private func findAll() {
    nodes.removeAll()
    configurationTool?.sendVerifyNodeIdGlobal()
  }
  
  private func reload() {
    tableViewDS.dictionary = nodes
    tableView.reloadData()
  }
  
  public override func refreshRequired() {
    findAll()
  }

  // MARK: OpenLCBConfigurationTollDelegate Methods
  
  public func openLCBMessageReceived(message:OpenLCBMessage) {
    
    guard let configurationTool else {
      return
    }
    
    switch message.messageTypeIndicator {
     
    case .initializationCompleteSimpleSetSufficient, .initializationCompleteFullProtocolRequired, .verifiedNodeIDSimpleSetSufficient, .verifiedNodeIDFullProtocolRequired:
      
      if let newNodeId = message.sourceNodeId, !nodes.keys.contains(newNodeId) {
        nodes[newNodeId] = OpenLCBNode(nodeId: newNodeId)
        reload()
        configurationTool.sendSimpleNodeInformationRequest(destinationNodeId: newNodeId)
        configurationTool.sendProtocolSupportInquiry(destinationNodeId: newNodeId)
      }
      
    case .simpleNodeIdentInfoReply:
      
      if let node = nodes[message.sourceNodeId!] {
        node.encodedNodeInformation = message.payload
        reload()
      }

    case .protocolSupportReply:
      
      if let node = nodes[message.sourceNodeId!] {
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
    
    guard let networkLayer = configurationTool?.networkLayer else {
      return
    }

    let node = tableViewDS.nodes[sender.tag]
    
    var exclusive = false
    
    if let internalNode = networkLayer.virtualNodeLookup[node.nodeId] {
      
      let requireExclusive : Set<MyTrainsVirtualNodeType> = [
        .applicationNode,
        .layoutNode,
      ]
      
      exclusive = requireExclusive.contains(internalNode.virtualNodeType)
      
    }
    
    if let ct = networkLayer.getConfigurationTool(exclusive: exclusive) {
      let vc = MyTrainsWindow.configurationTool.viewController as! ConfigurationToolVC
      vc.configurationTool = ct
      vc.configurationTool?.delegate = vc
      vc.node = node
      vc.showWindow()
    }
    
  }
  
  @IBAction func btnUpdateFirmwareAction(_ sender: NSButton) {
    
    guard let networkLayer = configurationTool?.networkLayer else {
      return
    }

    let node = tableViewDS.nodes[sender.tag]
    
    let vc = MyTrainsWindow.openLCBFirmwareUpdate.viewController as! OpenLCBFirmwareUpdateVC
    vc.configurationTool = networkLayer.getConfigurationTool()
    vc.configurationTool?.delegate = vc
    vc.node = node
    vc.showWindow()

  }
  
  @IBAction func btnInfoAction(_ sender: NSButton) {
    
    guard let networkLayer = configurationTool?.networkLayer else {
      return
    }

    let node = tableViewDS.nodes[sender.tag]
    
    let vc = MyTrainsWindow.viewNodeInfo.viewController as! ViewNodeInfoVC
    vc.configurationTool = networkLayer.getConfigurationTool()
    vc.configurationTool?.delegate = vc
    vc.node = node
    vc.showWindow()

  }
    
  @IBAction func btnDeleteAction(_ sender: NSButton) {
    
    guard let networkLayer = configurationTool?.networkLayer else {
      return
    }

    let node = tableViewDS.nodes[sender.tag]

    let alert = NSAlert()
    
    alert.messageText = String(localized: "Are You Sure?")
    alert.informativeText = String(localized: "Are you sure that you want to delete the node \"\(node.userNodeName)\" (\(node.nodeId.toHexDotFormat(numberOfBytes: 6)))? This action cannot be undone!")
    alert.addButton(withTitle: String(localized: "Yes"))
    alert.addButton(withTitle: String(localized: "No"))
    alert.alertStyle = .informational
    
    switch alert.runModal() {
    case .alertFirstButtonReturn:
      networkLayer.deleteNode(nodeId: node.nodeId)
      findAll()
    default:
      break
    }

  }
  
}

