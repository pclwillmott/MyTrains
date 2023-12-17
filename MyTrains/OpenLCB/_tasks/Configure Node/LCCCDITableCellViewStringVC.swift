//
//  LCCCDITableCellViewVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/04/2023.
//

import Foundation
import Cocoa

class LCCCDITableCellViewStringVC: NSTableCellView {

  // MARK: Window & View Control
  
  override func draw(_ dirtyRect: NSRect) {
      super.draw(dirtyRect)

      // Drawing code here.
  }

  // MARK: Private Properties
  
  private var _field : LCCCDIElement?
  
  // MARK: Public Properties
  
  public var field : LCCCDIElement? {
    get {
      return _field
    }
    set(value) {
      _field = value
      if let field = _field {
        boxName.title = field.name
        lblDescription.stringValue = field.description
        txtString.stringValue = field.stringValue
      }
    }
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var boxName: NSBox!
  
  @IBOutlet weak var lblDescription: NSTextField!
  
  @IBOutlet weak var txtString: NSTextField!
  
  @IBAction func txtStringAction(_ sender: NSTextField) {
  }
  
}
