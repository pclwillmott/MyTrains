//
//  OpSwTCV.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/02/2022.
//

import Foundation
import Cocoa

class OpSwTCV: NSTableCellView {

  // MARK: View Control
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    // Drawing code here.
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  // MARK: Private Properties
  
  private var _optionSwitch : CommandStationOptionSwitch?
  
  // MARK: Public Properties
  
  public var isConfigurationSlotMode : Bool = true
  
  public var state : OptionSwitchState  {
    get {
      return radClosed.state == .on ? .closed : .thrown
    }
    set(value) {
      radClosed.state = value == .closed ? .on : .off
      radThrown.state = value == .thrown ? .on : .off
    }
  }
  
  public var optionSwitch : CommandStationOptionSwitch? {
    get {
      return _optionSwitch
    }
    set(value) {
      _optionSwitch = value
      if let opsw = _optionSwitch {
        let enabled = (opsw.switchNumber <= 48 && opsw.switchNumber % 8 != 0) || !isConfigurationSlotMode
        if !enabled {
          lblThrown.textColor = .gray
          lblClosed.textColor = .gray
          radThrown.isEnabled = false
          radClosed.isEnabled = false
        }
        else {
          lblThrown.textColor = .black
          lblClosed.textColor = .black
          radThrown.isEnabled = true
          radClosed.isEnabled = true
        }
        
        lblThrown.stringValue = "t \(opsw.switchDefinition.thrownEffect != "" ? " - " : "")\(opsw.switchDefinition.thrownEffect)"
        lblClosed.stringValue = "c \(opsw.switchDefinition.closedEffect != "" ? " - " : "")\(opsw.switchDefinition.closedEffect)"
        state = opsw.state
      }
    }
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var radThrown: NSButton!
  
  @IBAction func radThrownAction(_ sender: NSButton) {
    radClosed.state = sender.state == .off ? .on : .off
    optionSwitch?.newState = state
  }
  
  @IBOutlet weak var radClosed: NSButton!
  
  @IBAction func radClosedAction(_ sender: NSButton) {
    radThrown.state = sender.state == .off ? .on : .off
    optionSwitch?.newState = state
  }
  
  @IBOutlet weak var lblThrown: NSTextField!
  
  @IBOutlet weak var lblClosed: NSTextField!
  
}
