//
//  OpSwDecoderType.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/02/2022.
//

import Foundation
import Cocoa

class OpSwDecoderView: NSTableCellView {

  // MARK: View Control
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    // Drawing code here.
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  // MARK: Private Properties
  
  private var _optionSwitch : OptionSwitch?
  
  // MARK: Public Properties
  
  public var defaultDecoderType : SpeedSteps {
    get {
      return SpeedSteps.selected(comboBox: cboDecoderType)
    }
    set(value) {
      SpeedSteps.select(comboBox: cboDecoderType, value: value)
    }
  }
  
  public var optionSwitch : OptionSwitch? {
    get {
      return _optionSwitch
    }
    set(value) {
      
      _optionSwitch = value
      
      SpeedSteps.populate(comboBox: cboDecoderType)
      
      if let opsw = _optionSwitch {
        defaultDecoderType = opsw.defaultDecoderType
      }
      
    }
  }

  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboDecoderType: NSComboBox!
  
  @IBAction func cboDecoderTypeAction(_ sender: NSComboBox) {
    optionSwitch?.newDefaultDecoderType = defaultDecoderType
  }
  
}

