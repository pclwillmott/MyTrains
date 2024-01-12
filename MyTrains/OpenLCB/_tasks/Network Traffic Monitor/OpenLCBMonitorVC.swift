//
//  OpenLCBMonitorVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/11/2023.
//

import Foundation
import Cocoa

class OpenLCBMonitorVC: NSViewController, NSWindowDelegate, OpenLCBCANDelegate {
  
  // MARK: Window & View Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
    
    guard let gateway else {
      return
    }
    
    gateway.removeObserver(id: observerId)
    
    myTrainsController.openLCBNetworkLayer!.removeObserver(id: observerId2)
    
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    txtMonitor.font = NSFont(name: "Menlo", size: 12)
    
    cboCANOptions.selectItem(at: 3)
    
    cboOpenLCBOptions.selectItem(at: 3)
    
    self.gateway = myTrainsController.openLCBNetworkLayer!.defaultCANGateway
    
    guard let gateway else {
      return
    }
    
    observerId = gateway.addObserver(observer: self)
    
    observerId2 = myTrainsController.openLCBNetworkLayer!.addObserver(observer: self)
        
  }
  
  // MARK: Private Properties

  private var isPaused : Bool {
    get {
      return btnPause.state == .on
    }
  }
  
  private var showCANReceived : Bool {
    let index = cboCANOptions.indexOfSelectedItem
    return index == 1 || index == 3
  }

  private var showCANSent : Bool {
    let index = cboCANOptions.indexOfSelectedItem
    return index == 2 || index == 3
  }

  private var showOpenLCBInternal : Bool {
    let index = cboOpenLCBOptions.indexOfSelectedItem
    return index == 1 || index == 3
  }
  
  private var showOpenLCBExternal : Bool {
    let index = cboOpenLCBOptions.indexOfSelectedItem
    return index == 2 || index == 3
  }
  
  private var gateway : OpenLCBCANGateway?
  
  private var observerId : Int = -1
  private var observerId2 : Int = -1

  private var lineBuffer : [String] = []

  // MARK: Private Methods
  
  private func addToConsole(message:String) {
  
    if !message.isEmpty {
      lineBuffer.append(message)
      
      while lineBuffer.count > 2000 {
        lineBuffer.removeFirst()
      }
    }
    
    if !isPaused {
      
      var newString = ""

      for line in lineBuffer {
        newString += "\(line)\n\n"
      }

      txtMonitor.string = "\(newString)"
      
      let range = NSMakeRange(txtMonitor.string.count - 1, 0)

      txtMonitor.scrollRangeToVisible(range)
      
    }

  }
  
  private func openLCBMessage(message:OpenLCBMessage) {
    
    var text = ""
    
    if let sourceNodeId = message.sourceNodeId {
      text += "\(sourceNodeId.toHexDotFormat(numberOfBytes: 6)) "
    }
    if let destinationNodeId = message.destinationNodeId {
      text += " → \(destinationNodeId.toHexDotFormat(numberOfBytes: 6)) "
    }
    text += "\(message.messageTypeIndicator) "
    if let datagramType = message.datagramType {
      text += "\n  \(datagramType) "
    }
    if message.messageTypeIndicator == .tractionControlCommand || message.messageTypeIndicator == .tractionControlReply {
      if let instruction = OpenLCBTractionControlInstructionType(rawValue: message.payload[0] & 0b01111111) {
        text += "\(instruction) "
      }
    }
    if let eventId = message.eventId {
      text += "\n  event: \(eventId.toHexDotFormat(numberOfBytes: 8)) "
      if let wellKnownEvent = OpenLCBWellKnownEvent(rawValue: eventId) {
        text += "\(wellKnownEvent) "
      }
      else if let wellKnownEvent = OpenLCBWellKnownEvent(rawValue: eventId & 0xffffffffffff0000) {
        text += "\(wellKnownEvent) "
      }
      else if let wellKnownEvent = OpenLCBWellKnownEvent(rawValue: eventId & 0xffff000000000000) {
        text += "\(wellKnownEvent) "
        if let locoNetMessage = message.locoNetMessage {
          text += "\(locoNetMessage.messageType) "
        }
        else if message.isLocationServicesEvent {
          text += "\(message.locationServicesFlagEntryExit!) id: \(message.trainNodeId!.toHexDotFormat(numberOfBytes: 6)) direction Relative: \(message.locationServicesFlagDirectionRelative!) direction Absolute: \(message.locationServicesFlagDirectionAbsolute!) contentType: \(message.locationServicesFlagContentFormat!) "
          if let blocks = message.locationServicesContent {
            for block in blocks {
              text += "\nblockType: \(block.blockType) content: \(block.content)"
            }
          }
        }
      }
    }
    if !message.payload.isEmpty {
      text += "\n  payload: "
      for byte in message.payload {
        text += "\(byte.toHex(numberOfDigits: 2)) "
      }
    }

    addToConsole(message: text)
    
  }
  
  private func canFrame(frame:LCCCANFrame) {
    
    addToConsole(message: frame.info)

  }
  
  // MARK: OpenLCBCANDelegate Methods
  
  @objc func OpenLCBMessageReceived(message: OpenLCBMessage) {
    openLCBMessage(message: message)
  }
  
  @objc func rawCANPacketReceived(packet:String) {
    if showCANReceived {
      var info = ""
      if let frame = LCCCANFrame(message: packet) {
        info = frame.info
      }
      addToConsole(message: "→ \(packet) \(info) ")
    }
  }
  
  @objc func rawCANPacketSent(packet:String) {
    if showCANSent {
      var info = ""
      if let frame = LCCCANFrame(message: packet) {
        info = frame.info
      }
      addToConsole(message: "← \(packet) \(info)")
    }
  }
  
  @objc func openLCBCANPacketReceived(packet:LCCCANFrame) {
//    canFrame(frame: packet)
  }
  
  @objc func openLCBCANPacketSent(packet:LCCCANFrame) {
//    canFrame(frame: packet)
  }

  // MARK: Outlets & Actions
  
  @IBOutlet weak var scvMonitor: NSScrollView!
  
  @IBOutlet var txtMonitor: NSTextView!
  
  @IBAction func btnClearAction(_ sender: NSButton) {
    lineBuffer.removeAll()
    txtMonitor.string = ""
  }
  
  @IBOutlet weak var btnPause: NSButton!
  
  @IBAction func btnPauseAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var cboCANOptions: NSComboBox!
  
  @IBOutlet weak var cboOpenLCBOptions: NSComboBox!
  
}

