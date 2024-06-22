//
//  SwitchboardSpeedProfilerView.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/06/2024.
//

import Foundation
import AppKit

class SwitchboardSpeedProfilerView: SwitchboardView {
  
  // MARK: Drawing Stuff
  
  override func draw(_ dirtyRect: NSRect) {
 
    guard let switchboardPanel, let switchboardItems = switchboardPanel.switchboardItems else {
      return
    }
    
//    if bounds.width <= bounds.height {
      cellSize = bounds.width / CGFloat(cellsWide)
//    }
//    else {
//      cellSize = bounds.height / CGFloat(cellsHigh)
//    }
    
    let lineWidth = cellSize * 0.1
    
    for (_, item) in switchboardItems {

      if let speedProfile, speedProfile.route != 0, let layout = appNode?.layout, layout.loopNodes.count >= speedProfile.route {
        
        if let block = item.controlBlock {
          
          let path = NSBezierPath()
          
          let x = CGFloat(item.location.x) * cellSize
          let y = CGFloat(item.location.y) * cellSize
          
          let rect = NSRect(x: x, y: y, width: cellSize, height: cellSize)
          
          path.appendRect(rect)
          
          if layout.loopNodes[Int(speedProfile.route) - 1].contains(block.nodeId) {
            NSColor.setFillColor(color: .blue)
            path.fill()
          }
          
        }
      }
            
      SwitchboardShape.drawShape(partType: item.itemType, orientation: item.orientation, location: item.location, lineWidth: lineWidth, cellSize: cellSize, isButton: false, isEnabled: true, offset: CGPoint(x: 0.0, y: 0.0), switchBoardItem: nil)
      
      if item.isTurnout || item.isSensor {
        
        SwitchboardShape.drawShape(partType: item.itemType, orientation: item.orientation, location: item.location, lineWidth: lineWidth, cellSize: cellSize, isButton: false, isEnabled: true, offset: CGPoint(x: 0.0, y: 0.0), switchBoardItem: item)
        
      }
      
    }

  }
  
  // MARK: Public Properties
  
  public var speedProfile : SpeedProfile? {
    didSet {
      needsDisplay = true
    }
  }
  
  // MARK: Mouse Events
  
  override func mouseDown(with event: NSEvent) {
    
    if let item = getItem(event: event), item.itemType.isGroup {
      
      let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
      let connections = item.itemType.connections
      
      if !item.doNotUseForSpeedProfiling {
       
        switch flags {
        case [.control]:
          if let speedProfile, speedProfile.routeType == .straight {
            speedProfile.endBlockId = item.nodeId
          }
        default:
          speedProfile?.startBlockId = item.nodeId
        }
        
        needsDisplay = true
        
      }
      
    }
    
  }

}

