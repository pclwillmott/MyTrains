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
  }
  
  // MARK: Private Properties
  
  private var cboCommandStationDS : ComboBoxDictDS = ComboBoxDictDS()
  
  private var cboNetworkDS : ComboBoxDictDS = ComboBoxDictDS()

  private var observerId : Int = -1
  
  private var interface : Interface?
  
  private var configState : ConfigState = .idle
  
  private var opswTableViewDS : OpSwTableViewDS = OpSwTableViewDS()
  
  private var selectedSwitches : Set<Int> = []
  
  private var timer : Timer?
  
  private var isRead : Bool = true
  
  private var lastIndex : Int = 0
  
  private var noResponse : Bool = false
  
  private var lastMethod : OptionSwitchMethod = .OpMode
  
  private var inOpMode : Bool = false

  let series7CV : [Set<Int>] = [
    [ 1, 2, 3, 4, 5, 6, 7, 8],
    [ 9,10,11,12,13,14,15,16],
    [17,18,19,20,21,22,23,24],
    [25,26,27,28,29,30,31,32],
    [33,34,35,36,37,38,39,40],
    [41,42,43,44,45,46,47,48],
  ]

  // MARK: Private Methods
  
  @objc func next() {
    
    if noResponse {
      stopTimer()
      return
    }
    
    noResponse = true
    
    if let device = cboCommandStationDS.editorObjectAt(index: cboCommandStation.indexOfSelectedItem) as? LocoNetDevice, let interface = self.interface {
      
      if let method = device.methodForOpSw[.Series7], !method.intersection(selectedSwitches).isEmpty {
        
        lastIndex = 0
        
        for cv in series7CV {
          
          if !cv.intersection(selectedSwitches).isEmpty {
            
            lastMethod = .Series7
            
            interface.getS7CV(device: device, cvNumber: 11 + lastIndex)
            
            return
            
          }
          
          lastIndex += 1
          
        }
        
      }
      
      else if let method = device.methodForOpSw[.OpSwDataAP1], !method.intersection(selectedSwitches).isEmpty {
          
        lastMethod = .OpSwDataAP1
        
        if isRead {
          interface.getOpSwDataAP1()
        }
        else {
          
          interface.setLocoSlotDataP1(slotData: device.newOpSwDataAP1)

          for switchNumber in 1...64 {
            if (switchNumber % 8) != 0 {
              selectedSwitches.remove(switchNumber)
            }
          }
          
        }

      }
      
      else if let method = device.methodForOpSw[.OpSwDataBP1], !method.intersection(selectedSwitches).isEmpty {
        
        lastMethod = .OpSwDataBP1
        
        if isRead {
          interface.getOpSwDataBP1()
        }
        else {
          
          interface.setLocoSlotDataP1(slotData: device.newOpSwDataBP1)

          for switchNumber in 65...128 {
            if (switchNumber % 8) != 0 {
              selectedSwitches.remove(switchNumber)
            }
          }

        }
        
      }
      
      else if let method = device.methodForOpSw[.BrdOpSw], !method.intersection(selectedSwitches).isEmpty {
        
        let intersect = method.intersection(selectedSwitches)
        
        lastIndex = intersect.first!
        
        lastMethod = .BrdOpSw
        
        if isRead {
          interface.getBrdOpSwState(device: device, switchNumber: lastIndex)
        }
        else {
          if let opsw = device.optionSwitchDictionary[lastIndex] {
            interface.setSw(switchNumber: lastIndex, state: opsw.newState)
            selectedSwitches.remove(lastIndex)
          }
        }

      }
      
      else if let method = device.methodForOpSw[.OpMode], !method.intersection(selectedSwitches).isEmpty {
        
        if !inOpMode, let message = OptionSwitch.enterOptionSwitchModeInstructions[device.locoNetProductId] {
            
          let alert = NSAlert()

          alert.messageText = message
          alert.informativeText = ""
          alert.addButton(withTitle: "OK")
          alert.alertStyle = .informational

          alert.runModal() 
          
          inOpMode = true

        }
        
        let intersect = method.intersection(selectedSwitches)
        
        lastIndex = intersect.first!
        
        lastMethod = .OpMode
        
        if isRead {
          interface.getSwState(switchNumber: lastIndex)
        }
        else {
          if let opsw = device.optionSwitchDictionary[lastIndex] {
            interface.setSw(switchNumber: lastIndex, state: opsw.newState)
            selectedSwitches.remove(lastIndex)
          }
        }
        
      }
      
      else {
        stopTimer()
      }

    }
    
  }
  
  func startTimer() {
    timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(next), userInfo: nil, repeats: true)
    noResponse = false
    RunLoop.current.add(timer!, forMode: .common)
  }
  
  func stopTimer() {
    
    timer?.invalidate()
    timer = nil
    
    if let device = cboCommandStationDS.editorObjectAt(index: cboCommandStation.indexOfSelectedItem) as? LocoNetDevice {
      
      device.optionSwitchesOK = true
      
      device.save()
      
      setupTableView()
      
      if inOpMode, let message = OptionSwitch.exitOptionSwitchModeInstructions[device.locoNetProductId] {
          
        let alert = NSAlert()

        alert.messageText = message
        alert.informativeText = ""
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .informational

        alert.runModal()
        
      }
      
      inOpMode = false

    }
    
  }
  
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
    
    lblOptionSwitchesRead.stringValue = "Option Switches have not been read."
    
    if let device = cboCommandStationDS.editorObjectAt(index: cboCommandStation.indexOfSelectedItem) as? LocoNetDevice {
      opswTableViewDS.options = device.optionSwitches
      tableView.dataSource = opswTableViewDS
      tableView.delegate = opswTableViewDS
      lblOptionSwitchesRead.stringValue = device.optionSwitchesOK ? "Option Switches have been read." : "Option Switches have not been read."
    }

    tableView.reloadData()

  }
  
  // MARK: InterfaceDelegate Methods
  
  @objc func networkMessageReceived(message:NetworkMessage) {
    
    if let device = cboCommandStationDS.editorObjectAt(index: cboCommandStation.indexOfSelectedItem) as? LocoNetDevice {
 
      switch message.messageType {
        
      case .opSwDataAP1:
        
        guard lastMethod == .OpSwDataAP1 else {
          return
        }
        
        device.setState(opswDataAP1: message)
        
        for switchNumber in 1...64 {
          if (switchNumber % 8) != 0 {
            selectedSwitches.remove(switchNumber)
          }
        }
        
        noResponse = false
        
      case .opSwDataBP1:
        
        guard lastMethod == .OpSwDataBP1 else {
          return
        }
        
        device.setState(opswDataBP1: message)
        
        for switchNumber in 65...128 {
          if (switchNumber % 8) != 0 {
            selectedSwitches.remove(switchNumber)
          }
        }
        
        noResponse = false
        
      case .swState:
        
        guard lastMethod == .OpMode else {
          return
        }
        
        if let opsw = device.optionSwitchDictionary[lastIndex] {
          
          let mask : UInt8 = 0b00100000
          
          opsw.state = (message.message[2] & mask) == mask ? .closed : .thrown
          
          selectedSwitches.remove(lastIndex)
          
          noResponse = false
          
        }
        
      case .brdOpSwState:
        
        guard lastMethod == .BrdOpSw else {
          return
        }
        
        if let opsw = device.optionSwitchDictionary[lastIndex] {
          
          let mask : UInt8 = 0b00100000
          
          opsw.state = (message.message[2] & mask) == mask ? .closed : .thrown
          
          selectedSwitches.remove(lastIndex)
          
          noResponse = false
          
        }
        
      case .routesDisabled, .s7CVState:
        
        guard lastMethod == .Series7 else {
          return
        }
        
        for bit in 0...7 {
          
          let switchNumber = lastIndex * 8 + bit + 1
          
          if bit < 7 {
            
            let mask : UInt8 = 1 << bit
            
            let value : OptionSwitchState = ((message.message[2] & mask) == mask ? .closed : .thrown)
            
            device.setState(switchNumber: switchNumber, value: value)
            
            if let opsw = device.optionSwitchDictionary[switchNumber] {
              opsw.state = value
            }
            
          }
          else {
            
            let mask : UInt8 = 0b00000011
            
            let value : OptionSwitchState = ((message.message[1] & mask) == 0b00000010 ? .closed : .thrown)

            device.setState(switchNumber: switchNumber, value: value)
            
            if let opsw = device.optionSwitchDictionary[switchNumber] {
              opsw.state = value
            }
            
          }
          
          selectedSwitches.remove(switchNumber)
          
        }
        
        noResponse = false

      default:
        break
      }

    }
    
  }

  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboCommandStation: NSComboBox!
  
  @IBAction func cboCommandStationAction(_ sender: NSComboBox) {
    setupTableView()
  }
  
  @IBOutlet weak var btnRead: NSButton!
  
  @IBAction func btnReadAction(_ sender: NSButton) {
    
    selectedSwitches.removeAll()
    
    if let device = cboCommandStationDS.editorObjectAt(index: cboCommandStation.indexOfSelectedItem) as? LocoNetDevice {
      
      selectedSwitches = device.optionSwitchSet
      
      if selectedSwitches.count > 0 {
        
        isRead = true
        
        startTimer()
        
      }
      
    }
    
  }
  
  @IBOutlet weak var btnWrite: NSButton!
  
  @IBAction func btnWriteAction(_ sender: NSButton) {

    selectedSwitches.removeAll()
    
    if let device = cboCommandStationDS.editorObjectAt(index: cboCommandStation.indexOfSelectedItem) as? LocoNetDevice {
      
      selectedSwitches = device.optionSwitchesChangedSet
      
      if selectedSwitches.count > 0 {
        
        isRead = false
        
        startTimer()
        
      }
      
    }

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
