//
//  EditInterfacesVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/05/2022.
//

import Foundation
import Cocoa
import ORSSerial

class EditInterfacesVC: NSViewController, NSWindowDelegate, DBEditorDelegate, NetworkControllerDelegate {
 
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
    
    ORSSerialPortManager.populate(comboBox: cboPort)

    editorView.delegate = self
    
    editorView.tabView = self.tabView
    
    editorView.dictionary = networkController.interfaceDevices
    
  }
  
  // MARK: Private Properties
  
  private var interfaceProductDictionary = LocoNetProducts.productDictionary(attributes: [.ComputerInterface])
  
  private var cboDeviceTypeDS = ComboBoxDictDS()
  
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
  
  // MARK: DBEditorView Delegate Methods
 
  func clearFields(dbEditorView:DBEditorView) {
    cboPort.stringValue = ""
    cboPort.textColor = NSColor.black
    cboDeviceType.stringValue = ""
    txtInterfaceName.stringValue = ""
    cboBaudrate.selectItem(at: 0)
    cboFlowControl.selectItem(at: 0)
  }
  
  func setupFields(dbEditorView: DBEditorView, editorObject: EditorObject) {
    if let device = editorObject as? LocoNetDevice {
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
  
  func setFields(device:LocoNetDevice) {
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
    device.save()
  }
  
  func saveNew(dbEditorView: DBEditorView) -> EditorObject {
    let device = LocoNetDevice(primaryKey: -1)
    setFields(device: device)
    networkController.addDevice(device: device)
    editorView.dictionary = networkController.interfaceDevices
    editorView.setSelection(key: device.primaryKey)
    return device
  }
  
  func saveExisting(dbEditorView: DBEditorView, editorObject: EditorObject) {
    if let device = editorObject as? LocoNetDevice {
      setFields(device: device)
      editorView.dictionary = networkController.interfaceDevices
      editorView.setSelection(key: device.primaryKey)
    }
  }
  
  func delete(dbEditorView: DBEditorView, primaryKey: Int) {
    LocoNetDevice.delete(primaryKey: primaryKey)
    networkController.removeDevice(primaryKey: primaryKey)
    editorView.dictionary = networkController.interfaceDevices
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var editorView: DBEditorView!
  
  @IBOutlet weak var tabView: NSTabView!
  
  @IBOutlet weak var cboPort: NSComboBox!
  
  @IBAction func cboPortAction(_ sender: NSComboBox) {
    editorView.modified = true
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
  
}

