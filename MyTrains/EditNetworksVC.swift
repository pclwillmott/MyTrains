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
    
    editorView.dataArea = boxDataArea
    
    cboCommandStation.dataSource = cboCommandStationDS
    
  }
  
  
  private var modified = false
  
  private var cboCommandStationDS = ComboBoxDBDS(tableName: TABLE.COMMAND_STATION, codeColumn: COMMAND_STATION.COMMAND_STATION_ID, displayColumn: COMMAND_STATION.COMMAND_STATION_NAME, sortColumn: COMMAND_STATION.COMMAND_STATION_NAME)
  
  @IBOutlet weak var editorView: DBEditorView!
  
  @IBOutlet weak var boxDataArea: NSBox!
  
  @IBOutlet weak var txtNetworkName: NSTextField!
  
  @IBAction func txtNetworkNameAction(_ sender: NSTextField) {
    modified = true
  }
  
  @IBOutlet weak var cboCommandStation: NSComboBox!
  
  @IBAction func cboCommandStationAction(_ sender: NSComboBox) {
    modified = true
  }
  
}

