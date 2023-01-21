//
//  IODeviceBXP88PropertySheetVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/01/2023.
//

import Foundation
import Cocoa

class IODeviceBXP88PropertySheetVC: NSViewController, NSWindowDelegate, IODevicePropertySheetDelegate {
  
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
    
    ShortCircuitDetectionType.populate(comboBox: cboShortCircuitDetectionSpeed)
    
    DetectionSensitivity.populate(comboBox: cboDetectionSensitivity)
    
    reloadData()
    
  }
  
  // MARK: Public Properties
  
  public var ioDevice : IODeviceBXP88?
  
  // MARK: Public Methods
  
  public func reloadData() {
    
    if let ioDevice = self.ioDevice {
      
      chkPowerManagerEnabled.boolValue = ioDevice.isPowerManagerEnabled
      
      chkPowerManagerReportingEnabled.boolValue = ioDevice.isPowerManagerReportingEnabled
      
      chkOpsModeReadbackEnabled.boolValue = ioDevice.isOpsModeReadbackEnabled
      
      ShortCircuitDetectionType.select(comboBox: cboShortCircuitDetectionSpeed, value: ioDevice.shortCircuitDetectionType)
      
      DetectionSensitivity.select(comboBox: cboDetectionSensitivity, value: ioDevice.detectionSensitivity)
      
      sendOccupiedMessageWhenFaulted.boolValue = ioDevice.sendOccupiedMessageWhenFaulted
      
      chkTranspondingEnabled.boolValue = ioDevice.isTranspondingEnabled
      
      chkFastFindEnabled.boolValue = ioDevice.isFastFindEnabled
      
      chkSelectiveTranspondingEnabled.boolValue = ioDevice.isSelectiveTranspondingEnabled
      
    }
    
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var chkPowerManagerEnabled: NSButton!
  
  @IBOutlet weak var chkPowerManagerReportingEnabled: NSButton!
  
  @IBOutlet weak var chkOpsModeReadbackEnabled: NSButton!
  
  @IBOutlet weak var cboShortCircuitDetectionSpeed: NSComboBox!
  
  @IBOutlet weak var cboDetectionSensitivity: NSComboBox!
  
  @IBOutlet weak var sendOccupiedMessageWhenFaulted: NSButton!
  
  @IBOutlet weak var chkTranspondingEnabled: NSButton!
  
  @IBOutlet weak var chkFastFindEnabled: NSButton!
  
  @IBOutlet weak var chkSelectiveTranspondingEnabled: NSButton!
  
  @IBAction func btnRead(_ sender: NSButton) {
    if let ioDevice = ioDevice {
      ioDevice.readOptionSwitches()
    }
  }
  
  @IBAction func btnWrite(_ sender: NSButton) {
    
    if let ioDevice = ioDevice {
      
      ioDevice.isPowerManagerEnabled = chkPowerManagerEnabled.boolValue
      
      ioDevice.isPowerManagerReportingEnabled = chkPowerManagerReportingEnabled.boolValue
      
      ioDevice.isOpsModeReadbackEnabled = chkOpsModeReadbackEnabled.boolValue
      
      ioDevice.shortCircuitDetectionType = ShortCircuitDetectionType.selected(comboBox: cboShortCircuitDetectionSpeed)
      
      ioDevice.detectionSensitivity = DetectionSensitivity.selected(comboBox: cboDetectionSensitivity)
      
      ioDevice.sendOccupiedMessageWhenFaulted = sendOccupiedMessageWhenFaulted.boolValue
      
      ioDevice.isTranspondingEnabled = chkTranspondingEnabled.boolValue
      
      ioDevice.isFastFindEnabled = chkFastFindEnabled.boolValue
      
      ioDevice.isSelectiveTranspondingEnabled = chkSelectiveTranspondingEnabled.boolValue
      
      ioDevice.writeOptionSwitches()
      
    }
    
  }
  
}
