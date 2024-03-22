//
//  CDIElementView.swift
//  MyTrains
//
//  Created by Paul Willmott on 20/12/2023.
//

import Foundation
import AppKit

class CDIView: NSView {
  
  // MARK: Destructors
  
  deinit {
    subviews.removeAll()
  }
  
  // MARK: Drawing Stuff
  
  override func draw(_ dirtyRect: NSRect) {
    
    let path = NSBezierPath()
    
    path.appendRect(bounds)
    
    NSColor.setStrokeColor(color: .gray)

//    NSColor.setFillColor(color: .darkGray)
    
//    path.fill()
    
    path.stroke()
    
    setup()

  }
  
  // MARK: Private & Internal Properties
  
  internal let parentGap : CGFloat = 20.0
  
  internal let siblingGap : CGFloat = 8.0

  internal var needsInit = true
  
  // MARK: Private & Internal Methods
  
  internal func setup() {
    
  }
  
}

