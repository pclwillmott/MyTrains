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

class ViewNodeInfoVC: MyTrainsViewController, OpenLCBConfigurationToolDelegate {
  
  // MARK: Window & View Methods
  
  override func windowWillClose(_ notification: Notification) {
    
    configurationTool?.delegate = nil
    appDelegate.networkLayer?.releaseConfigurationTool(configurationTool: configurationTool!)
    configurationTool = nil
    tableView.delegate = nil
    tableView.dataSource = nil
    tableViewDS = nil
    timeoutTimer?.invalidate()
    timeoutTimer = nil
    node = nil

    super.windowWillClose(notification)
    
  }
  
  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    guard let node, let configurationTool else {
      return
    }
    
    nodeId = configurationTool.nodeId
    
    if node.userNodeName != "" {
      self.view.window?.title = "\(node.userNodeName) (\(node.nodeId.toHexDotFormat(numberOfBytes: 6)))"
    }
    else {
      self.view.window?.title = "\(node.manufacturerName) - \(node.nodeModelName) (\(node.nodeId.toHexDotFormat(numberOfBytes: 6)))"
    }
    
    tableView.dataSource = tableViewDS
    tableView.delegate = tableViewDS
    
    reload()
    
    state = .waitingForGetConfigOptionsAck
    startTimeoutTimer()
    configurationTool.sendGetConfigurationOptionsCommand(destinationNodeId: node.nodeId)

  }
  
  // MARK: Private Properties
  
  private var tableViewDS : ViewNodeInfoMemorySpaceInfoTVDS? = ViewNodeInfoMemorySpaceInfoTVDS()
  
  private var nodeId : UInt64 = 0
  
  private var state : State = .idle
  
  private var timeoutTimer : Timer?
  
  private var currentAddressSpace : UInt8 = 0
  
  private var possibleAddressSpaces : [UInt8] = []
  
  // MARK: Public Properties
  
  public weak var node: OpenLCBNode?
  
  public weak var configurationTool : OpenLCBNodeConfigurationTool?

  // MARK: Private Methods
  
  private func reload() {
  
    textView.string = node!.supportedProtocolsAsString
    
    txtAvailableCommands.string = node!.configurationOptions!.availableCommandsAsString
    
    txtWriteLengths.string = node!.configurationOptions!.writeLengthsAsString
    
    lblLowestAddressSpace.stringValue = "0x\(node!.configurationOptions!.lowestAddressSpace.toHex(numberOfDigits: 2))"
    
    lblHighestAddressSpace.stringValue = "0x\(node!.configurationOptions!.highestAddressSpace.toHex(numberOfDigits: 2))"
    
    lblName.stringValue = node!.configurationOptions!.name
    
    tableViewDS?.addressSpaceInformation = node!.addressSpaceInformation
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
    
    guard let node, message.destinationNodeId == nodeId && message.sourceNodeId == node.nodeId else {
      return
    }
    
    switch message.messageTypeIndicator {
    
    case .datagramRejected:
      
      stopTimeoutTimer()
      
      if state == .waitingForAddressSpaceInfoAck {
        
        if !possibleAddressSpaces.isEmpty {
          
          currentAddressSpace = possibleAddressSpaces.removeFirst()
          
          startTimeoutTimer()
          
          configurationTool?.sendGetMemorySpaceInformationCommand(destinationNodeId: node.nodeId, addressSpace: currentAddressSpace)
          
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
          
          node.configurationOptions!.encodedOptions = message.payload
          
          reload()
          
          possibleAddressSpaces = node.possibleAddressSpaces
          
          if !possibleAddressSpaces.isEmpty {
            
            currentAddressSpace = possibleAddressSpaces.removeFirst()
            
            state = .waitingForAddressSpaceInfoAck
            
            startTimeoutTimer()
            
            configurationTool?.sendGetMemorySpaceInformationCommand(destinationNodeId: node.nodeId, addressSpace: currentAddressSpace)
            
          }
          
        case .getAddressSpaceInformationReply, .getAddressSpaceInformationReplyLowAddressPresent:
          
          let _ = node.addAddressSpaceInformation(message: message)
          
          reload()
          
          if !possibleAddressSpaces.isEmpty {
            
            state = .waitingForAddressSpaceInfoAck
            
            currentAddressSpace = possibleAddressSpaces.removeFirst()
            
            startTimeoutTimer()
            
            configurationTool?.sendGetMemorySpaceInformationCommand(destinationNodeId: node.nodeId, addressSpace: currentAddressSpace)
            
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
