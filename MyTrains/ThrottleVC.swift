//
//  ThrottleVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/01/2022.
//

import Foundation
import Cocoa

class ThrottleVC: NSViewController, NSWindowDelegate, NetworkControllerDelegate {

  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }

  func windowWillClose(_ notification: Notification) {
    networkController.removeDelegate(id: networkControllerDelegateId)
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    networkControllerDelegateId = networkController.appendDelegate(delegate: self)
    
    let xStart : CGFloat = 25
    var xPos : CGFloat = xStart
    var yPos : CGFloat = 150
    
    var index = 0
    while index < 29 {
      
      let button : NSButton = NSButton()
      button.frame = NSRect(x: xPos, y: yPos, width: 35, height: 20)
      button.title = "F\(index)"
      button.action = #selector(self.buttonAction(_:))
      view.subviews.append(button)

      index += 1
      if index % 10 == 0 {
        yPos -= 30
        xPos = xStart
      }
      else {
        xPos += button.frame.width + 5
      }
      
    }

    setup()
    
  }
  
  // MARK: Private Properties
  
  private var dataSource : ComboBoxDictDS = ComboBoxDictDS()
  
  private var first : Bool = true
  
  private var networkControllerDelegateId : Int = -1
  
  private var locomotive : Locomotive? {
    get {
      var result : Locomotive? = nil
      if let editorObject = dataSource.editorObjectAt(index: cboLocomotive.indexOfSelectedItem) {
        result = networkController.locomotives[editorObject.primaryKey]
      }
      return result
    }
  }
  
  // MARK: Private Methods
  
  private func setup() {
    
    var code : Int = -1
    
    if !first {
      
      if let editorObject = dataSource.editorObjectAt(index: cboLocomotive.indexOfSelectedItem) {
        code = editorObject.primaryKey
      }
    }
    
    cboLocomotive.deselectItem(at: cboLocomotive.indexOfSelectedItem)
    
    dataSource.dictionary = networkController.locomotives
    
    cboLocomotive.dataSource = dataSource

    if dataSource.numberOfItems(in: cboLocomotive) > 0 {
      if first {
        cboLocomotive.selectItem(at: 0)
        first = false
      }
      else {
        if let index = dataSource.indexWithKey(key: code) {
          cboLocomotive.selectItem(at: index)
        }
      }
    }
    
    setupLocomotive()
    
  }
  
  private func setupLocomotive() {
    
    if let loco = locomotive {
      
      swPower.state = loco.isInUse ? .on : .off
      
      switch loco.direction {
      case .forward:
        radForward.state = .on
        radReverse.state = .off
        break
      case .reverse:
        radForward.state = .off
        radReverse.state = .on
        break
      }
      
      vsThrottle.integerValue = loco.targetSpeed
      
      chkInertial.state = loco.isInertial ? .on : .off
      
    }
    else {
      
      swPower.state = .off
      
      radForward.state = .on
      radReverse.state = .off
      
      vsThrottle.integerValue = 0
      
      chkInertial.state = .on
      
    }
        
  }
  
  // MARK: NetworkControllerDelegate Methods
  
  func messengersUpdated(messengers: [NetworkMessenger]) {
  }
  
  func networkControllerUpdated(netwokController: NetworkController) {
    setup()
  }
  
  func statusUpdated(networkController: NetworkController) {
  }
  
  // MARK: Outlets & Actions
  
  @IBAction func buttonAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var cboLocomotive: NSComboBox!
  
  @IBAction func cboLocomotiveAction(_ sender: NSComboBox) {
    
    setupLocomotive()
    
  }
  
  @IBOutlet weak var swPower: NSSwitch!
  
  @IBAction func swPowerAction(_ sender: NSSwitch) {
    if let loco = locomotive {
      loco.isInUse = sender.state == .on
    }
  }
  
  @IBOutlet weak var radForward: NSButton!
  
  @IBAction func radForwardAction(_ sender: NSButton) {
    
    radForward.state = .on
    radReverse.state = .off
 
    if let loco = locomotive {
      loco.direction = radForward.state == .on ? .forward : .reverse
    }
    
  }
  
  @IBOutlet weak var radReverse: NSButton!
  
  @IBAction func radReverseAction(_ sender: NSButton) {
    
    radForward.state = .off
    radReverse.state = .on
 
    if let loco = locomotive {
      loco.direction = radForward.state == .on ? .forward : .reverse
    }
    
  }
  
  @IBOutlet weak var lblSpeed: NSTextField!
  
  @IBOutlet weak var lblDistance: NSTextField!
  
  @IBOutlet weak var vsThrottle: NSSlider!
  
  @IBAction func vsThrottleAction(_ sender: NSSlider) {
    if let loco = locomotive {
      loco.targetSpeed = sender.integerValue
    }
    lblTargetStep.stringValue = "\(sender.integerValue)"
  }
  
  @IBOutlet weak var chkInertial: NSButton!
  
  @IBAction func chkInerialAction(_ sender: NSButton) {
    
    if let loco = locomotive {
      loco.isInertial = chkInertial.state == .on
    }
  }
  
  @IBOutlet weak var lblTargetStep: NSTextField!
  
}
