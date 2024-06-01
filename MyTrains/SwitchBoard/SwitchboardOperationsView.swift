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
    
    guard let switchboardPanel, let appLayoutId, let layout = appDelegate.networkLayer?.virtualNodeLookup[appLayoutId] as? LayoutNode else {
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
        
        for (key, item) in switchboardPanel.switchboardItems {
          
          if item.groupId == block.nodeId {
            
            let path = NSBezierPath()
            
            let x = CGFloat(item.location.x) * cellSize
            let y = CGFloat(item.location.y) * cellSize
            
            let rect = NSRect(x: x, y: y, width: cellSize, height: cellSize)
            
            path.appendRect(rect)
            
            NSColor.setFillColor(color: block.isTrackFaulted ? .red : .orange)
            
            path.fill()
            
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
    /*
     if let item = getItem(event: event) {
     
     switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
     
     case [.control]:
     if item.itemPartType == .block {
     let vc = MyTrainsWindow.placeLocomotive.viewController as! PlaceLocomotiveVC
     vc.switchBoardItem = item
     vc.isOrigin = false
     vc.showWindow()
     }
     case [.option]:
     break
     case [.shift]:
     if item.itemPartType == .block {
     let vc = MyTrainsWindow.placeLocomotive.viewController as! PlaceLocomotiveVC
     vc.switchBoardItem = item
     vc.isOrigin = true
     vc.showWindow()
     }
     default:
     if item.isTurnout {
     item.nextTurnoutConnection()
     }
     }
     
     }
     
     */
    //    needsDisplay = true
    
    
  }


}
