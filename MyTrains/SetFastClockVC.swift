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
    if let fastClock = myTrainsController.openLCBNetworkLayer?.fastClock {
      fastClock.removeObserver(observerId: observerId)
      observerId = -1
    }
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    if let fastClock = myTrainsController.openLCBNetworkLayer?.fastClock {
      
      txtRate.stringValue = "\(fastClock.rate)"
      
      swSwitch.state = fastClock.clockState == .running ? .on : .off
      
      pckTime.dateValue = fastClock.date
      
      observerId = fastClock.addObserver(observer: self)
      
    }
    
  }
  
  // MARK: Private Properties
  
  var observerId : Int = -1
  
  // MARK: OpenLCBClockDelegate Methods
  
  func clockTick(clock: OpenLCBClock) {
    clockView.subState = clock.subState
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
    
    if let networkLayer = myTrainsController.openLCBNetworkLayer {

      let fastClock = networkLayer.fastClock
      
      var events : [UInt64] = []

      let date = pckTime.dateValue
      
      let components = date.dateComponents
       
      let nodeId = networkLayer.configurationToolNode.nodeId

      networkLayer.sendEvent(sourceNodeId: nodeId, eventId: fastClock.encodeStopStartEvent(state: .stopped))

      for index in 0 ... 4 {
        
        if let eventIndex = OpenLCBFastClockEventIndex(rawValue: index) {
          
          switch eventIndex {
          case .startOrStopEvent:
            events.append(fastClock.encodeStopStartEvent(state: swSwitch.state == .on ? .running : .stopped))
          case .reportRateEvent:
            if let rate = Double(txtRate.stringValue) {
              var r = rate
              if rate < -512.0 || rate > 511.75 {
                txtRate.stringValue = "1.0"
                r = 1.0
              }
              events.append(fastClock.encodeRateEvent(subCode: .setRateEventId, rate: r))
            }
          case .reportYearEvent:
            events.append(fastClock.encodeYearEvent(subCode: .setYearEventId, year: components.year!))
          case .reportDateEvent:
            events.append(fastClock.encodeDateEvent(subCode: .setDateEventId, month: components.month!, day: components.day!))
          case .reportTimeEvent:
            events.append(fastClock.encodeTimeEvent(subCode: .setTimeEventId, hour: components.hour!, minute: components.minute!))
          }
          
        }
        
        for eventId in events {
          networkLayer.sendEvent(sourceNodeId: nodeId, eventId: eventId)
        }

      }
      
    }
 
  }
  
  @IBOutlet weak var swSwitch: NSSwitch!
  
  @IBAction func swSwitchAction(_ sender: NSSwitch) {

    if let networkLayer = myTrainsController.openLCBNetworkLayer {
      let fastclock = networkLayer.fastClock
      let nodeId = networkLayer.configurationToolNode.nodeId
      networkLayer.sendEvent(sourceNodeId: nodeId, eventId: fastclock.encodeStopStartEvent(state: (swSwitch.state == .on ? .running : .stopped)))
    }
    
  }
  
  @IBOutlet weak var clockView: ClockView!
  
}

