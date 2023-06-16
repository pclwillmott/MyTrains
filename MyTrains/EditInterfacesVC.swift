//
//  EditInterfacesVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/05/2022.
//

import Foundation
import Cocoa

private enum InitialState {
  case existingInterfaceOpen
  case existingInterfaceClosed
  case temporaryInterface
  case inactive
}

class EditInterfacesVC: NSViewController, NSWindowDelegate, DBEditorDelegate, MyTrainsControllerDelegate, InterfaceDelegate {
 
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
    
    cboDeviceTypeDS.dictionary = interfaceProductDictionary
    
    cboDeviceType.dataSource = cboDeviceTypeDS
    
    BaudRate.populate(comboBox: cboBaudrate)
    
    FlowControl.populate(comboBox: cboFlowControl)
    
    MTSerialPortManager.populate(comboBox: cboPort)

    editorView.delegate = self
    
    editorView.tabView = self.tabView
    
    editorView.dictionary = myTrainsController.interfaceDevices
    
  }
  
  // MARK: Private Properties
  
  private var interfaceProductDictionary = LocoNetProducts.productDictionary(attributes: [.ComputerInterface])
  
  private var cboDeviceTypeDS = ComboBoxDictDS()
  
  private var interface : Interface?
  
  private var tempInterface : InterfaceLocoNet?
  
  private var initialState : InitialState = .inactive

  var observerId : Int = -1
  
  var partialSerialNumberLow : UInt8 = 0
  
  var partialSerialNumberHigh : UInt8 = 0
  
  var productCode : UInt8 = 0
  
  // MARK: Private Methods
  
  private func checkPort() {
  
    guard cboPort.numberOfItems > 0 else {
      return
    }
    
    var color = NSColor.red
    
    for index in 0...cboPort.numberOfItems-1 {
      if let item = cboPort.itemObjectValue(at: index) as? String {
        if item == cboPort.stringValue {
          color = NSColor.black
          break
        }
      }
    }
    
    cboPort.textColor = color
    
  }
  
  private func tidyUp() {
    if observerId != -1 {
      tempInterface?.removeObserver(id: observerId)
    }
    tempInterface?.close()
    tempInterface = nil
    if initialState == .existingInterfaceOpen {
      interface?.open()
    }
    btnIdentify.isEnabled = true
  }
  
  // MARK: DBEditorView Delegate Methods
 
  func clearFields(dbEditorView:DBEditorView) {
    interface = nil
    cboPort.stringValue = ""
    cboPort.textColor = NSColor.black
    cboDeviceType.stringValue = ""
    txtInterfaceName.stringValue = ""
    cboBaudrate.selectItem(at: 0)
    cboFlowControl.selectItem(at: 0)
    lblSerialNumber.stringValue = ""
    chkLocoNetTerminator.state = .off
  }
  
  func setupFields(dbEditorView: DBEditorView, editorObject: EditorObject) {
    if let device = editorObject as? Interface {
      interface = device
      cboPort.stringValue = device.devicePath
      checkPort()
      if let index = cboDeviceTypeDS.indexWithKey(key: device.locoNetProductId.rawValue) {
        cboDeviceType.selectItem(at: index)
      }
      txtInterfaceName.stringValue = device.deviceName
      cboBaudrate.selectItem(at: device.baudRate.rawValue)
      cboFlowControl.selectItem(at: device.flowControl.rawValue)
      lblSerialNumber.stringValue = device.serialNumber == 0 ? "" : "\(device.serialNumber)"
      chkLocoNetTerminator.state = device.isStandAloneLoconet ? .on : .off
    }
  }
  
  func validate(dbEditorView: DBEditorView) -> String? {
    if txtInterfaceName.stringValue.trimmingCharacters(in: .whitespaces) == "" {
      txtInterfaceName.becomeFirstResponder()
      return "The interface must have a name."
    }
    if cboPort.stringValue.trimmingCharacters(in: .whitespaces) == "" {
      cboPort.becomeFirstResponder()
      return "The interface must have a port selected."
    }
    if cboDeviceType.stringValue.trimmingCharacters(in: .whitespaces) == "" {
      cboDeviceType.becomeFirstResponder()
      return "The interface must have a device type selected."
    }
    return nil
  }
  
  func setFields(device:Interface) {
    device.devicePath = cboPort.stringValue
    if let editorObject = cboDeviceTypeDS.editorObjectAt(index: cboDeviceType.indexOfSelectedItem) {
      device.locoNetProductId = LocoNetProductId(rawValue: editorObject.primaryKey) ?? .UNKNOWN
    }
    else {
      device.locoNetProductId = .UNKNOWN
    }
    device.deviceName = txtInterfaceName.stringValue
    device.baudRate = BaudRate(rawValue: cboBaudrate.indexOfSelectedItem) ?? .br19200
    device.flowControl = FlowControl(rawValue: cboFlowControl.indexOfSelectedItem) ?? .noFlowControl
    device.serialNumber = lblSerialNumber.integerValue
    device.isStandAloneLoconet = chkLocoNetTerminator.state == .on
  }
  
  func saveNew(dbEditorView: DBEditorView) -> EditorObject {
    let device = Interface(primaryKey: -1)
    setFields(device: device)
    device.save()
    myTrainsController.addDevice(device: device)
    editorView.dictionary = myTrainsController.interfaceDevices
    editorView.setSelection(key: device.primaryKey)
    return device
  }
  
  func saveExisting(dbEditorView: DBEditorView, editorObject: EditorObject) {
    if let device = editorObject as? Interface {
      setFields(device: device)
      device.save()
      editorView.dictionary = myTrainsController.interfaceDevices
      editorView.setSelection(key: device.primaryKey)
    }
  }
  
  func delete(dbEditorView: DBEditorView, primaryKey: Int) {
    Interface.delete(primaryKey: primaryKey)
    myTrainsController.removeDevice(primaryKey: primaryKey)
    editorView.dictionary = myTrainsController.interfaceDevices
  }
  
  // MARK: InterfaceDelegate Methods
  
  func networkMessageReceived(message:LocoNetMessage) {
    
    switch message.messageType {
    case .interfaceData:
      
      productCode = message.message[14]
      
      if let product = LocoNetProducts.product(productCode: productCode) {
        if let index = cboDeviceTypeDS.indexWithKey(key: product.id.rawValue) {
          cboDeviceType.selectItem(at: index)
          lblSerialNumber.stringValue = ""
          txtInterfaceName.stringValue = ""
        }
      }
      
      partialSerialNumberLow = message.message[6]
      partialSerialNumberHigh = message.message[7]
      
      tempInterface?.iplDiscover()
    
    case .iplDevData:
      
      let iplDevData = IPLDevData(message: message)
      
      if iplDevData.partialSerialNumberLow == partialSerialNumberLow &&   iplDevData.partialSerialNumberHigh == partialSerialNumberHigh &&
        iplDevData.productCode.rawValue == productCode {
        lblSerialNumber.stringValue = "\(iplDevData.serialNumber)"
        txtInterfaceName.stringValue = "\(cboDeviceType.stringValue) SN: #\(iplDevData.serialNumber)"
      }
      
    default:
      break
    }
  }
  
  func interfaceWasOpened(interface:Interface) {
    tempInterface?.getInterfaceData(timeoutCode: .getInterfaceData)
  }
  
  func interfaceWasClosed(interface:Interface) {
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var editorView: DBEditorView!
  
  @IBOutlet weak var tabView: NSTabView!
  
  @IBOutlet weak var cboPort: NSComboBox!
  
  @IBAction func cboPortAction(_ sender: NSComboBox) {
    editorView.modified = true
    checkPort()
  }
  
  @IBOutlet weak var cboDeviceType: NSComboBox!
  
  @IBAction func cboDeviceTypeAction(_ sender: NSComboBox) {
    editorView.modified = true
    if txtInterfaceName.stringValue == "" {
      txtInterfaceName.stringValue = cboDeviceType.stringValue
    }
  }
  
  @IBOutlet weak var txtInterfaceName: NSTextField!
  
  @IBAction func txtInterfaceNameAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet weak var cboBaudrate: NSComboBox!
  
  @IBAction func cboBaudRateAction(_ sender: NSComboBox) {
    editorView.modified = true
  }
  
  @IBOutlet weak var cboFlowControl: NSComboBox!
  
  @IBAction func cboFlowControlAction(_ sender: NSComboBox) {
    editorView.modified = true
  }
  
  @IBOutlet weak var btnIdentify: NSButton!
  
  @IBAction func btnIdentifyAction(_ sender: NSButton) {
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      self.tidyUp()
    }
    
    btnIdentify.isEnabled = false
    partialSerialNumberLow = 0
    partialSerialNumberHigh = 0
    productCode = 0
    if let device = interface {
      if cboPort.stringValue == device.devicePath {
        initialState = device.isOpen ? .existingInterfaceOpen : .existingInterfaceClosed
        device.close()
      }
      else {
        initialState = .temporaryInterface
      }
    }
    else {
      initialState = .temporaryInterface
    }
    tempInterface = InterfaceLocoNet(primaryKey: -1)
    if let device = tempInterface {
      device.isEdit = true
      setFields(device: device)
      observerId = device.addObserver(observer: self)
      device.open()
    }
  }
  
  @IBOutlet weak var lblSerialNumber: NSTextField!
  
  @IBOutlet weak var chkLocoNetTerminator: NSButton!
  
  @IBAction func chkLocoNetTerminatorAction(_ sender: NSButton) {
    editorView.modified = true
  }
  
}

