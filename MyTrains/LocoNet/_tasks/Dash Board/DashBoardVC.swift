//
//  DashBoardVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 09/04/2022.
//

import Foundation
import Cocoa

class DashBoardVC: MyTrainsViewController, MyTrainsControllerDelegate {
  
  // MARK: Window & View Control

  override func windowWillClose(_ notification: Notification) {
    
    if observerId != -1 {
  /*    if let mess = interface {
        mess.removeObserver(id: observerId)
        observerId = -1
      } */
    }
    if delegateId != -1 {
  //    myTrainsController.removeDelegate(id: delegateId)
      delegateId = -1
    }
    
    super.windowWillClose(notification)
    
  }

  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    bits.append(lbl40)
    bits.append(lbl41)
    bits.append(lbl42)
    bits.append(lbl43)
    bits.append(lbl44)
    bits.append(lbl45)
    bits.append(lbl46)
    bits.append(lbl50)
    bits.append(lbl51)
    bits.append(lbl52)
    bits.append(lbl53)
    bits.append(lbl54)
    bits.append(lbl55)
    bits.append(lbl56)
    
    others.append(lblProduct)
    others.append(lblSerialNumber)
    others.append(lblHardwareVersion)
    others.append(lblSoftwareVersion)
    others.append(lblBoardID)
    others.append(lblTrackVoltage)
    others.append(lblInputVoltage)
    others.append(lblCurrentDrawn)
    others.append(lblCurrentLimit)
    others.append(lblRailSyncVoltage)
    others.append(lblLocoNetVoltage)
    others.append(lblSlotsUsed)
    others.append(lblIdleSlots)
    others.append(lblFreeSlots)
    others.append(lblConsists)
    others.append(lblUplinked)
    others.append(lblTrackFaults)
    others.append(lblAutoReverse)
    others.append(lblDisturbances)
    others.append(lblGoodMessages)
    others.append(lblBadMessages)
    others.append(lblSleeps)

    clearFields()
    
//    delegateId = myTrainsController.addDelegate(delegate: self)
    
//    interfacesUpdated(interfaces: myTrainsController.networkInterfaces)
    
    startQuery()
    
  }
  
  // MARK: Private Properties
  
  private var bits : [NSTextField] = []
  
  private var others : [NSTextField] = []
  
  private var observerId : Int = -1
  
//  private var interface : InterfaceLocoNet?
  
  private var delegateId : Int = -1
  
  private var querySlot1 : [String:LocoNetMessage] = [:]
  private var querySlot2 : [String:LocoNetMessage] = [:]
  private var querySlot3 : [String:LocoNetMessage] = [:]
  private var querySlot4 : [String:LocoNetMessage] = [:]
  private var querySlot5 : [String:LocoNetMessage] = [:]
  private var names      : [String:LocoNetMessage] = [:]
  
  private var nextQuery : Int = 0

  private var timer : Timer?
  
  // MARK: Private Methods
  
  private func clearFields() {
    for lbl in bits {
      lbl.stringValue = "Off"
    }
    setColours()
    for lbl in others {
      lbl.stringValue = ""
    }
  }
  
  private func setColours() {
    for lbl in bits {
      lbl.textColor = lbl.stringValue == "On" ? .orange : .black
    }
  }
  
  func startQuery() {
    cboDevice.removeAllItems()
    querySlot1.removeAll()
    querySlot2.removeAll()
    querySlot3.removeAll()
    querySlot4.removeAll()
    querySlot5.removeAll()
    names.removeAll()
    nextQuery = 0
    query()
  }
  
  private func query() {
    nextQuery += 1
    if nextQuery <= 5 {
  //    interface?.getQuerySlot(querySlot: nextQuery)
      startTimer()
    }
    else {
      cboDeviceAction(cboDevice)
    }
  }
  
  @objc func timerAction() {
    stopTimer()
    query()
  }
  
  func startTimer() {
    stopTimer()
    let timeInterval = 200.0 / 1000.0
    timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
    RunLoop.current.add(timer!, forMode: .common)
  }
  
  func stopTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  // MARK: MyTrainsControllerDelegate Methods
  
  func statusUpdated(myTrainsController: MyTrainsController) {
  }
  
  func myTrainsControllerUpdated(myTrainsController: MyTrainsController) {
  }
  
  /*
  func interfacesUpdated(interfaces: [Interface]) {
    
    if observerId != -1 {
      self.interface?.removeObserver(id: observerId)
      observerId = -1
    }
    
    let interfaceId = UserDefaults.standard.string(forKey: DEFAULT.MONITOR_INTERFACE_ID) ?? ""

    cboInterface.removeAllItems()
    cboInterface.deselectItem(at: cboInterface.indexOfSelectedItem)
    
    for interface in interfaces {
      
      let name = interface.deviceName
      
      cboInterface.addItem(withObjectValue: name)
      
      if interfaceId == name, let x = interface as? InterfaceLocoNet {
        cboInterface.selectItem(at: cboInterface.numberOfItems-1)
        self.interface = x
        observerId = interface.addObserver(observer: self)
      }
      
    }
    
  }
*/
  // MARK: NetworkMessengerDelegate Methods
  
  @objc func networkMessageReceived(message: LocoNetMessage) {
    
    var resetTimer : Bool = true
    
    switch message.messageType {
    case .querySlot1:
      querySlot1[message.comboName] = message
      if let _ = names[message.comboName] {
        break
      }
      names[message.comboName] = message
      cboDevice.addItem(withObjectValue: message.comboName)
    case .querySlot2:
      querySlot2[message.comboName] = message
      if let _ = names[message.comboName] {
        break
      }
      names[message.comboName] = message
      cboDevice.addItem(withObjectValue: message.comboName)
    case .querySlot3:
      querySlot3[message.comboName] = message
      if let _ = names[message.comboName] {
        break
      }
      names[message.comboName] = message
      cboDevice.addItem(withObjectValue: message.comboName)
    case .querySlot4:
      querySlot4[message.comboName] = message
      if let _ = names[message.comboName] {
        break
      }
      names[message.comboName] = message
      cboDevice.addItem(withObjectValue: message.comboName)
    case .querySlot5:
      querySlot5[message.comboName] = message
      if let _ = names[message.comboName] {
        break
      }
      names[message.comboName] = message
      cboDevice.addItem(withObjectValue: message.comboName)
    default:
      resetTimer = false
      break
    }
    
    if resetTimer {
      startTimer()
    }
    
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var lbl46: NSTextField!
  
  @IBOutlet weak var lbl45: NSTextField!
  
  @IBOutlet weak var lbl44: NSTextField!
  
  @IBOutlet weak var lbl43: NSTextField!
  
  @IBOutlet weak var lbl42: NSTextField!
  
  @IBOutlet weak var lbl41: NSTextField!
  
  @IBOutlet weak var lbl40: NSTextField!
  
  @IBOutlet weak var lbl56: NSTextField!
  
  @IBOutlet weak var lbl55: NSTextField!
  
  @IBOutlet weak var lbl54: NSTextField!
  
  @IBOutlet weak var lbl53: NSTextField!
  
  @IBOutlet weak var lbl52: NSTextField!
  
  @IBOutlet weak var lbl51: NSTextField!
  
  @IBOutlet weak var lbl50: NSTextField!
  
  @IBOutlet weak var lblProduct: NSTextField!
  
  @IBOutlet weak var lblSerialNumber: NSTextField!
  
  @IBOutlet weak var lblHardwareVersion: NSTextField!
  
  @IBOutlet weak var lblSoftwareVersion: NSTextField!
  
  @IBOutlet weak var lblBoardID: NSTextField!
  
  @IBOutlet weak var lblTrackVoltage: NSTextField!
  
  @IBOutlet weak var lblInputVoltage: NSTextField!
  
  @IBOutlet weak var lblCurrentDrawn: NSTextField!
  
  @IBOutlet weak var lblCurrentLimit: NSTextField!
  
  @IBOutlet weak var lblRailSyncVoltage: NSTextField!
  
  @IBOutlet weak var lblLocoNetVoltage: NSTextField!
  
  @IBOutlet weak var lblSlotsUsed: NSTextField!
  
  @IBOutlet weak var lblUplinked: NSTextField!
  
  @IBOutlet weak var lblConsists: NSTextField!
  
  @IBOutlet weak var lblFreeSlots: NSTextField!
  
  @IBOutlet weak var lblIdleSlots: NSTextField!
  
  @IBOutlet weak var btnReset: NSButton!
  
  @IBAction func btnResetAction(_ sender: Any) {
//    interface?.resetQuerySlot4(timeoutCode: .resetQuerySlot4)
  }
  
  @IBOutlet weak var lblGoodMessages: NSTextField!
  
  @IBOutlet weak var lblBadMessages: NSTextField!
  
  @IBOutlet weak var lblSleeps: NSTextField!
  
  @IBOutlet weak var lblTrackFaults: NSTextField!
  
  @IBOutlet weak var lblDisturbances: NSTextField!
  
  @IBOutlet weak var lblAutoReverse: NSTextField!
  
  @IBOutlet weak var btnQuery: NSButton!
  
  @IBAction func btnQueryAction(_ sender: Any) {
    startQuery()
  }
  
  @IBOutlet weak var cboInterface: NSComboBox!
 
  @IBAction func cboInterfaceAction(_ sender: NSComboBox) {
    
    let name = cboInterface.stringValue
    
    UserDefaults.standard.set(name, forKey: DEFAULT.MONITOR_INTERFACE_ID)
    /*
    if let x = interface {
      if name != x.deviceName && observerId != -1 {
        x.removeObserver(id: observerId)
      }
    }
    */

  }
  
  @IBOutlet weak var cboDevice: NSComboBox!
  
  @IBAction func cboDeviceAction(_ sender: NSComboBox) {
    
    clearFields()
    
    let name = cboDevice.stringValue
    
    if let query1 = querySlot1[name] {
    
      lbl40.stringValue = query1.bit40! ? "On" : "Off"
      lbl41.stringValue = query1.bit41! ? "On" : "Off"
      lbl42.stringValue = query1.bit42! ? "On" : "Off"
      lbl43.stringValue = query1.bit43! ? "On" : "Off"
      lbl44.stringValue = query1.bit44! ? "On" : "Off"
      lbl45.stringValue = query1.bit45! ? "On" : "Off"
      lbl46.stringValue = query1.bit46! ? "On" : "Off"

      lbl50.stringValue = query1.bit50! ? "On" : "Off"
      lbl51.stringValue = query1.bit51! ? "On" : "Off"
      lbl52.stringValue = query1.bit52! ? "On" : "Off"
      lbl53.stringValue = query1.bit53! ? "On" : "Off"
      lbl54.stringValue = query1.bit54! ? "On" : "Off"
      lbl55.stringValue = query1.bit55! ? "On" : "Off"
      lbl56.stringValue = query1.bit56! ? "On" : "Off"
      
      setColours()
      
      lblProduct.stringValue = query1.productName
      
      lblSerialNumber.stringValue = "\(query1.serialNumber!)"
      
      lblHardwareVersion.stringValue = "\(query1.hardwareVersion!)"
      
      lblSoftwareVersion.stringValue = "\(query1.softwareVersion!)"
      
      lblBoardID.stringValue = "\(query1.boardIDString)"
      
    }
    
    if let query2 = querySlot2[name] {
      
      lblProduct.stringValue = query2.productName
      
      lblSerialNumber.stringValue = "\(query2.serialNumber!)"
      
      lblTrackVoltage.stringValue = "\(query2.trackVoltage!)"
      
      lblInputVoltage.stringValue = "\(query2.inputVoltage!)"
      
      lblCurrentDrawn.stringValue = "\(query2.currentDrawn!)"
      
      lblCurrentLimit.stringValue = "\(query2.currentLimit!)"
      
      lblRailSyncVoltage.stringValue = "\(query2.railSyncVoltage!)"
      
      lblLocoNetVoltage.stringValue = "\(query2.locoNetVoltage!)"
      
      lblBoardID.stringValue = "\(query2.boardIDString)"
      
    }
    
    if let query3 = querySlot3[name] {
      
      lblProduct.stringValue = query3.productName
      
      lblSerialNumber.stringValue = "\(query3.serialNumber!)"
      
      lblSlotsUsed.stringValue = "\(query3.slotsUsed!)"
      
      lblIdleSlots.stringValue = "\(query3.idleSlots!)"
      
      lblFreeSlots.stringValue = "\(query3.freeSlots!)"
      
      lblConsists.stringValue = "\(query3.consists!)"
      
      lblUplinked.stringValue = "\(query3.subMembers!)"
      
      lblBoardID.stringValue = "\(query3.boardIDString)"
      
    }
    
    if let query4 = querySlot4[name] {
      
      lblProduct.stringValue = query4.productName
      
      lblSerialNumber.stringValue = "\(query4.serialNumber!)"
      
      lblGoodMessages.stringValue = "\(query4.goodLocoNetMessages!)"
      
      lblBadMessages.stringValue = "\(query4.badLocoNetMessages!)"
      
      lblSleeps.stringValue = "\(query4.numberOfSleeps!)"
      
      lblBoardID.stringValue = "\(query4.boardIDString)"
      
    }
    
    if let query5 = querySlot5[name] {
      
      lblProduct.stringValue = query5.productName
      
      lblSerialNumber.stringValue = "\(query5.serialNumber!)"
      
      lblTrackFaults.stringValue = "\(query5.trackFaults!)"
      
      lblAutoReverse.stringValue = "\(query5.autoReverseEvents!)"
      
      lblDisturbances.stringValue = "\(query5.disturbances!)"
      
      lblBoardID.stringValue = "\(query5.boardIDString)"
      
    }
    
  }
  
}
