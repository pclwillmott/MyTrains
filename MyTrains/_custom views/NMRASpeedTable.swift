//
//  NMRASpeedTable.swift
//  MyTrains
//
//  Created by Paul Willmott on 09/08/2024.
//

import Foundation
import AppKit

class NMRASpeedTable: NSView {
  
  // MARK: Drawing Stuff
  
  override func draw(_ dirtyRect: NSRect) {
    
    super.draw(dirtyRect)

    NSColor.white.setFill()
    bounds.fill()

    NSColor.black.setStroke()

    let path = NSBezierPath()
    path.move(to: NSMakePoint(0, 0))
    path.line(to: NSMakePoint(0, bounds.height))
    path.line(to: NSMakePoint(bounds.width, bounds.height))
    path.line(to: NSMakePoint(bounds.width, 0))
    path.close()
    path.stroke()

    guard let decoder else {
      return
    }
    
    if speedTableIndex == nil {
      values.removeAll()
      values = decoder.getProperty(property: .esuSpeedTable)
    }

    var lastX  : CGFloat = 0
    var lastY : CGFloat = 0
    
    for index in 0 ... 27 {
      
      let value = values[index]
      
      let dx = boxSize + CGFloat(index) * scaleWidth
      let dy = boxSize + CGFloat(value) * scaleHeight
      
      if index > 0 {
        
        let path = NSBezierPath()

        path.move(to: NSMakePoint(lastX, lastY))
        path.line(to: NSMakePoint(dx, dy))
        
        path.stroke()

      }
      
      lastX = dx
      lastY = dy
      
    }

    for index in 0 ... 27 {
      
      let value = values[index]
      
      let dx = boxSize + CGFloat(index) * scaleWidth
      let dy = boxSize + CGFloat(value) * scaleHeight
      
      let dxLeft = dx - boxSize / 2.0
      let dxRight = dx + boxSize / 2.0
      
      let dyTop = dy + boxSize / 2.0
      let dyBottom = dy - boxSize / 2.0
      
      let path = NSBezierPath()
      
      path.move(to: NSMakePoint(dxLeft, dyBottom))
      path.line(to: NSMakePoint(dxLeft, dyTop))
      path.line(to: NSMakePoint(dxRight, dyTop))
      path.line(to: NSMakePoint(dxRight, dyBottom))
      path.close()
      
      if (index + 1) == (speedTableIndex == nil ? decoder.speedTableIndex : speedTableIndex!) {
        NSColor.systemBlue.setFill()
      }
      else {
        NSColor.white.setFill()
      }
      
      path.fill()
      path.stroke()

    }

  }
  
  // MARK: Private Properties
  
  private var values : [UInt8] = []
  
  private var speedTableIndex : Int?
  
  private var boxSize : CGFloat {
    return 11
  }
  
  private var scaleHeight : CGFloat {
    return (bounds.height - boxSize * 2) / 256
  }
  
  private var scaleWidth : CGFloat {
    return (bounds.width - boxSize * 2) / 27
  }

  // MARK: Public Properties
  
  public weak var decoder : Decoder?
  
  // MARK: Private Methods
  
  private func setValue(speedTableIndex:Int, value:UInt8) {
  
    values[speedTableIndex - 1] = value
    
    if speedTableIndex > 1 {
      for index in 1 ... speedTableIndex - 1 {
        values[index - 1] = min(values[index - 1], value)
      }
    }
    if speedTableIndex < 28 {
      for index in speedTableIndex + 1 ... 28 {
        values[index - 1] = max(values[index - 1], value)
      }
    }

  }
  
  override func mouseDown(with event: NSEvent) {
    if let pos = position(from: event) {
      speedTableIndex = pos.x + 1
    }
  }

  override func mouseDragged(with event: NSEvent) {
    if let speedTableIndex {
      let cc = self.convert(event.locationInWindow, from: nil)
      setValue(speedTableIndex: speedTableIndex, value: UInt8(max(1,min(255,round((cc.y - boxSize) / scaleHeight)))))
      needsDisplay = true
    }
  }
  
  override func mouseUp(with event: NSEvent) {

    if let speedTableIndex, let decoder {
      let cc = self.convert(event.locationInWindow, from: nil)
      setValue(speedTableIndex: speedTableIndex, value: UInt8(max(1,min(255,round((cc.y - boxSize) / scaleHeight)))))
      needsDisplay = true
      decoder.setProperty(property: .esuSpeedTable, values: values)
      decoder.setValue(property: .speedTableIndex, string: "\(speedTableIndex)")
      self.speedTableIndex = nil
    }
    
  }

  internal func position(from: NSEvent) -> (x:Int, y:UInt8)? {
    
    let cc = self.convert(from.locationInWindow, from: nil)
    
    let x = cc.x
    
    let y = cc.y
    
    for index in 0 ... 27 {
      
      let value = values[index]
      
      let dx = boxSize + CGFloat(index) * scaleWidth
      let dy = boxSize + CGFloat(value) * scaleHeight
      
      let dxLeft = dx - boxSize / 2.0
      let dxRight = dx + boxSize / 2.0
      
      let dyTop = dy + boxSize / 2.0
      let dyBottom = dy - boxSize / 2.0
      
      if x >= dxLeft && x <= dxRight && y >= dyBottom && y <= dyTop {
        return (index, value)
      }
      
    }

    return nil
    
  }

}
