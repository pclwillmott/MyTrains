//
//  LEDView.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/03/2024.
//

import Foundation
import AppKit

class LEDView: NSView {
  
  // MARK: Drawing Stuff
  
  override func draw(_ dirtyRect: NSRect) {
    
    guard state else {
      return
    }
    
    let path = NSBezierPath()

    path.lineWidth = 1.0
    
    path.appendArc(withCenter: NSMakePoint(self.frame.width / 2.0, self.frame.height / 2.0), radius: min(frame.width, frame.height) / 2.0, startAngle: 0.0, endAngle: 360.0)

    NSColor.setFillColor(color: fillColor)
    
    path.fill()

    NSColor.setStrokeColor(color: strokeColor)
    
    path.stroke()

  }
  
  // MARK: Private Properties
  
  private var timeoutTimer : Timer?
  
  // MARK: Public Properties
  
  public var fillColor : NSColor = .red
  
  public var strokeColor : NSColor = .red
  
  public var state : Bool = false {
    didSet {
      if state {
        startTimeoutTimer()
      }
      needsDisplay = true
    }
  }
  
  // MARK: Private Methods
  
  internal func startTimeoutTimer() {
    timeoutTimer = Timer.scheduledTimer(timeInterval: 0.010, target: self, selector: #selector(timeoutTimerAction), userInfo: nil, repeats: false)
    if let timeoutTimer {
      RunLoop.current.add(timeoutTimer, forMode: .common)
    }
    else {
      #if DEBUG
      debugLog("failed to create timeoutTimer")
      #endif
    }
  }
  
  @objc internal func timeoutTimerAction() {
    state = false
  }
  
}
