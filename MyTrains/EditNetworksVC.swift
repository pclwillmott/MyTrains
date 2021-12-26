//
//  EditNetworksVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/12/2021.
//

import Foundation
import Cocoa

class EditNetworksVC: NSViewController, NSWindowDelegate, DBEditorDelegate {

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
    
    editorView.dictionary = networkController.networks
    
    cboCommandStation.dataSource = cboCommandStationDS
    
    cboLayout.dataSource = cboLayoutDS
    
  }
  
  // Private Properties
  
  private var cboCommandStationDS = ComboBoxDBDS(tableName: TABLE.COMMAND_STATION, codeColumn: COMMAND_STATION.COMMAND_STATION_ID, displayColumn: COMMAND_STATION.COMMAND_STATION_NAME, sortColumn: COMMAND_STATION.COMMAND_STATION_NAME)
  
  private var cboLayoutDS = ComboBoxDBDS(tableName: TABLE.LAYOUT, codeColumn: LAYOUT.LAYOUT_ID, displayColumn: LAYOUT.LAYOUT_NAME, sortColumn: LAYOUT.LAYOUT_NAME)
  
  // DBEditorView Delegate Methods
  
  func clearFields(dbEditorView:DBEditorView) {
    txtNetworkName.stringValue = ""
    cboCommandStation.deselectItem(at: cboCommandStation.indexOfSelectedItem)
    cboLayout.deselectItem(at: cboLayout.indexOfSelectedItem)
  }
  
  func setupFields(dbEditorView: DBEditorView, editorObject: EditorObject) {
    clearFields(dbEditorView: dbEditorView)
    if let network = editorObject as? Network {
      txtNetworkName.stringValue = network.networkName
      if let csIndex = cboCommandStationDS.indexOfItemWithCodeValue(code: network.commandStationId) {
        cboCommandStation.selectItem(at: csIndex)
      }
      if let loIndex = cboLayoutDS.indexOfItemWithCodeValue(code: network.layoutId) {
        cboLayout.selectItem(at: loIndex)
      }
    }
  }
  
  func validate(dbEditorView: DBEditorView) -> String? {
    if txtNetworkName.stringValue.trimmingCharacters(in: .whitespaces) == "" {
      txtNetworkName.becomeFirstResponder()
      return "The network must have a name."
    }
    if cboLayout.indexOfSelectedItem == -1 {
      cboLayout.becomeFirstResponder()
//      return "The network must belong to a layout."
    }
    return nil
  }
  
  func setFields(network:Network) {
    network.networkName = txtNetworkName.stringValue
    network.commandStationId = cboCommandStationDS.codeForItemAt(index: cboCommandStation.indexOfSelectedItem) ?? -1
    network.layoutId = cboLayoutDS.codeForItemAt(index: cboLayout.indexOfSelectedItem) ?? -1
    network.save()
  }
  
  func saveNew(dbEditorView: DBEditorView) -> EditorObject {
    let network = Network()
    setFields(network: network)
    networkController.networks[network.primaryKey] = network
    editorView.dictionary = networkController.networks
    return network
  }
  
  func saveExisting(dbEditorView: DBEditorView, editorObject: EditorObject) {
    if let network = editorObject as? Network {
      setFields(network: network)
    }
  }
  
  func delete(dbEditorView: DBEditorView, primaryKey: Int) {
    networkController.networks.removeValue(forKey: primaryKey)
    Network.delete(primaryKey: primaryKey)
    editorView.dictionary = networkController.networks
  }
  
  // Outlets & Actions
  
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
  
  @IBOutlet weak var cboCommandStation: NSComboBox!
  
  @IBAction func cboCommandStationAction(_ sender: NSComboBox) {
    editorView.modified = true
  }
  
  @IBOutlet weak var tabView: NSTabView!
  
}

