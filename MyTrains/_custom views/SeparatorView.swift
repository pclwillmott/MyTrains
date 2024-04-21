//
//  SeparatorView.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/04/2024.
//

import Foundation
import AppKit

class SeparatorView: NSView {
  
  // MARK: Drawing Stuff
  
  override func draw(_ dirtyRect: NSRect) {
    
    let path = NSBezierPath()
    
    NSColor.setStrokeColor(color: .lightGray)

    path.lineWidth = 1
    
    let y = (bounds.minY + bounds.maxY) / 2
    
    path.move(to: NSMakePoint(0, y))
    
    path.line(to: NSMakePoint(bounds.maxX, y))
    
    path.stroke()
    
    alphaValue = 0.5
    
  }
  
}

