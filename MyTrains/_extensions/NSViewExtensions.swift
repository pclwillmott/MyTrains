//
//  NSViewExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/04/2024.
//

import Foundation
import AppKit

extension NSView {
  
  public var backgroundColor : CGColor? {
    get {
      wantsLayer = true
      return layer?.backgroundColor
    }
    set(value) {
      wantsLayer = true
      layer?.backgroundColor = value
    }
  }

}
