//
//  EditSwitchesVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/12/2021.
//

import Foundation
import Cocoa

class EditSwitchesVC: NSViewController, NSWindowDelegate, DBEditorDelegate {
   
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
    
    cboDeviceTypeDS.dictionary = switchProductDictionary
    
    cboDeviceType.dataSource = cboDeviceTypeDS
    
    cboNetwork.dataSource = cboNetworkDS
    
    editorView.dictionary = networkController.stationaryDecoders
    
  }
  
  // MARK: Private Properties
  
  private var editorState : DBEditorState = .select

  private var switchProductDictionary = LocoNetProducts.productDictionaryOr(attributes: [.StationaryDecoder])

  private var cboDeviceTypeDS = ComboBoxDictDS()
  
  private var cboNetworkDS = ComboBoxDBDS(tableName: TABLE.NETWORK, codeColumn: NETWORK.NETWORK_ID, displayColumn: NETWORK.NETWORK_NAME, sortColumn: NETWORK.NETWORK_NAME)

//  private var switchTableViewDS : SensorTableViewDS = SensorTableViewDS()
  
  private var observerId : Int = -1
  
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
  
  private var interface : Interface?
  
  // MARK: Private Methods
  
  private func setupView() {
    lblBoardID.stringValue = "Board ID"
    btnSetBoardID.title = "Set Board ID"
    if let device = editorView.editorObject as? LocoNetDevice {
      if device.isSeries7 {
        lblBoardID.stringValue = "Base Address"
        btnSetBoardID.title = "Set Base Address"
      }
    }
  }

  // MARK: InterfaceDelegate Methods
  
  func networkMessageReceived(message:NetworkMessage) {
    
  }

  // MARK: DBEditorDelegate Methods
  
  func clearFields(dbEditorView: DBEditorView) {
    cboDeviceType.deselectItem(at: cboDeviceType.indexOfSelectedItem)
    txtDeviceName.stringValue = ""
    cboNetwork.deselectItem(at: cboNetwork.indexOfSelectedItem)
    txtBoardID.stringValue = ""
//    sensorTableViewDS.sensors = []
//    sensorTableView.dataSource = sensorTableViewDS
//    sensorTableView.reloadData()
    setupView()
  }
  
  func setupFields(dbEditorView: DBEditorView, editorObject: EditorObject) {
    if let device = editorObject as? LocoNetDevice {
      if let index = cboDeviceTypeDS.indexWithKey(key: device.locoNetProductId.rawValue) {
        cboDeviceType.selectItem(at: index)
      }
      txtDeviceName.stringValue = device.deviceName
      cboNetwork.selectItem(at: cboNetworkDS.indexOfItemWithCodeValue(code: device.networkId) ?? -1)
      txtBoardID.integerValue = device.boardId
//      sensorTableViewDS.sensors = device.sensors
//      sensorTableView.dataSource = sensorTableViewDS
//      sensorTableView.delegate = sensorTableViewDS
//      sensorTableView.reloadData()
      tabView.selectFirstTabViewItem(self)
      editorView.modified = true
    }
    setupView()
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
    device.boardId = txtBoardID.integerValue
  }

  func saveNew(dbEditorView: DBEditorView) -> EditorObject {
    let device = LocoNetDevice(primaryKey: -1)
    setFields(device: device)
    device.save()
    networkController.addDevice(device: device)
    editorView.dictionary = networkController.stationaryDecoders
    editorView.setSelection(key: device.primaryKey)
    return device
  }
  
  func saveExisting(dbEditorView: DBEditorView, editorObject: EditorObject) {
    if let device = editorObject as? LocoNetDevice {
      setFields(device: device)
      device.save()
      editorView.dictionary = networkController.stationaryDecoders
      editorView.setSelection(key: device.primaryKey)
    }
  }
  
  func delete(dbEditorView: DBEditorView, primaryKey: Int) {
    LocoNetDevice.delete(primaryKey: primaryKey)
    networkController.removeDevice(primaryKey: primaryKey)
    editorView.dictionary = networkController.stationaryDecoders
  }

  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboDeviceType: NSComboBox!
  
  @IBAction func cboDeviceTypeAction(_ sender: NSComboBox) {
    editorView.modified = true
    setupView()
  }
  
  @IBOutlet weak var txtDeviceName: NSTextField!
  
  @IBAction func txtDeviceNameAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet weak var cboNetwork: NSComboBox!
  
  @IBAction func cboNetworkAction(_ sender: NSComboBox) {
    editorView.modified = true
  }
  
  @IBOutlet weak var lblBoardID: NSTextField!
  
  @IBOutlet weak var txtBoardID: NSTextField!
  
  @IBAction func txtBoardIDAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet weak var btnSetBoardID: NSButton!
  
  @IBAction func btnSetBoardIDAction(_ sender: NSButton) {
    
    if let device = editorView.editorObject as? LocoNetDevice, let message = OptionSwitch.enterSetBoardIdModeInstructions[device.locoNetProductId] {
      
      let alert = NSAlert()

      alert.messageText = message
      alert.informativeText = ""
      alert.addButton(withTitle: "OK")
      alert.addButton(withTitle: "Cancel")
      alert.alertStyle = .informational

      if alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn {
        
        device.networkId = cboNetworkDS.codeForItemAt(index: cboNetwork.indexOfSelectedItem) ?? -1
        
        editorView.modified = true

        if let interface = device.network?.interface {
          
          mode = .wrapUpSetBID

          interface.setSw(switchNumber: txtBoardID.integerValue, state: .closed)
          
   //       startTimer()
          
        }
        
      }
      
    }
    
  }
  
  @IBOutlet weak var tabView: NSTabView!
  
  @IBOutlet weak var editorView: DBEditorView!
  
}
