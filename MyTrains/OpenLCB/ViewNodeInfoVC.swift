//
//  ViewNodeInfoVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/05/2023.
//

import Foundation
import Cocoa

private enum State {

  case idle
  case waitingForGetConfigOptionsAck
  case waitingForGetConfigOptions
  case waitingForAddressSpaceInfoAck
  case waitingForAddressSpaceInfo
  case done

}

class ViewNodeInfoVC: NSViewController, NSWindowDelegate, OpenLCBConfigurationToolDelegate {
  
  // MARK: Window & View Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
    
    guard let networkLayer, let configurationTool else {
      return
    }
    
    configurationTool.delegate = nil
    networkLayer.releaseConfigurationTool(configurationTool: configurationTool)
    
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    guard let node, let configurationTool else {
      return
    }
    
    networkLayer = configurationTool.networkLayer
    
    nodeId = configurationTool.nodeId
    
    if node.userNodeName != "" {
      self.view.window?.title = "\(node.userNodeName) (\(node.nodeId.toHexDotFormat(numberOfBytes: 6)))"
    }
    else {
      self.view.window?.title = "\(node.manufacturerName) - \(node.nodeModelName) (\(node.nodeId.toHexDotFormat(numberOfBytes: 6)))"
    }
    
    state = .waitingForGetConfigOptionsAck
    startTimeoutTimer()
    networkLayer?.sendGetConfigurationOptionsCommand(sourceNodeId: nodeId, destinationNodeId: node.nodeId)

  }
  
  // MARK: Private Properties
  
  private var tableViewDS = ViewNodeInfoMemorySpaceInfoTVDS()
  
  private var networkLayer : OpenLCBNetworkLayer?
  
  private var nodeId : UInt64 = 0
  
  private var state : State = .idle
  
  private var timeoutTimer : Timer?
  
  private var currentAddressSpace : UInt8 = 0
  
  private var possibleAddressSpaces : [UInt8] = []
  
  // MARK: Public Properties
  
  public var node: OpenLCBNode?
  
  public var configurationTool : OpenLCBNodeConfigurationTool?

  // MARK: Private Methods
  
  private func reload() {
  
    textView.string = node!.supportedProtocolsAsString
    
    txtAvailableCommands.string = node!.configurationOptions.availableCommandsAsString
    
    txtWriteLengths.string = node!.configurationOptions.writeLengthsAsString
    
    lblLowestAddressSpace.stringValue = "0x\(node!.configurationOptions.lowestAddressSpace.toHex(numberOfDigits: 2))"
    
    lblHighestAddressSpace.stringValue = "0x\(node!.configurationOptions.highestAddressSpace.toHex(numberOfDigits: 2))"
    
    lblName.stringValue = node!.configurationOptions.name
    
    tableViewDS.addressSpaceInformation = node!.addressSpaceInformation
    tableView.dataSource = tableViewDS
    tableView.delegate = tableViewDS
    tableView.reloadData()
    
  }
  
  @objc func timeoutTimerAction() {
    stopTimeoutTimer()
    state = .done
  }
  
  private func startTimeoutTimer() {
    let interval : TimeInterval = 3.0
    timeoutTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timeoutTimerAction), userInfo: nil, repeats: false)
    RunLoop.current.add(timeoutTimer!, forMode: .common)
  }
  
  private func stopTimeoutTimer() {
    timeoutTimer?.invalidate()
    timeoutTimer = nil
  }

  
  // MARK: OpenLCBConfigurationToolDelegate Methods
  
  func openLCBMessageReceived(message: OpenLCBMessage) {
    
    guard let networkLayer, let node, message.destinationNodeId == nodeId && message.sourceNodeId == node.nodeId else {
      return
    }
    
    switch message.messageTypeIndicator {
    
    case .datagramRejected:
      
      stopTimeoutTimer()
      
      if state == .waitingForAddressSpaceInfoAck {
        
        if !possibleAddressSpaces.isEmpty {
          
          currentAddressSpace = possibleAddressSpaces.removeFirst()
          
          startTimeoutTimer()
          
          networkLayer.sendGetMemorySpaceInformationRequest(sourceNodeId: nodeId, destinationNodeId: node.nodeId, addressSpace: currentAddressSpace)
          
        }
        else {
          state = .done
        }

      }
      else {
        state = .done
      }
      
    case .datagramReceivedOK:
     
      switch state {
      case .waitingForGetConfigOptionsAck:
        stopTimeoutTimer()
        state = .waitingForGetConfigOptions
      case .waitingForAddressSpaceInfoAck:
        stopTimeoutTimer()
        state = .waitingForAddressSpaceInfo
      default:
        break
      }
      
    case .datagram:
      
      if let datagramType = message.datagramType {
        
        switch datagramType {
          
        case .getConfigurationOptionsReply:
          
          node.configurationOptions.encodedOptions = message.payload
          
          reload()
          
          possibleAddressSpaces = node.possibleAddressSpaces
          
          if !possibleAddressSpaces.isEmpty {
            
            currentAddressSpace = possibleAddressSpaces.removeFirst()
            
            state = .waitingForAddressSpaceInfoAck
            
            startTimeoutTimer()
            
            networkLayer.sendGetMemorySpaceInformationRequest(sourceNodeId: nodeId, destinationNodeId: node.nodeId, addressSpace: currentAddressSpace)
            
          }
          
        case .getAddressSpaceInformationReply, .getAddressSpaceInformationReplyLowAddressPresent:
          
          let _ = node.addAddressSpaceInformation(message: message)
          
          reload()
          
          if !possibleAddressSpaces.isEmpty {
            
            state = .waitingForAddressSpaceInfoAck
            
            currentAddressSpace = possibleAddressSpaces.removeFirst()
            
            startTimeoutTimer()
            
            networkLayer.sendGetMemorySpaceInformationRequest(sourceNodeId: nodeId, destinationNodeId: node.nodeId, addressSpace: currentAddressSpace)
            
          }
          else {
            state = .done
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
  
  @IBOutlet var textView: NSTextView!
  
  @IBOutlet var txtAvailableCommands: NSTextView!
  
  @IBOutlet var txtWriteLengths: NSTextView!
  
  @IBOutlet weak var lblHighestAddressSpace: NSTextField!
  
  @IBOutlet weak var lblLowestAddressSpace: NSTextField!
  
  @IBOutlet weak var lblName: NSTextField!
  
  @IBOutlet weak var tableView: NSTableView!
  
}
