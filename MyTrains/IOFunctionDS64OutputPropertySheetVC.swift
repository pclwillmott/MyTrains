//
//  IOFunctionDS64OutputPropertySheetVC.swift
//  MyTrains
//
//  Created by Paul Willmott on 15/01/2023.
//

import Foundation
import Cocoa

class IOFunctionDS64OutputPropertySheetVC: NSViewController, NSWindowDelegate {
  
  // MARK: Window & View Control
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  func windowShouldClose(_ sender: NSWindow) -> Bool {
    return true
  }
  
  func windowWillClose(_ notification: Notification) {
    stopModal()
  }
  
  override func viewWillAppear() {
    
    self.view.window?.delegate = self
    
    reloadData()
    
  }
 
  // MARK: Public Properties
  
  public var ioFunction : IOFunctionDS64Output?
  
  // MARK: Public Methods
  
  public func reloadData() {
    
    if let ioFunction = self.ioFunction {
      view.window?.title = "\(ioFunction.displayString())"
      txtSwitchAddress.stringValue = "\(ioFunction.address)"
    }

  }
  
  // MARK: Outlets & Actions
  
  @IBOutlet weak var txtSwitchAddress: NSTextField!
  
  @IBAction func btnSaveAction(_ sender: NSButton) {
    ioFunction?.address = txtSwitchAddress.integerValue
    ioFunction?.save()
    view.window?.close()
  }
  
}
