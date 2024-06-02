//
//  SwitchboardOperationsView.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/04/2024.
//

import Foundation
import AppKit

class SwitchboardOperationsView : SwitchboardView {
  
  // MARK: Drawing Stuff
  
  override func draw(_ dirtyRect: NSRect) {
    
    guard let switchboardPanel else {
      return
    }
    
    if bounds.width <= bounds.height {
      cellSize = bounds.width / CGFloat(switchboardPanel.numberOfColumns)
    }
    else {
      cellSize = bounds.height / CGFloat(switchboardPanel.numberOfRows)
    }
    
    for (_, block) in switchboardPanel.switchboardBlocks {
      
      if block.isBlockOccupied || block.isTrackFaulted {
        
        for (_, item) in switchboardPanel.switchboardItems {
          
          if item.groupId == block.nodeId {
            
            let path = NSBezierPath()
            
            let x = CGFloat(item.location.x) * cellSize
            let y = CGFloat(item.location.y) * cellSize
            
            let rect = NSRect(x: x, y: y, width: cellSize, height: cellSize)
            
            path.appendRect(rect)
            
            if block.isBlockOccupied {
              NSColor.setFillColor(color: .orange)
              path.fill()
            }
            
            if block.isTrackFaulted {
              NSColor.setStrokeColor(color: .red)
              path.lineWidth = cellSize * 0.1
              path.stroke()
            }
            
          }
          
        }
        
      }
      
    }
    
    super.draw(dirtyRect)
    
    if bounds.width <= bounds.height {
      cellSize = bounds.width / CGFloat(switchboardPanel.numberOfColumns)
    }
    else {
      cellSize = bounds.height / CGFloat(switchboardPanel.numberOfRows)
    }
    
    let lineWidth = cellSize * 0.1
    
    for (_, item) in switchboardPanel.switchboardItems {
      
      if item.isTurnout || item.isSensor {
        
        SwitchboardShape.drawShape(partType: item.itemType, orientation: item.orientation, location: item.location, lineWidth: lineWidth, cellSize: cellSize, isButton: false, isEnabled: true, offset: CGPoint(x: 0.0, y: 0.0), switchBoardItem: item)
        
      }
      
    }
    
  }

  // MARK: Mouse Events
  
  override func mouseDown(with event: NSEvent) {
  }

}
