//
//  IODeviceDS64PropertySheet.swift
//  MyTrains
//
//  Created by Paul Willmott on 14/01/2023.
//

import Foundation
import Cocoa

class IODeviceDS64PropertySheetVC: NSViewController, NSWindowDelegate {
  
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
    
    view.window?.title = ioDevice!.deviceName
    
    TurnoutMotorType.populate(comboBox: cboOutputType, fromSet: [.solenoid, .slowMotion])
    TurnoutMotorType.select(comboBox: cboOutputType, value: ioDevice!.outputType)
    
    lblTiming.stringValue = ioDevice!.outputType == .solenoid ? "Solenoid Pulse Length" : "Crossing Gate Blink Rate"
    
    cboTiming.removeAllItems()
    for index in 0...15 {
      cboTiming.addItem(withObjectValue: "\(index * 200) ms")
    }
    cboTiming.selectItem(at: ioDevice!.timing)
    
    chkOutputsPowerUpAtPowerOn.state = ioDevice!.outputsPowerUpAtPowerOn ? .on : .off
    
    chkLongStartupDelay.state = ioDevice!.isLongStartUpDelay ? .on : .off
    
    chkOutputsDoNotShutOff.state = ioDevice!.outputsDoNotShutOff ? .on : .off
    
    chkOnlyAcceptsComputerCommands.state = ioDevice!.ignoreSetSwCommands ? .on : .off
    
    chkEnableRouteCommandsFromInputs.state = ioDevice!.localRoutesUsingInputsEnabled ? .on : .off
    
    radToggle.state = ioDevice!.forcedOutputOnHigh ? .off : .on
    
    radForce.state = ioDevice!.forcedOutputOnHigh ? .on : .off
    
    chkEnableSensorMessages.state = ioDevice!.inputsForSensorMessagesEnabled ? .on : .off
    
    chkInputsForSensorsOnly.state = ioDevice!.inputsForSensorMessagesOnly ? .on : .off
    
    chkEnableOperationOfRoutes.state = ioDevice!.isLocalRoutesEnabled ? .on : .off
    
    chkEnableCrossingGate1.state = ioDevice!.isCrossingGate1Enabled ? .on : .off
    chkEnableCrossingGate2.state = ioDevice!.isCrossingGate2Enabled ? .on : .off
    chkEnableCrossingGate3.state = ioDevice!.isCrossingGate3Enabled ? .on : .off
    chkEnableCrossingGate4.state = ioDevice!.isCrossingGate4Enabled ? .on : .off

    SensorMessageType.populate(comboBox: cboSensorMessageType, fromSet: [.generalSensorReport, .turnoutSensorState])
    SensorMessageType.select(comboBox: cboSensorMessageType, value: ioDevice!.sensorMessageType)
    
  }
  
  // MARK: Public Properties
  
  public var ioDevice : IODeviceDS64? 
  
  // MARK: Outlets & Actions
  
  
  @IBOutlet weak var chkOnlyAcceptsComputerCommands: NSButton!
  
  @IBOutlet weak var chkOnlyAcceptsCommandsFromTrack: NSButton!
  
  @IBOutlet weak var chkOutputsPowerUpAtPowerOn: NSButton!
  
  @IBOutlet weak var chkLongStartupDelay: NSButton!
  
  @IBOutlet weak var chkOutputsDoNotShutOff: NSButton!
  
  @IBOutlet weak var cboOutputType: NSComboBox!
  
  @IBAction func cboOutputTypeAction(_ sender: NSComboBox) {
    lblTiming.stringValue = TurnoutMotorType.selected(comboBox: cboOutputType) == .solenoid ? "Solenoid Pulse Length" : "Crossing Gate Blink Rate"
  }
  
  @IBOutlet weak var lblTiming: NSTextField!
  
  @IBOutlet weak var cboTiming: NSComboBox!
  
  @IBOutlet weak var chkEnableCrossingGate1: NSButton!
  
  @IBOutlet weak var chkEnableCrossingGate2: NSButton!
  
  @IBOutlet weak var chkEnableCrossingGate3: NSButton!
  
  @IBOutlet weak var chkEnableCrossingGate4: NSButton!
  
  @IBOutlet weak var radToggle: NSButton!
  
  @IBAction func radToggleAction(_ sender: NSButton) {
    radForce.state = sender.state == .on ? .off : .on
  }
  
  @IBOutlet weak var radForce: NSButton!
  
  @IBAction func radForceAction(_ sender: NSButton) {
    radToggle.state = sender.state == .on ? .off : .on
  }
  
  @IBOutlet weak var chkEnableSensorMessages: NSButton!
  
  @IBOutlet weak var chkInputsForSensorsOnly: NSButton!
  
  @IBOutlet weak var cboSensorMessageType: NSComboBox!
  
  @IBOutlet weak var chkEnableOperationOfRoutes: NSButton!
  
  @IBOutlet weak var chkEnableRouteCommandsFromInputs: NSButton!
  
  @IBAction func btnRead(_ sender: NSButton) {
  }
  
  @IBAction func btnWrite(_ sender: NSButton) {
    
    if let ioDevice = ioDevice {
      
      ioDevice.outputType = TurnoutMotorType.selected(comboBox: cboOutputType)
      
      ioDevice.timing = cboTiming.indexOfSelectedItem
      
      ioDevice.outputsPowerUpAtPowerOn = chkOutputsPowerUpAtPowerOn.state == .on
      
      ioDevice.isLongStartUpDelay = chkLongStartupDelay.state == .on
      
      ioDevice.outputsDoNotShutOff = chkOutputsDoNotShutOff.state == .on
      
      ioDevice.ignoreSetSwCommands = chkOnlyAcceptsComputerCommands.state == .on
      
      ioDevice.localRoutesUsingInputsEnabled = chkEnableRouteCommandsFromInputs.state == .on
      
      ioDevice.forcedOutputOnHigh = radForce.boolValue
      
      ioDevice.inputsForSensorMessagesEnabled = chkEnableSensorMessages.state == .on
      
      ioDevice.obeySwitchCommandsFromTrackOnly = chkOnlyAcceptsCommandsFromTrack.state == .on
      
      ioDevice.inputsForSensorMessagesOnly = chkInputsForSensorsOnly.state == .on
      
      ioDevice.isCrossingGate1Enabled = chkEnableCrossingGate1.state == .on
      ioDevice.isCrossingGate2Enabled = chkEnableCrossingGate2.state == .on
      ioDevice.isCrossingGate3Enabled = chkEnableCrossingGate3.state == .on
      ioDevice.isCrossingGate4Enabled = chkEnableCrossingGate4.state == .on
      
      ioDevice.sensorMessageType = SensorMessageType.selected(comboBox: cboSensorMessageType)
      
    }
    
  }
  
}
