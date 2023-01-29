//
//  IOFunctionTC64MkIIOutputPropertySheetVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 28/01/2023.
//

import Foundation
import Cocoa

class IOFunctionTC64MkIIOutputPropertySheetVC: NSViewController, NSWindowDelegate, IODevicePropertySheetDelegate {
  
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
    
    view.window?.title = ioFunction!.displayString()
    
    TC64Direction.populate(comboBox: cboDirection, fromSet: ioFunction!.allowedDirection)
    
    TC64Mode.populate(comboBox: cboMessage)
    
    TC64TransitionControl.populate(comboBox: cboTransitionControl)
    
    reloadData()
    
  }
  
  // MARK: Public Properties
  
  public var ioFunction : IOFunctionTC64MkII?
  
  // MARK: Public Methods
  
  public func reloadData() {
    
    if let ioFunction = self.ioFunction {
      
      view.window?.title = ioFunction.displayString()

      txtAddress.stringValue = "\(ioFunction.address)"
      
      TC64Direction.select(comboBox: cboDirection, value: ioFunction.direction)
      
      TC64Mode.select(comboBox: cboMessage, value: ioFunction.mode)
      
      TC64TransitionControl.select(comboBox: cboTransitionControl, value: ioFunction.transitionControl)
      
      chkInverted.boolValue = ioFunction.isInverted
      
    }
    
  }
  
  // MARK: Outlets & Actions
  
  
  @IBOutlet weak var txtAddress: NSTextField!
  
  @IBOutlet weak var cboDirection: NSComboBox!
  
  @IBOutlet weak var cboMessage: NSComboBox!
  
  @IBOutlet weak var cboTransitionControl: NSComboBox!
  
  @IBOutlet weak var chkInverted: NSButton!
  
  @IBAction func btnReadAction(_ sender: NSButton) {
    
    ioFunction?.ioChannel.propertySheetDelegate = self
    
    ioFunction?.ioChannel.readChannel()
    
  }
  
  @IBAction func btnWriteAction(_ sender: NSButton) {
    
    if let ioFunction = self.ioFunction {
      
      ioFunction.address = txtAddress.integerValue
      
      ioFunction.direction = TC64Direction.selected(comboBox: cboDirection)
      
      ioFunction.mode = TC64Mode.selected(comboBox: cboMessage)
      
      ioFunction.transitionControl = TC64TransitionControl.selected(comboBox: cboTransitionControl)
      
      ioFunction.isInverted = chkInverted.boolValue
      
      ioFunction.ioChannel.propertySheetDelegate = self
      
      ioFunction.ioChannel.writeChannel()
      
    }
  }
  
}
