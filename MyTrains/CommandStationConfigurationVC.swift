//
//  CommandStationConfigurationVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/02/2022.
//

import Foundation
import Cocoa

class CommandStationConfigurationVC: NSViewController, NSWindowDelegate {
 
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
    
    cboCommandStationDS.dictionary = networkController.commandStations
    
    cboCommandStation.dataSource = cboCommandStationDS
    
    if cboCommandStation.numberOfItems > 0 {
      cboCommandStation.selectItem(at: 0)
      commandStation = cboCommandStationDS.commandStationAt(index: 0)
      if let cs = commandStation {
        csConfigurationTableViewDS.options = cs.optionSwitches
        tableView.dataSource = csConfigurationTableViewDS
        tableView.delegate = csConfigurationTableViewDS
        tableView.reloadData()
      }
    }

  }
  
  // MARK: Private Properties
  
  private var cboCommandStationDS : CommmandStationComboBoxDS = CommmandStationComboBoxDS()

  private var commandStation : CommandStation? {
    didSet {
      if let cs = commandStation {
        csConfigurationTableViewDS.options = cs.optionSwitches
        tableView.dataSource = csConfigurationTableViewDS
        tableView.reloadData()
      }
    }
  }
  
  private var csConfigurationTableViewDS : CSConfigurationTableViewDS = CSConfigurationTableViewDS()
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboCommandStation: NSComboBox!
  
  @IBAction func cboCommandStationAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var radConfigurationSlot: NSButton!
  
  @IBAction func radConfigurationSlotAction(_ sender: NSButton) {
    radOptionSwitches.state = sender.state == .on ? .off : .on
  }
  
  @IBOutlet weak var radOptionSwitches: NSButton!
  
  @IBAction func radOptionSwitchesAction(_ sender: NSButton) {
    radConfigurationSlot.state = sender.state == .on ? .off : .on
  }
  
  @IBOutlet weak var btnRead: NSButton!
  
  @IBAction func btnReadAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var btnWrite: NSButton!
  
  @IBAction func btnWriteAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var tableView: NSTableView!
  
  @IBAction func tableViewAction(_ sender: NSTableView) {
  }
  
}


