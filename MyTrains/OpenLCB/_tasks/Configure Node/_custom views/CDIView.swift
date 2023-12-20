//
//  CDIElementView.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/12/2023.
//

import Foundation
import AppKit

class CDIView: NSView {
  
  // MARK: Drawing Stuff
  
  override func draw(_ dirtyRect: NSRect) {
  }
  
  // MARK: Private & Internal Methods
  
  internal func viewType() -> OpenLCBCDIViewType? {
    return nil
  }
  
}

