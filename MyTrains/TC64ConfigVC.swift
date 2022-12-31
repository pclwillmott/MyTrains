//
//  TC64ConfigVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 28/12/2022.
//

import Foundation
import Cocoa

enum TC64ConfigMode {
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
    
    let deviceId = UserDefaults.standard.integer(forKey: DEFAULT.TC64_CONFIG_LAST_DEVICE)

    cboDevice.selectItem(at: cboDeviceDS.indexWithKey(key: deviceId) ?? -1)
    
    cboProgrammerDS.dictionary = networkController.interfaceDevices

    cboProgrammer.dataSource = cboProgrammerDS
    
    let interfaceId = UserDefaults.standard.integer(forKey: DEFAULT.TC64_CONFIG_INTERFACE)
    
    cboProgrammer.selectItem(at: cboProgrammerDS.indexWithKey(key: interfaceId) ?? -1)
    
    tabView.isHidden = true
    
    cboIOPortNumber.removeAllItems()
    for index in 1...64 {
      cboIOPortNumber.addItem(withObjectValue: "\(index)")
    }
    cboIOPortNumber.selectItem(at: 0)
    
    InputOutput.populate(comboBox: cboIOPortType)
    
    TC64Mode.populate(comboBox: cboOMessageTypePrimary)
    TC64Mode.populate(comboBox: cboOMessageTypeSecondary)
    TC64Mode.populate(comboBox: cboOMessageTypeTertiary)
    TC64Mode.populate(comboBox: cboIMessageTypePrimary)
    TC64Mode.populate(comboBox: cboIMessageTypeSecondary)
    TC64Mode.populate(comboBox: cboIMessageTypeTertiary)

    TC64TransitionControl.populate(comboBox: cboOTControlPrimary)
    TC64TransitionControl.populate(comboBox: cboOTControlSecondary)
    TC64TransitionControl.populate(comboBox: cboOTControlTertiary)
    TC64TransitionControl.populate(comboBox: cboITControlPrimary)
    TC64TransitionControl.populate(comboBox: cboITControlSecondary)
    TC64TransitionControl.populate(comboBox: cboITControlTertiary)
    
    TC64DebounceTiming.populate(comboBox: cboIDebounceTiming)
    
    TC64OutputPolarityPrimary.populate(comboBox: cboOPolarityPrimary)
    TC64Polarity.populate(comboBox: cboOPolaritySecondary)
    TC64Polarity.populate(comboBox: cboOPolarityTertiary)

    TC64InputPolarityPrimary.populate(comboBox: cboIPolarityPrimary)
    TC64Polarity.populate(comboBox: cboIPolaritySecondary)
    TC64Polarity.populate(comboBox: cboIPolarityTertiary)
    
    TC64OutputType.populate(comboBox: cboOutputType)
    
    TC64Action.populate(comboBox: cboIAction)
    
    TC64Paired.populate(comboBox: cboOutputPaired)

    boxInput.frame.origin.x = 19
    boxInput.frame.origin.y = 7
    boxOutput.frame.origin.x = 19
    boxOutput.frame.origin.y = 7
    
    lblStatus.stringValue = ""

    setup()

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
  
  private var mode : TC64ConfigMode = .idle
  
  private let specialCV : [Int] = [17, 18, 1, 112, 116, 117]
  
  private var tvCVsDS = TC64CVTableDS()
  
  private var currentPort : TC64IOPort? {
    get {
      if let device = self.device {
        return device.tc64IOPorts[cboIOPortNumber.indexOfSelectedItem]
      }
      return nil
    }
  }

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
        
        UserDefaults.standard.set(cs.primaryKey, forKey: DEFAULT.TC64_CONFIG_INTERFACE)

        observerId = cs.addObserver(observer: self)
        
        if let device = cboDeviceDS.editorObjectAt(index: cboDevice.indexOfSelectedItem) as? LocoNetDevice {
          
          UserDefaults.standard.set(device.primaryKey, forKey: DEFAULT.TC64_CONFIG_LAST_DEVICE)

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
      
      if let port = currentPort {
        
        InputOutput.select(comboBox: cboIOPortType, value: port.io)
        
        lblIOPortName.stringValue = port.ioPortName
        
        boxInput.isHidden = port.io == .output
        boxOutput.isHidden = !boxInput.isHidden
        
        TC64DebounceTiming.select(comboBox: cboIDebounceTiming, value: port.debounceTiming)
        
        TC64Paired.select(comboBox: cboOutputPaired, value: port.paired)
        
        TC64Action.select(comboBox: cboIAction, value: port.action)
        
        if port.ioType.isLong {
          TC64LongTiming.populate(comboBox: cboOutputTiming)
          TC64LongTiming.select(comboBox: cboOutputTiming, value: port.outputLongTiming)
        }
        else {
          TC64ShortTiming.populate(comboBox: cboOutputTiming)
          TC64ShortTiming.select(comboBox: cboOutputTiming, value: port.outputShortTiming)
        }
        
        TC64TransitionControl.select(comboBox: cboOTControlPrimary, value: port.transitionControlPrimary)
        TC64TransitionControl.select(comboBox: cboOTControlSecondary, value: port.transitionControlSecondary)
        TC64TransitionControl.select(comboBox: cboOTControlTertiary, value: port.transitionControlTertiary)
        TC64TransitionControl.select(comboBox: cboITControlPrimary, value: port.transitionControlPrimary)
        TC64TransitionControl.select(comboBox: cboITControlSecondary, value: port.transitionControlSecondary)
        TC64TransitionControl.select(comboBox: cboITControlTertiary, value: port.transitionControlTertiary)

        TC64Mode.select(comboBox: cboOMessageTypePrimary, value: port.modePrimary)
        TC64Mode.select(comboBox: cboOMessageTypeSecondary, value: port.modeSecondary)
        TC64Mode.select(comboBox: cboOMessageTypeTertiary, value: port.modeTertiary)
        TC64Mode.select(comboBox: cboIMessageTypePrimary, value: port.modePrimary)
        TC64Mode.select(comboBox: cboIMessageTypeSecondary, value: port.modeSecondary)
        TC64Mode.select(comboBox: cboIMessageTypeTertiary, value: port.modeTertiary)

        chkOutputInverted.state = port.isOutputInverted ? .on : .off
        
        txtOAddressPrimary.stringValue = "\(port.addressPrimary)"
        txtOAddressSecondary.stringValue = "\(port.addressSecondary)"
        txtOAddressTertiary.stringValue = "\(port.addressTertiary)"
        txtIAddressPrimary.stringValue = "\(port.addressPrimary)"
        txtIAddressSecondary.stringValue = "\(port.addressSecondary)"
        txtIAddressTertiary.stringValue = "\(port.addressTertiary)"
        
        TC64OutputPolarityPrimary.select(comboBox: cboOPolarityPrimary, value: port.outputPolarityPrimary)
        TC64Polarity.select(comboBox: cboOPolaritySecondary, value: port.polaritySecondary)
        TC64Polarity.select(comboBox: cboOPolarityTertiary, value: port.polarityTertiary)
        TC64InputPolarityPrimary.select(comboBox: cboIPolarityPrimary, value: port.inputPolarityPrimary)
        TC64Polarity.select(comboBox: cboIPolaritySecondary, value: port.polaritySecondary)
        TC64Polarity.select(comboBox: cboIPolarityTertiary, value: port.polarityTertiary)
        
        TC64OutputType.select(comboBox: cboOutputType, value: port.ioType)

      }
      
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
  
  @IBOutlet weak var cboIOPortNumber: NSComboBox!
  
  @IBAction func cboIOPortNumberAction(_ sender: NSComboBox) {
    updateDisplay()
  }
  
  @IBOutlet weak var lblIOPortName: NSTextField!
  
  @IBOutlet weak var cboIOPortType: NSComboBox!
  
  @IBAction func cboIOPortTypeAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.io = InputOutput.selected(comboBox: cboIOPortType)
      updateDisplay()
    }
  }
  
  @IBOutlet weak var boxOutput: NSBox!
  
  @IBOutlet weak var cboOutputPaired: NSComboBox!
  
  @IBAction func cboOutputPairedAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.paired = TC64Paired.selected(comboBox: sender)
      updateDisplay()
    }
  }
  
  @IBOutlet weak var cboOutputType: NSComboBox!
  
  @IBAction func cboOutputTypeAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.ioType = TC64OutputType.selected(comboBox: sender)
      updateDisplay()
    }
  }
  
  @IBOutlet weak var cboOutputTiming: NSComboBox!
  
  @IBAction func cboOutputTimingAction(_ sender: NSComboBox) {
    if let port = currentPort {
      if port.ioType.isLong {
        port.outputLongTiming = TC64LongTiming.selected(comboBox: sender)
      }
      else {
        port.outputShortTiming = TC64ShortTiming.selected(comboBox: sender)
      }
      updateDisplay()
    }
  }
  
  @IBOutlet weak var chkOutputInverted: NSButton!
  
  @IBAction func chkOutputInvertedAction(_ sender: NSButton) {
    if let port = currentPort {
      port.isOutputInverted = chkOutputInverted.state == .on
      updateDisplay()
    }
  }
  
  @IBOutlet weak var txtOAddressPrimary: NSTextField!
  
  
  @IBAction func txtOAddressPrimaryAction(_ sender: NSTextField) {
    if let port = currentPort {
      port.addressPrimary = sender.integerValue
      updateDisplay()
    }
  }
  
  @IBOutlet weak var txtOAddressSecondary: NSTextField!
  
  @IBAction func txtOAddressSecondaryAction(_ sender: NSTextField) {
    if let port = currentPort {
      port.addressSecondary = sender.integerValue
      updateDisplay()
    }
  }
  
  @IBOutlet weak var txtOAddressTertiary: NSTextField!
  
  @IBAction func txtOAddressTertiaryAction(_ sender: NSTextField) {
    if let port = currentPort {
      port.addressTertiary = sender.integerValue
      updateDisplay()
    }
  }
  
  @IBOutlet weak var cboOPolarityPrimary: NSComboBox!
  
  @IBAction func cboOPolarityPrimaryAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.outputPolarityPrimary = TC64OutputPolarityPrimary.selected(comboBox: sender)
      updateDisplay()
    }
  }
  
  @IBOutlet weak var cboOPolaritySecondary: NSComboBox!
  
  @IBAction func cboOPolaritySecondaryAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.polaritySecondary = TC64Polarity.selected(comboBox: sender)
      updateDisplay()
    }
  }
  
  @IBOutlet weak var cboOPolarityTertiary: NSComboBox!
  
  @IBAction func cboOPolarityTertiaryAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.polarityTertiary = TC64Polarity.selected(comboBox: sender)
      updateDisplay()
    }
  }
  
  @IBOutlet weak var cboOMessageTypePrimary: NSComboBox!
  
  @IBAction func cboOMessageTypePrimaryAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.modePrimary = TC64Mode.selected(comboBox: sender)
      updateDisplay()
    }
  }
  
  @IBOutlet weak var cboOMessageTypeSecondary: NSComboBox!
  
  @IBAction func cboOMessageTypeSecondaryAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.modeSecondary = TC64Mode.selected(comboBox: sender)
      updateDisplay()
    }
  }
  
  @IBOutlet weak var cboOMessageTypeTertiary: NSComboBox!
  
  @IBAction func cboOMessageTypeTertiaryAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.modeTertiary = TC64Mode.selected(comboBox: sender)
      updateDisplay()
    }
  }
  
  @IBOutlet weak var cboOTControlPrimary: NSComboBox!
  
  @IBAction func cboOTControlPrimaryAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.transitionControlPrimary = TC64TransitionControl.selected(comboBox: sender)
      updateDisplay()
    }
  }
  
  @IBOutlet weak var cboOTControlSecondary: NSComboBox!
  
  @IBAction func cboOTControlSecondaryAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.transitionControlSecondary = TC64TransitionControl.selected(comboBox: sender)
      updateDisplay()
    }
  }
  
  @IBOutlet weak var cboOTControlTertiary: NSComboBox!
  
  @IBAction func cboOTControlTertiaryAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.transitionControlTertiary = TC64TransitionControl.selected(comboBox: sender)
      updateDisplay()
    }
  }
  
  @IBOutlet weak var boxInput: NSBox!
  
  @IBOutlet weak var cboIAction: NSComboBox!
  
  @IBAction func cboIActionAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.action = TC64Action.selected(comboBox: sender)
      updateDisplay()
    }
  }
  
  @IBOutlet weak var cboIDebounceTiming: NSComboBox!
  
  @IBAction func cboIDebounceTimingAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.debounceTiming = TC64DebounceTiming.selected(comboBox: sender)
      updateDisplay()
    }
  }
  
  @IBOutlet weak var txtIAddressPrimary: NSTextField!
  
  @IBAction func txtIAddressPrimaryAction(_ sender: NSTextField) {
    if let port = currentPort {
      port.addressPrimary = sender.integerValue
      updateDisplay()
    }
  }
  
  @IBOutlet weak var txtIAddressSecondary: NSTextField!
  
  @IBAction func txtIAddressSecondaryAction(_ sender: NSTextField) {
    if let port = currentPort {
      port.addressSecondary = sender.integerValue
      updateDisplay()
    }
  }
  
  @IBOutlet weak var txtIAddressTertiary: NSTextField!
  
  @IBAction func txtIAddressTertiaryAction(_ sender: NSTextField) {
    if let port = currentPort {
      port.addressTertiary = sender.integerValue
      updateDisplay()
    }
  }
  
  @IBOutlet weak var cboIPolarityPrimary: NSComboBox!
  
  @IBAction func cboIPolarityPrimaryAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.inputPolarityPrimary = TC64InputPolarityPrimary.selected(comboBox: sender)
      updateDisplay()
    }
  }
  
  @IBOutlet weak var cboIPolaritySecondary: NSComboBox!
  
  @IBAction func cboIPolaritySecondaryAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.polaritySecondary = TC64Polarity.selected(comboBox: sender)
      updateDisplay()
    }
  }
  
  @IBOutlet weak var cboIPolarityTertiary: NSComboBox!
  
  @IBAction func cboIPolarityTertiaryAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.polarityTertiary = TC64Polarity.selected(comboBox: sender)
      updateDisplay()
    }
  }
  
  @IBOutlet weak var cboIMessageTypePrimary: NSComboBox!
  
  @IBAction func cboIMessageTypePrimaryAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.modePrimary = TC64Mode.selected(comboBox: sender)
      updateDisplay()
    }
  }
  
  @IBOutlet weak var cboIMessageTypeSecondary: NSComboBox!
  
  @IBAction func cboIMessageTypeSecondaryAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.modeSecondary = TC64Mode.selected(comboBox: sender)
      updateDisplay()
    }
  }
  
  @IBOutlet weak var cboIMessageTypeTertiary: NSComboBox!
  
  @IBAction func cboIMessageTypeTertiaryAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.modeTertiary = TC64Mode.selected(comboBox: sender)
      updateDisplay()
    }
  }
  
  @IBOutlet weak var cboITControlPrimary: NSComboBox!
  
  @IBAction func cboITControlPrimaryAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.transitionControlPrimary = TC64TransitionControl.selected(comboBox: sender)
      updateDisplay()
    }
  }
  
  @IBOutlet weak var cboITControlSecondary: NSComboBox!
  
  @IBAction func cboITControlSecondaryAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.transitionControlSecondary = TC64TransitionControl.selected(comboBox: sender)
      updateDisplay()
    }
  }
  
  @IBOutlet weak var cboITControlTertiary: NSComboBox!
  
  @IBAction func cboITControlTertiaryAction(_ sender: NSComboBox) {
    if let port = currentPort {
      port.transitionControlTertiary = TC64TransitionControl.selected(comboBox: sender)
      updateDisplay()
    }
  }
  
  
  
  
  
}

