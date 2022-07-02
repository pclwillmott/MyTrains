//
//  EditSensorsVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/12/2021.
//

import Foundation
import Cocoa

class EditSensorsVC: NSViewController, NSWindowDelegate, DBEditorDelegate {
  
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
    
    editorView.delegate = self
    
    editorView.tabView = tabView
    
    cboDeviceTypeDS.dictionary = sensorProductDictionary
    
    cboDeviceType.dataSource = cboDeviceTypeDS
    
    cboNetwork.dataSource = cboNetworkDS
    
    editorView.dictionary = networkController.sensors
  }

  // MARK: Private Properties
  
  private var editorState : DBEditorState = .select

  private var sensorProductDictionary = LocoNetProducts.productDictionaryOr(attributes: [.Transponding, .OccupancyDetector, .PowerManager])

  private var cboDeviceTypeDS = ComboBoxDictDS()
  
  private var cboNetworkDS = ComboBoxDBDS(tableName: TABLE.NETWORK, codeColumn: NETWORK.NETWORK_ID, displayColumn: NETWORK.NETWORK_NAME, sortColumn: NETWORK.NETWORK_NAME)

  private var opSwTableViewDS : OpSwTableViewDS = OpSwTableViewDS()

  // MARK: DBEditorDelegate Methods
  
  func clearFields(dbEditorView: DBEditorView) {
    cboDeviceType.stringValue = ""
    txtDeviceName.stringValue = ""
    cboNetwork.stringValue = ""
    txtBoardId.stringValue = ""
    tableView.dataSource = nil
  }
  
  func setupFields(dbEditorView: DBEditorView, editorObject: EditorObject) {
    if let device = editorObject as? LocoNetDevice {
      if let index = cboDeviceTypeDS.indexWithKey(key: device.locoNetProductId.rawValue) {
        cboDeviceType.selectItem(at: index)
      }
      txtDeviceName.stringValue = device.deviceName
      cboNetwork.stringValue = device.network?.networkName ?? ""
      txtBoardId.integerValue = device.boardId
      opSwTableViewDS.options = device.optionSwitches
      tableView.dataSource = opSwTableViewDS
      tableView.delegate = opSwTableViewDS
       tableView.reloadData()
    }
  }
  
  func validate(dbEditorView: DBEditorView) -> String? {
    if txtDeviceName.stringValue.trimmingCharacters(in: .whitespaces) == "" {
      txtDeviceName.becomeFirstResponder()
      return "The device must have a name."
    }
    if cboDeviceType.stringValue.trimmingCharacters(in: .whitespaces) == "" {
      cboDeviceType.becomeFirstResponder()
      return "The device must have a device type selected."
    }
    return nil
  }

  func setFields(device:LocoNetDevice) {
    if let editorObject = cboDeviceTypeDS.editorObjectAt(index: cboDeviceType.indexOfSelectedItem) {
      device.locoNetProductId = LocoNetProductId(rawValue: editorObject.primaryKey) ?? .UNKNOWN
    }
    else {
      device.locoNetProductId = .UNKNOWN
    }
    device.deviceName = txtDeviceName.stringValue
    device.networkId = cboNetworkDS.codeForItemAt(index: cboNetwork.indexOfSelectedItem) ?? -1
    device.boardId = txtBoardId.integerValue
  }

  func saveNew(dbEditorView: DBEditorView) -> EditorObject {
    let device = LocoNetDevice(primaryKey: -1)
    setFields(device: device)
    device.save()
    networkController.addDevice(device: device)
    editorView.dictionary = networkController.sensors
    editorView.setSelection(key: device.primaryKey)
    return device
  }
  
  func saveExisting(dbEditorView: DBEditorView, editorObject: EditorObject) {
    if let device = editorObject as? LocoNetDevice {
      setFields(device: device)
      device.save()
      editorView.dictionary = networkController.sensors
      editorView.setSelection(key: device.primaryKey)
    }
  }
  
  func delete(dbEditorView: DBEditorView, primaryKey: Int) {
    LocoNetDevice.delete(primaryKey: primaryKey)
    networkController.removeDevice(primaryKey: primaryKey)
    editorView.dictionary = networkController.sensors
  }
  
  // MARK: Outlets & Actions
  
  // General
  
  @IBOutlet weak var editorView: DBEditorView!
  
  @IBOutlet weak var tabView: NSTabView!
  
  @IBOutlet weak var cboDeviceType: NSComboBox!
  
  @IBAction func cboDeviceTypeAction(_ sender: NSComboBox) {
    editorView.modified = true
  }
  
  @IBOutlet weak var txtDeviceName: NSTextField!
  
  @IBAction func txtDeviceNameAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet weak var cboNetwork: NSComboBox!
  
  @IBAction func cboNetworkAction(_ sender: NSComboBox) {
    editorView.modified = true
  }
  
  @IBOutlet weak var txtBoardId: NSTextField!
  
  @IBAction func txtBoardIdAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet weak var btnSetBoardId: NSButton!
  
  @IBAction func btnSetBoardIdAction(_ sender: NSButton) {
    
    if let device = editorView.editorObject as? LocoNetDevice, let message = OptionSwitch.enterSetBoardIdModeInstructions[device.locoNetProductId] {
      
      let alert = NSAlert()

      alert.messageText = message
      alert.informativeText = ""
      alert.addButton(withTitle: "OK")
      alert.addButton(withTitle: "Cancel")
      alert.alertStyle = .informational

      if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
        
        if let interface = device.network?.interface {
          interface.setSw(switchNumber: txtBoardId.integerValue, state: .closed)
          
          if let message = OptionSwitch.exitSetBoardIdModeInstructions[device.locoNetProductId] {
            alert.messageText = message
            alert.informativeText = ""
            alert.alertStyle = .informational

            if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
            }
          }
        }
        
      }
      
    }
  }
  
  // Sensors
  
  // Option Switches
  
  @IBOutlet weak var btnRead: NSButton!
  
  @IBAction func btnReadAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var btnWrite: NSButton!
  
  @IBAction func btnWriteAction(_ sender: NSButton) {
    
    if let device = editorView.editorObject as? LocoNetDevice, let message = OptionSwitch.enterOptionSwitchModeInstructions[device.locoNetProductId] {
      
      let alert = NSAlert()

      alert.messageText = message
      alert.informativeText = ""
      alert.addButton(withTitle: "OK")
      alert.addButton(withTitle: "Cancel")
      alert.alertStyle = .informational

      if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
        if let interface = device.network?.interface {
          for opsw in opSwTableViewDS.options {
            interface.setSw(switchNumber: opsw.switchNumber, state: opsw.newState)
            let newState = opsw.newState
            opsw.state = newState
          }
        }
        
        if let message = OptionSwitch.exitOptionSwitchModeInstructions[device.locoNetProductId] {
          alert.messageText = message
          alert.informativeText = ""
          alert.alertStyle = .informational
          if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
          }
        }
        
      }
      
      
    }

  }
  
  @IBOutlet weak var tableView: NSTableView!
  
  @IBAction func tableViewAction(_ sender: NSTableView) {
  }
  
}
