//
//  CommandStationConfigurationVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/02/2022.
//

import Foundation
import Cocoa

class CommandStationConfigurationVC: NSViewController, NSWindowDelegate, InterfaceDelegate {
 
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }

  func windowWillClose(_ notification: Notification) {
    if let interface = self.interface, observerId != -1 {
      interface.removeObserver(id: observerId)
      observerId = -1
      self.interface = nil
    }
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    cboNetworkDS.dictionary = networkController.networksForCurrentLayout
    
    cboNetwork.dataSource = cboNetworkDS
    
    if cboNetworkDS.dictionary.count > 0 {
      cboNetwork.selectItem(at: 0)
    }
    
    setupView()
    
  }
  
  // MARK: Private Enums
  
  private enum ConfigState {
    case idle
    case waitingForCfgSlotDataP1
    case waitingForReadSwitchAck
    case waitingforMassReadSwitchAck
    case waitingForBaseCase
    case waitingForNewCase
  }
  
  // MARK: Private Properties
  
  private var buttons : [NSButton] = []
  
  private var isDirty : Bool = true
  
  private var cboCommandStationDS : ComboBoxDictDS = ComboBoxDictDS()
  
  private var cboNetworkDS : ComboBoxDictDS = ComboBoxDictDS()

  private var observerId : Int = -1
  
  private var interface : Interface?
  
  private var configState : ConfigState = .idle
  
  private var nextReadIndex : Int = 0
  
  private var readSwitchNumber : Int = -1
  
  private var opswTableViewDS : OpSwTableViewDS = OpSwTableViewDS()
  
  // MARK: Private Methods
  
  private func setupView() {
    
    cboCommandStation.dataSource = nil
    
    if let interface = self.interface, observerId != -1 {
      interface.removeObserver(id: observerId)
      observerId = -1
      self.interface = nil
    }
    
    if cboNetwork.indexOfSelectedItem != -1 {
      
      if let network = cboNetworkDS.editorObjectAt(index: cboNetwork.indexOfSelectedItem) as? Network {
        
        if let interface = network.interface {
          self.interface = interface
          observerId = interface.addObserver(observer: self)
        }
        
        cboCommandStationDS.dictionary = networkController.locoNetDevicesForNetworkWithAttributes(networkId: network.primaryKey, attributes: [.OptionSwitches])
        
        cboCommandStation.dataSource = cboCommandStationDS
        
        if cboCommandStation.numberOfItems > 0 {
          cboCommandStation.selectItem(at: 0)
          setupTableView()
        }
        
      }
      
    }
    
  }
  
  private func setupTableView() {
    
    tableView.dataSource = nil
    tableView.delegate = nil
    tableView.reloadData()
    
    if let device = cboCommandStationDS.editorObjectAt(index: cboCommandStation.indexOfSelectedItem) as? LocoNetDevice {
      opswTableViewDS.options = device.optionSwitches
      tableView.dataSource = opswTableViewDS
      tableView.delegate = opswTableViewDS
      tableView.reloadData()
    }
    
  }
  
  // MARK: InterfaceDelegate Methods
  
  @objc func networkMessageReceived(message:NetworkMessage) {
    
  }

  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboCommandStation: NSComboBox!
  
  @IBAction func cboCommandStationAction(_ sender: NSComboBox) {
    setupTableView()
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
    
  @IBOutlet weak var cboNetwork: NSComboBox!
  
  @IBAction func cboNetworkAction(_ sender: NSComboBox) {
    setupView()
  }
  
  @IBOutlet weak var lblOptionSwitchesRead: NSTextField!
  
}


