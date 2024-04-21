//
//  SwitchboardView.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/04/2024.
//

import Foundation
import AppKit

//@objc public protocol SwitchBoardViewDelegate {
//  @objc optional func groupChanged(groupNames: [String], selectedIndex: Int)
//  @objc optional func panelsChanged()
//}

//@IBDesignable
class SwitchboardView: NSView {
  
  // MARK: Drawing Stuff
  
  override func draw(_ dirtyRect: NSRect) {
    
    super.draw(dirtyRect)
    
    guard let switchboardPanel else {
      return
    }

    if bounds.width <= bounds.height {
      cellSize = bounds.width / CGFloat(switchboardPanel.numberOfColumns)
    }
    else {
      cellSize = bounds.height / CGFloat(switchboardPanel.numberOfRows)
    }
    
    let lineWidth = cellSize * 0.1
    
    for (_, item) in switchboardPanel.switchboardItems {
      
      SwitchboardShape.drawShape(partType: item.itemType, orientation: item.orientation, location: item.location, lineWidth: lineWidth, cellSize: cellSize, isButton: false, isEnabled: true, offset: CGPoint(x: 0.0, y: 0.0), switchBoardItem: nil)

    }
    
    if showGridLines {
      
      let path = NSBezierPath()
      
      path.lineWidth = 1
      
      NSColor.setStrokeColor(color: .gray)
   
      let yLength = CGFloat(switchboardPanel.numberOfRows) * cellSize
      
      for x in 0...switchboardPanel.numberOfColumns {
        let xPos = CGFloat(x) * cellSize
        path.move(to: NSMakePoint(xPos, 0))
        path.line(to: NSMakePoint(xPos, yLength))
      }
      
      let xLength = CGFloat(switchboardPanel.numberOfColumns) * cellSize
      
      for y in 0...switchboardPanel.numberOfRows {
        let yPos = CGFloat(y) * cellSize
        path.move(to: NSMakePoint(0, yPos))
        path.line(to: NSMakePoint(xLength, yPos))
      }
      
      path.stroke()

    }

  }
  
  // MARK: Private Properties
    
  internal var cellSize : CGFloat = 0.0

  // MARK: Public Properties
  
  public var switchboardPanel : SwitchboardPanelNode? {
    didSet {
      needsDisplay = true
    }
  }
  
  //@IBInspectable
  public var lineWidth : CGFloat = 3.0 {
    didSet {
      needsDisplay = true
    }
  }
  
  //@IBInspectable
  public var showGridLines : Bool = true {
    didSet {
      needsDisplay = true
    }
  }
  
  // MARK: Private Methods
  
  internal func gridSquare(from: NSEvent) -> SwitchBoardLocation {
    let cc = self.convert(from.locationInWindow, from: nil)
    let x = Int(cc.x / cellSize)
    let y = Int(cc.y / cellSize)
    return (x:x, y:y)
  }
  
  internal func getItem(event:NSEvent) -> SwitchboardItemNode? {
    guard let switchboardPanel else {
      return nil
    }
    let gridSquare = gridSquare(from: event)
    for (_, item) in switchboardPanel.switchboardItems {
      if item.location == gridSquare {
        return item
      }
    }
    return nil
  }
  
  internal func getItem(x:Int, y:Int) -> SwitchboardItemNode? {
    guard let switchboardPanel else {
      return nil
    }
    let test : SwitchBoardLocation = (x:x, y:y)
    for (_, item) in switchboardPanel.switchboardItems {
      if item.location == test {
        return item
      }
    }
    return nil
  }

}
