//
//  SlotViewVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/01/2022.
//

import Foundation
import Cocoa

class SlotViewVC : NSViewController, NSWindowDelegate, InterfaceDelegate {
  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
   
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }

  func windowWillClose(_ notification: Notification) {
    if let interface = self.interface {
      if observerId != -1 {
        interface.removeObserver(id: observerId)
        observerId = -1
      }
    }
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    cboCommandStationDS.dictionary = networkController.commandStations
    
    cboCommandStation.dataSource = cboCommandStationDS
    
    if cboCommandStation.numberOfItems > 0 {
      
      let key = UserDefaults.standard.integer(forKey: DEFAULT.SLOT_VIEW_COMMAND_STATION)
      
      if let index = cboCommandStationDS.indexWithKey(key: key), let cs = cboCommandStationDS.editorObjectAt(index: index) as? Interface {
        cboCommandStation.selectItem(at: index)
        commandStation = cs
      }
      else if let cs = cboCommandStationDS.editorObjectAt(index: 0) as? Interface {
        cboCommandStation.selectItem(at: 0)
        commandStation = cs
      }
      
    }
    
  }
  
  // MARK: Private Enums
  
  private enum State {
    case idle
    case readAll
    case read
    case clearAll
    case clear
  }
  
  // MARK: Private Properties

  private var cboCommandStationDS : ComboBoxDictDS = ComboBoxDictDS()
  
  private var observerId : Int = -1
  
  private var interface : Interface?
  
  private var commandStation : Interface? {
    willSet {
      stopTimer()
      if observerId != -1 {
        interface?.removeObserver(id: observerId)
        observerId = -1
      }
      interface = nil
    }
    didSet {
      if let cs = commandStation, let interface = cs.network?.interface {
        self.interface = interface
        observerId = interface.addObserver(observer: self)
        startTimer(timeInterval: 2.0)
      }
    }
  }
  
  private var slotTableViewDS : SlotTableViewDS = SlotTableViewDS()
  
  private var slotObserverId : Int = -1
  
  private var timer : Timer?
  
  private var nextToReview = 0
  
  private var slots : [LocoSlotData] = [] {
    didSet {
      slotTableViewDS.slots = slots
      slotTableView.dataSource = slotTableViewDS
      slotTableView.delegate = slotTableViewDS
      slotTableView.reloadData()
    }
  }
  
  private var state : State = .idle
  
  private var slotPage : Int = 0
  
  private var slotNumber : Int = 0
  
  // MARK: Private Methods
  
  func startTimer(timeInterval:TimeInterval) {
    timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    RunLoop.current.add(timer!, forMode: .common)
  }
  
  func stopTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  @objc func timerAction() {
    
    if nextToReview >= slots.count {
      nextToReview = 0
    }
    
    while nextToReview < slots.count {
      let slot = slots[nextToReview]
      if slot.isDirty {
        slot.isDirty = false
        if let cs = commandStation, let interface = self.interface {
          
          if cs.implementsProtocol2 {
            interface.getLocoSlotDataP2(slotPage: slot.slotPage, slotNumber: slot.slotNumber)
          }
          else {
            interface.getLocoSlotDataP1(slotNumber: slot.slotNumber)
          }
          break
        }
      }
      nextToReview += 1
    }
    
  }
  
  // MARK: InterfaceDelegate Methods
  
  @objc func networkMessageReceived(message:NetworkMessage) {

    if message.messageType == .locoSlotDataP1 || message.messageType == .locoSlotDataP2 {
      
      if let cs = commandStation, let interface = self.interface {

        switch state {
        case .readAll:
          
          slotNumber += 1
          if slotNumber == 120 {
            slotNumber = 1
            slotPage += 1
          }
          
          if !cs.implementsProtocol2 && slotPage > 0 {
            state = .idle
            lblStatus.stringValue = "Read Completed"
            return
          }
          
          lblStatus.stringValue = "Reading \(slotPage).\(slotNumber)"
          if cs.implementsProtocol2 {
            interface.getLocoSlotDataP2(slotPage: slotPage, slotNumber: slotNumber)
          }
          else {
            interface.getLocoSlotDataP1(slotNumber: slotNumber)
          }
          
        case .read:
          state = .idle
          lblStatus.stringValue = "Read Completed"
          return
        case .clearAll:
          break
        case .clear:
          break
        default:
          break
        }

      }
    }
  }

  @objc func slotsUpdated(interface: Interface) {
    slots = interface.locoSlots
  }

  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboCommandStation: NSComboBox!
  
  @IBAction func cboCommandStationAction(_ sender: NSComboBox) {
    if let cs = cboCommandStationDS.editorObjectAt(index: cboCommandStation.indexOfSelectedItem) as? Interface {
      commandStation = cs
      UserDefaults.standard.set(cs.primaryKey, forKey: DEFAULT.SLOT_VIEW_COMMAND_STATION)
    }
  }
  
  @IBOutlet weak var slotTableView: NSTableView!
  
  @IBAction func slotTableViewAction(_ sender: NSTableView) {
  }
  
  @IBOutlet weak var lblStatus: NSTextField!
  
  @IBOutlet weak var btnReadSlot: NSButton!
  
  @IBAction func btnReadSlotAction(_ sender: NSButton) {
    
    let index = slotTableView.selectedRow
    
    if index != -1 {
      
      if let cs = commandStation, let interface = self.interface {
        
        state = .read

        let slot = slots[index]
        
        lblStatus.stringValue = "Reading \(slot.displaySlotNumber)"

        if cs.implementsProtocol2 {
          slotPage = slot.slotPage
          slotNumber = slot.slotNumber
          interface.getLocoSlotDataP2(slotPage: slotPage, slotNumber: slotNumber)
        }
        else {
          slotNumber = slot.slotNumber
          interface.getLocoSlotDataP1(slotNumber: slotNumber)
        }

      }
    }
    
  }
  
  @IBOutlet weak var btnReadAllSlots: NSButton!
  
  @IBAction func btnReadAllSlotsAction(_ sender: NSButton) {
  
    if let cs = commandStation, let interface = self.interface, let _ = cs.maxSlotNumber {
      state = .readAll
      slotPage = 0
      slotNumber = 1
      lblStatus.stringValue = "Reading \(slotPage).\(slotNumber)"
      interface.getLocoSlotDataP2(slotPage: slotPage, slotNumber: slotNumber)
    }
    
  }
  
  @IBOutlet weak var btnClearSlot: NSButton!
  
  @IBAction func btnClearSlotAction(_ sender: NSButton) {
    
    let index = slotTableView.selectedRow
    
    if index != -1 {
      
      if let _ = commandStation {
        
        state = .read

        let slot = slots[index]
        
        lblStatus.stringValue = "Clearing \(slot.displaySlotNumber)"
/*
        if slot.isP1 {
          slotNumber = slot.slotNumber
  //        cs.clearLocoSlotDataP1(slotNumber: slotNumber)
        }
        else {
          slotPage = slot.slotPage
          slotNumber = slot.slotNumber
  //        cs.clearLocoSlotDataP2(slotPage: slotPage, slotNumber: slotNumber)
        } */

      }
      
    }

  }
  
  @IBOutlet weak var btnClearAllSlots: NSButton!
  
  @IBAction func btnClearAllSlotsAction(_ sender: NSButton) {
  }
  
}
