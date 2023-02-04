//
//  IOFunctionBXP88InputPropertySheetVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/01/2023.
//

import Foundation
import Cocoa

class IOFunctionBXP88InputPropertySheetVC: NSViewController, NSWindowDelegate {
  
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
    
    var sensorTypes : Set<SensorType> = []
    
    switch ioFunction!.ioFunctionNumber {
    case 1:
      sensorTypes = [.occupancy, .unconnected]
    case 2:
      sensorTypes = [.occupancy, .transponder, .unconnected]
    case 3:
      sensorTypes = [.trackFault, .unconnected]
    default:
      break
    }
    
    SensorType.populate(comboBox: cboSensorType, fromSet: sensorTypes)
    
    reloadData()
    
  }
 
  // MARK: Public Properties
  
  public var ioFunction : IOFunctionBXP88Input?
  
  // MARK: Public Methods
  
  public func reloadData() {
    
    if let ioFunction = self.ioFunction {
      view.window?.title = "\(ioFunction.displayString())"
      txtSensorAddress.stringValue = "\(ioFunction.address)"
      SensorType.select(comboBox: cboSensorType, value: ioFunction.sensorType)
      txtDelayOn.stringValue = "\(ioFunction.delayOn)"
      txtDelayOff.stringValue = "\(ioFunction.delayOff)"
      chkInverted.boolValue = ioFunction.inverted
      if let ioDevice = ioFunction.ioDevice as? IODeviceBXP88 {
        chkOccupancyDetectionEnabled.boolValue = ioDevice.isOccupancyReportingEnabled(detectionSection: ioFunction.ioChannel.ioChannelNumber)
        chkTranspondingReportingEnabled.boolValue = ioDevice.isTranspondingReportingEnabled(detectionSection: ioFunction.ioChannel.ioChannelNumber)
      }
      chkOccupancyDetectionEnabled.isHidden = ioFunction.ioFunctionNumber != 1
      chkTranspondingReportingEnabled.isHidden = ioFunction.ioFunctionNumber != 2
      chkTranspondingReportingEnabled.frame = chkOccupancyDetectionEnabled.frame
    }
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var chkOccupancyDetectionEnabled: NSButton!
  
  @IBOutlet weak var chkTranspondingReportingEnabled: NSButton!
  
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
      ioFunction.inverted = chkInverted.boolValue
      ioFunction.save()
      if let ioDevice = ioFunction.ioDevice as? IODeviceBXP88 {
        ioDevice.setOccupancyReportingEnabled(detectionSection: ioFunction.ioChannel.ioChannelNumber, isEnabled: chkOccupancyDetectionEnabled.boolValue)
        ioDevice.setTranspondingReportingEnabled(detectionSection: ioFunction.ioChannel.ioChannelNumber, isEnabled: chkTranspondingReportingEnabled.boolValue)
      }
    }
    
    view.window?.close()
  }
  
}
