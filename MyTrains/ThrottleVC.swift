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

    throttle = myTrainsController.openLCBNetworkLayer?.getThrottle()
    throttle?.delegate = self
    txtSearchAction(txtSearch)

    
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

//    setupLocomotive()

  }
  
  // MARK: Private Properties
  
  private var dataSource : ComboBoxDictDS = ComboBoxDictDS()
  
  private var buttons : [NSButton] = []
  
  private var throttle : OpenLCBThrottle?
  
  private var cboLocomotiveDS = ComboBoxSimpleDS()
  
  // MARK: Private Methods
  
  private func setupLocomotive() {
    
  }
  
  private func enableControls() {
//    let enabled = locomotive?.isInUse ?? false
    
//    boxMain.isHidden = !enabled
    
//    boxRoute.isHidden = ThrottleMode.selected(comboBox: cboThrottleMode) == .manual
    
  }
  
  // MARK: LocomotiveDelegate Methods
  /*
  func stateUpdated(locomotive: Locomotive) {
    lblSpeed.stringValue = "\(locomotive.speed.speed)"
    lblDistance.stringValue = String(format: "%.1f", locomotive.distanceTravelled)
    lblOrigin.stringValue = ""
    if let origin = locomotive.originBlock {
      lblOrigin.stringValue = "\(origin.blockName) \(String(format:"%.1f", locomotive.originBlockPosition))"
    }
    lblDestination.stringValue = ""
    if let destination = locomotive.destinationBlock {
      lblDestination.stringValue = "\(destination.blockName) \(String(format:"%.1f", locomotive.destinationBlockPosition))"
    }

  }
  */
  /*
  func stealZap(locomotive: Locomotive) {

    locomotive.targetSpeed.speed = 0
    
    locomotive.isInUse = false
    
    lblSpeed.intValue = 0
    
    locomotive.removeDelegate(withKey: locomotiveDelegateId)
    
    locomotiveDelegateId = -1
    
    self.locomotive = nil
    
    cboLocomotive.deselectItem(at: cboLocomotive.indexOfSelectedItem)

  }
  */
  // MARK: OpenLCBThrottleDelegate Methods
  
  @objc func trainSearchResultsReceived(throttle:OpenLCBThrottle, results:[UInt64:String]) {
    cboLocomotive.selectItem(at: -1)
    cboLocomotiveDS.dictionary = results
    cboLocomotive.reloadData()
    if !results.isEmpty && throttle.throttleState == .idle {
      cboLocomotive.selectItem(at: 0)
    }
  }
  
  @objc func throttleStateChanged(throttle:OpenLCBThrottle) {
    
    self.view.window?.title = "\(throttle.userNodeName) (\(throttle.nodeId.toHexDotFormat(numberOfBytes: 6)))"
    
    if let trainNode = throttle.trainNode {
      lblSelectedLocomotive.stringValue = trainNode.userNodeName
      lblNodeId.stringValue = trainNode.nodeId.toHexDotFormat(numberOfBytes: 6)
    }
    else {
      lblSelectedLocomotive.stringValue = "IDLE"
      lblNodeId.stringValue = ""
    }
    
  }

  // MARK: Outlets & Actions
  
  @IBAction func buttonAction(_ sender: NSButton) {
    /*
    if let loco = locomotive {
      let locoFunc = loco.functions[sender.tag]
      if locoFunc.isMomentary {
        locoFunc.state = true
      }
      else {
        locoFunc.state = sender.state == .on
        locoFunc.save()
      }
    }
     */
  }
  
  @IBOutlet weak var cboLocomotive: NSComboBox!
  
  @IBAction func cboLocomotiveAction(_ sender: NSComboBox) {
    setupLocomotive()
  }
  
  @IBOutlet weak var swPower: NSSwitch!
  
  @IBAction func swPowerAction(_ sender: NSSwitch) {
    /*
    if let loco = locomotive {
      if sender.state == .off {
        loco.targetSpeed = (speed: 0, direction: radForward.state == .on ? .forward : .reverse)
        vsThrottle.integerValue = 0
        lblTargetStep.stringValue = "0"
      }
      loco.isInUse = sender.state == .on
      enableControls()
    }
     */
  }
  
  @IBOutlet weak var radForward: NSButton!
  
  @IBAction func radForwardAction(_ sender: NSButton) {
    
    radForward.state = .on
    radReverse.state = .off
 
    /*
    if let loco = locomotive {
      let speed = UInt8(lblTargetStep.integerValue)
      loco.targetSpeed = (speed: speed, direction: radForward.state == .on ? .forward : .reverse)
    }
     */
    
  }
  
  @IBOutlet weak var radReverse: NSButton!
  
  @IBAction func radReverseAction(_ sender: NSButton) {
    
    radForward.state = .off
    radReverse.state = .on
 
    /*
    if let loco = locomotive {
      let speed = UInt8(lblTargetStep.integerValue)
      loco.targetSpeed = (speed: speed, direction: radForward.state == .on ? .forward : .reverse)
    }
     */
    
  }
  
  @IBOutlet weak var lblSpeed: NSTextField!
  
  @IBOutlet weak var vsThrottle: NSSlider!
  
  @IBAction func vsThrottleAction(_ sender: NSSlider) {
    /*
    if let loco = locomotive {
      let speed = UInt8(sender.integerValue)
      loco.targetSpeed = (speed: speed, direction: radForward.state == .on ? .forward : .reverse)
    }
    lblTargetStep.stringValue = "\(sender.integerValue)"
     */
  }
  
  @IBOutlet weak var cboSearchType: NSComboBox!
  
  @IBOutlet weak var cboSearchMatchType: NSComboBox!
  
  @IBOutlet weak var cboSeatchMatchTarget: NSComboBox!
  
  @IBOutlet weak var txtSearch: NSSearchField!
  
  @IBAction func txtSearchAction(_ sender: NSSearchField) {
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
  
  @IBOutlet weak var viewF0F28: NSView!
  
  @IBOutlet weak var viewF29F68: NSView!
  
  @IBOutlet weak var viewBinaryAnalogStates: NSView!
  
  @IBOutlet weak var lblSelectedLocomotive: NSTextField!
  
  @IBOutlet weak var lblNodeId: NSTextField!
  
  @IBOutlet weak var btnEmergencyStop: NSButton!
  
  @IBAction func btnEmergencyStopAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var btnGlobalEmergencyStop: NSButton!
  
  @IBAction func btnGlobalEmergencyStopAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var btnGlobalEmergencyOff: NSButton!
  
  @IBAction func btnGlobalEmergencyOffAction(_ sender: NSButton) {
  }
  
  
  
}
