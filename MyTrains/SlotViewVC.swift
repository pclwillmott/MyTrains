//
//  SlotViewVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/01/2022.
//

import Foundation
import Cocoa

class SlotViewVC : NSViewController, NSWindowDelegate, SlotObserverDelegate, CommandStationDelegate {
  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
   
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }

  func windowWillClose(_ notification: Notification) {
    if let cs = commandStation {
      if slotObserverId != -1 {
  //      cs.removeSlotObserver(id: slotObserverId)
        slotObserverId = -1
      }
      if commandStationDelegateId != -1 {
        cs.removeDelegate(id: commandStationDelegateId)
        commandStationDelegateId = -1
      }
    }
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
 //   cboCommandStationDS.dictionary = networkController.commandStations
    /*
    cboCommandStation.dataSource = cboCommandStationDS
    
    if cboCommandStation.numberOfItems > 0 {
      cboCommandStation.selectItem(at: 0)
      commandStation = cboCommandStationDS.commandStationAt(index: 0)
    }
    */
  }
  
  // MARK: Private Enums
  
  private enum State {
    case idle
    case readAllP1
    case readAllP2
    case read
    case clearAll
    case clear
  }
  
  // MARK: Private Properties

  private var cboCommandStationDS : ComboBoxDictDS = ComboBoxDictDS()
  
  private var commandStationDelegateId : Int = -1
  
  private var commandStation : CommandStation? {
    willSet {
      stopTimer()
      if slotObserverId != -1 {
   //     commandStation?.removeSlotObserver(id: slotObserverId)
        slotObserverId = -1
      }
      if commandStationDelegateId != -1 {
        commandStation?.removeDelegate(id: commandStationDelegateId)
        commandStationDelegateId = -1
      }
    }
    didSet {
      if let cs = commandStation {
   //     slotObserverId = cs.addSlotObserver(observer:self)
        commandStationDelegateId = cs.addDelegate(delegate: self)
        startTimer(timeInterval: 0.05)
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
//      slotTableView.dataSource = slotTableViewDS
  //    slotTableView.delegate = slotTableViewDS
    //  slotTableView.reloadData()
    }
  }
  
  private var state : State = .idle
  
  private var slotPage : Int = 0
  
  private var slotNumber : Int = 0
  
  // MARK: Private Methods
  
  func startTimer(timeInterval:TimeInterval) {
    timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
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
        if let cs = commandStation {
          /*
          if slot.isP1 {
   //         cs.getLocoSlotDataP1(slotNumber: slot.slotNumber)
          }
          else {
   //         cs.getLocoSlotDataP2(slotPage: slot.slotPage, slotNumber: slot.slotNumber)
          } */
          break
        }
      }
      nextToReview += 1
    }
    
  }
  
  // MARK: CommandStationDelegate Methods
  
  @objc func messageReceived(message:NetworkMessage) {

    if message.messageType == .locoSlotDataP1 || message.messageType == .locoSlotDataP2 {
      /*
      if let cs = commandStation, let bounds = cs.maxSlotNumber {

        switch state {
        case .readAllP2:
          if slotPage == bounds.page && slotNumber == bounds.number {
            state = .readAllP1
            slotNumber = 0
            lblStatus.stringValue = "Reading \(slotNumber)"
    //        cs.getLocoSlotDataP1(slotNumber: slotNumber)
            return
          }
          slotNumber += 1
          if slotNumber == 120 {
            slotNumber = 1
            slotPage += 1
          }
          lblStatus.stringValue = "Reading \(slotPage).\(slotNumber)"
  //        cs.getLocoSlotDataP2(slotPage: slotPage, slotNumber: slotNumber)
        case .readAllP1:
          if slotNumber == 119 {
            state = .idle
            lblStatus.stringValue = "Read Completed"
            return
          }
          slotNumber += 1
          lblStatus.stringValue = "Reading \(slotNumber)"
  //        cs.getLocoSlotDataP1(slotNumber: slotNumber)
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

      } */
    }
  }

  // MARK: SlotObserverDelegate Methods
  
  @objc func slotsUpdated(commandStation: CommandStation) {
//    slots = commandStation.locoSlots
  }

  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboCommandStation: NSComboBox!
  
  @IBAction func cboCommandStationAction(_ sender: NSComboBox) {
//    commandStation = cboCommandStationDS.commandStationAt(index: cboCommandStation.indexOfSelectedItem)
  }
  
  @IBOutlet weak var slotTableView: NSTableView!
  
  @IBAction func slotTableViewAction(_ sender: NSTableView) {
  }
  
  @IBOutlet weak var lblStatus: NSTextField!
  
  @IBOutlet weak var btnReadSlot: NSButton!
  
  @IBAction func btnReadSlotAction(_ sender: NSButton) {
    
    let index = slotTableView.selectedRow
    
    if index != -1 {
      
      if let cs = commandStation {
        
        state = .read

        let slot = slots[index]
        
        lblStatus.stringValue = "Reading \(slot.displaySlotNumber)"
/*
        if slot.isP1 {
          slotNumber = slot.slotNumber
    //      cs.getLocoSlotDataP1(slotNumber: slotNumber)
        }
        else {
          slotPage = slot.slotPage
          slotNumber = slot.slotNumber
    //      cs.getLocoSlotDataP2(slotPage: slotPage, slotNumber: slotNumber)
        } */

      }
    }
    
  }
  
  @IBOutlet weak var btnReadAllSlots: NSButton!
  
  @IBAction func btnReadAllSlotsAction(_ sender: NSButton) {
    /*
    if let cs = commandStation, let _ = cs.maxSlotNumber {
      state = .readAllP2
      slotPage = 0
      slotNumber = 0
      lblStatus.stringValue = "Reading \(slotPage).\(slotNumber)"
 //     cs.getLocoSlotDataP2(slotPage: slotPage, slotNumber: slotNumber)
    } */
    
  }
  
  @IBOutlet weak var btnClearSlot: NSButton!
  
  @IBAction func btnClearSlotAction(_ sender: NSButton) {
    
    let index = slotTableView.selectedRow
    
    if index != -1 {
      
      if let cs = commandStation {
        
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
