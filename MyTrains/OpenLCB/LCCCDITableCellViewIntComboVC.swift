//
//  LCCCDITableCellViewIntComboVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/04/2023.
//

import Foundation
import Cocoa

class LCCCDITableCellViewIntComboVC: NSTableCellView {
  
  // MARK: Window & View Control
  
  override func draw(_ dirtyRect: NSRect) {
    super.draw(dirtyRect)
    
    // Drawing code here.
  }
  
  // MARK: Private Properties
  
  private var _field : LCCCDIElement?
  
  private var map : LCCCDIMap?
  
  // MARK: Public Properties
  
  public var field : LCCCDIElement? {
    get {
      return _field
    }
    set(value) {
      _field = value
      if let field = _field {
        map = LCCCDIMap(field: field)
        boxName.title = field.name
        lblDescription.stringValue = field.description
        map!.populate(comboBox: cboMap)
        map!.selectItem(comboBox: cboMap, property: field.stringValue)
      }
    }
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var boxName: NSBox!
  
  @IBOutlet weak var lblDescription: NSTextField!
  
  @IBOutlet weak var cboMap: NSComboBox!
  
  @IBAction func cboMapAction(_ sender: NSComboBox) {
    
    if let string = map!.selectedItem(comboBox: sender) {
      field?.stringValue = string
    }
  }
  
}
