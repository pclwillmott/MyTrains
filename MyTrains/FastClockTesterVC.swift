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
  case findTickRate
  case setClock
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

    cboNetwork.selectItem(at: cboNetworkDS.indexOfItemWithCodeValue(code: UserDefaults.standard.integer(forKey: DEFAULT.FC_TESTER_NETWORK_ID)) ?? -1)
    
    changeNetwork()
    
    txtSetDate.dateValue = myTrainsController.fastClock.scaleDate
    
    FastClockScaleFactor.populate(comboBox: cboScaleFactor)
    
    FastClockScaleFactor.select(comboBox: cboScaleFactor, value: FastClockScaleFactor(rawValue: UserDefaults.standard.integer(forKey: DEFAULT.FC_TESTER_SCALE_FACTOR)) ?? .defaultValue)
      
    changeScaleFactor()
    
    SampleRate.populate(comboBox: cboSampleRate)
    
    SampleRate.select(comboBox: cboSampleRate, value: SampleRate(rawValue: UserDefaults.standard.integer(forKey: DEFAULT.FC_TESTER_SAMPLE_RATE)) ?? .defaultValue)
    
    changeSampleRate()
    
    txtDays.integerValue = UserDefaults.standard.integer(forKey: DEFAULT.FC_TESTER_DAYS)
    
    changeDays()
    
    lblDays.stringValue = ""
    lblHour.stringValue = ""
    lblMinute.stringValue = ""
    lblSeconds.stringValue = ""
    lblTicks.stringValue = ""
    lblOtherBits.stringValue = ""
    
  }
  
  // MARK: Private Properties
  
  private var cboNetworkDS = ComboBoxDBDS(tableName: TABLE.NETWORK, codeColumn: NETWORK.NETWORK_ID, displayColumn: NETWORK.NETWORK_NAME, sortColumn: NETWORK.NETWORK_NAME)

  private var mode : Mode = .idle
  
  private var networkId : Int = -1
  
  private var interface : InterfaceLocoNet?
  
  private var observerId : Int = -1
  
  private var timer : Timer?
  
  private var scaleFactor : FastClockScaleFactor = .defaultValue
  
  private var sampleRate : SampleRate = .defaultValue
  
  private var days : Int = 1
  
  private var startTime : TimeInterval = 0.0
  
  private var numberOfTicks : Int = -1
  
  private var lastTicks : Int = 0
  
  private var lastMinute : Int = 0
  
  private var lastCombined : Int = 0
  
  private var lastJump : Int = 0
  
  private var startOfMinutesCount : TimeInterval = 0.0
  
  private var minuteCount : TimeInterval = 0.0
  
  // MARK: Private Methods
  
  private func changeNetwork() {
    
    interface?.removeObserver(id: observerId)
    
    interface = nil
    
    networkId = cboNetworkDS.codeForItemAt(index: cboNetwork.indexOfSelectedItem) ?? -1
    
    UserDefaults.standard.set(networkId, forKey: DEFAULT.FC_TESTER_NETWORK_ID)

    if let network = myTrainsController.networks[networkId], let interface = network.interface as? InterfaceLocoNet {
      self.interface = interface
      observerId = interface.addObserver(observer: self)
    }

  }
  
  private func changeScaleFactor() {
    
    scaleFactor = FastClockScaleFactor.selected(comboBox: cboScaleFactor)

    UserDefaults.standard.set(scaleFactor.rawValue, forKey: DEFAULT.FC_TESTER_SCALE_FACTOR)

  }
  
  private func changeSampleRate() {
    
    sampleRate = SampleRate.selected(comboBox: cboSampleRate)

    UserDefaults.standard.set(sampleRate.rawValue, forKey: DEFAULT.FC_TESTER_SAMPLE_RATE)
    
  }
  
  private func changeDays() {
    
    days = txtDays.integerValue

    UserDefaults.standard.set(days, forKey: DEFAULT.FC_TESTER_DAYS)

  }
  
  @objc func timerAction() {
    
    interface?.getFastClock()
        
  }
  
  func startTimer() {
    
    stoptimer()
    
    let interval : TimeInterval = 1.0 / TimeInterval(sampleRate.rawValue)
    
    timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    
    RunLoop.current.add(timer!, forMode: .common)
    
  }
  
  func stoptimer() {
    timer?.invalidate()
    timer = nil
  }

  // MARK: InterfaceDelegate Methods
  
  @objc func networkMessageReceived(message:LocoNetMessage) {
    
    switch message.messageType {
    case .setSlotDataOKP1:
      
      if mode == .setClock {
        interface?.getFastClock()
        mode = .idle
      }
      
    case .fastClockData:
  
      // 0xe7 0x0e 0x7b 0x10 0x79 0x79 0x01 0x04 0x6d 0x01 0x40 0x7f 0x7f 0x54
      
      let hour = Int(message.message[8]) - 104
          
      let minute = Int(message.message[6]) - 68

//      let mask = 0x3ff
      
      let combined = (Int(message.message[4]) | (Int(message.message[5]) << 7))
      
 //     let s = combined < lastCombined ? "*" : ""
      
 //     print("\(combined) \(s)")
      
      let ticks = combined
      
      let seconds = ticks
      
  //    let otherBits = combined & ~mask
      
      lblDays.stringValue = "\(message.message[9])"
      
      lblHour.stringValue = "\(hour)"
      
      lblMinute.stringValue = "\(minute)"
      
      lblSeconds.stringValue = "\(seconds)"
      
      lblTicks.stringValue = "\(ticks)"
      
      if lastMinute != minute {
        
        if lastMinute != -1 {
          if startOfMinutesCount == 0.0 {
            startOfMinutesCount = message.timeStamp
            minuteCount = 0.0
          }
          else {
            minuteCount += 1.0
            let time = (message.timeStamp - startOfMinutesCount) / TimeInterval(minuteCount)
            lblOtherBits.stringValue = "\(time)" // "0x\(String(combined, radix: 16).suffix(4))"
          }
        }
        
        lastMinute = minute
        
      }
      
      if mode == .findTickRate {
        interface?.getFastClock()
      }

      
      if lastCombined > combined {
 //       print("\(minute) \(combined) \(lastCombined)" + " *** \(combined - lastCombined) \(lastCombined - lastJump)")
        lastJump = lastCombined
      }
      lastCombined = combined

//      lblOtherBits.stringValue = "0b\(("0000000000000000" + String(otherBits, radix: 2)).suffix(16)) 0x\(("0000" + String(otherBits, radix: 16)).suffix(4))"
      
      if mode == .findTickRate {
        
        if numberOfTicks == -1 {
          numberOfTicks = 0
    //      startTime = message.timeStamp
          lastTicks = combined
        }
        else {
          if lastTicks != combined {
            
            numberOfTicks += 1
            
            lastTicks = combined
            
      //      let elapsed = message.timeStamp - startTime
            
     //       let rate = TimeInterval(numberOfTicks) / elapsed
            
      //      lblElapsedTime.doubleValue = elapsed
            
      //      lblNumberOfTicks.integerValue = numberOfTicks
            
      //      lblTickRate.doubleValue = rate
            
          }
        }
        
        interface?.getFastClock()

      }
      
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
  
    myTrainsController.fastClock.isEnabled = false
    mode = .setClock
    interface?.setFastClock(date: txtSetDate.dateValue, scaleFactor: scaleFactor)

  }
  
  @IBOutlet weak var btnSetAndRunTest: NSButton!
  
  // Tick Rate Test Start
  @IBAction func btnSetAndRunTestAction(_ sender: NSButton) {
    
    myTrainsController.fastClock.isEnabled = false
    mode = .findTickRate
    numberOfTicks = -1
    lastMinute = -1
//    startTimer()
    startOfMinutesCount = 0.0
    minuteCount = 0.0
    
    interface?.getFastClock()

  }
  
  @IBOutlet weak var btnStopTest: NSButton!
  
  @IBAction func btnStopTestAction(_ sender: NSButton) {
    
    stoptimer()
    mode = .idle
    myTrainsController.fastClock.isEnabled = true
    
  }
  
  @IBOutlet weak var cboScaleFactor: NSComboBox!
  
  @IBAction func cboScaleFactorAction(_ sender: NSComboBox) {
    changeScaleFactor()
  }
  
  @IBOutlet weak var cboNetwork: NSComboBox!
  
  
  @IBAction func cboNetworkAction(_ sender: NSComboBox) {
    
    changeNetwork()
    
  }
  
  @IBOutlet weak var lblNumberOfTicks: NSTextField!
  
  @IBOutlet weak var lblElapsedTime: NSTextField!
  
  @IBOutlet weak var lblTickRate: NSTextField!
  
  @IBOutlet weak var txtDays: NSTextField!
  
  @IBAction func txtDaysAction(_ sender: NSTextField) {
    
    changeDays()
    
  }
  
  
  @IBOutlet weak var cboSampleRate: NSComboBox!
  
  @IBAction func cboSampleRateAction(_ sender: NSComboBox) {
    
    changeSampleRate()
    
  }
  
  
  @IBOutlet weak var lblDays: NSTextField!
  
  @IBOutlet weak var lblHour: NSTextField!
  
  @IBOutlet weak var lblMinute: NSTextField!
  
  @IBOutlet weak var lblSeconds: NSTextField!
  
  @IBOutlet weak var lblTicks: NSTextField!
  
  @IBOutlet weak var lblOtherBits: NSTextField!
  
  @IBAction func btnMakeSequenceAction(_ sender: NSButton) {
    
    let start = 0x3410
    
    let end = 0b0011111111111111
    
    let adjustStart = start + 239
    
    var tick = start
    
    var nextAdjust = adjustStart
    
    var loop = 3
    
    var totalTicks = 0
    
    var comment = ""
    
    while loop > 0 {
      
      print("\(tick) \(comment)")
      
      comment = ""
      
      tick += 1
      
      totalTicks += 1
      
      if tick > nextAdjust {
        
        tick -= 128
        
        nextAdjust += 128

        comment = "*"
        
      }
      else if tick > end {
        
        tick = start

        nextAdjust = adjustStart

        print ("\ntotalTicks = \(totalTicks)\n")
        
        totalTicks = 0
        
        loop -= 1

      }
      
    }

    print ("\ntotalTicks = \(totalTicks)\n")
    
  }
  
  
  
  
  
  
  
  
  
  
}
