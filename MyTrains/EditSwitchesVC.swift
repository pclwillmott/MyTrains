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

  private var turnoutSwitchTableViewDS : TurnoutSwitchTableViewDS = TurnoutSwitchTableViewDS()
  
  // MARK: Private Methods
  
  private func setupView() {
    lblBoardID.stringValue = "Board ID"
    if let device = editorView.editorObject as? LocoNetDevice {
      if device.isSeries7 {
        lblBoardID.stringValue = "Base Address"
      }
    }
  }

  // MARK: DBEditorDelegate Methods
  
  func clearFields(dbEditorView: DBEditorView) {
    cboDeviceType.deselectItem(at: cboDeviceType.indexOfSelectedItem)
    txtDeviceName.stringValue = ""
    cboNetwork.deselectItem(at: cboNetwork.indexOfSelectedItem)
    txtBoardID.stringValue = ""
    turnoutSwitchTableViewDS.turnoutSwitches = []
    turnoutSwitchTableView.dataSource = turnoutSwitchTableViewDS
    turnoutSwitchTableView.reloadData()
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
      turnoutSwitchTableViewDS.turnoutSwitches = device.turnoutSwitches
      turnoutSwitchTableView.dataSource = turnoutSwitchTableViewDS
      turnoutSwitchTableView.delegate = turnoutSwitchTableViewDS
      turnoutSwitchTableView.reloadData()
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
    device.save()
    editorView.dictionary = networkController.stationaryDecoders
    editorView.setSelection(key: device.primaryKey)
    return device
  }
  
  func saveExisting(dbEditorView: DBEditorView, editorObject: EditorObject) {
    if let device = editorObject as? LocoNetDevice {
      setFields(device: device)
      device.save()
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
    
  @IBOutlet weak var tabView: NSTabView!
  
  @IBOutlet weak var editorView: DBEditorView!
  
  @IBOutlet weak var turnoutSwitchTableView: NSTableView!
  
}
