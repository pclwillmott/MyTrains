//
//  LocomotiveRosterVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 02/10/2022.
//

import Foundation
import Cocoa

public typealias AliasEntry = (index:Int, extendedAddress:Int, primaryAddress:Int)

class LocomotiveRosterVC: NSViewController, InterfaceDelegate, NSWindowDelegate {
  
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
    
    cboCommandStationDS.dictionary = myTrainsController.commandStations
    
    cboCommandStation.dataSource = cboCommandStationDS
    
    if cboCommandStation.numberOfItems > 0 {
      
      let key = UserDefaults.standard.integer(forKey: DEFAULT.LOCOMOTIVE_ROSTER_COMMAND_STATION)
      
      if let index = cboCommandStationDS.indexWithKey(key: key), let cs = cboCommandStationDS.editorObjectAt(index: index) as? Interface {
        cboCommandStation.selectItem(at: index)
        commandStation = cs
      }
      else if let cs = cboCommandStationDS.editorObjectAt(index: 0) as? Interface {
        cboCommandStation.selectItem(at: 0)
        commandStation = cs
      }
      
      tableViewDS.locomotiveRoster = locomotiveRoster
      tableView.dataSource = tableViewDS
      tableView.delegate = tableViewDS
      
    }
    
  }

  // MARK: Private Properties
  
  private var cboCommandStationDS : ComboBoxDictDS = ComboBoxDictDS()
  
  private var tableViewDS = LocomotiveRosterTableViewDS()
  
  private var observerId : Int = -1
  
  private var interface : InterfaceLocoNet?
  
  private enum Mode {
    case idle
    case waitingForRosterEntry
  }
  
  private var mode : Mode = .idle
  
  private var nextRecordNumber : Int = 0
  
  private var locomotiveRoster : [AliasEntry] = []
  
  private var commandStation : Interface? {
    willSet {
      if observerId != -1 {
        interface?.removeObserver(id: observerId)
        observerId = -1
      }
      interface = nil
    }
    didSet {
      if let cs = commandStation, let interface = cs.network?.interface as? InterfaceLocoNet {
        self.interface = interface
        observerId = interface.addObserver(observer: self)
      }
    }
  }
  
  // MARK: Private Methods
  
  private func updateRoster(entryNumber: Int) {
    
    let recordNumber = entryNumber >> 1
    
    let ext1 = locomotiveRoster[recordNumber * 2 + 0].extendedAddress
    let pri1 = locomotiveRoster[recordNumber * 2 + 0].primaryAddress
    let ext2 = locomotiveRoster[recordNumber * 2 + 1].extendedAddress
    let pri2 = locomotiveRoster[recordNumber * 2 + 1].primaryAddress

    interface?.setRosterEntry(entryNumber: entryNumber, extendedAddress1: ext1, primaryAddress1: pri1, extendedAddress2: ext2, primaryAddress2: pri2)
    
  }
  
  // MARK: InterfaceDelegate Methods
  
  @objc func networkMessageReceived(message: LocoNetMessage) {
    
    switch message.messageType {
    case .rosterEntry:
      
      guard mode == .waitingForRosterEntry else {
        return
      }
      
      var extendedAddress = Int(message.message[7]) | (Int(message.message[8]) << 7)
      var primaryAddress = Int(message.message[9])
      let index = Int(message.message[4])
      
      let newEntry1 : AliasEntry = (index: index * 2 + 0, extendedAddress:extendedAddress, primaryAddress: primaryAddress)
      
      locomotiveRoster.append(newEntry1)
      
      extendedAddress = Int(message.message[11]) | (Int(message.message[12]) << 7)
      primaryAddress = Int(message.message[13])
      
      let newEntry2 : AliasEntry = (index: index * 2 + 1, extendedAddress:extendedAddress, primaryAddress: primaryAddress)
      
      locomotiveRoster.append(newEntry2)
      
      tableViewDS.locomotiveRoster = locomotiveRoster
      tableView.reloadData()

      if nextRecordNumber < 0x1f {
        nextRecordNumber += 1
        interface?.getRosterEntry(recordNumber: nextRecordNumber)
      }
      else {
        mode = .idle
        return
      }
      
      
      break
    default:
      break
    }
    
  }

  // MARK: Outlets & Actions
  
  
  @IBOutlet weak var cboCommandStation: NSComboBox!
  
  @IBAction func cboCommandStationAction(_ sender: NSComboBox) {
    if let cs = cboCommandStationDS.editorObjectAt(index: cboCommandStation.indexOfSelectedItem) as? Interface {
      commandStation = cs
      UserDefaults.standard.set(cs.primaryKey, forKey: DEFAULT.LOCOMOTIVE_ROSTER_COMMAND_STATION)
    }
  }
  
  @IBOutlet weak var btnReset: NSButton!
  
  @IBAction func btnResetAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var btnRead: NSButton!
  
  @IBAction func btnReadAction(_ sender: NSButton) {
    
    locomotiveRoster.removeAll()
    
    nextRecordNumber = 0
    
    mode = .waitingForRosterEntry
    
    interface?.getRosterEntry(recordNumber: nextRecordNumber)

  }
  
  @IBOutlet weak var btnWrite: NSButton!
  
  @IBAction func btnWriteAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var tableView: NSTableView!
  
  @IBAction func tableViewAction(_ sender: NSTableView) {
  }
  
  @IBAction func txtExtendedAddressAction(_ sender: NSTextField) {
    locomotiveRoster[sender.tag].extendedAddress = sender.integerValue
    updateRoster(entryNumber: sender.tag)
  }
  
  @IBAction func txtPrimaryAddressAction(_ sender: NSTextField) {
    locomotiveRoster[sender.tag].primaryAddress = sender.integerValue
    updateRoster(entryNumber: sender.tag)
  }
  
  
  
  
  
  
  
  
  
}

