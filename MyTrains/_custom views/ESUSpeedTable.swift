//
//  ESUSpeedTable.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/07/2024.
//

import Foundation
import AppKit

class ESUSpeedTable: NSView {
  
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
      for index in 0 ... 27 {
        values.append(decoder.getUInt8(cv: .cv_000_000_067 + index)!)
      }
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
      else if index == 0 || index == 27 {
        NSColor.lightGray.setFill()
      }
      else {
        NSColor.white.setFill()
      }
      
      path.fill()
      path.stroke()

    }
    /*
    if isDrag {
      
      let dx = boxSize + CGFloat(decoder.speedTableIndex - 1) * scaleWidth
      let dy = boxSize + CGFloat(dragValue) * scaleHeight
      
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
      
      NSColor.orange.setFill()

      path.fill()
      path.stroke()

    }
*/

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
    return (bounds.width - boxSize / 3) / 28
  }

  // MARK: Public Properties
  
  public var decoder : Decoder?
  
  // MARK: Private Methods
  
  private func setValue(speedTableIndex:Int, value:UInt8) {
  
    values[speedTableIndex - 1] = value
    
    if speedTableIndex > 2 {
      for index in 2 ... speedTableIndex - 1 {
        values[index - 1] = min(values[index - 1], value)
      }
    }
    if speedTableIndex < 27 {
      for index in speedTableIndex + 1 ... 27 {
        values[index - 1] = max(values[index - 1], value)
      }
    }

  }
  
  override func mouseDown(with event: NSEvent) {

    speedTableIndex = nil
    
    if let pos = position(from: event), let decoder {
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
      for index in 0 ... values.count - 1 {
        decoder.setUInt8(cv: .cv_000_000_067 + index, value: values[index])
      }
      self.speedTableIndex = nil
      decoder.speedTableIndex = speedTableIndex
    }
    
  }

  internal func position(from: NSEvent) -> (x:Int, y:UInt8)? {
    
    if let decoder {
      
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
      
    }
    
    return nil
    
  }

}