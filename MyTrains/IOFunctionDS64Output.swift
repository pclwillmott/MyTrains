//
//  IOFunctionOutput.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2023.
//

import Foundation
import AppKit

public class IOFunctionDS64Output : IOFunction {
 
  // MARK: Public Properties
  
  override public var hasPropertySheet: Bool {
    get {
      return true
    }
  }
  
  // MARK: Public Methods
  
  override public func displayString() -> String {
    return "\(super.displayString()) (\(address))"
  }
  
  override public func propertySheet() {
    
    let x = ModalWindow.IOFunctionDS64OutputPropertySheet
    let wc = x.windowController
    let vc = x.viewController(windowController: wc) as! IOFunctionDS64OutputPropertySheetVC
    vc.ioFunction = self
    if let window = wc.window {
      NSApplication.shared.runModal(for: window)
      window.close()
    }

  }

}
