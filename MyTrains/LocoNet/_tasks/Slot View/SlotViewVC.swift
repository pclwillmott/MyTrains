//
//  SlotViewVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/01/2022.
//

import Foundation
import AppKit
import SGInteger

class SlotViewVC : MyTrainsViewController, OpenLCBLocoNetMonitorDelegate {
  
  // MARK: Window & View Control
  
  override func windowWillClose(_ notification: Notification) {
    
    guard let monitorNode else {
      return
    }
    
//    appDelegate.networkLayer?.releaseLocoNetMonitor(monitor: monitorNode)
    
    super.windowWillClose(notification)
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewType = .locoNetSlotView
  }

  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    self.view.window?.title = "LocoNet Slot Monitor"
    
    if let monitorNode {
      self.view.window?.title = "\(self.view.window!.title) (\(monitorNode.nodeId.dotHex(numberOfBytes: 6)))"
    }
    
    monitorNode?.delegate = self

    slotTableViewDS.slots = slots
    slotTableView.dataSource = slotTableViewDS
    slotTableView.delegate = slotTableViewDS

  }
  
  // MARK: Private Properties

  private var slotTableViewDS : SlotTableViewDS = SlotTableViewDS()
  
  private var timer : Timer?
  
  private var gatewayDS = ComboBoxSimpleDS()
  
  private var bankNumber : UInt8 = 0
  
  private var slotNumber : UInt8 = 1
  
  private var slots : [LocoSlotData] = []
  
  private var currentIndex : Int?
  
  private enum State {
    case idle
    case readAll
    case clearAll
  }
  
  private var state : State = .idle {
    didSet {
      switch state {
      case .idle:
        lblStatus.stringValue = ""
      default:
        break
      }
    }
  }
  
  // MARK: Public Properties
  
  public var monitorNode : OpenLCBLocoNetMonitorNode?

  // MARK: Private Methods
  
  private func insertSlot(slot:LocoSlotData) {
    var index = 0
    while index < slots.count {
      if slots[index].slotID == slot.slotID {
        slots.remove(at: index)
        break
      }
      index += 1
    }
    slots.append(slot)
    slots.sort {$0.slotID < $1.slotID}
    slotTableViewDS.slots = slots
    slotTableView.reloadData()
  }
  
  func startTimer(timeInterval:TimeInterval) {
    timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
    RunLoop.current.add(timer!, forMode: .common)
  }
  
  func stopTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  @objc func timerAction() {
    switch state {
    case .readAll:
      state = .idle
    case .clearAll:
      break
    default:
      break
    }
  }

  // MARK: OpenLCBLocoNetMonitorDelegate Methods
  
  @objc public func locoNetGatewaysUpdated(monitorNode:OpenLCBLocoNetMonitorNode, gateways:[UInt64:String]) {
    
    gatewayDS.dictionary = gateways
    cboInterface.dataSource = gatewayDS
    cboInterface.reloadData()
    
    let gatewayId = UInt64(UserDefaults.standard.integer(forKey: DEFAULT.MONITOR_INTERFACE_ID))
    
    if let index = gatewayDS.indexWithKey(key: gatewayId) {
      cboInterface.selectItem(at: index)
      monitorNode.gatewayId = gatewayId
    }

  }

  @objc public func locoNetMessageReceived(message:LocoNetMessage) {
    
    switch message.messageType {
    case .locoSlotDataP1, .locoSlotDataP2:
      
      stopTimer()
      
      if let slot = LocoSlotData(message: message) {
        insertSlot(slot: slot)
      }
      
      if state == .readAll, let locoNet = monitorNode?.locoNetGateway {
        
        slotNumber += 1
        if slotNumber == 120 {
          slotNumber = 1
          bankNumber += 1
        }
        
        startTimer(timeInterval: 1.0)
        
        if locoNet.commandStationType.implementsProtocol2 {
          locoNet.getLocoSlotDataP2(bankNumber: bankNumber, slotNumber: slotNumber)
        }
        else {
          locoNet.getLocoSlotDataP1(slotNumber: slotNumber)
        }
        
      }
      
      if let currentIndex {
        slotTableView.selectRowIndexes([currentIndex], byExtendingSelection: false)
        self.currentIndex = nil
      }
    
      
    default:
      
      if state == .idle && message.isSlotUpdate, let number = message.slotNumber, let locoNet = monitorNode?.locoNetGateway {
        
        let bank : UInt8 = message.slotBank ?? 0x00
        
        if locoNet.commandStationType.implementsProtocol2 {
          locoNet.getLocoSlotDataP2(bankNumber: bank, slotNumber: number)
        }
        else {
          locoNet.getLocoSlotDataP1(slotNumber: number)
        }

      }
      
    }
    
  }

  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboCommandStation: NSComboBox!
  
  @IBAction func cboCommandStationAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var slotTableView: NSTableView!
  
  @IBAction func slotTableViewAction(_ sender: NSTableView) {
  }
  
  @IBOutlet weak var lblStatus: NSTextField!
  
  @IBOutlet weak var btnReadSlot: NSButton!
  
  @IBAction func btnReadSlotAction(_ sender: NSButton) {
    
    guard state == .idle else {
      return
    }
    
    let index = slotTableView.selectedRow
    
    if index != -1, let locoNet = monitorNode?.locoNetGateway {
      currentIndex = index
      let slot = slots[index]
      if locoNet.commandStationType.implementsProtocol2 {
        locoNet.getLocoSlotDataP2(bankNumber: slot.slotBank, slotNumber: slot.slotNumber)
      }
      else {
        locoNet.getLocoSlotDataP1(slotNumber: slot.slotNumber)
      }

    }
    
  }
  
  @IBOutlet weak var btnReadAllSlots: NSButton!
  
  @IBAction func btnReadAllSlotsAction(_ sender: NSButton) {
    if let locoNet = monitorNode?.locoNetGateway {
      bankNumber = 0
      slotNumber = 1
      state = .readAll
      startTimer(timeInterval: 1.0)
      if locoNet.commandStationType.implementsProtocol2 {
        locoNet.getLocoSlotDataP2(bankNumber: bankNumber, slotNumber: slotNumber)
      }
      else {
        locoNet.getLocoSlotDataP1(slotNumber: slotNumber)
      }
    }
  }
  
  @IBOutlet weak var btnClearSlot: NSButton!
  
  @IBAction func btnClearSlotAction(_ sender: NSButton) {
    
    let index = slotTableView.selectedRow
    
    if index != -1, let locoNet = monitorNode?.locoNetGateway {
      currentIndex = index
      let slot = slots[index]
      let stat1 = (slot.slotStatus1 & 0b11001111) | 0b00010000
      if locoNet.commandStationType.implementsProtocol2 {
        locoNet.locoSpdDirP2(slotNumber: slot.slotNumber, slotPage: slot.slotBank, speed: 0, direction: slot.direction, throttleID: slot.throttleID)
        locoNet.setLocoSlotStat1P2(slotPage: slot.slotBank, slotNumber: slot.slotNumber, stat1: stat1)
        locoNet.getLocoSlotDataP2(bankNumber: slot.slotBank, slotNumber: slot.slotNumber)
      }
      else {
        locoNet.locoSpdP1(slotNumber: slot.slotNumber, speed: 0)
        locoNet.setLocoSlotStat1P1(slotNumber: slot.slotNumber, stat1: stat1)
        locoNet.getLocoSlotDataP1(slotNumber: slot.slotNumber)
      }

    }

  }
  
  @IBOutlet weak var btnClearAllSlots: NSButton!
  
  @IBAction func btnClearAllSlotsAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var cboInterface: NSComboBox!
  
  @IBAction func cboInterfaceAction(_ sender: NSComboBox) {
    
    let id = gatewayDS.keyForItemAt(index: cboInterface.indexOfSelectedItem)
    
    UserDefaults.standard.set(id, forKey: DEFAULT.MONITOR_INTERFACE_ID)

    if let id, let monitorNode {
      monitorNode.gatewayId = id
    }

  }
  
}
