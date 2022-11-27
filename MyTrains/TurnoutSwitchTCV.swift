//
//  TurnoutSwitchTCV.swift
//  MyTrains
//
//  Created by Paul Willmott on 31/07/2022.
//

import Foundation
import Cocoa

class TurnoutSwitchTCV: NSTableCellView {

  // MARK: View Control

  override func draw(_ dirtyRect: NSRect) {
      super.draw(dirtyRect)

      // Drawing code here.
  }

  override func prepareForReuse() {
    super.prepareForReuse()
  }
  
  // MARK: Private Properties
  
  private var cboTurnoutDS : ComboBoxDictDS = ComboBoxDictDS()
  
  // MARK: Public Properties
  
  public var turnoutSwitch : TurnoutSwitch? {
    didSet {
      if let t = turnoutSwitch {
        txtSwitchAddress.integerValue = t.switchAddress
      }
    }
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var txtSwitchAddress: NSTextField!
  
  @IBAction func txtSwitchAddressAction(_ sender: NSTextField) {
    if let t = turnoutSwitch {
      t.nextSwitchAddress = sender.integerValue
    }
  }
  
}
