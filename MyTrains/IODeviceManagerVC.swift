//
//  IODeviceManagerVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 12/01/2023.
//

import Foundation
import Cocoa

class IODeviceManagerVC: NSViewController, NSWindowDelegate, InterfaceDelegate {
  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
    if observerId != -1 {
      interface?.removeObserver(id: observerId)
      observerId = -1
    }
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    cboNetworkDS.dictionary = networkController.networksForCurrentLayout
    
    cboNetwork.dataSource = cboNetworkDS
    
    let networkId = UserDefaults.standard.integer(forKey: DEFAULT.IODEVICE_MANAGER_NETWORK)
    
    cboNetwork.selectItem(at: cboNetworkDS.indexWithKey(key: networkId) ?? -1)
    
    if cboNetwork.indexOfSelectedItem == -1 {
      cboNetwork.selectItem(at: 0)
    }
    
    setupInterface()
    
  }
  
  // MARK: Private Properties
  
  private var cboNetworkDS : ComboBoxDictDS = ComboBoxDictDS()

  private var observerId : Int = -1
  
  private var interface : Interface?
  
  private var tableViewDS = IODeviceManagerTableViewDS()
  
  // MARK: Private Methods
  
  private func setupInterface() {
    
    if observerId != -1 {
      interface?.removeObserver(id: observerId)
      observerId = -1
    }
    
    if let network = cboNetworkDS.editorObjectAt(index: cboNetwork.indexOfSelectedItem) as? Network, let interface = network.interface {
      
      self.interface = interface
      self.observerId = interface.addObserver(observer: self)
      
      tableViewDS.ioFunctions = networkController.ioFunctions(networkId: network.primaryKey)
      tvTableView.dataSource = tableViewDS
      tvTableView.delegate = tableViewDS
      tvTableView.reloadData()
      
    }
    
  }
  
  // MARK: InterfaceDelegate Methods
  
  func networkMessageReceived(message:NetworkMessage) {
    
  }

  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboNetwork: NSComboBox!
  
  @IBAction func cboNetworkAction(_ sender: NSComboBox) {
    
    let networkId = cboNetworkDS.editorObjectAt(index: cboNetwork.indexOfSelectedItem)?.primaryKey ?? -1
    
    UserDefaults.standard.set(networkId, forKey: DEFAULT.IODEVICE_MANAGER_NETWORK)
    
    setupInterface()
    
  }
  
  @IBOutlet weak var tvTableView: NSTableView!
  
  @IBAction func tvTableViewAction(_ sender: NSTableView) {
    print("tvAction")
  }
  
  @IBAction func btnEditIODeviceAction(_ sender: NSButton) {
    if let ioFunctions = tableViewDS.ioFunctions {
      ioFunctions[sender.tag].ioDevice.propertySheet()
      tvTableView.reloadData()
    }
  }
  
  @IBAction func btnDeleteIODeviceAction(_ sender: NSButton) {
  }
  
  @IBAction func btnEditChannelAction(_ sender: NSButton) {
    if let ioFunctions = tableViewDS.ioFunctions {
      ioFunctions[sender.tag].ioChannel.propertySheet()
      tvTableView.reloadData()
    }
  }
  
  @IBAction func btnEditFunctionAction(_ sender: NSButton) {
    if let ioFunctions = tableViewDS.ioFunctions {
      ioFunctions[sender.tag].propertySheet()
      tvTableView.reloadData()
    }
  }
  
  @IBAction func txtBoardIDAction(_ sender: NSTextField) {
    if let ioFunctions = tableViewDS.ioFunctions {
      ioFunctions[sender.tag].ioDevice.boardId = sender.integerValue
      tvTableView.reloadData()
    }
  }
  
}

