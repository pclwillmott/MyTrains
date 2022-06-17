//
//  SwitchBoardView.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/04/2022.
//

import Foundation
import Cocoa

@objc public protocol SwitchBoardViewDelegate {
  @objc optional func groupChanged(groupNames: [String], selectedIndex: Int)
  @objc optional func panelsChanged()
}

@IBDesignable
class SwitchBoardView: NSView {
  
  // MARK: Drawing Stuff
  
  override func draw(_ dirtyRect: NSRect) {
    
    super.draw(dirtyRect)
    
    guard panels.count > 0 else {
      return
    }
    
    let panel = panels[panelId]
    
    if bounds.width <= bounds.height {
      cellSize = bounds.width / CGFloat(panel.numberOfColumns)
    }
    else {
      cellSize = bounds.height / CGFloat(panel.numberOfRows)
    }
    
    let lineWidth = cellSize * 0.1
    
    for kv in items {
      
      let item = kv.value
      
      if item.panelId == self.panelId {
      
        SwitchBoardShape.drawShape(partType: item.itemPartType, orientation: item.orientation, location: item.location, lineWidth: lineWidth, cellSize: cellSize, isButton: false, isEnabled: true)
        
      }
      
    }
    
    if true || showGridLines {
      
      let path = NSBezierPath()
      
      path.lineWidth = 1
      
      NSColor.setStrokeColor(color: .gray)
   
      let yLength = CGFloat(panel.numberOfRows) * cellSize
      
      for x in 0...panel.numberOfColumns {
        let xPos = CGFloat(x) * cellSize
        path.move(to: NSMakePoint(xPos, 0))
        path.line(to: NSMakePoint(xPos, yLength))
      }
      
      let xLength = CGFloat(panel.numberOfColumns) * cellSize
      
      for y in 0...panel.numberOfRows {
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
  
  public var items : [Int:SwitchBoardItem] = [:] {
    didSet {
      needsDisplay = true
    }
  }
  
  public var panels : [SwitchBoardPanel] = [] {
    didSet {
      needsDisplay = true
      delegate?.panelsChanged?()
    }
  }
  
  @IBInspectable
  public var lineWidth : CGFloat = 3.0 {
    didSet {
      needsDisplay = true
    }
  }
  
  @IBInspectable
  public var showGridLines : Bool = true {
    didSet {
      needsDisplay = true
    }
  }
  
  public var panelId : Int = 0 {
    didSet {
      needsDisplay = true
      delegate?.panelsChanged?()
    }
  }
  
  public var delegate : SwitchBoardViewDelegate?
  
  // MARK: Private Methods
  
  internal func gridSquare(from: NSEvent) -> SwitchBoardLocation {
    let cc = self.convert(from.locationInWindow, from: nil)
    let x = Int(cc.x / cellSize)
    let y = Int(cc.y / cellSize)
    return (x:x, y:y)
  }
  
  internal func getItem(event:NSEvent) -> SwitchBoardItem? {
    let gridSquare = gridSquare(from: event)
    let key = SwitchBoardItem.createKey(panelId: panelId, location: gridSquare, nextAction: .noAction)
    if let item = items[key] {
      return item
    }
    return nil
  }
  
  internal func getItem(x:Int, y:Int) -> SwitchBoardItem? {
    let key = SwitchBoardItem.createKey(panelId: panelId, location: (x:x, y:y), nextAction: .noAction)
    if let item = items[key] {
      return item
    }
    return nil
  }

}
