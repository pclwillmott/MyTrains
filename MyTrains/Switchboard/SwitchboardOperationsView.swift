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

      if let block = item.controlBlock {
        
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
      
      SwitchboardShape.drawShape(partType: item.itemType, orientation: item.orientation, location: item.location, lineWidth: lineWidth, cellSize: cellSize, isButton: false, isEnabled: true, offset: CGPoint(x: 0.0, y: 0.0), switchBoardItem: nil)

      if item.itemType.isTurnout || item.itemType.isSensor {
        
        SwitchboardShape.drawShape(partType: item.itemType, orientation: item.orientation, location: item.location, lineWidth: lineWidth, cellSize: cellSize, isButton: false, isEnabled: true, offset: CGPoint(x: 0.0, y: 0.0), switchBoardItem: item)
        
      }

    }

  }

  // MARK: Mouse Events
  
  override func mouseDown(with event: NSEvent) {
    
    if let item = getItem(event: event), item.itemType.isTurnout {
      
      let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
      let connections = item.itemType.connections
      
      var index = 0
      while index < connections.count {
        let route = connections[index]
        if !route.switchSettings.isEmpty, route.modifier == flags {
          item.setRoute(route: index)
          break
        }
        index += 1
      }
      
    }
    
  }
  
}
