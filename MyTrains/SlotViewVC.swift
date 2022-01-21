//
//  SlotViewVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/01/2022.
//

import Foundation
import Cocoa

class SlotViewVC : NSViewController, NSWindowDelegate {
  
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
    
    cboCommandStationDS.dictionary = networkController.commandStations
    
    cboCommandStation.dataSource = cboCommandStationDS
    
    if cboCommandStation.numberOfItems > 0 {
      cboCommandStation.selectItem(at: 0)
    }
    
  }
  
  // MARK: Private Properties

  private var cboCommandStationDS : CommmandStationComboBoxDS = CommmandStationComboBoxDS()

  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboCommandStation: NSComboBox!
  
  @IBAction func cboCommandStationAction(_ sender: NSComboBox) {
  }
  
}
