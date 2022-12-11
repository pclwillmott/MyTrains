//
//  FastClockTesterVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 10/12/2022.
//

import Foundation
import Cocoa

private enum Mode {
  case idle
  case setFastClockTest
  case setAndRunTest
}

class FastClockTesterVC: NSViewController, NSWindowDelegate, InterfaceDelegate {
  
  // MARK: Window & View Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }

  func windowWillClose(_ notification: Notification) {
    stoptimer()
    interface?.removeObserver(id: observerId)
    observerId = -1
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    cboNetwork.dataSource = cboNetworkDS
    
    txtSetDate.dateValue = networkController.fastClock.scaleDate
    
    clkSetTime.date = txtSetDate.dateValue
    clkReadTime.date = txtSetDate.dateValue
    clkDifference.date = txtSetDate.dateValue
 

  }
  
  // MARK: Private Properties
  
  private var cboNetworkDS = ComboBoxDBDS(tableName: TABLE.NETWORK, codeColumn: NETWORK.NETWORK_ID, displayColumn: NETWORK.NETWORK_NAME, sortColumn: NETWORK.NETWORK_NAME)

  private var mode : Mode = .idle
  
  private var networkId : Int = -1
  
  private var interface : Interface?
  
  private var observerId : Int = -1
  
  private var timer : Timer?
  
  // MARK: Private Methods
  
  @objc func timerAction() {
    
    interface?.getFastClock()
        
  }
  
  func startTimer() {
    
    stoptimer()
    
    let interval : TimeInterval = 1.0 / 16.0
    
    timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    
    RunLoop.current.add(timer!, forMode: .common)
    
  }
  
  func stoptimer() {
    timer?.invalidate()
    timer = nil
  }

  // MARK: InterfaceDelegate Methods
  
  @objc func networkMessageReceived(message:NetworkMessage) {
    
    switch message.messageType {
    case .fastClockData:
      break
    default:
      break
    }
    
  }

  // MARK: Outlets & Actions
  
  @IBOutlet weak var txtSetDate: NSDatePicker!
  
  @IBAction func txtSetDateAction(_ sender: NSDatePicker) {
  }
  
  @IBOutlet weak var btnSetFastClockTest: NSButton!
  
  @IBAction func btnFastClockTestAction(_ sender: NSButton) {
    
    networkId = cboNetworkDS.codeForItemAt(index: cboNetwork.indexOfSelectedItem) ?? -1
    
    if let network = networkController.networks[networkId], let interface = network.interface {
      networkController.fastClock.isEnabled = false
      mode = .setFastClockTest
      self.interface = interface
      observerId = interface.addObserver(observer: self)
      startTimer()
      print("here")
    }

  }
  
  @IBOutlet weak var btnSetAndRunTest: NSButton!
  
  @IBAction func btnSetAndRunTestAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var btnStopTest: NSButton!
  
  @IBAction func btnStopTestAction(_ sender: NSButton) {
    
    stoptimer()
    
    mode = .idle
    
    if let interface = self.interface {
      interface.removeObserver(id: observerId)
      observerId = -1
    }
    
    networkId = -1
    
    networkController.fastClock.isEnabled = true
    
  }
  
  @IBOutlet weak var clkSetTime: ClockView!
  
  @IBOutlet weak var clkReadTime: ClockView!
  
  @IBOutlet weak var clkDifference: ClockView!
  
  @IBOutlet weak var cboScaleFactor: NSComboBox!
  
  @IBAction func cboScaleFactorAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var cboNetwork: NSComboBox!
  
  
  @IBAction func cboNetworkAction(_ sender: NSComboBox) {
  }
  
}
