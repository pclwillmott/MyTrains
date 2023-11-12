//
//  OpenLCBFirmwareUpdateVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/10/2023.
//

import Foundation
import Cocoa

private enum State {
  case idle
  case waitingForFreezeConfirmation
  case waitingForWriteReply
  case waitingForUnfreezeConfirmation
}

class OpenLCBFirmwareUpdateVC: NSViewController, NSWindowDelegate, OpenLCBConfigurationToolDelegate {
  
  // MARK: Window & View Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    guard let node, let configurationTool else {
      return
    }
    
    networkLayer = configurationTool.networkLayer
    
    nodeId = configurationTool.nodeId
    
    let title = node.userNodeName == "" ? "\(node.manufacturerName) - \(node.nodeModelName)" : node.userNodeName
    
    self.view.window?.title = "Update Firmware - \(title) (\(node.nodeId.toHexDotFormat(numberOfBytes: 6)))"
    
    btnStart.isEnabled = false
    btnCancel.isEnabled = false
    barProgress.isHidden = true
    
//    dmfPath = UserDefaults.standard.string(forKey: DEFAULT.IPL_DMF_FILENAME) ?? ""

  }
  
  // MARK: Private Properties
  
  private var networkLayer : OpenLCBNetworkLayer?
  
  private var nodeId : UInt64 = 0
  
  private var _dmfPath = ""
  
  private var buffer : [UInt8] = []

  private var data : [UInt8] = []
  
  private var startAddress : Int = 0
  
  private var dmfPath : String {
    get {
      return _dmfPath
    }
    set(value) {
      _dmfPath = value
      lblFilename.stringValue = dmfURL?.lastPathComponent ?? ""
      UserDefaults.standard.set(value, forKey: DEFAULT.IPL_DMF_FILENAME)
   }
  }

  private var dmfURL : URL? {
    get {
      let sfn = _dmfPath
      return sfn == "" ? nil : URL(fileURLWithPath: sfn)
    }
  }

  private var state : State = .idle {
    didSet {
      switch state {
      case .idle:
        btnCancel.isEnabled = false
      default:
        btnCancel.isEnabled = true
      }
    }
  }
  
  // MARK: Public Properties
  
  public var node: OpenLCBNode?
  
  public var configurationTool : OpenLCBNodeConfigurationTool?

  // MARK: Private Methods
  
  private func transferNextPart() {
    
    guard let node else {
      return
    }
    
    state = .waitingForWriteReply
    
    let size = min(64, buffer.count)
    
    data.removeAll()
    
    for index in 0...size - 1 {
      data.append(buffer[index])
    }
    
    networkLayer?.sendNodeMemoryWriteRequest(sourceNodeId: nodeId, destinationNodeId: node.nodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.firmware.rawValue, startAddress: startAddress, dataToWrite: data)
    
  }
  
  // MARK: OpenLCBConfigurationToolDelegate Methods
  
  func openLCBMessageReceived(message:OpenLCBMessage) {
    
    guard let node else {
      return
    }
    
    switch message.messageTypeIndicator {
      
    case .initializationCompleteSimpleSetSufficient, .initializationCompleteFullProtocolRequired:
      
      if message.sourceNodeId! == node.nodeId {
        
        switch state {
        case .waitingForFreezeConfirmation:
          transferNextPart()
        case .waitingForUnfreezeConfirmation:
          state = .idle
        default:
          break
        }
        
      }
      
    case .datagram:
      
      if message.destinationNodeId! == nodeId {
        
        if let datagramType = message.datagramType {
          
          switch datagramType {
            
          default:
            break
          }
          
        }
      }
      
    default:
      break
    }
    
  }

  // MARK: Outlets & Actions
  
  @IBOutlet weak var lblFilename: NSTextField!
  
  @IBOutlet weak var btnSelect: NSButton!
  
  @IBAction func btnSelectAction(_ sender: NSButton) {
    
    let dialog = NSOpenPanel()
    
    dialog.title                     = "Select"
    dialog.showsResizeIndicator      = true
    dialog.showsHiddenFiles          = false
    dialog.canChooseDirectories      = false
    dialog.canCreateDirectories      = true
    dialog.allowsMultipleSelection   = false
    dialog.canChooseFiles            = true
//    dialog.allowedFileTypes          = ["*.*"]
    dialog.allowsOtherFileTypes      = true
    
    if let url = dmfURL {
      dialog.nameFieldStringValue = url.lastPathComponent
    }
    
    if dialog.runModal() == .OK {
      
      btnCancel.isEnabled = false
      
      if let result = dialog.url {
        dmfPath = result.path
        btnStart.isEnabled = true
      }
      else {
      // User clicked on "Cancel"
        btnStart.isEnabled = !dmfPath.isEmpty
      }
    }
  }
  
  @IBOutlet weak var btnStart: NSButton!
  
  @IBAction func btnStartAction(_ sender: NSButton) {
    
    guard FileManager.default.fileExists(atPath: dmfPath), let node else {
      return
    }
    
    if let contents = NSData(contentsOfFile: dmfPath) {
      buffer.append(contentsOf: contents)
      startAddress = 0
      state = .waitingForFreezeConfirmation
      networkLayer?.sendFreezeCommand(sourceNodeId: nodeId, destinationNodeId: node.nodeId)
    }
    else {
      buffer = []
      state = .idle
    }
    
  }
  
  @IBOutlet weak var btnCancel: NSButton!
  
  @IBAction func btnCancelAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var barProgress: NSProgressIndicator!
  
}

