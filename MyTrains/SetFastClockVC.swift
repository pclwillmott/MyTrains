//
//  SetFastClockVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 04/12/2022.
//

import Foundation
import Cocoa

class SetFastClockVC: NSViewController, NSWindowDelegate, OpenLCBClockDelegate {
  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
    if let fastClock = networkController.openLCBNetworkLayer?.myTrainsNode.fastClock {
      fastClock.removeObserver(observerId: observerId)
      observerId = -1
    }
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    if let fastClock = networkController.openLCBNetworkLayer?.myTrainsNode.fastClock {
      
      txtRate.stringValue = "\(fastClock.rate)"
      
      swSwitch.state = fastClock.state == .running ? .on : .off
      
      pckTime.timeZone = TimeZone(secondsFromGMT: 0)!
      
      pckTime.dateValue = fastClock.date
      
      observerId = fastClock.addObserver(observer: self)
      
    }
    
  }
  
  // MARK: Private Properties
  
  var observerId : Int = -1
  
  // MARK: OpenLCBClockDelegate Methods
  
  func clockTick(clock: OpenLCBClock) {
    clockView.date = clock.date
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var pckTime: NSDatePicker!
  
  @IBAction func pckTimeAction(_ sender: NSDatePicker) {
  }
  
  @IBOutlet weak var txtRate: NSTextField!
  
  @IBAction func txtRateAction(_ sender: NSTextField) {
  }
  
  @IBAction func btnSetAction(_ sender: NSButton) {
    
    if let networkLayer = networkController.openLCBNetworkLayer {

      var events : [UInt64] = []

      let date = pckTime.dateValue
      
      let components = date.dateComponents
      
      for index in 0 ... 4 {
        
        if let eventIndex = OpenLCBFastClockEventIndex(rawValue: index) {
          
          var eventId : UInt64 = OpenLCBClockType.fastClock.rawValue
          
          switch eventIndex {
          case .startOrStopEvent:
            eventId |= (swSwitch.state == .on ? 0xf002 : 0xf001)
          case .reportRateEvent:
            if let rate = Double(txtRate.stringValue) {
              eventId |= 0xc000 + UInt64(rate.openLCBClockRate)
            }
          case .reportYearEvent:
            eventId |= UInt64(0xb000 + components.year!)
          case .reportDateEvent:
            eventId |= UInt64(0xa000 + (components.month! << 8) + components.day!)
          case .reportTimeEvent:
            eventId |= UInt64(0x8000 + (components.hour! << 8) + components.minute!)
          }
          
          events.append(eventId)

        }
        
        let nodeId = networkLayer.myTrainsNode.nodeId

        for eventId in events {
          networkLayer.sendEvent(sourceNodeId: nodeId, eventId: eventId)
        }

      }
      
    }
 
//    view.window?.close()

  }
  
  @IBAction func btnResetAction(_ sender: NSButton) {
    
    pckTime.dateValue = Date()
    
    btnSetAction(sender)
    
  }
  
  @IBOutlet weak var swSwitch: NSSwitch!
  
  @IBAction func swSwitchAction(_ sender: NSSwitch) {
  }
  
  @IBOutlet weak var clockView: ClockView!
  
}

