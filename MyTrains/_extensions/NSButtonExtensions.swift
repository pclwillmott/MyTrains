//
//  NSButtonExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/06/2022.
//

import Foundation
import AppKit

extension NSButton {
  
  // MARK: Public Properties
  
  public var boolValue : Bool {
    get {
      return state == .on
    }
    set(value) {
      state = value ? .on : .off
    }
  }
  
}
