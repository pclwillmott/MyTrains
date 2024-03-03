//
//  PlaceLocomotiveVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/08/2022.
//

import Foundation
import AppKit

class PlaceLocomotiveVC: MyTrainsViewController {
   
  // MARK: Private Properties
  
  private var cboLocomotiveDS : ComboBoxDictDS = ComboBoxDictDS()
  
  // MARK: Public Properties
  
  public var switchBoardItem : SwitchBoardItem?
  
  public var isOrigin : Bool = true {
    didSet {
      self.view.window?.title = isOrigin ? "Set Origin" : "Set Destination"
    }
  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var cboLocomotive: NSComboBox!
  
  @IBAction func cboLocomotiveAction(_ sender: NSComboBox) {
  }
  
  @IBOutlet weak var btnSet: NSButton!
  
  @IBAction func btnSetAction(_ sender: NSButton) {
    
    self.view.window?.close()
    
  }
  
}
