//
//  EditNetworksVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/12/2021.
//

import Foundation
import Cocoa

class EditNetworksVC: NSViewController, NSWindowDelegate {
    
  private var editorState : DBEditorState = .select
  
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
    
    cboNetwork.dataSource = cboNetworkDS
    
    cboCommandStation.dataSource = cboCommandStationDS
    
    setControls()
    
  }
  
  private func setControls() {
    
    switch editorState {
    case .select, .selectAndDisplay:
      boxDataArea.isHidden = true
      btnNew.isEnabled = true
      btnEdit.isEnabled = cboNetwork.numberOfItems > 0
      btnSave.isEnabled = false
      btnCancel.isEnabled = false
      btnDelete.isEnabled = cboNetwork.numberOfItems > 0
    case .editExisting, .editNew:
      boxDataArea.isHidden = false
      btnNew.isEnabled = false
      btnEdit.isEnabled = false
      btnSave.isEnabled = modified
      btnCancel.isEnabled = true
      btnDelete.isEnabled = false
      
    }
    
  }
  
  private var modified = false
  
  private func setupDataArea() {
    switch editorState {
    case .select, .selectAndDisplay:
      currentNetwork = nil
      break
    case .editNew:
      currentNetwork = Network()
    case .editExisting:
      let index = cboNetwork.indexOfSelectedItem
      currentNetwork = networkController.networks[index]
    }
    if let network = currentNetwork {
      txtNetworkName.stringValue = network.networkName
      modified = false
    }
  }
  
  private var cboNetworkDS = ComboBoxNetworksDS()
  
  private var cboCommandStationDS = ComboBoxDBDS(tableName: TABLE.COMMAND_STATION, codeColumn: COMMAND_STATION.COMMAND_STATION_ID, displayColumn: COMMAND_STATION.COMMAND_STATION_NAME, sortColumn: COMMAND_STATION.COMMAND_STATION_NAME)
  
  private var currentNetwork : Network?
  
  @IBOutlet weak var btnNew: NSButton!
  
  @IBAction func btnNewAction(_ sender: NSButton) {
    editorState = .editNew
    setupDataArea()
    setControls()
  }
  
  @IBOutlet weak var btnEdit: NSButton!
  
  @IBAction func btnEditAction(_ sender: NSButton) {
    editorState = .editExisting
    setupDataArea()
    setControls()
  }
  
  @IBOutlet weak var btnSave: NSButton!
  
  @IBAction func btnSave(_ sender: NSButton) {
    editorState = .select
    
    print(String(format: "%08x", cboCommandStationDS.codeForItemAt(index: cboCommandStation.indexOfSelectedItem)!))
    setControls()
  }
  
  @IBOutlet weak var btnCancel: NSButton!
  
  @IBAction func btnCancelAction(_ sender: NSButton) {
    editorState = .select
    setControls()
  }
  
  @IBOutlet weak var btnDelete: NSButton!
  
  @IBAction func btnDeleteAction(_ sender: NSButton) {
    editorState = .select
    setControls()
  }
 
  @IBOutlet weak var cboNetwork: NSComboBox!
  
  @IBAction func cboNetworkAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var boxDataArea: NSBox!
  
  @IBOutlet weak var txtNetworkName: NSTextField!
  
  @IBAction func txtNetworkNameAction(_ sender: NSTextField) {
    modified = true
    setControls()
  }
  
  @IBOutlet weak var cboCommandStation: NSComboBox!
  
  @IBAction func cboCommandStationAction(_ sender: NSComboBox) {
    modified = true
    setControls()
  }
  
}

