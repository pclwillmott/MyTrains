//
//  EditCommandStationsVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/08/2022.
//

import Foundation
import Cocoa

class EditCommandStationsVC: NSViewController, NSWindowDelegate, DBEditorDelegate {

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

    editorView.tabView = self.tabView
    
    editorView.dictionary = myTrainsController.commandStations
    
    cboDeviceTypeDS.dictionary = productDictionary
    
    cboCommandStationType.dataSource = cboDeviceTypeDS
    
    cboNetwork.dataSource = cboNetworkDS
    
  }
  
  // MARK: Private Properties
  
  private var productDictionary = LocoNetProducts.productDictionaryOr(attributes: [.CommandStation])

  private var cboDeviceTypeDS = ComboBoxDictDS()
  
  private var cboNetworkDS = ComboBoxDBDS(tableName: TABLE.NETWORK, codeColumn: NETWORK.NETWORK_ID, displayColumn: NETWORK.NETWORK_NAME, sortColumn: NETWORK.NETWORK_NAME)
  
  // MARK: DBEditorView Delegate Methods
  
  func clearFields(dbEditorView: DBEditorView) {
    txtCommandStationName.stringValue = ""
    cboCommandStationType.deselectItem(at: cboCommandStationType.indexOfSelectedItem)
    cboNetwork.deselectItem(at: cboNetwork.indexOfSelectedItem)
    txtSerialNumber.stringValue = ""
  }
  
  func setupFields(dbEditorView: DBEditorView, editorObject: EditorObject) {
    if let cs = editorObject as? LocoNetDevice {
      txtCommandStationName.stringValue = cs.deviceName
      if let index = cboDeviceTypeDS.indexWithKey(key: cs.locoNetProductId.rawValue) {
        cboCommandStationType.selectItem(at: index)
      }
      cboNetwork.selectItem(at: cboNetworkDS.indexOfItemWithCodeValue(code: cs.networkId) ?? -1)
      if cs.serialNumber != 0 {
        txtSerialNumber.stringValue = "\(cs.serialNumber)"
      }
    }
  }
  
  func validate(dbEditorView: DBEditorView) -> String? {
    if txtCommandStationName.stringValue.trimmingCharacters(in: .whitespaces) == "" {
      txtCommandStationName.becomeFirstResponder()
      return "The command station must have a name."
    }
    if cboCommandStationType.stringValue.trimmingCharacters(in: .whitespaces) == "" {
      cboCommandStationType.becomeFirstResponder()
      return "The command station must have a command station type selected."
    }
    return nil
  }
  
  func setFields(cs:LocoNetDevice) {
    cs.deviceName = txtCommandStationName.stringValue
    if let editorObject = cboDeviceTypeDS.editorObjectAt(index: cboCommandStationType.indexOfSelectedItem) {
      cs.locoNetProductId = DeviceId(rawValue: editorObject.primaryKey) ?? .UNKNOWN
    }
    else {
      cs.locoNetProductId = .UNKNOWN
    }
    cs.networkId = cboNetworkDS.codeForItemAt(index: cboNetwork.indexOfSelectedItem) ?? -1
    cs.serialNumber = txtSerialNumber.integerValue
    cs.save()
  }
  
  func saveNew(dbEditorView: DBEditorView) -> EditorObject {
    let cs = LocoNetDevice(primaryKey: -1)
    setFields(cs: cs)
    myTrainsController.addDevice(device: cs)
    editorView.dictionary = myTrainsController.commandStations
    editorView.setSelection(key: cs.primaryKey)
    return cs
  }
  
  func saveExisting(dbEditorView: DBEditorView, editorObject: EditorObject) {
    if let cs = editorObject as? LocoNetDevice {
      setFields(cs: cs)
      editorView.dictionary = myTrainsController.commandStations
      editorView.setSelection(key: cs.primaryKey)
    }
  }

  func delete(dbEditorView: DBEditorView, primaryKey: Int) {
    LocoNetDevice.delete(primaryKey: primaryKey)
    myTrainsController.removeDevice(primaryKey: primaryKey)
    editorView.dictionary = myTrainsController.commandStations
  }

  // MARK: Outlets & Actions
  
  @IBOutlet weak var editorView: DBEditorView!
  
  @IBOutlet weak var cboCommandStationType: NSComboBox!
  
  @IBAction func cboCommandStationAction(_ sender: NSComboBox) {
    editorView.modified = true
  }
  
  @IBOutlet weak var txtCommandStationName: NSTextField!
  
  @IBAction func txtCommandStationNameAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet weak var cboNetwork: NSComboBox!
  
  @IBAction func cboNetworkAction(_ sender: NSComboBox) {
    editorView.modified = true
  }
  
  @IBOutlet weak var txtSerialNumber: NSTextField!
  
  @IBAction func txtSerialNumberAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet weak var tabView: NSTabView!
  
}

