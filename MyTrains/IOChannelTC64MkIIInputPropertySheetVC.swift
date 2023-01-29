//
//  IOChannelTC64MkIIInputPropertySheetVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 28/01/2023.
//

import Foundation
import Cocoa

class IOChannelTC64MkIIInputPropertySheetVC: NSViewController, NSWindowDelegate, IODevicePropertySheetDelegate {
  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
    stopModal()
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    view.window?.title = ioChannel!.displayString()
    
    TC64ActionPaired.populate(comboBox: cboAction, fromSet: ioChannel!.allowedActionPaired)
    
    TC64DebounceTiming.populate(comboBox: cboDebounce)
    
    reloadData()
    
  }
  
  // MARK: Public Properties
  
  public var ioChannel : IOChannelTC64MkII?
  
  // MARK: Public Methods
  
  public func reloadData() {
    
    if let ioChannel = self.ioChannel {
      
      TC64ActionPaired.select(comboBox: cboAction, value: ioChannel.actionPaired)
      
      TC64DebounceTiming.select(comboBox: cboDebounce, value: ioChannel.debounceTiming)
      
    }
    
  }
  
  // MARK: Outlets & Actions
  
  
  @IBOutlet weak var cboAction: NSComboBox!
  
  @IBOutlet weak var cboDebounce: NSComboBox!
  
  @IBAction func btnReadAction(_ sender: NSButton) {
    
    ioChannel?.readChannel()

  }
  
  @IBAction func btnWriteAction(_ sender: NSButton) {
    
    if let ioChannel = self.ioChannel {
      
      ioChannel.actionPaired = TC64ActionPaired.selected(comboBox: cboAction)
      
      ioChannel.debounceTiming = TC64DebounceTiming.selected(comboBox: cboDebounce)
      
      ioChannel.writeChannel()
      
    }

  }
  
}

