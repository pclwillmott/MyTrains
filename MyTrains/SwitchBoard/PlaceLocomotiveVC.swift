//
//  PlaceLocomotiveVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/08/2022.
//

import Foundation
import Cocoa

class PlaceLocomotiveVC: NSViewController, NSWindowDelegate {
   
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
    
 
  }
  
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
