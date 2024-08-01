//
//  ThreeValueSpeedTable.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/08/2024.
//

import Foundation
import AppKit

class ThreeValueSpeedTable: NSView {
  
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
    
    if !isDrag {
      values.removeAll()
      values = decoder.getProperty(property: .threeValueSpeedTable)
    }

    var lastX  : CGFloat = 0
    var lastY : CGFloat = 0
    
    for index in 0 ... 2 {
      
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

    for index in 0 ... 2 {
      
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
      
      if index == speedTableIndex {
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
  
  private var speedTableIndex : Int = 0
  
  private var isDrag : Bool = false
  
  private var boxSize : CGFloat {
    return 11
  }
  
  private var scaleHeight : CGFloat {
    return (bounds.height - boxSize * 2) / 256
  }
  
  private var scaleWidth : CGFloat {
    return (bounds.width - boxSize * 2 ) / 2
  }

  // MARK: Public Properties
  
  public weak var decoder : Decoder?
  
  // MARK: Private Methods
  
  private func setValue(speedTableIndex:Int, value:UInt8) {
  
    values[speedTableIndex] = value
    
    if speedTableIndex > 0 {
      for index in 0 ... speedTableIndex - 1 {
        values[index] = min(values[index], value)
      }
    }
    if speedTableIndex < 2 {
      for index in speedTableIndex + 1 ... 2 {
        values[index] = max(values[index], value)
      }
    }

  }
  
  override func mouseDown(with event: NSEvent) {
    if let pos = position(from: event) {
      speedTableIndex = pos.x
      isDrag = true
    }
  }

  override func mouseDragged(with event: NSEvent) {
    if isDrag {
      let cc = self.convert(event.locationInWindow, from: nil)
      setValue(speedTableIndex: speedTableIndex, value: UInt8(max(1,min(255,round((cc.y - boxSize) / scaleHeight)))))
      needsDisplay = true
    }
  }
  
  override func mouseUp(with event: NSEvent) {

    if isDrag, let decoder {
      let cc = self.convert(event.locationInWindow, from: nil)
      setValue(speedTableIndex: speedTableIndex, value: UInt8(max(1,min(255,round((cc.y - boxSize) / scaleHeight)))))
      needsDisplay = true
      decoder.setProperty(property: .threeValueSpeedTable, values: values)
      isDrag = false
    }
    
  }

  internal func position(from: NSEvent) -> (x:Int, y:UInt8)? {
    
    let cc = self.convert(from.locationInWindow, from: nil)
    
    let x = cc.x
    
    let y = cc.y
    
    for index in 0 ... 2 {
      
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
