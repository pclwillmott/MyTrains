//
//  SwitchBoardOperationsView.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/04/2022.
//

import Foundation
import Cocoa

class SwitchBoardOperationsView : SwitchBoardView {

  // MARK: Drawing Stuff
  
  override func draw(_ dirtyRect: NSRect) {
    
    if let layout = self.layout {

      let panel = layout.switchBoardPanels[panelId]
      
      if bounds.width <= bounds.height {
        cellSize = bounds.width / CGFloat(panel.numberOfColumns)
      }
      else {
        cellSize = bounds.height / CGFloat(panel.numberOfRows)
      }

      for (_, block) in layout.operationalBlocks {
        
        if block.isOccupied, let group = layout.operationalGroups[block.groupId] {
          
          for item in group {
            
            let path = NSBezierPath()
            
            let x = CGFloat(item.location.x) * cellSize
            let y = CGFloat(item.location.y) * cellSize
            
            let rect = NSRect(x: x, y: y, width: cellSize, height: cellSize)
            
            path.appendRect(rect)
            
            NSColor.setFillColor(color: .orange)
            
            path.fill()

          }
          
        }
        
      }
      
    }
    
    super.draw(dirtyRect)
    
  }

  // MARK: Mouse Events
  
  override func mouseDown(with event: NSEvent) {

    if let layout = self.layout {
      
      switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
        
      case [.control]:
        if let item = getItem(event: event), let turnoutSwitch = layout.operationalTurnouts[item.primaryKey] {
          turnoutSwitch.setThrown()
        }
      case [.option]:
        if let item = getItem(event: event), let turnoutSwitch = layout.operationalTurnouts[item.primaryKey] {
          turnoutSwitch.toggle()
        }
      case [.shift]:
        if let item = getItem(event: event), let turnoutSwitch = layout.operationalTurnouts[item.primaryKey] {
          turnoutSwitch.setClosed()
        }
      default:
        break
      }

  //    needsDisplay = true

    }
    
  }

}
