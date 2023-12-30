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
    
    var path = NSBezierPath()
    
    path.appendRect(bounds)
    
    NSColor.setStrokeColor(color: .gray)

    path.stroke()
    
    setup()

  }
  
  // MARK: Private & Internal Properties
  
  internal let gap : CGFloat = 5.0

  internal var needsInit = true
  
  // MARK: Private & Internal Methods
  
  internal func viewType() -> OpenLCBCDIViewType? {
    return nil
  }
  
  internal func setup() {
    
  }
  
}

