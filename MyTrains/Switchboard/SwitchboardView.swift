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
    
//    super.draw(dirtyRect)
    
    guard let switchboardPanel, let switchboardItems = switchboardPanel.switchboardItems else {
      return
    }

    if bounds.width <= bounds.height {
      cellSize = bounds.width / CGFloat(switchboardPanel.numberOfColumns)
    }
    else {
      cellSize = bounds.height / CGFloat(switchboardPanel.numberOfRows)
    }
    
    let lineWidth = cellSize * 0.1
    
    for (_, item) in switchboardItems {
      
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
  
  public var height : CGFloat {
    guard let switchboardPanel, let switchboardItems = switchboardPanel.switchboardItems else {
      return 0.0
    }
    var result : CGFloat = 0.0
    for (_, item) in switchboardItems {
      result = max(result,CGFloat(item.yPos))
    }
    return (result + 2.0) * cellSize
  }

  public var width : CGFloat {
    guard let switchboardPanel, let switchboardItems = switchboardPanel.switchboardItems else {
      return 0.0
    }
    var result : CGFloat = 0.0
    for (_, item) in switchboardItems {
      result = max(result,CGFloat(item.xPos))
    }
    return (result + 2.0) * cellSize
  }

  public var cellsHigh : Int {
    guard let switchboardPanel, let switchboardItems = switchboardPanel.switchboardItems else {
      return 0
    }
    var result = 0
    for (_, item) in switchboardItems {
      result = max(result,Int(item.yPos))
    }
    return result + 2
  }

  public var cellsWide : Int {
    guard let switchboardPanel, let switchboardItems = switchboardPanel.switchboardItems else {
      return 0
    }
    var result = 0
    for (_, item) in switchboardItems {
      result = max(result,Int(item.xPos))
    }
    return result + 2
  }


  internal var _switchboardPanel : SwitchboardPanelNode?
  
  public var switchboardPanel : SwitchboardPanelNode? {
    get {
      return _switchboardPanel
    }
    set(value) {
      _switchboardPanel = value
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
  
  internal func gridSquare(from: NSEvent) -> SwitchboardLocation {
    let cc = self.convert(from.locationInWindow, from: nil)
    let x = Int(cc.x / cellSize)
    let y = Int(cc.y / cellSize)
    return (x:x, y:y)
  }
  
  internal func getItem(event:NSEvent) -> SwitchboardItemNode? {
    guard let switchboardPanel, let switchboardItems = switchboardPanel.switchboardItems else {
      return nil
    }
    let gridSquare = gridSquare(from: event)
    for (_, item) in switchboardItems {
      if item.location == gridSquare {
        return item
      }
    }
    return nil
  }
  
  internal func getItem(x:Int, y:Int) -> SwitchboardItemNode? {
    guard let switchboardPanel, let switchboardItems = switchboardPanel.switchboardItems else {
      return nil
    }
    let test : SwitchboardLocation = (x:x, y:y)
    for (_, item) in switchboardItems {
      if item.location == test {
        return item
      }
    }
    return nil
  }

  internal func getItem(location:SwitchboardLocation) -> SwitchboardItemNode? {
    guard let switchboardPanel, let switchboardItems = switchboardPanel.switchboardItems else {
      return nil
    }
    for (_, item) in switchboardItems {
      if item.location == location {
        return item
      }
    }
    return nil
  }

}
