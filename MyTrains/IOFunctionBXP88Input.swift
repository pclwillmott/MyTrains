//
//  IOFunctionBXP88Input.swift
//  MyTrains
//
//  Created by Paul Willmott on 12/01/2023.
//

import Foundation
import AppKit

public class IOFunctionBXP88Input : IOFunction {
  
  // MARK: Public Properties
  
  override public var hasPropertySheet: Bool {
    get {
      return true
    }
  }

  override public var address : Int {
    get {
      if let device = ioDevice as? IODeviceBXP88 {
        return device.baseSensorAddress + ioChannel.ioChannelNumber - 1
      }
      return _address
    }
    set(value) {
      _ = value
      _address = address
    }
  }

  // MARK: Public Methods
  
  override public func displayString() -> String {
    return "\(super.displayString()) (\(address))"
  }
  
  override public func propertySheet() {
    
    let x = ModalWindow.IOFunctionBXP88InputPropertySheet
    let wc = x.windowController
    let vc = x.viewController(windowController: wc) as! IOFunctionBXP88InputPropertySheetVC
    vc.ioFunction = self
    if let window = wc.window {
      NSApplication.shared.runModal(for: window)
      window.close()
    }

  }

}
