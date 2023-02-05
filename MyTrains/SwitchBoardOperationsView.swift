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
        
        if block.isOccupied || block.isTrackFault, let group = layout.operationalGroups[block.groupId] {
          
          for item in group {
            
            let path = NSBezierPath()
            
            let x = CGFloat(item.location.x) * cellSize
            let y = CGFloat(item.location.y) * cellSize
            
            let rect = NSRect(x: x, y: y, width: cellSize, height: cellSize)
            
            path.appendRect(rect)
            
            NSColor.setFillColor(color: block.isTrackFault ? .red : .orange)
            
            path.fill()

          }
          
        }
        
      }
      
    }
    
    super.draw(dirtyRect)
    
    if let layout = self.layout {
      
      let panel = layout.switchBoardPanels[panelId]
      
      if bounds.width <= bounds.height {
        cellSize = bounds.width / CGFloat(panel.numberOfColumns)
      }
      else {
        cellSize = bounds.height / CGFloat(panel.numberOfRows)
      }
      
      let lineWidth = cellSize * 0.1
      
      for (_, item) in layout.switchBoardItems {
        
        if item.panelId == self.panelId && (item.isTurnout || item.isFeedback) {
          
          SwitchBoardShape.drawShape(partType: item.itemPartType, orientation: item.orientation, location: item.location, lineWidth: lineWidth, cellSize: cellSize, isButton: false, isEnabled: true, offset: CGPoint(x: 0.0, y: 0.0), switchBoardItem: item)
          
        }
        
      }
      
    }
    
  }

  // MARK: Mouse Events
  
  override func mouseDown(with event: NSEvent) {

    if let layout = self.layout {
      
      if let item = getItem(event: event) {
        
        switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
          
        case [.control]:
          if item.itemPartType == .block {
            let x = ModalWindow.PlaceLocomotive
            let wc = x.windowController
            if let vc = wc.contentViewController as? PlaceLocomotiveVC {
              vc.switchBoardItem = item
              vc.isOrigin = false
            }
            wc.showWindow(nil)
          }
        case [.option]:
          break
        case [.shift]:
          if item.itemPartType == .block {
            let x = ModalWindow.PlaceLocomotive
            let wc = x.windowController
            if let vc = wc.contentViewController as? PlaceLocomotiveVC {
              vc.switchBoardItem = item
              vc.isOrigin = true
            }
            wc.showWindow(nil)
          }
        default:
          if item.isTurnout {
            item.nextTurnoutConnection()
          }
        }

      }
      

  //    needsDisplay = true

    }
    
  }

}
