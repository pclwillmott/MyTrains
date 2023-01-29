//
//  IOChannelTC64MkIIOutputPropertySheetVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 28/01/2023.
//

import Foundation
import Cocoa

class IOChannelTC64MkIIOutputPropertySheetVC: NSViewController, NSWindowDelegate, IODevicePropertySheetDelegate {
  
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
    
    view.window?.title = ioChannel!.ioDevice.deviceName
    
    TC64ActionPaired.populate(comboBox: cboPaired, fromSet: ioChannel!.allowedActionPaired)
    
    TC64OutputType.populate(comboBox: cboOutputType)
    
    reloadData()
    
  }
  
  // MARK: Public Properties
  
  public var ioChannel : IOChannelTC64MkII?
  
  // MARK: Public Methods
  
  public func reloadData() {
    
    if let ioChannel = self.ioChannel {
      
      TC64ActionPaired.select(comboBox: cboPaired, value: ioChannel.actionPaired)
      
      TC64OutputType.select(comboBox: cboOutputType, value: ioChannel.ioType)
      
      if ioChannel.ioType.isLong {
        TC64LongTiming.populate(comboBox: cboTiming)
        TC64LongTiming.select(comboBox: cboTiming, value: ioChannel.outputLongTiming)
      }
      else {
        TC64ShortTiming.populate(comboBox: cboTiming)
        TC64ShortTiming.select(comboBox: cboTiming, value: ioChannel.outputShortTiming)
      }
      
      chkOutputInverted.boolValue = ioChannel.isOutputInverted
      
    }
    
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboPaired: NSComboBox!
  
  @IBOutlet weak var cboOutputType: NSComboBox!
  
  @IBAction func cboOutputTypeAction(_ sender: NSComboBox) {
    
    let outputType = TC64OutputType.selected(comboBox: cboOutputType)
    
    if outputType.isLong {
      TC64LongTiming.populate(comboBox: cboTiming)
      TC64LongTiming.select(comboBox: cboTiming, value: ioChannel!.outputLongTiming)
    }
    else {
      TC64ShortTiming.populate(comboBox: cboTiming)
      TC64ShortTiming.select(comboBox: cboTiming, value: ioChannel!.outputShortTiming)
    }

  }
  
  @IBOutlet weak var cboTiming: NSComboBox!
  
  @IBOutlet weak var chkOutputInverted: NSButton!
  
  @IBAction func btnReadAction(_ sender: NSButton) {
    
    ioChannel?.readChannel()
    
  }
  
  @IBAction func btnWriteAction(_ sender: NSButton) {
    
    if let ioChannel = self.ioChannel {
      
      ioChannel.actionPaired = TC64ActionPaired.selected(comboBox: cboPaired)
      
      ioChannel.ioType = TC64OutputType.selected(comboBox: cboOutputType)
      
      if ioChannel.ioType.isLong {
        ioChannel.outputLongTiming = TC64LongTiming.selected(comboBox: cboTiming)
      }
      else {
        ioChannel.outputShortTiming = TC64ShortTiming.selected(comboBox: cboTiming)
      }
      
      ioChannel.isOutputInverted = chkOutputInverted.boolValue
      
      ioChannel.writeChannel()
      
    }
  }
  
  
}
