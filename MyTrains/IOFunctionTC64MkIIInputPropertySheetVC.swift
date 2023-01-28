//
//  IOFunctionTC64MkIIInputPropertySheetVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 28/01/2023.
//

import Foundation
import Cocoa

class IOFunctionTC64MkIIInputPropertySheetVC: NSViewController, NSWindowDelegate, IODevicePropertySheetDelegate {
  
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
    
    view.window?.title = ioFunction!.ioChannel.ioDevice.deviceName
    
    TC64Direction.populate(comboBox: cboDirection, fromSet: ioFunction!.allowedDirection)
    
    TC64Mode.populate(comboBox: cboMessage)
    
    TC64TransitionControl.populate(comboBox: cboTransitionControl)
    
    SensorType.populate(comboBox: cboSensorType)
    
    reloadData()
    
  }
  
  // MARK: Public Properties
  
  public var ioFunction : IOFunctionTC64MkII?
  
  // MARK: Public Methods
  
  public func reloadData() {
    
    if let ioFunction = self.ioFunction {
      
      txtAddress.stringValue = "\(ioFunction.address)"
      
      TC64Direction.select(comboBox: cboDirection, value: ioFunction.direction)
      
      TC64Mode.select(comboBox: cboMessage, value: ioFunction.mode)
      
      TC64TransitionControl.select(comboBox: cboTransitionControl, value: ioFunction.transitionControl)
      
      SensorType.select(comboBox: cboSensorType, value: ioFunction.sensorType)
      
      txtDelayOn.stringValue = "\(ioFunction.delayOn)"
      
      txtDelayOff.stringValue = "\(ioFunction.delayOff)"
      
      chkInverted.boolValue = ioFunction.isInverted
      
    }
    
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var txtAddress: NSTextField!
  
  @IBOutlet weak var cboDirection: NSComboBox!
  
  @IBOutlet weak var cboMessage: NSComboBox!
  
  @IBOutlet weak var cboTransitionControl: NSComboBox!
  
  @IBOutlet weak var cboSensorType: NSComboBox!
  
  @IBOutlet weak var txtDelayOn: NSTextField!
  
  @IBOutlet weak var txtDelayOff: NSTextField!
  
  @IBOutlet weak var chkInverted: NSButton!
  
  @IBAction func btnReadAction(_ sender: NSButton) {
  }
  
  @IBAction func btnWriteAction(_ sender: NSButton) {
  }
  
}
