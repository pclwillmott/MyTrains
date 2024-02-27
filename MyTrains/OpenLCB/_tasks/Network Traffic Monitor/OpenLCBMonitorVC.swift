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
    
    guard let networkLayer = myTrainsController.openLCBNetworkLayer else {
      return
    }
    
    self.view.window?.delegate = self
    
    txtMonitor.font = NSFont(name: "Menlo", size: 12)
    
    cboCANOptions.selectItem(at: 3)
    
    cboOpenLCBOptions.selectItem(at: 3)
    
    observerId = networkLayer.addObserver(observer: self)
    
    networkLayer.isMonitorPaused = false
    
  }
  
  // MARK: Private Properties

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

  // MARK: Private Methods
  
  // MARK: OpenLCBNetworkObserverDelegate Methods
  
  @objc func updateMonitor(text: String) {
    guard !text.isEmpty else {
      return
    }
    txtMonitor.string = text
    let range = NSMakeRange(text.count - 1, 0)
    txtMonitor.scrollRangeToVisible(range)
  }

  // MARK: Outlets & Actions
  
  @IBOutlet weak var scvMonitor: NSScrollView!
  
  @IBOutlet var txtMonitor: NSTextView!
  
  @IBAction func btnClearAction(_ sender: NSButton) {
    guard let networkLayer = myTrainsController.openLCBNetworkLayer else {
      return
    }
    networkLayer.clearMonitorBuffer()
  }
  
  @IBOutlet weak var btnPause: NSButton!
  
  @IBAction func btnPauseAction(_ sender: NSButton) {
    guard let networkLayer = myTrainsController.openLCBNetworkLayer else {
      return
    }
    networkLayer.isMonitorPaused = sender.state == .on
  }
  
  @IBOutlet weak var cboCANOptions: NSComboBox!
  
  @IBOutlet weak var cboOpenLCBOptions: NSComboBox!
  
}

