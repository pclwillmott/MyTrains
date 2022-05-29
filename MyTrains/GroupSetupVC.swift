//
//  GroupSetupVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 14/04/2022.
//

import Foundation
import Cocoa

class GroupSetupVC: NSViewController, NetworkControllerDelegate, InterfaceDelegate, NSWindowDelegate {
  
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
    
    if delegateId != -1 {
      networkController.removeDelegate(id: delegateId)
      delegateId = -1
    }
    
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self

    delegateId = networkController.appendDelegate(delegate: self)
    
    interfacesUpdated(interfaces: networkController.networkInterfaces)
    
    btnReadAction(btnRead)

    lblNowScanning.stringValue = ""
        
  }
  
  // MARK: Private Properties
  
  private var delegateId : Int = -1
  
  private var observerId : Int = -1
  
  private var interface : Interface? = nil
  
  private var isFirst : Bool = true
  
  private var scanCount : [Int] = Array(repeating: 0, count: 16)
  private var maxValue  : [Double] = Array(repeating: 0.0, count: 16)
  private var totals    : [Double] = Array(repeating: 0.0, count: 16)
  private var average   : [Double] = Array(repeating: 0.0, count: 16)
  private var current   : [Double] = Array(repeating: 0.0, count: 16)

  private var maxRepeat = 50
  
  private var repeatCount : Int = 0

  private var duplexGroupChannel = 11

  private var timer : Timer?
  
  // MARK: Private Methods
  
  @objc func timerAction() {
    
    scanCount[duplexGroupChannel-11] += 1

    let pass = 1 + maxRepeat - repeatCount
    
    lblNowScanning.stringValue = "Pass: \(pass) - Scanning Channel: \(duplexGroupChannel)"
    
    interface?.getDuplexSignalStrength(duplexGroupChannel: duplexGroupChannel)
    
    duplexGroupChannel += 1
    
    if duplexGroupChannel == 27 {
      repeatCount -= 1
      if repeatCount == 0 {
        stopTimer()
        current = Array(repeating: 0.0, count: 16)
        signalStrengthView.current = current
        lblNowScanning.stringValue = "Scan Completed"
        btnScan.title = "Scan"
      }
      else {
        duplexGroupChannel = 11
      }
    }
  }
  
  func startTimer() {
    stopTimer()
    let timeInterval = 300.0 / 1000.0
    timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
  }
  
  func stopTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  // MARK: NetworkControllerDelegate Methods
  
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
      
      if interfaceId == name {
        cboInterface.selectItem(at: cboInterface.numberOfItems-1)
        self.interface = interface
        observerId = interface.addObserver(observer: self)
      }
      
    }
    
  }

  // MARK: NetworkMessengerDelegate Methods
  
  @objc func networkMessageReceived(message: NetworkMessage) {
  
    switch message.messageType {
    case .duplexGroupData:
      if isFirst {
        let duplexData = DuplexData(message: message)
        txtGroupName.stringValue = duplexData.groupName
        txtGroupPassword.stringValue = duplexData.groupPassword
        txtChannelNumber.integerValue = duplexData.channelNumber
        txtGroupID.integerValue = duplexData.groupID
        isFirst = false
      }
    case .receiverRep:
      txtLocoNetID.stringValue = "\(message.message[3] & 0x7)"
    case .duplexSignalStrength:
      let cn = Int(message.message[5] | (((message.message[4] & 0b00000001) == 0b00000001) ? 0b10000000 : 0)) - 11
      let ss = Double(message.message[6] | (((message.message[4] & 0b00000010) == 0b00000010) ? 0b10000000 : 0))
      current[cn] = ss
      if maxValue[cn] < ss {
        maxValue[cn] = ss
      }
      totals[cn] += ss
      for index in 0...15 {
        if scanCount[index] == 0 {
          average[index] = 0.0
        }
        else {
          average[index] = totals[index] / Double(scanCount[index])
        }
      }
      signalStrengthView.max = maxValue
      signalStrengthView.current = current
      signalStrengthView.average = average
    case .getDuplexSignalStrength:
//      let cn = Int(message.message[5] | (((message.message[4] & 0b00000001) == 0b00000001) ? 0b10000000 : 0))
//      messenger?.setDuplexSignalStrength(duplexGroupChannel: cn, signalStrength: 97)
      break
    default:
      break
    }
  }

  // MARK: Outlets & Actions

  @IBOutlet var cboInterface: NSComboBox!
  
  @IBAction func cboInterfaceAction(_ sender: NSComboBox) {
    
    let name = cboInterface.stringValue
    
    UserDefaults.standard.set(name, forKey: DEFAULT.MONITOR_INTERFACE_ID)
    
    if let x = interface {
      if name != x.deviceName && observerId != -1 {
        x.removeObserver(id: observerId)
      }
    }
    
    for x in networkController.networkInterfaces {
      if x.deviceName == name {
        interface = x
        observerId = interface?.addObserver(observer: self) ?? -1
        btnReadAction(btnRead)
      }
    }

 }
  
  @IBOutlet var txtGroupName: NSTextField!
  
  @IBAction func txtGroupNameAction(_ sender: NSTextField) {
  }
  
  @IBOutlet var txtGroupPassword: NSTextField!
  
  @IBAction func txtGroupPasswordAction(_ sender: NSTextField) {
  }
  
  @IBOutlet var txtGroupID: NSTextField!
  
  @IBAction func txtGroupIDAction(_ sender: NSTextField) {
  }
  
  @IBOutlet var txtChannelNumber: NSTextField!
  
  @IBAction func txtChannelNumberAction(_ sender: NSTextField) {
  }
  
  @IBOutlet var btnRead: NSButton!
  
  @IBAction func btnReadAction(_ sender: NSButton) {
    isFirst = true
    interface?.findReceiver()
    interface?.getDuplexData()
  }
  
  @IBOutlet var btnWrite: NSButton!
  
  @IBAction func btnWriteAction(_ sender: NSButton) {
    
    interface?.setDuplexChannelNumber(channelNumber: txtChannelNumber.integerValue)
    interface?.setDuplexGroupID(groupID: txtGroupID.integerValue)
    interface?.setDuplexGroupName(groupName: txtGroupName.stringValue)
    interface?.setDuplexPassword(password: txtGroupPassword.stringValue)
    interface?.setLocoNetID(locoNetID: txtLocoNetID.integerValue)
    
  }
  
  @IBOutlet var btnScan: NSButton!
  
  @IBAction func btnScanAction(_ sender: NSButton) {
    
    if sender.title == "Scan" {
      
      repeatCount = maxRepeat
      
      duplexGroupChannel = 11
      
      btnScan.title = "Stop"
      
      scanCount  = Array(repeating: 0, count: 16)
      maxValue   = Array(repeating: 0.0, count: 16)
      totals     = Array(repeating: 0.0, count: 16)
      average    = Array(repeating: 0.0, count: 16)
      current    = Array(repeating: 0.0, count: 16)

      signalStrengthView.max = maxValue
      signalStrengthView.average = average
      signalStrengthView.current = current

      startTimer()

    }
    else {
      
      stopTimer()
      
      btnScan.title = "Scan"
      
      lblNowScanning.stringValue = ""
      
      scanCount  = Array(repeating: 0, count: 16)
      maxValue   = Array(repeating: 0.0, count: 16)
      totals     = Array(repeating: 0.0, count: 16)
      average    = Array(repeating: 0.0, count: 16)
      current    = Array(repeating: 0.0, count: 16)

      signalStrengthView.max = maxValue
      signalStrengthView.average = average
      signalStrengthView.current = current
      
    }
    
    maxValue  = Array(repeating: 0.0, count: 17)
        
  }
  
  @IBOutlet weak var signalStrengthView: SignalStrengthView!
  
  @IBOutlet weak var lblNowScanning: NSTextField!
  
  @IBOutlet weak var txtLocoNetID: NSTextField!
  
}

