//
//  CommandStationConfigurationVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/02/2022.
//

import Foundation
import Cocoa

class CommandStationConfigurationVC: NSViewController, NSWindowDelegate, CommandStationDelegate {
 
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }

  func windowWillClose(_ notification: Notification) {
    if delegateId != -1 {
      commandStation?.removeDelegate(id: delegateId)
    }
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
        delegateId = cs.addDelegate(delegate: self)
      }
    }

  }
  
  // MARK: Private Enums
  
  private enum ConfigState {
    case idle
    case waitingForCfgSlotDataP1
    case waitingForReadSwitchAck
  }
  
  // MARK: Private Properties
  
  private var cboCommandStationDS : CommmandStationComboBoxDS = CommmandStationComboBoxDS()

  private var delegateId : Int = -1
  
  private var configState : ConfigState = .idle
  
  private var nextReadIndex : Int = 0
  
  private var readSwitchNumber : Int = -1
  
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
  
  // MARK: Command Station Delegate Methods
  
  func trackStatusChanged(commandStation: CommandStation) {
    tableView.reloadData()
  }
  
  func messageReceived(message:NetworkMessage) {
    
    let options = csConfigurationTableViewDS.options
    
    switch message.messageType {
    case .cfgSlotDataP1:
      if radOptionSwitches.state == .on && configState == .waitingForCfgSlotDataP1 {
        nextReadIndex = 0
        while nextReadIndex < options.count && options[nextReadIndex].switchDefinition.configByte != -1 {
          nextReadIndex += 1
        }
        readSwitchNumber = options[nextReadIndex].switchNumber
        configState = .waitingForReadSwitchAck
        commandStation?.swState(switchNumber: readSwitchNumber)
        break
      }
      configState = .idle
      break
    case .swStateThrown, .swStateClosed:
      if configState == .waitingForReadSwitchAck {
        let state : OptionSwitchState = message.messageType == .swStateClosed ? .closed : .thrown
        options[nextReadIndex].state = state
        nextReadIndex += 1
        while nextReadIndex < options.count && options[nextReadIndex].switchDefinition.configByte != -1 {
          nextReadIndex += 1
        }
        if nextReadIndex == options.count {
          configState = .idle
          tableView.reloadData()
          break
        }
        readSwitchNumber = options[nextReadIndex].switchNumber
        configState = .waitingForReadSwitchAck
        commandStation?.swState(switchNumber: readSwitchNumber)
        break
      }
      configState = .idle
    default:
      break
    }
  }

  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboCommandStation: NSComboBox!
  
  @IBAction func cboCommandStationAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var radConfigurationSlot: NSButton!
  
  @IBAction func radConfigurationSlotAction(_ sender: NSButton) {
    radOptionSwitches.state = sender.state == .on ? .off : .on
    csConfigurationTableViewDS.isConfigurationSlotMode = sender.state == .on
    tableView.reloadData()
  }
  
  @IBOutlet weak var radOptionSwitches: NSButton!
  
  @IBAction func radOptionSwitchesAction(_ sender: NSButton) {
    radConfigurationSlot.state = sender.state == .on ? .off : .on
    csConfigurationTableViewDS.isConfigurationSlotMode = sender.state == .off
    tableView.reloadData()
  }
  
  @IBOutlet weak var btnRead: NSButton!
  
  @IBAction func btnReadAction(_ sender: NSButton) {
    configState = .waitingForCfgSlotDataP1
    commandStation?.getCfgSlotDataP1()
  }
  
  @IBOutlet weak var btnWrite: NSButton!
  
  @IBAction func btnWriteAction(_ sender: NSButton) {
    if radOptionSwitches.state == .on {
      for opsw in csConfigurationTableViewDS.options {
        if opsw.switchDefinition.configByte == -1 {
          commandStation?.swReq(switchNumber: opsw.switchNumber, state: opsw.newState)
        }
      }
    }
    commandStation?.setOptionSwitches()
  }
  
  @IBOutlet weak var tableView: NSTableView!
  
  @IBAction func tableViewAction(_ sender: NSTableView) {
  }
  
}


