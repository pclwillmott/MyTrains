//
//  BridgeVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/11/2022.
//

import Foundation
import Cocoa

class BridgeVC: NSViewController, NSWindowDelegate, InterfaceDelegate {
  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
  }
  
  @objc func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  @objc func windowWillClose(_ notification: Notification) {
    locoNetBridge.throttleNetwork = nil
    locoNetBridge.slaveNetwork = nil
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    cboThrottleNetwork.dataSource = cboThrottleNetworkDS
    
    cboSlaveNetwork.dataSource = cboSlaveNetworkDS
    
    throttleNetworkId = UserDefaults.standard.integer(forKey: DEFAULT.BRIDGE_THROTTLE_NETWORK)
    
    locoNetBridge.throttleNetwork = networkController.networks[throttleNetworkId]
    
    if let index = cboThrottleNetworkDS.indexOfItemWithCodeValue(code: throttleNetworkId) {
      cboThrottleNetwork.selectItem(at: index)
    }
    
    slaveNetworkId = UserDefaults.standard.integer(forKey: DEFAULT.BRIDGE_SLAVE_NETWORK)

    locoNetBridge.slaveNetwork = networkController.networks[slaveNetworkId]
    
    if let index = cboSlaveNetworkDS.indexOfItemWithCodeValue(code: slaveNetworkId) {
      cboSlaveNetwork.selectItem(at: index)
    }
    
  }
  
  // MARK: Private Properties
  
  private var cboThrottleNetworkDS = ComboBoxDBDS(tableName: TABLE.NETWORK, codeColumn: NETWORK.NETWORK_ID, displayColumn: NETWORK.NETWORK_NAME, sortColumn: NETWORK.NETWORK_NAME)

  private var cboSlaveNetworkDS = ComboBoxDBDS(tableName: TABLE.NETWORK, codeColumn: NETWORK.NETWORK_ID, displayColumn: NETWORK.NETWORK_NAME, sortColumn: NETWORK.NETWORK_NAME)
  
  private var throttleNetworkId : Int = -1
  
  private var slaveNetworkId : Int = -1
  
  private var locoNetBridge : LocoNetBridge = LocoNetBridge()


  // MARK: Actions & Outlets
  
  @IBOutlet weak var cboThrottleNetwork: NSComboBox!
  
  @IBAction func cboThrottleNetworkAction(_ sender: NSComboBox) {
    
    throttleNetworkId = -1

    if let id = cboThrottleNetworkDS.codeForItemAt(index: cboThrottleNetwork.indexOfSelectedItem) {
      throttleNetworkId = id
      locoNetBridge.throttleNetwork = networkController.networks[throttleNetworkId]
    }

    UserDefaults.standard.set(throttleNetworkId, forKey: DEFAULT.BRIDGE_THROTTLE_NETWORK)

  }
  
  @IBOutlet weak var cboSlaveNetwork: NSComboBox!
  
  @IBAction func cboSlaveNetworkAction(_ sender: NSComboBox) {
    
    slaveNetworkId = -1

    if let id = cboSlaveNetworkDS.codeForItemAt(index: cboSlaveNetwork.indexOfSelectedItem) {
      slaveNetworkId = id
      locoNetBridge.slaveNetwork = networkController.networks[slaveNetworkId]
    }

    UserDefaults.standard.set(slaveNetworkId, forKey: DEFAULT.BRIDGE_SLAVE_NETWORK)

  }
  
  @IBAction func btnThrottleNetwork(_ sender: NSButton) {

    locoNetBridge.throttleNetwork = nil
    
    throttleNetworkId = -1

    UserDefaults.standard.set(throttleNetworkId, forKey: DEFAULT.BRIDGE_THROTTLE_NETWORK)
    
    cboThrottleNetwork.deselectItem(at: cboThrottleNetwork.indexOfSelectedItem)

  }
  
  @IBAction func btnClearSlaveNetwork(_ sender: NSButton) {
    
    locoNetBridge.slaveNetwork = nil
    
    slaveNetworkId = -1

    UserDefaults.standard.set(slaveNetworkId, forKey: DEFAULT.BRIDGE_SLAVE_NETWORK)
    
    cboSlaveNetwork.deselectItem(at: cboSlaveNetwork.indexOfSelectedItem)
    
  }
  
}

