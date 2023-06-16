//
//  PurgeProfilerVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 24/09/2022.
//

import Foundation
import Cocoa

class PurgeProfilerVC : NSViewController, NSWindowDelegate, InterfaceDelegate {
  
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
      
      let key = UserDefaults.standard.integer(forKey: DEFAULT.PURGE_PROFILER_COMMAND_STATION)
      
      if let index = cboCommandStationDS.indexWithKey(key: key), let cs = cboCommandStationDS.editorObjectAt(index: index) as? Interface {
        cboCommandStation.selectItem(at: index)
        commandStation = cs
      }
      else if let cs = cboCommandStationDS.editorObjectAt(index: 0) as? Interface {
        cboCommandStation.selectItem(at: 0)
        commandStation = cs
      }
      
    }
    
    cboNumberOfTests.selectItem(at: 0)
    
    barProgress.isHidden = true
    btnCopy.isEnabled = false
    
  }
  
  // MARK: Private Properties
  
  private enum ProfilerState {
    case notInit
    case idle
    case waitingForSlot
    case waitingForPurge
  }
  
  private var observerId : Int = -1

  private var cboCommandStationDS : ComboBoxDictDS = ComboBoxDictDS()
  
  private var interface : InterfaceLocoNet?
  
  private var locoSlot : Int = -1
  
  private var locoSlotPage : Int = -1
  
  private var locoAddress : Int = 1
  
  private var isP1 : Bool = false
  
  private var profilerState : ProfilerState = .notInit
  
  private var startTime : TimeInterval = 0.0
  
  private var numberOfTests : Double {
    get {
      return Double(cboNumberOfTests.integerValue)
    }
  }
  
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
        safeIsStandardPurgeTime = interface.isStandardLocoAddressPurgeTime
        safeDoBeepsOnPurge = interface.doBeepsOnPurge
        safeIsSetToZeroSpeedOnPurge = interface.isSetToZeroSpeedOnPurge
        safeIsPurgeEnabled = interface.isPurgeEnabled
        chkLongPurgeTime.state = interface.isStandardLocoAddressPurgeTime ? .off : .on
        chkBeepsWhenPurged.state = interface.doBeepsOnPurge ? .on : .off
        chkSetSpeedToZero.state = interface.isSetToZeroSpeedOnPurge ? .on : .off
        chkPurgeEnabled.state = interface.isPurgeEnabled ? .on : .off
        profilerState = .idle
      }
    }
  }
  
  private var safeIsStandardPurgeTime     : Bool = false
  private var safeDoBeepsOnPurge          : Bool = false
  private var safeIsSetToZeroSpeedOnPurge : Bool = false
  private var safeIsPurgeEnabled          : Bool = false
  
  private var timer : Timer?
  
  // MARK: Private Methods
  
  private func restoreInitialState() {
    
    barProgress.isHidden = true
    
    btnStartTests.title = "Start Tests"
    
    guard profilerState != .notInit else {
      return
    }
    
    guard profilerState != .idle else {
      return
    }
    
//    if let interface = self.interface {
      /*
      interface.isStandardLocoAddressPurgeTime = safeIsStandardPurgeTime
      interface.doBeepsOnPurge = safeDoBeepsOnPurge
      interface.isSetToZeroSpeedOnPurge = safeIsSetToZeroSpeedOnPurge
      interface.isPurgeEnabled = safeIsPurgeEnabled
      interface.setLocoSlotDataP1(slotData: interface.newOpSwDataAP1)
      interface.save()
*/
//    }
    
    profilerState = .idle
    
  }
  
  func startTimer() {
    timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    RunLoop.current.add(timer!, forMode: .common)
  }
  
  func stopTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  @objc func timerAction() {
     
    if let interface = self.interface {
      
      if isP1 {
        interface.getLocoSlotDataP1(slotNumber: locoSlot)
      }
      else {
        interface.getLocoSlotDataP2(slotPage: locoSlotPage, slotNumber: locoSlot)
      }
      
    }
    
  }

  
  // MARK: InterfaceDelegate Methods

  @objc func networkMessageReceived(message:NetworkMessage) {
    
    if let interface = self.interface {
      
      switch message.messageType {
      case .locoSlotDataP1:
        
        if profilerState == .waitingForSlot {
          isP1 = true
          locoSlot = Int(message.message[2])
          locoSlotPage = -1
          interface.moveSlotsP1(sourceSlotNumber: locoSlot, destinationSlotNumber: locoSlot, timeoutCode: .none)
          startTime = Date.timeIntervalSinceReferenceDate
          profilerState = .waitingForPurge
          interface.locoSpdP1(slotNumber: locoSlot, speed: 40)
          startTimer()
        }
        else if profilerState == .waitingForPurge {
          
          let bits = Int(message.message[3] & 0b00110000)
          
          if timer != nil && locoAddress == Int(message.message[4]) && (bits == 0b00100000 || bits == 0b00010000 ) {

            stopTimer()

    //        let time = message.timeStamp - startTime
            
   //         print(time)
            
            barProgress.doubleValue += 1.0
            
            if barProgress.doubleValue == numberOfTests {
              restoreInitialState()
            }
            else {
              locoSlot = -1
              locoSlotPage = -1
              profilerState = .waitingForSlot
              locoAddress += 1
              interface.getLocoSlot(forAddress: locoAddress)
            }
            
          }
          
        }
        
      case .locoSlotDataP2:
        
        if profilerState == .waitingForSlot {
          isP1 = false
          locoSlot = Int(message.message[3])
          locoSlotPage = Int(message.message[2])
          interface.moveSlotsP2(sourceSlotNumber: locoSlot, sourceSlotPage: locoSlotPage, destinationSlotNumber: locoSlot, destinationSlotPage: locoSlotPage, timeoutCode: .none)
          startTime = Date.timeIntervalSinceReferenceDate
          profilerState = .waitingForPurge
          interface.locoSpdDirP2(slotNumber: locoSlot, slotPage: locoSlotPage, speed: 40, direction: .forward, throttleID: 0)
          startTimer()
        }
        else if profilerState == .waitingForPurge {
          
          let bits = Int(message.message[4] & 0b00110000)
          
          if timer != nil && locoAddress == Int(message.message[5]) && (bits == 0b00100000 || bits == 0b00010000) {
            
            stopTimer()
            
      //      let time = message.timeStamp - startTime
            
      //      print(time)
            
            barProgress.doubleValue += 1.0
            
            if barProgress.doubleValue == numberOfTests {
              restoreInitialState()
            }
            else {
              locoSlot = -1
              locoSlotPage = -1
              profilerState = .waitingForSlot
              locoAddress += 1
              interface.getLocoSlot(forAddress: locoAddress)
            }
            
          }
          
        }

      default:
        break
      }
      
    }
    
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboCommandStation: NSComboBox!
  
  @IBAction func cboCommandStationAction(_ sender: NSComboBox) {
    if let cs = cboCommandStationDS.editorObjectAt(index: cboCommandStation.indexOfSelectedItem) as? Interface {
      commandStation = cs
      UserDefaults.standard.set(cs.primaryKey, forKey: DEFAULT.PURGE_PROFILER_COMMAND_STATION)
    }
  }
  
  @IBOutlet weak var chkLongPurgeTime: NSButton!
  
  
  @IBAction func chkLongPurgeTimeAction(_ sender: NSButton) {
    if let interface = self.interface {
      interface.isStandardLocoAddressPurgeTime = sender.state == .off
    }
  }
  
  @IBOutlet weak var chkBeepsWhenPurged: NSButton!
  
  @IBAction func chkBeepsWhenPurgedAction(_ sender: NSButton) {
    if let interface = self.interface {
      interface.doBeepsOnPurge = sender.state == .on
    }
  }
  
  @IBOutlet weak var chkSetSpeedToZero: NSButton!
  
  @IBAction func chkSetSpeedToZeroAction(_ sender: NSButton) {
    if let interface = self.interface {
      interface.isSetToZeroSpeedOnPurge = sender.state == .on
    }
  }
  
  @IBOutlet weak var cboNumberOfTests: NSComboBox!
  
  
  @IBAction func cboNumberOfTestsAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var btnStartTests: NSButton!
  
  @IBAction func btnStartTestsAction(_ sender: NSButton) {
    if profilerState == .idle {
      if let interface = self.interface {
        profilerState = .waitingForSlot
  //      interface.setLocoSlotDataP1(slotData: interface.newOpSwDataAP1)
        locoAddress = 1
        interface.getLocoSlot(forAddress: locoAddress)
        btnStartTests.title = "Stop Tests"
        barProgress.minValue = 0.0
        barProgress.maxValue = Double(numberOfTests)
        barProgress.doubleValue = 0.0
        barProgress.isHidden = false
      }
    }
    else {
      stopTimer()
      restoreInitialState()
    }
  }
  
  @IBOutlet weak var tableView: NSTableView!
  
  @IBAction func tableViewAction(_ sender: NSTableView) {
  }
  
  @IBOutlet weak var barProgress: NSProgressIndicator!
  
  @IBOutlet weak var btnCopy: NSButton!
  
  @IBAction func btnCopyAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var chkPurgeEnabled: NSButton!
  
  @IBAction func chkPurgeEnabledAction(_ sender: NSButton) {
    if let interface = self.interface {
      interface.isPurgeEnabled = sender.state == .on
    }
  }
  
}

