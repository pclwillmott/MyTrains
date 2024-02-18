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
  case waitingForProtocolSupportReply
  case waitingForWriteReply
  case waitingForUnfreezeConfirmation
  case waitingToComplete
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
    
    state = .idle
    
//    dmfPath = UserDefaults.standard.string(forKey: DEFAULT.IPL_DMF_FILENAME) ?? ""

  }
  
  // MARK: Private Properties
  
  private var networkLayer : OpenLCBNetworkLayer?
  
  private var nodeId : UInt64 = 0
  
  private var _dmfPath = ""
  
  private var buffer : [UInt8] = []

  private var data : [UInt8] = []
  
  private var startAddress : Int = 0
  
  private var timeoutTimer : Timer?
  
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
        btnStart.isEnabled = !dmfPath.isEmpty
        btnCancel.isEnabled = false
        barProgress.isHidden = true
      default:
        btnStart.isEnabled = false
        btnCancel.isEnabled = true
        barProgress.isHidden = false
      }
    }
  }
  
  // MARK: Public Properties
  
  public var node: OpenLCBNode?
  
  public var configurationTool : OpenLCBNodeConfigurationTool?

  // MARK: Private Methods
 
  @objc func timeoutTimerAction() {
    
    stopTimeoutTimer()

    let alert = NSAlert()
    alert.informativeText = ""
    alert.addButton(withTitle: "OK")
    alert.alertStyle = .warning

    if state == .waitingToComplete {
      alert.messageText = "Firmware upgrade completed!"
    }
    else {
      alert.messageText = "The device is not responding. Firmware upgrade has been aborted."
    }
    
    alert.runModal()

    state = .idle
    
  }
  
  private func startTimeoutTimer(timeOut:OpenLCBDatagramTimeout) {
    let interval = timeOut.timeout
    timeoutTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timeoutTimerAction), userInfo: nil, repeats: false)
    RunLoop.current.add(timeoutTimer!, forMode: .common)
  }
  
  private func stopTimeoutTimer() {
    timeoutTimer?.invalidate()
    timeoutTimer = nil
  }

  private func transferNextPart() {
    
    guard let node else {
      return
    }
    
    barProgress.doubleValue += Double(data.count)

    if !data.isEmpty {
      startAddress += data.count
      buffer.removeFirst(data.count)
    }
    
    if buffer.isEmpty {
      
      state = .waitingForUnfreezeConfirmation
      
 //     networkLayer?.sendUnfreezeCommand(sourceNodeId: nodeId, destinationNodeId: node.nodeId)
      
    }
    else {
      
      state = .waitingForWriteReply
      
      let size = min(64, buffer.count)
      
      data = []
      
      for index in 0...size - 1 {
        data.append(buffer[index])
      }
      
 //     DispatchQueue.main.async {
   //     self.networkLayer?.sendNodeMemoryWriteRequest(sourceNodeId: self.nodeId, destinationNodeId: node.nodeId, addressSpace: OpenLCBNodeMemoryAddressSpace.firmware.rawValue, startAddress: self.startAddress, dataToWrite: self.data)
 //     }

    }
    
  }
  
  // MARK: OpenLCBConfigurationToolDelegate Methods
  
  func openLCBMessageReceived(message:OpenLCBMessage) {
    
    guard let node else {
      return
    }
    
    switch message.messageTypeIndicator {
    
    case .datagramReceivedOK:
      
      if message.destinationNodeId! == nodeId && state == .waitingForWriteReply {
        
        if let result = message.datagramReplyTimeOut {
          
          switch result {
          case .ok:
            transferNextPart()
          case .replyPendingNoTimeout:
            break
          default:
            startTimeoutTimer(timeOut: result)
          }
        }
        
      }
    case .datagramRejected:

      if message.destinationNodeId! == nodeId && state == .waitingForWriteReply {
        
        state = .idle
        
        let error = OpenLCBErrorCode(rawValue: UInt16(bigEndianData: [message.payload[0], message.payload[1]])!)!
        
        let alert = NSAlert()

        alert.messageText = "The device reported an error: \"\(error.userMessage)\". The firmware upgrade has been aborted"
        alert.informativeText = ""
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .warning

        alert.runModal()
        
      }
      
    case .protocolSupportReply:
      
      if message.destinationNodeId! == nodeId && state == .waitingForProtocolSupportReply {
        
        var protocols = message.payload
        while protocols.count < 3 {
          protocols.append(0x00)
        }
        
        let mask_FirmwareUpgradeActive : UInt8 = 0x10
        
        if (protocols[2] & mask_FirmwareUpgradeActive) == mask_FirmwareUpgradeActive {
          transferNextPart()
        }
        else {
          
          state = .idle
          
          let alert = NSAlert()

          alert.messageText = "The device is not in firmware upgarde mode. The firmware upgrade has been aborted."
          alert.informativeText = ""
          alert.addButton(withTitle: "OK")
          alert.alertStyle = .warning

          alert.runModal()

        }
        
      }
      
    case .initializationCompleteSimpleSetSufficient, .initializationCompleteFullProtocolRequired:
      
      if message.sourceNodeId! == node.nodeId {
        
        switch state {
        case .waitingForFreezeConfirmation:
          state = .waitingForProtocolSupportReply
     //     networkLayer?.sendProtocolSupportInquiry(sourceNodeId: nodeId, destinationNodeId: node.nodeId)
        case .waitingForUnfreezeConfirmation:
          
          state = .waitingToComplete
          startTimeoutTimer(timeOut: .ok)
          
        default:
          break
        }
        
      }
      
    case .datagram:
      
      if message.destinationNodeId! == nodeId {
        
        if let datagramType = message.datagramType {
          
          switch datagramType {
          case .writeReplyGeneric:
            
            if state == .waitingForWriteReply, let space = OpenLCBNodeMemoryAddressSpace(rawValue: message.payload[6]), space == .firmware {
              stopTimeoutTimer()
              transferNextPart()
            }
            
          case .writeReplyFailureGeneric:
            
            if state == .waitingForWriteReply, let space = OpenLCBNodeMemoryAddressSpace(rawValue: message.payload[6]), space == .firmware {
              
              stopTimeoutTimer()
              
              state = .idle
              
              let error = OpenLCBErrorCode(rawValue: UInt16(bigEndianData: [message.payload[7], message.payload[8]])!)!
              
              let alert = NSAlert()

              alert.messageText = "The device reported an error: \"\(error.userMessage)\". The firmware upgrade has been aborted"
              alert.informativeText = ""
              alert.addButton(withTitle: "OK")
              alert.alertStyle = .warning

              alert.runModal()

            }

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
    
    buffer = []
    data = []
    state = .idle
    barProgress.doubleValue = 0.0

    guard FileManager.default.fileExists(atPath: dmfPath), let node else {
      return
    }
    
    if let contents = NSData(contentsOfFile: dmfPath) {
      buffer.append(contentsOf: contents)
      barProgress.minValue = 0.0
      barProgress.maxValue = Double(buffer.count)
      startAddress = 0
      state = .waitingForFreezeConfirmation
 //     networkLayer?.sendFreezeCommand(sourceNodeId: nodeId, destinationNodeId: node.nodeId)
    }
    
  }
  
  @IBOutlet weak var btnCancel: NSButton!
  
  @IBAction func btnCancelAction(_ sender: NSButton) {
    state = .idle
  }
  
  @IBOutlet weak var barProgress: NSProgressIndicator!
  
}

