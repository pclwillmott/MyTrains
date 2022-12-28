//
//  TC64ConfigVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 28/12/2022.
//

import Foundation
import Cocoa

class TC64ConfigVC: NSViewController, NSWindowDelegate, InterfaceDelegate {
  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
    programmer?.removeObserver(id: observerId)
    observerId = -1
    programmer = nil
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    cboDeviceDS.dictionary = networkController.tc64s
    
    cboDevice.dataSource = cboDeviceDS
    
    cboProgrammerDS.dictionary = networkController.programmers
    
    cboProgrammer.dataSource = cboProgrammerDS
    
    if cboProgrammer.numberOfItems > 0 {
      cboProgrammer.selectItem(at: 0)
    }
    
    tabView.isHidden = true

  }
  
  // MARK: Private Properties
  
  private var cboDeviceDS : ComboBoxDictDS = ComboBoxDictDS()
  
  private var cboProgrammerDS : ComboBoxDictDS = ComboBoxDictDS()
  
  private var device: LocoNetDevice?
  
  private var observerId : Int = -1
  
  private var programmer : Interface?
  
  private var needToSetPRMode : Bool = false
  
  private var currentCV : Int = 1
  
  private var maxCV : Int = 0
  
  private var deviceAddr : Int = 0

  // MARK: Private Methods
  
  private func setup() {
  
    tabView.isHidden = true
    
    if observerId != -1 {
      self.programmer?.removeObserver(id: observerId)
      observerId = -1
      self.programmer = nil
    }
    
    if let programmer = cboProgrammerDS.editorObjectAt(index: cboProgrammer.indexOfSelectedItem) as? Interface {
      if let info = programmer.locoNetProductInfo, info.attributes.contains(.CommandStation) {
        self.programmer = networkController.commandStationInterface(commandStation: programmer)
        needToSetPRMode = false
      }
      else {
        self.programmer = programmer
        needToSetPRMode = true
      }
      if let cs = self.programmer {
        
        observerId = cs.addObserver(observer: self)
        
        if let device = cboDeviceDS.editorObjectAt(index: cboDevice.indexOfSelectedItem) as? LocoNetDevice {
          
          self.device = device
          
        }
        
        updateDisplay()
        
      }
      
    }
    
  }
  
  private func updateDisplay() {
    
    if let device = self.device {
      
      txtDCCAddress.integerValue = device.boardId
      
      lblFirmwareVersion.integerValue = device.firmwareVersion
      
      lblManufacturerId.integerValue = device.manufacturerId
      
      lblHardwareId.integerValue = device.hardwareId
      
      chkPortStateMemory.state = device.isPortStateEnabled ? .on : .off
      
      chkOpsModeEnabled.state = device.isOpsModeEnabled ? .on : .off
      
      chkIntTrackPowerOn.state = device.isInterrogatePwrOnEnabled ? .on : .off
      
      chkIntInputs.state = device.isInterrogateInputs ? .on : .off
      
      chkIntOutputs.state = device.isInterrogateOutputs ? .on : .off
      
      chkMasterMode.state = device.isMasterModeEnabled ? .on : .off
      
      lblFlashRewriteCount.integerValue = device.flashRewriteCount
      
      tabView.isHidden = false
      
    }
    else {
      tabView.isHidden = true
    }

  }
  
  // MARK: InterfaceDelegate Methods
  
  @objc func networkMessageReceived(message:NetworkMessage) {
    
    switch message.messageType {
    case .progSlotDataP1:

      if let device = self.device {
        
        var cvValue = message.message[10]
        
        let mask : UInt8 = 0b00000010
        
        cvValue |= ((message.message[8] & mask) == mask) ? 0b10000000 : 0
        
        device.cvs[currentCV-1].nextCVValue = Int(cvValue)
        
        updateDisplay()

      }

      if currentCV < maxCV {
        currentCV += 1
        lblStatus.stringValue = "Reading CV #\(currentCV)"
        programmer?.readCV(progMode: .operationsMode, cv: currentCV, address: deviceAddr)
      }
      else {
        lblStatus.stringValue = "Done"
      }
    default:
      break
    }
    
  }


  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboProgrammer: NSComboBox!
  
  
  @IBAction func cboProgrammerAction(_ sender: NSComboBox) {
    setup()
  }
  
  @IBOutlet weak var cboDevice: NSComboBox!
  
  @IBAction func cboDeviceAction(_ sender: NSComboBox) {
    setup()
  }
  
  @IBOutlet weak var tabView: NSTabView!
  
  @IBOutlet weak var txtDCCAddress: NSTextField!
  
  
  @IBAction func txtDCCAddressAction(_ sender: NSTextField) {
    device?.boardId = txtDCCAddress.integerValue
  }
  
  @IBOutlet weak var chkMasterMode: NSButton!
  
  @IBAction func chkMasterModeAction(_ sender: NSButton) {
    device?.isMasterModeEnabled = sender.state == .on
  }
  
  @IBOutlet weak var chkPortStateMemory: NSButton!
  
  @IBAction func chkPortStateAction(_ sender: NSButton) {
    device?.isPortStateEnabled = sender.state == .on
  }
  
  @IBOutlet weak var chkOpsModeEnabled: NSButton!
  
  @IBAction func chkOpsModeEnabledAction(_ sender: NSButton) {
    device?.isOpsModeEnabled = sender.state == .on
  }
  
  @IBOutlet weak var chkIntTrackPowerOn: NSButton!
  
  @IBAction func chkIntTrackPowerOnAction(_ sender: NSButton) {
    device?.isInterrogatePwrOnEnabled = sender.state == .on
  }
  
  @IBOutlet weak var chkIntInputs: NSButton!
  
  @IBAction func chkIntInputsAction(_ sender: NSButton) {
    device?.isInterrogateInputs = sender.state == .on
  }
  
  @IBOutlet weak var chkIntOutputs: NSButton!
  
  @IBAction func chkIntOutputsAction(_ sender: NSButton) {
    device?.isInterrogateOutputs = sender.state == .on
  }
  
  @IBOutlet weak var lblManufacturerId: NSTextField!
  
  @IBOutlet weak var lblHardwareId: NSTextField!
  
  @IBOutlet weak var lblFirmwareVersion: NSTextField!
  
  @IBOutlet weak var lblFlashRewriteCount: NSTextField!
  
  @IBOutlet weak var tvCVs: NSTableView!
  
  @IBAction func tvCVsAction(_ sender: NSTableView) {
  }
  
  
  @IBOutlet weak var btnReadAll: NSButton!
  
  @IBAction func btnReadAllAction(_ sender: NSButton) {
    currentCV = 1
    if let device = self.device, let info = device.locoNetProductInfo {
      maxCV = info.cvs
      deviceAddr = device.boardId
      lblStatus.stringValue = "Reading CV #\(currentCV)"
      programmer?.readCV(progMode: .operationsMode, cv: currentCV, address: deviceAddr)
    }
  }
  
  @IBOutlet weak var btnDiscardChanges: NSButton!
  
  @IBAction func btnDiscardChangesAction(_ sender: NSButton) {
    
    device?.discardChangesToCVs()
    updateDisplay()
    
  }
  
  @IBOutlet weak var btnWriteAll: NSButton!
  
  @IBAction func btnWriteAllAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var lblStatus: NSTextField!
  
  @IBOutlet weak var btnSave: NSButton!
  
  @IBAction func btnSaveAction(_ sender: NSButton) {
    
      device?.save()
    
  }
  
  
  
  
  
  
  
}

