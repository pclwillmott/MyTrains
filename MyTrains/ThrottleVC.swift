//
//  ThrottleVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/01/2022.
//

import Foundation
import Cocoa
import AppKit

class ThrottleVC: NSViewController, NSWindowDelegate, OpenLCBThrottleDelegate {

  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }

  func windowWillClose(_ notification: Notification) {
    myTrainsController.openLCBNetworkLayer?.releaseThrottle(throttle: throttle!)
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
  
    OpenLCBSearchType.populate(comboBox: cboSearchType)
    OpenLCBSearchMatchType.populate(comboBox: cboSearchMatchType)
    OpenLCBSearchMatchTarget.populate(comboBox: cboSeatchMatchTarget)
    OpenLCBTrackProtocol.populate(comboBox: cboTrackProtocol)
    
    cboLocomotiveDS.dictionary = [:]
    cboLocomotive.dataSource = cboLocomotiveDS
    cboLocomotive.selectItem(at: -1)

    throttle?.delegate = self
    txtSearchAction(txtSearch)
    
    globalEmergencyChanged(throttle: throttle!)
    
    // Throttle is scaled in scale miles per hour
    
    vsThrottle.minValue = 0.0
    vsThrottle.maxValue = 126.0
    vsThrottle.doubleValue = 0.0
    
    let xStart : CGFloat = 0
    let yStart : CGFloat = 250.0
    var xPos : CGFloat = xStart
    var yPos : CGFloat = yStart
        
    var index = 0
    
    for fn in 0 ... 68 {
      
      if fn == 29 {
        index = 0
        xPos = xStart
        yPos = yStart
      }
      
      let button : NSButton = NSButton(title: "F\(fn)", target: self, action: #selector(self.buttonAction(_:)))
      button.font = NSFont.systemFont(ofSize: 10, weight: .regular)
      button.frame = NSRect(x: xPos, y: yPos, width: 170, height: 20)
      button.tag = fn
      button.setButtonType(.momentaryPushIn)
      button.allowsExpansionToolTips = true
      button.setButtonType(.pushOnPushOff)
      
      if fn < 29 {
        viewF0F28.addSubview(button)
      }
      else {
        viewF29F68.addSubview(button)
      }
      buttons.append(button)
      
      index += 1
      if index % 4 == 0 {
        yPos -= 27
        xPos = xStart
      }
      else {
        xPos += button.frame.width
      }
      
    }

  }
  
  // MARK: Private Properties
  
  private var dataSource : ComboBoxDictDS = ComboBoxDictDS()
  
  private var buttons : [NSButton] = []
  
  private var cboLocomotiveDS = ComboBoxSimpleDS()
  
  // MARK: Public Properties
  
  public var throttle : OpenLCBThrottle?

  // MARK: Private Methods
  
  private func setSpeedDirection() {
    
    let direction : Float = radForward.state == .on ? +1.0 : -1.0
    
    let mph2smps : Float = (1000.0 * 1.609344) / 3600.0
    
    throttle?.speed = (vsThrottle.floatValue == 0.0 && direction == -1.0) ? -0.0 : vsThrottle.floatValue * direction * mph2smps

    lblSpeed.stringValue = String(format: "%.0f", vsThrottle.floatValue)

  }
  
  // MARK: OpenLCBThrottleDelegate Methods
  
  @objc func trainSearchResultsReceived(throttle:OpenLCBThrottle, results:[UInt64:String]) {
    cboLocomotive.selectItem(at: -1)
    cboLocomotiveDS.dictionary = results
    cboLocomotive.reloadData()
    if !results.isEmpty && throttle.throttleState == .idle {
      cboLocomotive.selectItem(at: 0)
    }
  }
  
  @objc func functionChanged(throttle:OpenLCBThrottle, address:UInt32, value:UInt16) {
    
    guard address < buttons.count else {
      return
    }
    
    buttons[Int(address)].state = value == 0 ? .off : .on
    
  }
  
  @objc func speedChanged(throttle:OpenLCBThrottle, speed:Float) {
    
    let smps2mph : Float = 3600.0 / (1000.0 * 1.609344)

    let _speed = speed * smps2mph
    
    vsThrottle.floatValue = abs(_speed)
    
    lblSpeed.stringValue = String(format: "%.0f", vsThrottle.floatValue)
    
    let minusZero : Float = -0.0

    let isReverse = speed.bitPattern == minusZero.bitPattern || speed < 0.0
    
    radForward.state = isReverse ? .off : .on
    radReverse.state = isReverse ? .on : .off
    
  }

  @objc func globalEmergencyChanged(throttle:OpenLCBThrottle) {
    
    btnGlobalEmergencyStop.title = throttle.globalEmergencyStop ? "Clear Global Emergency Stop" : "Global Emergency Stop"
    
    btnGlobalEmergencyOff.title = throttle.globalEmergencyOff ? "Clear Global Emergency Off" : "Global Emergency Off"

  }

  @objc func throttleStateChanged(throttle:OpenLCBThrottle) {
    
    self.view.window?.title = "\(throttle.userNodeName) (\(throttle.nodeId.toHexDotFormat(numberOfBytes: 6)))"
    
    if let trainNode = throttle.trainNode {
      lblSelectedLocomotive.stringValue = trainNode.userNodeName
      lblNodeId.stringValue = "\(trainNode.nodeId.toHexDotFormat(numberOfBytes: 6)) - \(throttle.controllerInfo)"
    }
    else {
      lblSelectedLocomotive.stringValue = "UNASSIGNED"
      lblNodeId.stringValue = ""
    }
    
  }
  
  private var momentary : Set<Int> = []
  
  @objc func fdiAvailable(throttle:OpenLCBThrottle) {
    
    for button in buttons {
      button.isEnabled = false
    }
    
    momentary = []
    
    for item in throttle.fdiItems {
      if item.number < 69 {
        let button = buttons[item.number]
        button.setButtonType(item.kind == .binary ? .pushOnPushOff : .momentaryLight)
        button.title = "F\(item.number) - \(item.name)"
        button.isEnabled = true
        if item.kind == .momentary {
          momentary.insert(button.tag)
          button.sendAction(on: [.leftMouseUp, .leftMouseDown])
        }
      }
    }
    
  }

  // MARK: Outlets & Actions
  
  @IBAction func buttonAction(_ sender: NSButton) {
    let address = UInt32(sender.tag)
    if momentary.contains(sender.tag) {
      if let x = NSApp.currentEvent?.type {
        if x == .leftMouseUp {
          throttle?.setFunction(address: address, value: 0x0000)
        }
        else if x == .leftMouseDown {
          throttle?.setFunction(address: address, value: 0x0001)
        }
      }
    }
    else {
      throttle?.setFunction(address: address, value: sender.state == .on ? 0x0001 : 0x0000)
    }
    
  }
  
  @IBOutlet weak var cboLocomotive: NSComboBox!
  
  @IBAction func cboLocomotiveAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var radForward: NSButton!
  
  @IBAction func radForwardAction(_ sender: NSButton) {
    
    radForward.state = .on
    radReverse.state = .off
 
    setSpeedDirection()
    
  }
  
  @IBOutlet weak var radReverse: NSButton!
  
  @IBAction func radReverseAction(_ sender: NSButton) {
    
    radForward.state = .off
    radReverse.state = .on
    
    setSpeedDirection()
 
  }
  
  @IBOutlet weak var lblSpeed: NSTextField!
  
  @IBOutlet weak var vsThrottle: NSSlider!
  
  @IBAction func vsThrottleAction(_ sender: NSSlider) {
    setSpeedDirection()
  }
  
  @IBOutlet weak var cboSearchType: NSComboBox!
  
  @IBOutlet weak var cboSearchMatchType: NSComboBox!
  
  @IBOutlet weak var cboSeatchMatchTarget: NSComboBox!
  
  @IBOutlet weak var txtSearch: NSSearchField!
  
  @IBAction func txtSearchAction(_ sender: NSSearchField) {
    cboLocomotiveDS.dictionary = [:]
    cboLocomotive.reloadData()

    throttle?.trainSearch(searchString: sender.stringValue,
                          searchType: OpenLCBSearchType.selected(comboBox: cboSearchType),
                          searchMatchType: OpenLCBSearchMatchType.selected(comboBox: cboSearchMatchType),
                          searchMatchTarget: OpenLCBSearchMatchTarget.selected(comboBox: cboSeatchMatchTarget),
                          trackProtocol: OpenLCBTrackProtocol.selected(comboBox: cboTrackProtocol))
  }
  
  @IBOutlet weak var cboTrackProtocol: NSComboBox!
  
  @IBAction func cboSearchTypeAction(_ sender: NSComboBox) {
    txtSearchAction(txtSearch)
  }
  
  @IBAction func cboSearchMatchTypeAction(_ sender: NSComboBox) {
    txtSearchAction(txtSearch)
  }
  
  @IBAction func cboSearchMatchTargetAction(_ sender: NSComboBox) {
    txtSearchAction(txtSearch)
  }
  
  @IBAction func cboTrackProtocolAction(_ sender: NSComboBox) {
    txtSearchAction(txtSearch)
  }
  
  @IBOutlet weak var tabView: NSTabView!
  
  @IBOutlet weak var viewF0F28: NSView!
  
  @IBOutlet weak var viewF29F68: NSView!
  
  @IBOutlet weak var viewBinaryAnalogStates: NSView!
  
  @IBOutlet weak var lblSelectedLocomotive: NSTextField!
  
  @IBOutlet weak var lblNodeId: NSTextField!
  
  @IBOutlet weak var btnEmergencyStop: NSButton!
  
  @IBAction func btnEmergencyStopAction(_ sender: NSButton) {
    throttle?.emergencyStop()
  }
  
  @IBOutlet weak var btnGlobalEmergencyStop: NSButton!
  
  @IBAction func btnGlobalEmergencyStopAction(_ sender: NSButton) {
    
    sender.title == "Global Emergency Stop" ? throttle?.sendGlobalEmergencyStop() : throttle?.sendClearGlobalEmergencyStop()
 
  }
  
  @IBOutlet weak var btnGlobalEmergencyOff: NSButton!
  
  @IBAction func btnGlobalEmergencyOffAction(_ sender: NSButton) {
    
    sender.title == "Global Emergency Off" ? throttle?.sendGlobalEmergencyOff() : throttle?.sendClearGlobalEmergencyOff()
 
  }
  
  @IBAction func btnSelectAction(_ sender: NSButton) {
    
    if let nodeId = cboLocomotiveDS.keyForItemAt(index: cboLocomotive.indexOfSelectedItem) {
      for button in buttons {
        button.title = "F\(button.tag)"
        button.isEnabled = true
        button.setButtonType(.pushOnPushOff)
      }
 
      throttle?.assignController(trainNodeId: nodeId)
      tabView.selectTabViewItem(at: 1)
    }
    
  }
  
  @IBAction func btnReleaseAction(_ sender: NSButton) {
    throttle?.releaseController()
    tabView.selectTabViewItem(at: 0)
  }
  
}
