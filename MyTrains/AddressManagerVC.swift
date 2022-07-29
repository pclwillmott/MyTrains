//
//  AddressManagerVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 28/07/2022.
//

import Foundation

import Foundation
import Cocoa

class AddressManagerVC: NSViewController, NSWindowDelegate, InterfaceDelegate {

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
  
  // MARK: Private Properties
  
  private var cboNetworkDS : ComboBoxDictDS = ComboBoxDictDS()

  private var observerId : Int = -1
  
  private var interface : Interface?
  
  private var tableViewDS : AddressTableViewDS = AddressTableViewDS()
  
  private var device : LocoNetDevice?
  
  private var timer : Timer?
  
  private var nextAddr : Int = 0
 
  // MARK: Private Methods
  
  private func setupView() {
    
    if let interface = self.interface, observerId != -1 {
      interface.removeObserver(id: observerId)
      observerId = -1
      self.interface = nil
    }
 
    tableViewDS.devices = nil
    tableView.dataSource = nil
    tableView.delegate = nil

    if cboNetwork.indexOfSelectedItem != -1, let network = cboNetworkDS.editorObjectAt(index: cboNetwork.indexOfSelectedItem) as? Network {
        
      if let interface = network.interface {
        self.interface = interface
        observerId = interface.addObserver(observer: self)
      }

      tableViewDS.devices = networkController.devicesWithAddresses(networkId: network.primaryKey)
      tableView.dataSource = tableViewDS
      tableView.delegate = tableViewDS
      
    }
    
    tableView.reloadData()
  }
  
  @objc func next() {
    
    if let device = self.device, let interface = self.interface {
      
      if nextAddr == device.numberOfAddresses {
        stopTimer()
        return
      }
      
      interface.setSw(switchNumber: device.baseAddress + nextAddr, state: .closed)
      
      nextAddr += 1
      
    }
    
  }
  
  func startTimer() {
    timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(next), userInfo: nil, repeats: true)
    RunLoop.current.add(timer!, forMode: .common)
  }
  
  func stopTimer() {
    
    timer?.invalidate()
    timer = nil
    
    if let device = self.device {
      
      device.baseAddressOK = true
      
      device.save()
      
      tableView.reloadData()
      
    }
    
  }

  // MARK: Outlets & Actions
  
  @IBOutlet weak var tableView: NSTableView!
  
  @IBAction func tableViewAction(_ sender: NSTableView) {
  }
  
  @IBAction func btnSetAction(_ sender: NSButton) {
    
    let device = tableViewDS.devices![sender.tag]
    
    self.device = device
    
    if let interface = self.interface {
      
      if device.isSeries7 {
        interface.setS7BaseAddr(device: device)
        device.baseAddressOK = true
        device.save()
        tableView.reloadData()
      }
      else if let message = OptionSwitch.enterSetBoardIdModeInstructions[device.locoNetProductId] {
        
        let alert = NSAlert()

        alert.messageText = message
        alert.informativeText = ""
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .informational

        alert.runModal()
        
        interface.setSw(switchNumber: device.boardId, state: .closed)
        
        if device.locoNetProductId == .DS64, let message = OptionSwitch.enterSetSwitchAddressModeInstructions[device.locoNetProductId] {

          alert.messageText = message

          alert.runModal()
          
          nextAddr = 0
          
          startTimer()
          
        }
        else {
          device.baseAddressOK = true
          device.save()
          tableView.reloadData()
        }

      }
      
    }
    
  }
  
  @IBOutlet weak var cboNetwork: NSComboBox!
  
  @IBAction func cboNetworkAction(_ sender: NSComboBox) {
    setupView()
  }
  @IBAction func txtBaseAddressAction(_ sender: NSTextField) {
    let device = tableViewDS.devices![sender.tag]
    device.baseAddressOK = device.boardId == sender.integerValue
    device.boardId = sender.integerValue
    device.save()
    tableView.reloadData()
  }
  
  @IBAction func txtBoardIDAction(_ sender: NSTextField) {
    let device = tableViewDS.devices![sender.tag]
    device.baseAddressOK = device.boardId == sender.integerValue
    device.boardId = sender.integerValue
    device.save()
    tableView.reloadData()
  }
}
