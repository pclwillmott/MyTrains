//
//  OpenLCBMonitorVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/11/2023.
//

import Foundation
import AppKit

class OpenLCBMonitorVC: MyTrainsViewController, OpenLCBNetworkObserverDelegate {
  
  // MARK: Window & View Methods
  
  override func windowWillClose(_ notification: Notification) {
    
    appDelegate.networkLayer!.removeObserver(id: observerId)
    
    monitorView?.subviews.removeAll()
    frame = nil
    btnClear?.target = nil
    btnClear = nil
    btnPause?.target = nil
    btnPause = nil
    gatewayViews.removeAll()
    postOfficeView = nil
    for view in stackView!.arrangedSubviews {
      stackView?.removeArrangedSubview(view)
    }
    stackView = nil
    view.subviews.removeAll()

    super.windowWillClose(notification)
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewType = .openLCBTrafficMonitor
  }

  override func viewWillAppear() {
    
    super.viewWillAppear()
    
    guard let stackView, let monitorView, let frame, let btnClear, let btnPause, let postOfficeView else {
      return
    }
    
    txtMonitor.font = NSFont(name: "Menlo", size: 12)
    
    observerId = appDelegate.networkLayer!.addObserver(observer: self)
    
    appDelegate.networkLayer!.isMonitorPaused = false
 
    view.window?.title = String(localized: "LCC/OpenLCB Traffic Monitor")
    
    stackView.translatesAutoresizingMaskIntoConstraints = false
    monitorView.translatesAutoresizingMaskIntoConstraints = false
    frame.translatesAutoresizingMaskIntoConstraints = false
    scvMonitor.translatesAutoresizingMaskIntoConstraints = false
    btnClear.translatesAutoresizingMaskIntoConstraints = false
    btnPause.translatesAutoresizingMaskIntoConstraints = false
    
    stackView.orientation = .vertical
    
    view.subviews.removeAll()
    
    view.addSubview(stackView)
    
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: view.topAnchor),
      view.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
      stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
    ])
    
    scvMonitor.hasVerticalScroller = true
    scvMonitor.allowsMagnification = false
    scvMonitor.autohidesScrollers = false

    stackView.addArrangedSubview(monitorView)
    
    monitorView.addSubview(frame)
    monitorView.addSubview(btnClear)
    monitorView.addSubview(btnPause)
    
    NSLayoutConstraint.activate([
      monitorView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
      monitorView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
    ])
    
    frame.addSubview(scvMonitor)
    
    btnClear.title = String(localized: "Clear")
    btnPause.title = String(localized: "Pause")
    btnPause.alternateTitle = String(localized: "Resume")
    
    btnClear.target = self
    btnClear.action = #selector(self.btnClearAction(_:))

    btnPause.target = self
    btnPause.action = #selector(self.btnPauseAction(_:))

    txtMonitor.isEditable = false

    NSLayoutConstraint.activate([
      
      frame.leadingAnchor.constraint(equalToSystemSpacingAfter: monitorView.leadingAnchor, multiplier: 1.0),
//      scvMonitor.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      frame.topAnchor.constraint(equalToSystemSpacingBelow: monitorView.topAnchor, multiplier: 1.0),
      monitorView.bottomAnchor.constraint(equalToSystemSpacingBelow: frame.bottomAnchor, multiplier: 1.0),
      btnClear.topAnchor.constraint(equalToSystemSpacingBelow: monitorView.topAnchor, multiplier: 1.0),
      btnPause.topAnchor.constraint(equalToSystemSpacingBelow: btnClear.bottomAnchor, multiplier: 1.0),
      btnClear.leadingAnchor.constraint(equalToSystemSpacingAfter: frame.trailingAnchor, multiplier: 1.0),
      btnPause.leadingAnchor.constraint(equalTo: btnClear.leadingAnchor),
      btnClear.trailingAnchor.constraint(equalTo: monitorView.trailingAnchor, constant: -20.0),
      scvMonitor.topAnchor.constraint(equalToSystemSpacingBelow: frame.topAnchor, multiplier: 1.0),
      scvMonitor.leadingAnchor.constraint(equalToSystemSpacingAfter: frame.leadingAnchor, multiplier: 1.0),
      frame.trailingAnchor.constraint(equalToSystemSpacingAfter: scvMonitor.trailingAnchor, multiplier: 1.0),
      frame.bottomAnchor.constraint(equalToSystemSpacingBelow: scvMonitor.bottomAnchor, multiplier: 1.0),
      btnClear.widthAnchor.constraint(greaterThanOrEqualTo: btnPause.widthAnchor, multiplier: 1.0),
      btnPause.widthAnchor.constraint(greaterThanOrEqualTo: btnClear.widthAnchor, multiplier: 1.0),
      
    ])

    let horizontalView = NSStackView()
    horizontalView.translatesAutoresizingMaskIntoConstraints = false
    horizontalView.orientation = .horizontal
    
    stackView.addArrangedSubview(horizontalView)
    stackView.alignment = .left
    
    postOfficeView.translatesAutoresizingMaskIntoConstraints = false
    postOfficeView.gatewayNumber = 0
    postOfficeView.name = String(localized: "Post Office")
    postOfficeView.nodeId = appDelegate.networkLayer!.postOfficeNodeId
    horizontalView.addArrangedSubview(postOfficeView)
    horizontalView.alignment = .top
    
    if !appDelegate.networkLayer!.gatewayNodes.isEmpty {
      
      NSLayoutConstraint.activate([
        horizontalView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1.0),
//        horizontalView.leadingAnchor.constraint(equalToSystemSpacingAfter: stackView.leadingAnchor, multiplier: 1.0),
//        horizontalView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
      ])
      
      for _ in 0 ... appDelegate.networkLayer!.gatewayNodes.count - 1 {
        let gatewayView = GatewayActivityView()
        gatewayView.translatesAutoresizingMaskIntoConstraints = false
        horizontalView.addArrangedSubview(gatewayView)
        gatewayViews.append(gatewayView)
      }
      
      for (_, temp) in appDelegate.networkLayer!.gatewayNodes {
        let gateway = temp as! OpenLCBCANGateway
        let view = gatewayViews[gateway.gatewayNumber]
        view.gatewayNumber = gateway.gatewayNumber + 1
        view.name = gateway.userNodeName
        view.nodeId = gateway.nodeId
      }
      
    }
      
  }
  
  // MARK: Private Properties

  private var observerId : Int = -1
  
  private var gatewayViews : [GatewayActivityView] = []

  private var postOfficeView : GatewayActivityView? = GatewayActivityView()

  // MARK: Private Methods
  
  // MARK: OpenLCBNetworkObserverDelegate Methods
  
  @objc func updateMonitor(text: String) {
    txtMonitor.string = text
    guard !text.isEmpty else {
      return
    }
    let range = NSMakeRange(text.count - 1, 0)
    txtMonitor.scrollRangeToVisible(range)
  }

  @objc func gatewayRXPacket(gateway:Int) {
    guard gateway < gatewayViews.count else {
      return
    }
    DispatchQueue.main.async {
      self.gatewayViews[gateway].rxPacket()
    }
  }
  
  @objc func gatewayTXPacket(gateway:Int) {
    guard gateway < gatewayViews.count else {
      return
    }
    gatewayViews[gateway].txPacket()
  }
  
  @objc func postOfficeRXMessage() {
    postOfficeView?.rxPacket()
  }
  
  @objc func postOfficeTXMessage() {
    postOfficeView?.txPacket()
  }

  // MARK: Actions
  
  @objc func btnClearAction(_ sender: NSButton) {
    appDelegate.networkLayer!.clearMonitorBuffer()
  }
  
  @objc func btnPauseAction(_ sender: NSButton) {
    sender.title = sender.state == .on ? String(localized: "Resume") : String(localized: "Pause")
    appDelegate.networkLayer!.isMonitorPaused = sender.state == .on
  }
  
  // MARK: Outlets
  
  @IBOutlet weak var scvMonitor: NSScrollView!
  
  @IBOutlet weak var txtMonitor: NSTextView!
  
  var stackView : NSStackView? = NSStackView()
  var monitorView : NSView? = NSView()
  var frame : FrameView? = FrameView()
  var btnClear : NSButton? = NSButton()
  var btnPause : NSButton? = NSButton()
  
}

