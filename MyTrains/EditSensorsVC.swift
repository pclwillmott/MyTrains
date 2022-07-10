//
//  EditSensorsVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/12/2021.
//

import Foundation
import Cocoa

class EditSensorsVC: NSViewController, NSWindowDelegate, DBEditorDelegate, InterfaceDelegate {
  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }

  func windowWillClose(_ notification: Notification) {
    if observerId != -1 {
      readInterface?.removeObserver(id: observerId)
    }
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
  
  private var sensorTableViewDS : SensorTableViewDS = SensorTableViewDS()
  
  private var observerId : Int = -1
  
  private var lastOpSw : Int = 0
  
  private var readInterface : Interface? = nil
  
  private var timer : Timer?
  
  enum Mode {
    case idle
    case read
    case write
    case wrapUpSetBID
    case wrapUpRead
    case wrapUpWrite
  }
  
  private var mode : Mode = .idle

  // MARK: Private Methods
  
  @objc func next() {
    
    switch mode {
    case .idle:
      break
    case .read:
      
      let options = opSwTableViewDS.options!
      
      lastOpSw += 1
    
      if lastOpSw == options.count {
        mode = .wrapUpRead
      }
      else {
        readInterface?.getSwState(switchNumber: options[lastOpSw].switchNumber)
      }
      
    case .write:

      let options = opSwTableViewDS.options!
      
      lastOpSw += 1
    
      if lastOpSw == options.count {
        mode = .wrapUpWrite
      }
      else {
        let newState = options[lastOpSw].newState
        options[lastOpSw].state = newState
        readInterface?.setSw(switchNumber: options[lastOpSw].switchNumber, state: newState)
      }

    case .wrapUpSetBID:
      
      stopTimer()
      
      if let device = editorView.editorObject as? LocoNetDevice, let message = OptionSwitch.exitSetBoardIdModeInstructions[device.locoNetProductId] {
        
        let alert = NSAlert()

        alert.messageText = message
        alert.informativeText = ""
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .informational

        if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
        }

      }
      
      mode = .idle
      
    case .wrapUpRead, .wrapUpWrite:
      
      stopTimer()
      
      if observerId != -1 {
        readInterface?.removeObserver(id: observerId)
      }
      
      observerId = -1
      
      lastOpSw = 0
      
      editorView.modified = true

      mode = .idle
      
      if let device = editorView.editorObject as? LocoNetDevice, let message = OptionSwitch.exitOptionSwitchModeInstructions[device.locoNetProductId] {
        
        let alert = NSAlert()

        alert.messageText = message
        alert.informativeText = ""
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .informational

        if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
        }

      }
      
      btnRead.isEnabled = true
      btnWrite.isEnabled = true

    }
    
  }
  
  func startTimer() {
    timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(next), userInfo: nil, repeats: true)
  }
  
  func stopTimer() {
    timer?.invalidate()
    timer = nil
  }

  // MARK: InterfaceDelegate Methods
  
  func networkMessageReceived(message:NetworkMessage) {
    
    switch message.messageType {
    case .swState:
      
      let options = opSwTableViewDS.options
      
      let option = options![lastOpSw]
      
      option.state = (message.message[2] & 0b00100000) == 0b00100000 ? .closed : .thrown
      
      tableView.reloadData()
              
    default:
      break
    }
  }

  // MARK: DBEditorDelegate Methods
  
  func clearFields(dbEditorView: DBEditorView) {
    cboDeviceType.stringValue = ""
    txtDeviceName.stringValue = ""
    cboNetwork.stringValue = ""
    txtBoardId.stringValue = ""
    tableView.dataSource = nil
    sensorTableViewDS.sensors = []
    sensorTableView.dataSource = sensorTableViewDS
    sensorTableView.reloadData()
  }
  
  func setupFields(dbEditorView: DBEditorView, editorObject: EditorObject) {
    if let device = editorObject as? LocoNetDevice {
      if let index = cboDeviceTypeDS.indexWithKey(key: device.locoNetProductId.rawValue) {
        cboDeviceType.selectItem(at: index)
      }
      txtDeviceName.stringValue = device.deviceName
      cboNetwork.selectItem(at: cboNetworkDS.indexOfItemWithCodeValue(code: device.networkId) ?? -1)
      txtBoardId.integerValue = device.boardId
      opSwTableViewDS.options = device.optionSwitches
      tableView.dataSource = opSwTableViewDS
      tableView.delegate = opSwTableViewDS
      tableView.reloadData()
      sensorTableViewDS.sensors = device.sensors
      sensorTableView.dataSource = sensorTableViewDS
      sensorTableView.delegate = sensorTableViewDS
      sensorTableView.reloadData()
      tabView.selectFirstTabViewItem(self)
      editorView.modified = true
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
          
          mode = .wrapUpSetBID

          interface.setSw(switchNumber: txtBoardId.integerValue, state: .closed)
          
          startTimer()
          
        }
        
      }
      
    }
  }
  
  // Sensors
  
  // Option Switches
  
  @IBOutlet weak var btnRead: NSButton!
  
  @IBAction func btnReadAction(_ sender: NSButton) {
    
    if let device = editorView.editorObject as? LocoNetDevice, let message = OptionSwitch.enterOptionSwitchModeInstructions[device.locoNetProductId] {
      
      let alert = NSAlert()

      alert.messageText = message
      alert.informativeText = ""
      alert.addButton(withTitle: "OK")
      alert.addButton(withTitle: "Cancel")
      alert.alertStyle = .informational

      if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
        
        if observerId != -1 {
          readInterface?.removeObserver(id: observerId)
        }
        
        readInterface = device.network?.interface
        
        if let interface = readInterface {
          
          observerId = interface.addObserver(observer: self)
          
          lastOpSw = 0
          
          let options = opSwTableViewDS.options!
          
          if lastOpSw < options.count {
            interface.getSwState(switchNumber: options[lastOpSw].switchNumber)
            mode = .read
            
          }
          else {
            mode = .wrapUpRead
          }
          
          btnRead.isEnabled = false
          btnWrite.isEnabled = false
          
          startTimer()
          
        }
        
      }
      
    }

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
        
        readInterface = device.network?.interface
        
        if let interface = readInterface {
          
          lastOpSw = 0
          
          let options = opSwTableViewDS.options!
          
          if lastOpSw < options.count {
            let newState = options[lastOpSw].newState
            options[lastOpSw].state = newState
            interface.setSw(switchNumber: options[lastOpSw].switchNumber, state: newState)
            mode = .write
            
          }
          else {
            mode = .wrapUpWrite
          }
          
          btnRead.isEnabled = false
          btnWrite.isEnabled = false
          
          startTimer()
          
        }
        
      }

    }

  }
  
  @IBOutlet weak var tableView: NSTableView!
  
  @IBAction func tableViewAction(_ sender: NSTableView) {
  }
  
  @IBOutlet weak var sensorTableView: NSTableView!
  
  
}
