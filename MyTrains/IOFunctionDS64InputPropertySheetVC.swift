//
//  IOFunctionDS64InputPropertySheetVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 15/01/2023.
//

import Foundation
import Cocoa

class IOFunctionDS64InputPropertySheetVC: NSViewController, NSWindowDelegate {
  
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
    
    SensorType.populate(comboBox: cboSensorType)
    
    reloadData()
    
  }
 
  // MARK: Public Properties
  
  public var ioFunction : IOFunctionDS64Input?
  
  // MARK: Public Methods
  
  public func reloadData() {
    
    if let ioFunction = self.ioFunction {
      view.window?.title = "\(ioFunction.displayString())"
      txtSensorAddress.stringValue = "\(ioFunction.address)"
      SensorType.select(comboBox: cboSensorType, value: ioFunction.sensorType)
      txtDelayOn.stringValue = "\(ioFunction.delayOn)"
      txtDelayOff.stringValue = "\(ioFunction.delayOff)"
      chkInverted.state = ioFunction.inverted ? .on : .off
    }
  }
  
  // MARK: Outlets & Actions
  
  
  @IBOutlet weak var txtSensorAddress: NSTextField!
  
  @IBOutlet weak var cboSensorType: NSComboBox!
  
  @IBOutlet weak var txtDelayOn: NSTextField!
  
  @IBOutlet weak var txtDelayOff: NSTextField!
  
  @IBOutlet weak var chkInverted: NSButton!
  
  @IBAction func btnSaveAction(_ sender: NSButton) {
    
    if let ioFunction = self.ioFunction {
      ioFunction.sensorType = SensorType.selected(comboBox: cboSensorType)
      ioFunction.delayOn = txtDelayOn.integerValue
      ioFunction.delayOff = txtDelayOff.integerValue
      ioFunction.inverted = chkInverted.state == .on
      ioFunction.save()
    }
    
    view.window?.close()
    
  }
  
}
