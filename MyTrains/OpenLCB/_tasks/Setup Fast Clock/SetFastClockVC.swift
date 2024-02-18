//
//  SetFastClockVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 04/12/2022.
//

import Foundation
import Cocoa

class SetFastClockVC: NSViewController, NSWindowDelegate, OpenLCBClockDelegate, OpenLCBConfigurationToolDelegate {
  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
    
    guard let networkLayer, let configurationTool else {
      return
    }
    
    if let fastClock {
      fastClock.removeObserver(observerId: observerId)
      observerId = -1
    }
    
    configurationTool.delegate = nil
    networkLayer.releaseConfigurationTool(configurationTool: configurationTool)
    
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    networkLayer = configurationTool!.networkLayer
    
    nodeId = configurationTool!.nodeId
    
    fastClock = networkLayer!.fastClock
    
    if let fastClock {
      
      txtRate.stringValue = "\(fastClock.rate)"
      
      swSwitch.state = fastClock.clockState == .running ? .on : .off
      
      pckTime.dateValue = fastClock.date
      
      observerId = fastClock.addObserver(observer: self)
      
    }
    
  }
  
  // MARK: Private Properties
  
  private var observerId : Int = -1
  
  private var networkLayer : OpenLCBNetworkLayer?
  
  private var nodeId : UInt64 = 0
  
  private var fastClock : OpenLCBClock?
  
  // MARK: Public Properties
  
  public var configurationTool : OpenLCBNodeConfigurationTool?
  
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
    
    guard let networkLayer, let fastClock else {
      return
    }
    
    var events : [UInt64] = []

    let date = pckTime.dateValue
    
    let components = date.dateComponents
     
   // networkLayer.sendEvent(sourceNode: configurationTool!, eventId: fastClock.encodeStopStartEvent(state: .stopped))

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
 //       networkLayer.sendEvent(sourceNode: configurationTool!, eventId: eventId)
      }

    }

  }
  
  @IBOutlet weak var swSwitch: NSSwitch!
  
  @IBAction func swSwitchAction(_ sender: NSSwitch) {

    guard let networkLayer, let fastClock else {
      return
    }
    
//    networkLayer.sendEvent(sourceNode: configurationTool!, eventId: fastClock.encodeStopStartEvent(state: (swSwitch.state == .on ? .running : .stopped)))

  }
  
  @IBOutlet weak var clockView: ClockView!
  
}
