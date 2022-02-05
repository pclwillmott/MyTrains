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
  
  // MARK: Public Properties
  
  public var state : OptionSwitchState = .thrown {
    didSet {
      radClosed.state = state == .closed ? .on : .off
      radThrown.state = state == .thrown ? .on : .off
    }
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var radThrown: NSButton!
  
  @IBAction func radThrownAction(_ sender: NSButton) {
  }
  
  @IBOutlet weak var radClosed: NSButton!
  
  @IBAction func radClosedAction(_ sender: NSButton) {
  }
  
}
