//
//  TC64ConfigVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 28/12/2022.
//

import Foundation
import Cocoa

enum TC64Mode {
  case idle
  case readAll
  case writeAll
  case readDefaults
}

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
    
    cboProgrammerDS.dictionary = networkController.interfaceDevices
    
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
  
  private var mode : TC64Mode = .idle
  
  private let specialCV : [Int] = [17, 18, 1, 112, 116, 117]
  
  private var tvCVsDS = TC64CVTableDS()

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
      
      txtDCCAddress.stringValue = "\(device.boardId)"
      
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

      tvCVsDS.cvs = device.cvs
      tvCVs.dataSource = tvCVsDS
      tvCVs.delegate = tvCVsDS
      tvCVs.reloadData()

      tabView.isHidden = false
      
    }
    else {
      tabView.isHidden = true
    }

  }
  
  // MARK: InterfaceDelegate Methods
  
  @objc func networkMessageReceived(message:NetworkMessage) {
    
    switch message.messageType {
      
    case .progCmdAcceptedBlind:
      
      if let device = self.device, mode == .writeAll {

        currentCV += 1
        let newCVNumber = currentCV < specialCV.count ? specialCV[currentCV] : 123 + currentCV

        if newCVNumber <= maxCV {
          lblStatus.stringValue = "Writing CV #\(newCVNumber)"
          programmer?.writeCV(progMode: .operationsMode, cv: newCVNumber, address: deviceAddr, value: device.cvs[newCVNumber - 1].nextCVValue)
        }
        else {
          
          let newAddress = device.cvs[17].nextCVValue | (device.cvs[16].nextCVValue << 8)
          
          if newAddress != device.boardId {
            
            let alert = NSAlert()

            alert.messageText = "The device address has been changed. The device must be power cycled in order for this to take effect."
            alert.informativeText = ""
            alert.addButton(withTitle: "OK")
            alert.alertStyle = .informational

            alert.runModal()

            device.boardId = txtDCCAddress.integerValue
            
          }
          
          lblStatus.stringValue = "Done"
          mode = .idle
          device.save()
        }

      }
     
    case .programmerBusy:
      
      if let device = self.device, mode == .writeAll {

        let newCVNumber = currentCV < specialCV.count ? specialCV[currentCV] : 123 + currentCV
        programmer?.writeCV(progMode: .operationsMode, cv: newCVNumber, address: deviceAddr, value: device.cvs[newCVNumber - 1].nextCVValue)

      }
      
      
    case .progSlotDataP1:

      var cvNumber = Int(message.message[9])
      
      let mask1 : UInt8 = 0b00000001
      let mask2 : UInt8 = 0b00010000
      let mask3 : UInt8 = 0b00100000
      
      cvNumber |= ((message.message[8] & mask1) == mask1) ? 0b0000000010000000 : 0
      cvNumber |= ((message.message[8] & mask2) == mask2) ? 0b0000000100000000 : 0
      cvNumber |= ((message.message[8] & mask3) == mask3) ? 0b0000001000000000 : 0
      
      cvNumber += 1
      
      if (mode == .readAll || mode == .readDefaults) && cvNumber == currentCV {
        
        if let device = self.device {
          
          var cvValue = message.message[10]
          
          let mask : UInt8 = 0b00000010
          
          cvValue |= ((message.message[8] & mask) == mask) ? 0b10000000 : 0
          
          if mode == .readAll {
            device.cvs[cvNumber - 1].nextCVValue = Int(cvValue)
          }
          else {
            device.cvs[cvNumber - 1].defaultValue = Int(cvValue)
          }
          
          updateDisplay()
          
        }
        
        if currentCV < maxCV {
          currentCV += 1
          lblStatus.stringValue = "Reading CV #\(currentCV)"
          programmer?.readCV(progMode: .operationsMode, cv: currentCV, address: deviceAddr)
        }
        else {
          lblStatus.stringValue = "Done"
          mode = .idle
        }
        
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
    if let device = self.device {
      let address = txtDCCAddress.integerValue
      device.cvs[16].nextCVValue = address >> 8
      device.cvs[17].nextCVValue = address & 0xff
    }
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
      mode = .readAll
      maxCV = info.cvs
      deviceAddr = device.boardId
      lblStatus.stringValue = "Reading CV #\(currentCV)"
      programmer?.readCV(progMode: .operationsMode, cv: currentCV, address: deviceAddr)
    }
  }
  
  @IBOutlet weak var btnDiscardChanges: NSButton!
  
  @IBAction func btnDiscardChangesAction(_ sender: NSButton) {
    
    mode = .idle
    device?.discardChangesToCVs()
    updateDisplay()
    
  }
  
  @IBOutlet weak var btnWriteAll: NSButton!
  
  @IBAction func btnWriteAllAction(_ sender: NSButton) {
    if let device = self.device, let info = device.locoNetProductInfo {
      mode = .writeAll
      maxCV = info.cvs
      deviceAddr = device.boardId
      lblStatus.stringValue = "Writing CV #\(currentCV)"
      currentCV = 0
      let newCVNumber = currentCV < specialCV.count ? specialCV[currentCV] : 123 + currentCV
      programmer?.writeCV(progMode: .operationsMode, cv: newCVNumber, address: deviceAddr, value: device.cvs[newCVNumber - 1].nextCVValue)
    }
  }
  
  @IBOutlet weak var lblStatus: NSTextField!
  
  @IBOutlet weak var btnSave: NSButton!
  
  @IBAction func btnSaveAction(_ sender: NSButton) {
    
      device?.save()
    
  }
  
  @IBAction func btnReadDefaultsAction(_ sender: NSButton) {
    currentCV = 1
    if let device = self.device, let info = device.locoNetProductInfo {
      mode = .readDefaults
      maxCV = info.cvs
      deviceAddr = device.boardId
      lblStatus.stringValue = "Reading CV #\(currentCV)"
      programmer?.readCV(progMode: .operationsMode, cv: currentCV, address: deviceAddr)
    }
  }
  
  @IBAction func chkSupportedAction(_ sender: NSButton) {
    if let device = self.device {
      let item = device.cvs[sender.tag]
      item.nextIsEnabled = sender.state == .on
    }
  }
  
  @IBAction func txtDescriptionAction(_ sender: NSTextField) {
    if let device = self.device {
      let item = device.cvs[sender.tag]
      item.nextCustomDescription = sender.stringValue
    }
  }
  
  @IBAction func cboNumberBaseAction(_ sender: NSComboBox) {
    if let device = self.device {
      let item = device.cvs[sender.tag]
      item.nextCustomNumberBase = CVNumberBase.selected(comboBox: sender)
      tvCVs.reloadData()
    }
  }
  
  @IBAction func txtDefaultAction(_ sender: NSTextField) {
    if let device = self.device {
      let item = device.cvs[sender.tag]
      item.nextDefaultValue = sender.integerValue
    }
  }
  
  @IBAction func txtValueAction(_ sender: NSTextField) {
    if let device = self.device {
      let item = device.cvs[sender.tag]
      item.nextCVValue = sender.integerValue
    }
  }
  
}

