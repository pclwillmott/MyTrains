//
//  OpenLCBMonitorVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/11/2023.
//

import Foundation
import Cocoa

class OpenLCBMonitorVC: NSViewController, NSWindowDelegate, OpenLCBNetworkObserverDelegate {
  
  // MARK: Window & View Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
    myTrainsController.openLCBNetworkLayer?.removeObserver(id: observerId)
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    txtMonitor.font = NSFont(name: "Menlo", size: 12)
    
    cboCANOptions.selectItem(at: 3)
    
    cboOpenLCBOptions.selectItem(at: 3)
    
    observerId = myTrainsController.openLCBNetworkLayer!.addObserver(observer: self)
        
  }
  
  // MARK: Private Properties

  private var isPaused = false
  
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
  
  private var observerId : Int = -1

  private var lineBuffer : [String] = []

  // MARK: Private Methods
  
  // This is running in a background thread
  private func addToConsole(message:String) {
  
    if !message.isEmpty && !isPaused {
      
      // Update UI in main thread
      DispatchQueue.main.async {
        
        self.lineBuffer.append(message)
        
        while self.lineBuffer.count > 200 {
          self.lineBuffer.removeFirst()
        }
        
        var newString = ""

        for line in self.lineBuffer {
          newString += "\(line)\n"
        }
        
        self.txtMonitor.string = "\(newString)"
        let range = NSMakeRange(self.txtMonitor.string.count - 1, 0)
        self.txtMonitor.scrollRangeToVisible(range)
        
      }
      
    }

  }
  
  // MARK: OpenLCBNetworkObserverDelegate Methods
  
  // This is running in a background thread
  @objc func openLCBMessageReceived(message: OpenLCBMessage) {
    
    var text = ""
    
    if let sourceNodeId = message.sourceNodeId {
      text += "\(sourceNodeId.toHexDotFormat(numberOfBytes: 6))"
    }
    if let destinationNodeId = message.destinationNodeId {
      text += " → \(destinationNodeId.toHexDotFormat(numberOfBytes: 6)) "
    }
    
    text += String(repeating: " ", count: 39 - text.count)
    
    text += "\(message.messageTypeIndicator)"

    self.addToConsole(message: text)
    
  }
  
  // This is running in a background thread
  @objc func canFrameReceived(gateway:OpenLCBCANGateway, frame:LCCCANFrame) {
    addToConsole(message: "→ \(frame.info)")
  }
  
  // This is running in a background thread
  @objc func canFrameSent(gateway:OpenLCBCANGateway, frame:LCCCANFrame) {
    addToConsole(message: "← \(frame.info)")
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
    isPaused = sender.state == .on
  }
  
  private var _isPaused = false
  
  @IBOutlet weak var cboCANOptions: NSComboBox!
  
  @IBOutlet weak var cboOpenLCBOptions: NSComboBox!
  
}

