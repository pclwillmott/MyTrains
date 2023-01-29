//
//  IODeviceTC64MkIIPropertySheetVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/01/2023.
//

import Foundation
import Cocoa

class IODeviceTC64MkIIPropertySheetVC: NSViewController, NSWindowDelegate, IODevicePropertySheetDelegate {
  
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
    
    reloadData()
    
  }
  
  // MARK: Public Properties
  
  public var ioDevice : IODeviceTC64MkII?
  
  // MARK: Public Methods
  
  public func reloadData() {
    
    if let ioDevice = self.ioDevice {
      
      lblManufacturerId.stringValue = "\(ioDevice.manufacturerId)"
      
      lblHardwareId.stringValue = "\(ioDevice.hardwareId)"
      
      lblFirmwareVersion.stringValue = "\(ioDevice.firmwareVersion)"
      
      lblFlashRewriteCount.stringValue = "\(ioDevice.flashRewriteCount)"
      
      chkMasterMode.boolValue = ioDevice.isMasterModeEnabled
      
      chkPortStateMemory.boolValue = ioDevice.isPortStateEnabled
      
      chkOpsModeEnable.boolValue = ioDevice.isOpsModeEnabled
      
      chkIntTrackPowerOn.boolValue = ioDevice.isInterrogatePwrOnEnabled
      
      chkIntInputs.boolValue = ioDevice.isInterrogateInputs
      
      chkIntOutputs.boolValue = ioDevice.isInterrogateOutputs
      
    }
    
  }
  
  // MARK: Outlets & Actions
 
  @IBOutlet weak var lblManufacturerId: NSTextField!
  
  @IBOutlet weak var lblHardwareId: NSTextField!
  
  @IBOutlet weak var lblFirmwareVersion: NSTextField!
  
  @IBOutlet weak var lblFlashRewriteCount: NSTextField!
  
  @IBOutlet weak var chkMasterMode: NSButton!
  
  @IBOutlet weak var chkPortStateMemory: NSButton!
  
  @IBOutlet weak var chkOpsModeEnable: NSButton!
  
  @IBOutlet weak var chkIntTrackPowerOn: NSButton!
  
  @IBOutlet weak var chkIntInputs: NSButton!
  
  @IBOutlet weak var chkIntOutputs: NSButton!
  
  @IBAction func btnReadAction(_ sender: NSButton) {
    
    ioDevice?.readDeviceCVs()
    
  }
  
  @IBAction func btnWriteAction(_ sender: NSButton) {
    
    if let ioDevice = self.ioDevice {
      
      ioDevice.isPortStateEnabled = chkPortStateMemory.boolValue
      
      ioDevice.isOpsModeEnabled = chkOpsModeEnable.boolValue
      
      ioDevice.isInterrogatePwrOnEnabled = chkIntTrackPowerOn.boolValue
      
      ioDevice.isInterrogateInputs = chkIntInputs.boolValue
      
      ioDevice.isInterrogateOutputs = chkIntOutputs.boolValue
      
      ioDevice.isMasterModeEnabled = chkMasterMode.boolValue
      
      ioDevice.writeDeviceCVs()
      
    }
    
  }
  
  @IBAction func btnReadAllAction(_ sender: NSButton) {
    
    ioDevice?.readAllChannelCVs()
    
  }
  
  @IBAction func btnSetToDefaults(_ sender: Any) {
    
    ioDevice?.setToDefaults()
    
  }
  
}

