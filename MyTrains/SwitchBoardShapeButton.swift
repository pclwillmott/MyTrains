//
//  SwitchBoardShapeButton.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/04/2022.
//

import Foundation
import Cocoa

@IBDesignable
class SwitchBoardShapeButton: NSButton {

  // MARK: Drawing Stuff
  
  override func draw(_ dirtyRect: NSRect) {

    super.draw(dirtyRect)

    let cellSize = min(bounds.width, bounds.height)
    
    let lineWidth = cellSize * 0.1
 
    let path = NSBezierPath()
    
    path.appendRect(bounds)
    
    NSColor.windowBackgroundColor.setFill()
    
    path.fill()
    
    SwitchBoardShape.drawShape(partType: partType, orientation: 0, location: (x:0,y:0), lineWidth: lineWidth, cellSize: cellSize, isButton: true, isEnabled: isEnabled)
    
    if isEnabled {
      
      state == .on ? NSColor.setStrokeColor(color: .red) : NSColor.setStrokeColor(color: .clear)
      
      path.appendRect(frame)
      
      path.lineWidth = lineWidth
      
      path.stroke()
      
    }
    
    toolTip = partType.partName

  }
  
  // MARK : Public Properties
  
  public var partType : SwitchBoardPart = .straight {
    didSet {
      needsDisplay = true
    }
  }
  
  @IBInspectable
  public var partTypeRawValue : Int {
    get {
      return partType.rawValue
    }
    set(value) {
      if let part = SwitchBoardPart(rawValue: value) {
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
