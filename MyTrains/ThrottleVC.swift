//
//  ThrottleVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/01/2022.
//

import Foundation
import Cocoa
import AppKit

class ThrottleVC: NSViewController, NSWindowDelegate, MyTrainsControllerDelegate {

  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }

  func windowWillClose(_ notification: Notification) {
    
    myTrainsController.removeDelegate(id: networkControllerDelegateId)
    
    if locomotiveDelegateId != -1 {
      /*
      locomotive?.removeDelegate(withKey: locomotiveDelegateId)
      locomotiveDelegateId = -1
      locomotive?.isInUse = false
      locomotive = nil
       */
    }
    
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    networkControllerDelegateId = myTrainsController.appendDelegate(delegate: self)
    
    let xStart : CGFloat = 110
    var xPos : CGFloat = xStart
    var yPos : CGFloat = 210
    
    var index = 0
    while index < 29 {
      
      let button : NSButton = NSButton(title: "F\(index)", target: self, action: #selector(self.buttonAction(_:)))
      button.frame = NSRect(x: xPos, y: yPos, width: 50, height: 20)
      button.tag = index
      button.setButtonType(.momentaryPushIn)
      button.allowsExpansionToolTips = true
      boxMain.addSubview(button)
      buttons.append(button)
      
      index += 1
      if index % 8 == 0 {
        yPos -= 30
        xPos = xStart
      }
      else {
        xPos += button.frame.width
      }
      
    }

//    dataSource.dictionary = myTrainsController.locomotives
    
//    cboLocomotive.dataSource = dataSource
    
    RouteDirection.populate(comboBox: cboRouteDirection)
    
    ThrottleMode.populate(comboBox: cboThrottleMode)
    
    setupLocomotive()

  }
  
  // MARK: Private Properties
  
  private var dataSource : ComboBoxDictDS = ComboBoxDictDS()
  
  private var first : Bool = true
  
  private var networkControllerDelegateId : Int = -1
  
//  private var locomotive : Locomotive?
  
  private var buttons : [NSButton] = []
  
  private var locomotiveDelegateId : Int = -1
  
  private var route : Route = []
  
  // MARK: Private Methods
  
  private func setupLocomotive() {
    
    if locomotiveDelegateId != -1 {
      /*
      locomotive?.removeDelegate(withKey: locomotiveDelegateId)
      locomotive?.isInUse = false
      locomotiveDelegateId = -1
      locomotive = nil
       */
    }
    
    lblOrigin.stringValue = ""
    lblDestination.stringValue = ""
    
    /*
    if let locomotive = dataSource.editorObjectAt(index: cboLocomotive.indexOfSelectedItem) as? Locomotive {
      
      self.locomotive = locomotive
      
      locomotive.throttleMode = ThrottleMode.selected(comboBox: cboThrottleMode)
      
      locomotiveDelegateId = locomotive.addDelegate(delegate: self)
      
      swPower.state = locomotive.isInUse ? .on : .off
      
      switch locomotive.targetSpeed.direction {
      case .forward:
        radForward.state = .on
        radReverse.state = .off
        break
      case .reverse:
        radForward.state = .off
        radReverse.state = .on
        break
      }
      
      vsThrottle.integerValue = Int(locomotive.targetSpeed.speed)
      
      lblTargetStep.integerValue = vsThrottle.integerValue
      
      lblSpeed.integerValue = Int(locomotive.speed.speed)
      
      chkInertial.state = locomotive.isInertial ? .on : .off
      
      for button in buttons {
        let locoFunc = locomotive.functions[button.tag]
        button.setButtonType(locoFunc.isMomentary ? .momentaryPushIn : .pushOnPushOff)
        button.isEnabled = true // locoFunc.isEnabled && locomotive.isInUse
        button.state = locoFunc.state ? .on : .off
        button.toolTip = locoFunc.toolTip
        button.allowsExpansionToolTips = true
      }
      
      RouteDirection.select(comboBox: cboRouteDirection, value: locomotive.routeDirection)
      
      if let origin = locomotive.originBlock {
        lblOrigin.stringValue = origin.blockName
      }
      
      if let destination = locomotive.destinationBlock {
        lblDestination.stringValue = destination.blockName
      }

      enableControls()
      
    }
    else {
      
      swPower.state = .off
      
      radForward.state = .on
      radReverse.state = .off
      
      vsThrottle.integerValue = 0
      
      chkInertial.state = .on
      
      for button in buttons {
        button.state = .off
        button.isEnabled = true
        button.setButtonType(.momentaryPushIn)
        button.toolTip = "F\(button.tag)"
      }
      
      lblTargetStep.stringValue = "0"
      lblSpeed.stringValue = "0"

      enableControls()
      
    }
     */
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
  // MARK: MyTrainsControllerDelegate Methods
  
  @objc func myTrainsControllerUpdated(myTrainsController: MyTrainsController) {
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
  
  @IBOutlet weak var lblDistance: NSTextField!
  
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
  
  @IBOutlet weak var chkInertial: NSButton!
  
  @IBAction func chkInerialAction(_ sender: NSButton) {
 //   locomotive?.isInertial = chkInertial.state == .on
  }
  
  @IBOutlet weak var lblTargetStep: NSTextField!
  
  @IBOutlet weak var lblRouteDirection: NSTextField!
  
  @IBOutlet weak var cboRouteDirection: NSComboBox!
  
  @IBAction func cboRouteDirectionAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var cboThrottleMode: NSComboBox!
  
  @IBAction func cboThrottleModeAction(_ sender: NSComboBox) {
//    locomotive?.throttleMode = ThrottleMode.selected(comboBox: cboThrottleMode)
    enableControls()
  }
  
  @IBOutlet weak var lblOrigin: NSTextField!
  
  @IBOutlet weak var lblDestination: NSTextField!
  
  @IBOutlet weak var btnSetRoute: NSButton!
  
  @IBAction func btnSetRouteAction(_ sender: NSButton) {
    /*
    if let locomotive = self.locomotive, let layout = myTrainsController.layout {
      layout.setRoute(route: locomotive.route)
    }
     */
  }
  
  @IBOutlet weak var btnGo: NSButton!
  
  @IBAction func btnGoAction(_ sender: NSButton) {
 //   locomotive?.startAutoRoute()
  }
  
  @IBOutlet weak var boxMain: NSBox!
  
  @IBOutlet weak var boxRoute: NSBox!
  
  
  
}
