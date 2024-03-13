//
//  FrameView.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/03/2024.
//

import Foundation
import AppKit

class FrameView: NSView {
  
  // MARK: Drawing Stuff
  
  override func draw(_ dirtyRect: NSRect) {
    
    let path = NSBezierPath()
    
    path.appendRect(bounds)
    
    NSColor.setStrokeColor(color: .gray)

    NSColor.setFillColor(color: .white)
    
    path.fill()
    
    path.stroke()
    
  }
  
}

