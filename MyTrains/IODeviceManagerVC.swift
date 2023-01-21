//
//  IODeviceManagerVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 12/01/2023.
//

import Foundation
import Cocoa

class IODeviceManagerVC: NSViewController, NSWindowDelegate, UpdateDelegate {
  
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

  private var tableViewDS = IODeviceManagerTableViewDS()
  
  // MARK: Private Methods
  
  private func setupInterface() {
    
    if let network = cboNetworkDS.editorObjectAt(index: cboNetwork.indexOfSelectedItem) as? Network, let interface = network.interface {
      
      tableViewDS.ioFunctions = networkController.ioFunctions(networkId: network.primaryKey)
      tvTableView.dataSource = tableViewDS
      tvTableView.delegate = tableViewDS
      tvTableView.reloadData()
      
    }
    
  }
  
  // MARK: UpdateDelegate Methods
  
  public func displayUpdate(update:String) {
    lblUpdate.stringValue = update
  }
  
  public func updateCompleted(success:Bool) {
    
    tvTableView.reloadData()
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
  }
  
  @IBAction func btnEditIODeviceAction(_ sender: NSButton) {
    if let ioFunctions = tableViewDS.ioFunctions {
      ioFunctions[sender.tag].ioDevice.upDateDelegate = self
      ioFunctions[sender.tag].ioDevice.propertySheet()
      tvTableView.reloadData()
    }
  }
  
  @IBAction func btnDeleteIODeviceAction(_ sender: NSButton) {
 
    if let ioFunctions = tableViewDS.ioFunctions {
      
      let ioDevice = ioFunctions[sender.tag].ioDevice

      let alert = NSAlert()

      alert.messageText = ioDevice.deleteCheck()
      alert.informativeText = ""
      alert.addButton(withTitle: "No")
      alert.addButton(withTitle: "Yes")
      alert.alertStyle = .warning

      if alert.runModal() == NSApplication.ModalResponse.alertSecondButtonReturn {
        if let network = cboNetworkDS.editorObjectAt(index: cboNetwork.indexOfSelectedItem) as? Network {
          networkController.removeDevice(primaryKey: ioDevice.primaryKey)
          IODevice.delete(primaryKey: ioDevice.primaryKey)
          tableViewDS.ioFunctions = networkController.ioFunctions(networkId: network.primaryKey)
          tvTableView.reloadData()
        }
      }

    }
    
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
      ioFunctions[sender.tag].ioDevice.setBoardId(newBoardId: sender.integerValue)
      tvTableView.reloadData()
    }
  }
  
  @IBAction func txtIODeviceAction(_ sender: NSTextField) {
    if let ioFunctions = tableViewDS.ioFunctions {
      ioFunctions[sender.tag].ioDevice.deviceName = sender.stringValue
      ioFunctions[sender.tag].ioDevice.save()
      tvTableView.reloadData()
    }
  }
  
  @IBAction func cboTVNetworkAction(_ sender: NSComboBox) {
    if let network = cboNetworkDS.editorObjectAt(index: sender.indexOfSelectedItem) as? Network, let ioFunctions = tableViewDS.ioFunctions {
      ioFunctions[sender.tag].ioDevice.networkId = network.primaryKey
      ioFunctions[sender.tag].ioDevice.save()
      tableViewDS.ioFunctions = networkController.ioFunctions(networkId: network.primaryKey)
      tvTableView.reloadData()
    }
  }
  
  @IBAction func btnNewAction(_ sender: NSButton) {
 
    if let network = cboNetworkDS.editorObjectAt(index: cboNetwork.indexOfSelectedItem) as? Network {
      
      let x = ModalWindow.IODeviceNew
      let wc = x.windowController
      let vc = x.viewController(windowController: wc) as! IODeviceNewVC
      vc.network = network
      if let window = wc.window {
        NSApplication.shared.runModal(for: window)
        window.close()
        tableViewDS.ioFunctions = networkController.ioFunctions(networkId: network.primaryKey)
        tvTableView.reloadData()
      }

    }
    
  }
  
  @IBOutlet weak var lblUpdate: NSTextField!
  
  @IBAction func btnWriteChannelAction(_ sender: NSButton) {
    if let ioFunctions = tableViewDS.ioFunctions, let ioFunction = ioFunctions[sender.tag] as? IOFunctionDS64Output {
      ioFunction.ioDevice.upDateDelegate = self
      ioFunction.ioChannel.writeChannel()
    }
    if let ioFunctions = tableViewDS.ioFunctions, let ioFunction = ioFunctions[sender.tag] as? IOFunctionBXP88Input {
      ioFunction.ioDevice.upDateDelegate = self
      ioFunction.ioChannel.writeChannel()
    }
  }
  
  @IBAction func cboChannelTypeAction(_ sender: NSComboBox) {
    
    if let ioFunctions = tableViewDS.ioFunctions {
      let ioChannel = ioFunctions[sender.tag].ioChannel
      ioChannel.channelType = InputOutput.selected(comboBox: sender)
    }
    
  }
  
  
  
}

