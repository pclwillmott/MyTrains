//
//  SwitchboardShapeButton.swift
//  MyTrains
//
//  Created by Paul Willmott on 17/04/2024.
//

import Foundation
import AppKit

@IBDesignable
class SwitchboardShapeButton: NSButton {

  // MARK: Drawing Stuff
  
  override func draw(_ dirtyRect: NSRect) {

    super.draw(dirtyRect)

    let cellSize = min(bounds.width, bounds.height)
    
    let lineWidth = cellSize * 0.1
 
    let path = NSBezierPath()
    
    path.appendRect(bounds)
    
    NSColor.windowBackgroundColor.setFill()
    
    path.fill()
    
    SwitchboardShape.drawShape(partType: partType, orientation: .deg0, location: (x:0,y:0), lineWidth: lineWidth, cellSize: cellSize, isButton: true, isEnabled: isEnabled, offset: CGPoint(x: 0.0, y: 0.0), switchBoardItem: nil)
    
    if isEnabled {
      
      state == .on ? NSColor.setStrokeColor(color: .red) : NSColor.setStrokeColor(color: .clear)
      
      path.lineWidth = lineWidth
      
      path.stroke()
      
    }
    
    toolTip = partType.title

  }
  
  // MARK: Public Properties
  
  public var partType : SwitchboardItemType = .none {
    didSet {
      needsDisplay = true
    }
  }
  
  @IBInspectable
  public var partTypeRawValue : UInt16 {
    get {
      return partType.rawValue
    }
    set(value) {
      if let part = SwitchboardItemType(rawValue: value) {
        partType = part
      }
      else {
        partType = .none
      }
    }
  }
  
  override var isEnabled: Bool {
    get {
      return super.isEnabled
    }
    set(value) {
      super.isEnabled = value
      needsDisplay = true
    }
  }
  
}
