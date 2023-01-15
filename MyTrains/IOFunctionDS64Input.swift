//
//  IOFunctionInput.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/01/2023.
//

import Foundation
import AppKit

public class IOFunctionDS64Input : IOFunction {
  
  // MARK: Public Properties
  
  override public var hasPropertySheet: Bool {
    get {
      return true
    }
  }
  
  // MARK: Public Properties
  
  override public var address : Int {
    get {
      if let device = ioDevice as? IODeviceDS64 {
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
    
    let x = ModalWindow.IOFunctionDS64InputPropertySheet
    let wc = x.windowController
    let vc = x.viewController(windowController: wc) as! IOFunctionDS64InputPropertySheetVC
    vc.ioFunction = self
    if let window = wc.window {
      NSApplication.shared.runModal(for: window)
      window.close()
    }

  }

}
