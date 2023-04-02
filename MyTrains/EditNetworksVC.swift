//
//  EditNetworksVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/12/2021.
//

import Foundation
import Cocoa

class EditNetworksVC: NSViewController, NSWindowDelegate, DBEditorDelegate {
 
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
    
    cboLayout.dataSource = cboLayoutDS
    
    cboComputerInterfaceDS.dictionary = networkController.interfaceDevices
    
    cboComputerInterface.dataSource = cboComputerInterfaceDS
    
    cboCommandStationDS.dictionary = networkController.commandStations
    
    cboCommandStation.dataSource = cboCommandStationDS
    
    editorView.dictionary = networkController.networks
    
  }
  
  // MARK: Private Properties
  
  private var cboComputerInterfaceDS = ComboBoxDictDS()

  private var cboCommandStationDS = ComboBoxDictDS()

  private var cboLayoutDS = ComboBoxDBDS(tableName: TABLE.LAYOUT, codeColumn: LAYOUT.LAYOUT_ID, displayColumn: LAYOUT.LAYOUT_NAME, sortColumn: LAYOUT.LAYOUT_NAME)
  
  // MARK: DBEditorView Delegate Methods
 
  func clearFields(dbEditorView:DBEditorView) {
    txtNetworkName.stringValue = ""
    cboLayout.deselectItem(at: cboLayout.indexOfSelectedItem)
    cboComputerInterface.deselectItem(at: cboComputerInterface.indexOfSelectedItem)
    cboCommandStation.deselectItem(at: cboCommandStation.indexOfSelectedItem)
    txtGroupName.stringValue = ""
    txtGroupPassword.stringValue = "0000"
    txtGroupChannel.integerValue = 11
    txtGroupId.integerValue = 0
    txtLocoNetId.integerValue = 0
  }
  
  func setupFields(dbEditorView: DBEditorView, editorObject: EditorObject) {
    if let network = editorObject as? Network {
      txtNetworkName.stringValue = network.networkName
      if let loIndex = cboLayoutDS.indexOfItemWithCodeValue(code: network.layoutId) {
        cboLayout.selectItem(at: loIndex)
      }
      if let index = cboComputerInterfaceDS.indexWithKey(key: network.interfaceId) {
        cboComputerInterface.selectItem(at: index)
      }
      if let index = cboCommandStationDS.indexWithKey(key: network.commandStationId) {
        cboCommandStation.selectItem(at: index)
      }
      txtGroupName.stringValue = network.duplexGroupName
      txtGroupPassword.stringValue = network.duplexGroupPassword
      txtGroupChannel.integerValue = network.duplexGroupChannel
      txtGroupId.integerValue = network.duplexGroupId
      txtLocoNetId.integerValue = network.locoNetId
    }
  }
  
  func validate(dbEditorView: DBEditorView) -> String? {
    if txtNetworkName.stringValue.trimmingCharacters(in: .whitespaces) == "" {
      txtNetworkName.becomeFirstResponder()
      return "The network must have a name."
    }
    if cboLayout.stringValue == "" {
      cboLayout.becomeFirstResponder()
      return "The network must belong to a layout."
    }
    if cboComputerInterface.stringValue == "" {
      cboComputerInterface.becomeFirstResponder()
      return "The network must have a computer interface selected."
    }
    return nil
  }
  
  func setFields(network:Network) {
    network.networkName = txtNetworkName.stringValue
    network.layoutId = cboLayoutDS.codeForItemAt(index: cboLayout.indexOfSelectedItem) ?? -1
    if let editorObject = cboComputerInterfaceDS.editorObjectAt(index: cboComputerInterface.indexOfSelectedItem) {
      network.interfaceId = editorObject.primaryKey
    }
    else {
      network.interfaceId = -1
    }
    if let editorObject = cboCommandStationDS.editorObjectAt(index: cboCommandStation.indexOfSelectedItem) {
      network.commandStationId = editorObject.primaryKey
    }
    else {
      network.commandStationId = -1
    }
    network.duplexGroupName = txtGroupName.stringValue
    network.duplexGroupPassword = txtGroupPassword.stringValue
    network.duplexGroupChannel = txtGroupChannel.integerValue
    network.duplexGroupId = txtGroupId.integerValue
    network.locoNetId = txtLocoNetId.integerValue
    network.save()
    networkController.connected ? networkController.connect() : networkController.disconnect()
  }
  
  func saveNew(dbEditorView: DBEditorView) -> EditorObject {
    let network = Network()
    setFields(network: network)
    networkController.addNetwork(network: network)
    editorView.dictionary = networkController.networks
    editorView.setSelection(key: network.primaryKey)
    return network
  }
  
  func saveExisting(dbEditorView: DBEditorView, editorObject: EditorObject) {
    if let network = editorObject as? Network {
      setFields(network: network)
      editorView.dictionary = networkController.networks
      editorView.setSelection(key: network.primaryKey)
    }
  }
  
  func delete(dbEditorView: DBEditorView, primaryKey: Int) {
    Network.delete(primaryKey: primaryKey)
    networkController.removeNetwork(primaryKey: primaryKey)
    editorView.dictionary = networkController.networks
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var editorView: DBEditorView!
  
  @IBOutlet weak var boxDataArea: NSBox!
  
  @IBOutlet weak var txtNetworkName: NSTextField!
  
  @IBAction func txtNetworkNameAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet weak var cboLayout: NSComboBox!

  @IBAction func cboLayoutAction(_ sender: NSComboBox) {
    editorView.modified = true
  }
  
  @IBOutlet weak var tabView: NSTabView!
  
  @IBOutlet weak var cboComputerInterface: NSComboBox!
  
  @IBAction func cboComputerInterfaceAction(_ sender: NSComboBox) {
    editorView.modified = true
  }
  
  @IBOutlet weak var txtGroupName: NSTextField!
  
  @IBAction func txtGroupNameAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet weak var txtGroupPassword: NSTextField!
  
  @IBAction func txtGroupPasswordAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet weak var txtGroupChannel: NSTextField!
  
  @IBAction func txtGroupChannelAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet weak var txtGroupId: NSTextField!
  
  @IBAction func txtGroupIdAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet weak var txtLocoNetId: NSTextField!
  
  @IBAction func txtLocoNetIdAction(_ sender: NSTextField) {
    editorView.modified = true
  }
  
  @IBOutlet weak var cboCommandStation: NSComboBox!
  
  @IBAction func cboCommandStationAction(_ sender: NSComboBox) {
    editorView.modified = true
  }
  
}

