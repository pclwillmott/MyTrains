//
//  AddressManagerVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 28/07/2022.
//

import Foundation

import Foundation
import Cocoa

class AddressManagerVC: NSViewController, NSWindowDelegate {

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
  
}
