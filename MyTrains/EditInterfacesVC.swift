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

class EditInterfacesVC: NSViewController, NSWindowDelegate, DBEditorDelegate, NetworkControllerDelegate, InterfaceDelegate {
 
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
    
    editorView.dictionary = networkController.interfaceDevices
    
  }
  
  // MARK: Private Properties
  
  private var interfaceProductDictionary = LocoNetProducts.productDictionary(attributes: [.ComputerInterface])
  
  private var cboDeviceTypeDS = ComboBoxDictDS()
  
  private var interface : Interface?
  
  private var tempInterface : Interface?
  
  private var initialState : InitialState = .inactive

  var observerId : Int = -1
  
  private var timer : Timer?
  
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
    stopTimer()
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
  
  @objc func timeoutTimer() {
    print("timeoutTimer")
    tidyUp()
  }
  
  func starttimer() {
//    stopTimer()
    print("startTimer 1")
    let interval : TimeInterval = 1.0
    timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timeoutTimer), userInfo: nil, repeats: false)
    print("startTimer 2")
  }
  
  func stopTimer() {
    print("stopTimer")
    timer?.invalidate()
    timer = nil
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
  }
  
  func setupFields(dbEditorView: DBEditorView, editorObject: EditorObject) {
    if let device = editorObject as? Interface {
      interface = device
      cboPort.stringValue = device.devicePath
      checkPort()
      if let index = cboDeviceTypeDS.indexWithKey(key: device.locoNetProductId) {
        cboDeviceType.selectItem(at: index)
      }
      txtInterfaceName.stringValue = device.deviceName
      cboBaudrate.selectItem(at: device.baudRate.rawValue)
      cboFlowControl.selectItem(at: device.flowControl.rawValue)
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
      device.locoNetProductId = editorObject.primaryKey
    }
    else {
      device.locoNetProductId = -1
    }
    device.deviceName = txtInterfaceName.stringValue
    device.baudRate = BaudRate(rawValue: cboBaudrate.indexOfSelectedItem) ?? .br19200
    device.flowControl = FlowControl(rawValue: cboFlowControl.indexOfSelectedItem) ?? .noFlowControl
  }
  
  func saveNew(dbEditorView: DBEditorView) -> EditorObject {
    let device = Interface(primaryKey: -1)
    setFields(device: device)
    device.save()
    networkController.addInterface(device: device)
    editorView.dictionary = networkController.interfaceDevices
    editorView.setSelection(key: device.primaryKey)
    return device
  }
  
  func saveExisting(dbEditorView: DBEditorView, editorObject: EditorObject) {
    if let device = editorObject as? Interface {
      setFields(device: device)
      device.save()
      editorView.dictionary = networkController.interfaceDevices
      editorView.setSelection(key: device.primaryKey)
    }
  }
  
  func delete(dbEditorView: DBEditorView, primaryKey: Int) {
    Interface.delete(primaryKey: primaryKey)
    networkController.removeInterface(primaryKey: primaryKey)
    editorView.dictionary = networkController.interfaceDevices
  }
  
  // MARK: InterfaceDelegate Methods
  
  func networkMessageReceived(message:NetworkMessage) {
    switch message.messageType {
    case .interfaceData:
      
      productCode = message.message[14]
      
      if let product = LocoNetProducts.product(productCode: productCode) {
        if let index = cboDeviceTypeDS.indexWithKey(key: product.id) {
          cboDeviceType.selectItem(at: index)
        }
      }
      
      partialSerialNumberLow = message.message[6]
      partialSerialNumberHigh = message.message[7]
      
      tempInterface?.iplDiscover()
      
      starttimer()
    
    case .iplDevData:
      
      let iplDevData = IPLDevData(message: message)
      
      if iplDevData.partialSerialNumberLow == partialSerialNumberLow &&   iplDevData.partialSerialNumberHigh == partialSerialNumberHigh &&
        iplDevData.productCode.rawValue == productCode {
        lblSerialNumber.stringValue = "\(iplDevData.serialNumber)"
        tidyUp()
      }
      else {
        starttimer()
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
    btnIdentify.isEnabled = false
    starttimer()
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
    tempInterface = Interface(primaryKey: -1)
    if let device = tempInterface {
      setFields(device: device)
      observerId = device.addObserver(observer: self)
  //    device.open()
    }
  }
  
  @IBOutlet weak var lblSerialNumber: NSTextField!
  
}

