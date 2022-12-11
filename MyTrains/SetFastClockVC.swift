//
//  SetFastClockVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 04/12/2022.
//

import Foundation
import Cocoa

class SetFastClockVC: NSViewController, NSWindowDelegate {
  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    let fastClock : FastClock = networkController.fastClock
    
    FastClockScaleFactor.populate(comboBox: cboScaleFactor)
    
    FastClockScaleFactor.select(comboBox: cboScaleFactor, value: fastClock.scaleFactor)
    
    pckTime.timeZone = TimeZone.current
    
    pckTime.dateValue = Date(timeIntervalSince1970: fastClock.scaleTime)
    
  }
  
  // MARK: Private Properties
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var pckTime: NSDatePicker!
  
  @IBAction func pckTimeAction(_ sender: NSDatePicker) {
  }
  
  @IBOutlet weak var cboScaleFactor: NSComboBox!
  
  @IBAction func cboScaleFactorAction(_ sender: NSComboBox) {
  }
  
  @IBAction func btnSetAction(_ sender: NSButton) {
    
    let fastClock = networkController.fastClock
    
    fastClock.scaleFactor = FastClockScaleFactor.selected(comboBox: cboScaleFactor)
    
    fastClock.epoch = pckTime.dateValue.timeIntervalSince1970
    
    let date = Date()
    
    fastClock.referenceTime = date.timeIntervalSince1970
    
    view.window?.close()

  }
  
  @IBAction func btnResetAction(_ sender: NSButton) {
    
    let fastClock = networkController.fastClock
    
    fastClock.scaleFactor = FastClockScaleFactor.selected(comboBox: cboScaleFactor)

    pckTime.dateValue = Date()
    
    fastClock.epoch = pckTime.dateValue.timeIntervalSince1970
    
    fastClock.referenceTime = pckTime.dateValue.timeIntervalSince1970
    
    view.window?.close()

  }
  
}

