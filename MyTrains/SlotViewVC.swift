//
//  SlotViewVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/01/2022.
//

import Foundation
import Cocoa

class SlotViewVC : NSViewController, NSWindowDelegate, SlotObserverDelegate {
  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
   
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }

  func windowWillClose(_ notification: Notification) {
    if slotObserverId != -1 {
      if let cs = commandStation {
        cs.removeSlotObserver(id: slotObserverId)
        slotObserverId = -1
      }
    }
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    cboCommandStationDS.dictionary = networkController.commandStations
    
    cboCommandStation.dataSource = cboCommandStationDS
    
    if cboCommandStation.numberOfItems > 0 {
      cboCommandStation.selectItem(at: 0)
      commandStation = cboCommandStationDS.commandStationAt(index: 0)
    }
    
  }
  
  // MARK: Private Properties

  private var cboCommandStationDS : CommmandStationComboBoxDS = CommmandStationComboBoxDS()
  
  private var commandStation : CommandStation? {
    willSet {
      if slotObserverId != -1 {
        commandStation?.removeSlotObserver(id: slotObserverId)
        slotObserverId = -1
      }
    }
    didSet {
      if let cs = commandStation {
        slotObserverId = cs.addSlotObserver(observer:self)
        locoAddress = 128
        cs.getLocoSlot(forAddress: locoAddress)
        locoAddress += 1
      }
    }
  }
  
  private var slotTableViewDS : SlotTableViewDS = SlotTableViewDS()
  
  private var slotObserverId : Int = -1
  
  private var timer : Timer?
  
  private var slots : [LocoSlotData] = [] {
    didSet {
      slotTableViewDS.slots = slots
      slotTableView.dataSource = slotTableViewDS
      slotTableView.delegate = slotTableViewDS
      slotTableView.reloadData()
    }
  }
  
  private var locoAddress = 128
  
  // MARK: Private Methods
  
  func startTimer(timeInterval:TimeInterval) {
    timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
  }
  
  func stopTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  @objc func timerAction() {
  }
  
  // MARK: SlotObserverDelegate Methods
  
  func slotsUpdated(locoSlots: [LocoSlotData]) {
    slots = locoSlots
  }

  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboCommandStation: NSComboBox!
  
  @IBAction func cboCommandStationAction(_ sender: NSComboBox) {
    commandStation = cboCommandStationDS.commandStationAt(index: cboCommandStation.indexOfSelectedItem)
  }
  
  @IBOutlet weak var slotTableView: NSTableView!
  
  @IBAction func slotTableViewAction(_ sender: NSTableView) {
  }
  
}
