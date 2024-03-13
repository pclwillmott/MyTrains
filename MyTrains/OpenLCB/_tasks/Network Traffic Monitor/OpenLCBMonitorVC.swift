//
//  OpenLCBMonitorVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/11/2023.
//

import Foundation
import Cocoa

class OpenLCBMonitorVC: MyTrainsViewController, OpenLCBNetworkObserverDelegate {
  
  // MARK: Window & View Methods
  
  override func windowWillClose(_ notification: Notification) {
    appDelegate.networkLayer.removeObserver(id: observerId)
    super.windowWillClose(notification)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewType = .openLCBTrafficMonitor
  }

  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    txtMonitor.font = NSFont(name: "Menlo", size: 12)
    
    observerId = appDelegate.networkLayer.addObserver(observer: self)
    
    appDelegate.networkLayer.isMonitorPaused = false
    
    scvMonitor.translatesAutoresizingMaskIntoConstraints = false
    btnClear.translatesAutoresizingMaskIntoConstraints = false
    btnPause.translatesAutoresizingMaskIntoConstraints = false
    frame.translatesAutoresizingMaskIntoConstraints = false
    
    scvMonitor.hasVerticalScroller = true
    scvMonitor.allowsMagnification = false
    scvMonitor.autohidesScrollers = false

    view.subviews.removeAll()
    
    view.addSubview(frame)
    frame.addSubview(scvMonitor)
    view.addSubview(btnClear)
    view.addSubview(btnPause)
    
    view.window?.title = String(localized: "LCC/OpenLCB Traffic Monitor")
    
    btnClear.title = String(localized: "Clear")
    btnPause.title = String(localized: "Pause")
    
    txtMonitor.isEditable = false

    NSLayoutConstraint.activate([
      
      frame.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 1.0),
//      scvMonitor.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      frame.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1.0),
      view.bottomAnchor.constraint(equalToSystemSpacingBelow: frame.bottomAnchor, multiplier: 1.0),
      btnClear.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1.0),
      btnPause.topAnchor.constraint(equalToSystemSpacingBelow: btnClear.bottomAnchor, multiplier: 1.0),
      btnClear.leadingAnchor.constraint(equalToSystemSpacingAfter: frame.trailingAnchor, multiplier: 1.0),
      btnPause.leadingAnchor.constraint(equalTo: btnClear.leadingAnchor),
      btnClear.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0),
      scvMonitor.topAnchor.constraint(equalToSystemSpacingBelow: frame.topAnchor, multiplier: 1.0),
      scvMonitor.leadingAnchor.constraint(equalToSystemSpacingAfter: frame.leadingAnchor, multiplier: 1.0),
      frame.trailingAnchor.constraint(equalToSystemSpacingAfter: scvMonitor.trailingAnchor, multiplier: 1.0),
      frame.bottomAnchor.constraint(equalToSystemSpacingBelow: scvMonitor.bottomAnchor, multiplier: 1.0),
      btnClear.widthAnchor.constraint(greaterThanOrEqualTo: btnPause.widthAnchor, multiplier: 1.0),
      btnPause.widthAnchor.constraint(greaterThanOrEqualTo: btnClear.widthAnchor, multiplier: 1.0),
      
    ])
    
    if !appDelegate.networkLayer.gatewayNodes.isEmpty {
      
      for index in 0 ... appDelegate.networkLayer.gatewayNodes.count - 1 {
        
        let rxLED = LEDView()
        rxLED.fillColor = .orange
        rxLED.strokeColor = .orange
        
        self.rxLED.append(rxLED)
        
        let txLED = LEDView()
        txLED.fillColor = .blue
        txLED.strokeColor = .blue
        
        self.txLED.append(txLED)

        rxPacketCount.append(0)
        
        txPacketCount.append(0)
        
        lblRXPacketCount.append(NSTextField(labelWithString: ""))
        
        lblTXPacketCount.append(NSTextField(labelWithString: ""))
        
      }
      
    }
      
  }
  
  // MARK: Private Properties

  private var observerId : Int = -1
  
  private var rxLED : [LEDView] = []
  
  private var txLED : [LEDView] = []
  
  private var lblRXPacketCount : [NSTextField] = []
  
  private var lblTXPacketCount : [NSTextField] = []
  
  private var rxPacketCount : [UInt64] = []
  
  private var txPacketCount : [UInt64] = []

  // MARK: Private Methods
  
  // MARK: OpenLCBNetworkObserverDelegate Methods
  
  @objc func updateMonitor(text: String) {
    guard !text.isEmpty else {
      return
    }
    txtMonitor.string = text
    let range = NSMakeRange(text.count - 1, 0)
    txtMonitor.scrollRangeToVisible(range)
  }

  @objc func gatewayRXPacket(gateway:Int) {
    
  }
  
  @objc func gatewayTXPacket(gateway:Int) {
    
  }

  // MARK: Controls
  
  private var btnClear = NSButton()
  
  private var btnPause = NSButton()
  
  private var frame = FrameView()
  
  // MARK: Actions
  
  @objc func btnClearAction(_ sender: NSButton) {
    appDelegate.networkLayer.clearMonitorBuffer()
  }
  
  @objc func btnPauseAction(_ sender: NSButton) {
    appDelegate.networkLayer.isMonitorPaused = sender.state == .on
  }
  
  @IBOutlet weak var scvMonitor: NSScrollView!
  
  @IBOutlet var txtMonitor: NSTextView!
  
}

