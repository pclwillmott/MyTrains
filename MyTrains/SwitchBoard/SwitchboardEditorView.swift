//
//  SwitchboardEditorView.swift
//  MyTrains
//
//  Created by Paul Willmott on 18/04/2024.
//

import Foundation
import AppKit

//@IBDesignable
class SwitchboardEditorView: SwitchboardView {
  
  // MARK: Drawing Stuff
  
  override func draw(_ dirtyRect: NSRect) {

    guard let switchboardPanel, let appLayoutId, let layout = appDelegate.networkLayer?.virtualNodeLookup[appLayoutId] as? LayoutNode else {
      return
    }

    if isGroupMode && groupId != -1 {
      
      for (key, item) in switchboardPanel.switchboardItems {
        
        if item.groupId != -1 {
          
          let path = NSBezierPath()
          
          let x = CGFloat(item.location.x) * cellSize
          let y = CGFloat(item.location.y) * cellSize
          
          let rect = NSRect(x: x, y: y, width: cellSize, height: cellSize)
          
          path.appendRect(rect)
          
          groupId == item.groupId ? NSColor.setFillColor(color: .orange) : NSColor.setFillColor(color: .darkGray)
          
          path.fill()
          
        }
        
      }
    }
    
    super.draw(dirtyRect)
        
    NSColor.setStrokeColor(color: .systemBlue)
    
    for (_, item) in switchboardPanel.switchboardItems {
      
      if isSelected(item: item) {
        
        let path = NSBezierPath()
        
        let x = CGFloat(item.location.x) * cellSize
        let y = CGFloat(item.location.y) * cellSize
        
        let rect = NSRect(x: x, y: y, width: cellSize, height: cellSize)
        
        path.appendRect(rect)
        
        path.lineWidth = lineWidth
        
        path.stroke()
        
      }
      
    }
    
    if selectedItems.isEmpty, let currentLocation {
      
      let path = NSBezierPath()
      
      let x = CGFloat(currentLocation.x) * cellSize
      let y = CGFloat(currentLocation.y) * cellSize
      
      let rect = NSRect(x: x, y: y, width: cellSize, height: cellSize)
      
      path.appendRect(rect)
      
      path.lineWidth = lineWidth
      
      path.stroke()
      
    }
     
    /*
    if let start = startMove {
      
      let path = NSBezierPath()
      
      path.lineWidth = lineWidth
      
      NSColor.setStrokeColor(color: .orange)
   
      let rect = NSRect(x: CGFloat(start.x) * cellSize, y: CGFloat(start.y) * cellSize, width: cellSize, height: cellSize)

      path.appendRect(rect)
      
      path.stroke()

    }
    
    if let end = endMove {
      
      let path = NSBezierPath()
      
      path.lineWidth = lineWidth
      
      NSColor.setStrokeColor(color: .green)
   
      let rect = NSRect(x: CGFloat(end.x) * cellSize, y: CGFloat(end.y) * cellSize, width: cellSize, height: cellSize)

      path.appendRect(rect)
      
      path.stroke()

    }
 
     */
    
  }
  
  // MARK: Private Properties
   
  private var currentLocation : SwitchBoardLocation?
  
  private var startMove : SwitchBoardLocation?
  
  private var endMove : SwitchBoardLocation?
  
  private var isDrag : Bool = false
  
  // MARK: Public Properties
  
  public var selectedItems : [SwitchboardItemNode] = []
  
  public var groupId : Int = -1 {
    didSet {
      
    }
  }
  
  public var mode : SwitchBoardMode = .arrange {
    didSet {
      needsDisplay = true
    }
  }
  
  public var nextPart : SwitchBoardItemType = .none
  
  public var isGroupMode : Bool {
    return mode == .group
  }
  
  public var isArrangeMode : Bool {
    return mode == .arrange
  }
  
  public var delegate: SwitchboardEditorViewDelegate?
  
  // MARK: Private Methods
  
  private func newGroup() -> Int {
    /*
    var candidate : Int = 1
    while true {
      var used = false
      for kv in layout!.switchBoardItems {
        if kv.value.groupId == candidate {
          used = true
          break
        }
      }
      if !used {
        return candidate
      }
      candidate += 1
    }
     */
    return 0
  }
  
  private func isSelected(item:SwitchboardItemNode) -> Bool {
    for selectedItem in selectedItems {
      if selectedItem === item {
        return true
      }
    }
    return false
  }

  override func mouseDown(with event: NSEvent) {

    switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
    case [.control]:
      debugLog("control")
      break
    case [.option]:
      debugLog("option")
      break
    case [.shift]:
      debugLog("shift")
      if let item = getItem(event: event) {
        selectedItems.append(item)
      }
      currentLocation = selectedItems.count > 1 ? nil : gridSquare(from: event)

    default:
      debugLog("default")
      selectedItems.removeAll()
      currentLocation = gridSquare(from: event)
      if let item = getItem(event: event) {
        selectedItems.append(item)
      }
   }
    
   delegate?.selectedItemChanged?(self, switchboardItem: nil)

    
/*
    if let layout = self.layout {
      
      switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
        
      case [.control]:
        
        startMove = gridSquare(from: event)
        if let item = getItem(event: event) {
          selectedItems.append(item)
        }
        else {
          
          let blank = SwitchBoardItem(location: startMove!, itemPartType: .none, orientation: .deg0, groupId: -1, panelId: panelId, layoutId: -1)
          
          layout.switchBoardItems[blank.key] = blank
          selectedItems.append(blank)
           
        }
        
      case [.option]:
        
        if let item = getItem(event: event) {
          item.propertySheet()
          needsDisplay = true
        }
        
      case [.shift]:
        
        if startMove == nil {
          startMove = gridSquare(from: event)
          selectedItems.removeAll()
          if let item = getItem(event: event) {
            selectedItems.append(item)
          }
          else {
            
            let blank = SwitchBoardItem(location: startMove!, itemPartType: .none, orientation: .deg0, groupId: -1, panelId: panelId, layoutId: -1)
            layout.switchBoardItems[blank.key] = blank
            selectedItems.append(blank)
             
          }
        }
        else {
          
          endMove = gridSquare(from: event)
          
          let sx = min(startMove!.x, endMove!.x)
          let sy = min(startMove!.y, endMove!.y)
          let ex = max(startMove!.x, endMove!.x)
          let ey = max(startMove!.y, endMove!.y)
          
          selectedItems.removeAll()
          
          for x in sx...ex {
            for y in sy...ey {
              if let item = getItem(x: x, y: y) {
                selectedItems.append(item)
              }
              else {
                let blank = SwitchBoardItem(location: (x:x, y:y), itemPartType: .none, orientation: .deg0, groupId: -1, panelId: panelId, layoutId: -1)
                layout.switchBoardItems[blank.key] = blank
                selectedItems.append(blank)
                 
              }
            }
            
          }
          
          startMove = endMove
          endMove = nil
          
        }
        
      default:
        
        startMove = gridSquare(from: event)
        
        selectedItems.removeAll()
        
        if let item = getItem(event: event) {
          if isArrangeMode && nextPart != .none {
          
            item.itemPartType = nextPart
          }
          selectedItems.append(item)
        }
        else {
          let blank = SwitchBoardItem(location: startMove!, itemPartType: .none, orientation: .deg0, groupId: -1, panelId: panelId, layoutId: -1)
          if isArrangeMode && nextPart != .none {
            blank.itemPartType = nextPart
          }
          layout.switchBoardItems[blank.key] = blank
          selectedItems.append(blank)
           
        }
        
        if selectedItems[0].groupId != -1 {
          groupId = selectedItems[0].groupId
        }

      }

    }
    */

    needsDisplay = true

  }

  override func mouseDragged(with event: NSEvent) {
    debugLog("mouseDragged")
    if isArrangeMode {
      switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
      case [.control]:
        break
      case [.option]:
        break
      case [.shift]:
        break
      default:
        let square = gridSquare(from: event)
        endMove = square
        isDrag = true
        needsDisplay = true
      }
    }
  }
  
  override func mouseUp(with event: NSEvent) {
    
    debugLog("mouseUp")

    if isArrangeMode {
      switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
      case [.control]:
        debugLog("control")
        break
      case [.option]:
        debugLog("option")
        break
      case [.shift]:
        debugLog("shift")
        
      default:
        
        break
      }
      
    }
    
   /*
    if let layout = self.layout {
    
      if isArrangeMode && selectedItems.count > 0 && isDrag && endMove != nil {
        
        let x = selectedItems[selectedItems.count-1]
        
        let sx = x.location.x
        let sy = x.location.y
        
        let ex = endMove!.x
        let ey = endMove!.y
        
        let dx = ex - sx
        let dy = ey - sy
        
        if dx <= 0 {
          if dy <= 0 {
            selectedItems.sort {$0.location.x < $1.location.x && $0.location.y < $1.location.y}
          }
          else {
            selectedItems.sort {$0.location.x < $1.location.x && $0.location.y > $1.location.y}
          }
        }
        else {
          if dy <= 0 {
            selectedItems.sort {$0.location.x > $1.location.x && $0.location.y < $1.location.y}
          }
          else {
            selectedItems.sort {$0.location.x > $1.location.x && $0.location.y > $1.location.y}
          }
        }
        
        for item in selectedItems {
          
          layout.switchBoardItems[item.key] = nil
          
          let newX = item.location.x + dx
          let newY = item.location.y + dy
          
          if let occupant = getItem(x: newX, y: newY) {
            
            if occupant.itemPartType == .none {
              layout.switchBoardItems[item.key] = nil
            }
            else {
              occupant.nextAction = .delete
            }
             
          }
          
          item.location.x = newX
          item.location.y = newY
          
          layout.switchBoardItems[item.key] = item
          
        }
        
        selectedItems.removeAll()
        
        startMove = nil
        endMove = nil
        
        isDrag = false
        
      }
      
      needsDisplay = true

    }
   */
  }
  
  // MARK: Public Methods
  
  public func rotateRight() {
    
    for item in selectedItems {
      item.rotateRight()
    }
    
    needsDisplay = true
    
  }
  
  public func rotateLeft() {
    
    for item in selectedItems {
      item.rotateLeft()
    }
    
    needsDisplay = true
    
  }
  
  public func changeGroup(groupName: String) {
    groupId = groupName == "(new group)" ? -1 : Int(groupName) ?? -1
  }
  
  public func addToGroup(groupName: String) {
    /*
    var gid = -1
    
    if groupName == "(new group)" {
      gid = newGroup()
    }
    else {
      gid = Int(groupName) ?? -1
    }
    
    for item in selectedItems {
      item.groupId = gid
    }
    
    groupId = gid
*/
  }

  public func removeFromGroup() {
    
    for item in selectedItems {
  //    item.groupId = -1
    }
    
  }
  
  public func deleteItem() {
    
    guard let networkLayer = appDelegate.networkLayer, let currentLocation else {
      return
    }
    
    if let item = getItem(location: currentLocation) {
      
      let alert = NSAlert()
      
      alert.messageText = String(localized: "Are You Sure?")
      alert.informativeText = String(localized: "Are you sure that you want to delete this item?")
      alert.addButton(withTitle: String(localized: "Yes"))
      alert.addButton(withTitle: String(localized: "No"))
      alert.alertStyle = .informational
      
      switch alert.runModal() {
      case .alertFirstButtonReturn:
        break
      default:
        return
      }
      
      networkLayer.deleteNode(nodeId: item.nodeId)
      selectedItems.removeAll()
      
      needsDisplay = true

    }

  }
  
  public func addItem(partType:SwitchBoardItemType) {
    
    guard let networkLayer = appDelegate.networkLayer, let currentLocation, let switchboardPanel else {
      return
    }
    
    if let item = getItem(location: currentLocation) {
      
      let alert = NSAlert()
      
      alert.messageText = String(localized: "Are You Sure?")
      alert.informativeText = String(localized: "Are you sure that you want to replace the existing item at this location?")
      alert.addButton(withTitle: String(localized: "Yes"))
      alert.addButton(withTitle: String(localized: "No"))
      alert.alertStyle = .informational
      
      switch alert.runModal() {
      case .alertFirstButtonReturn:
        break
      default:
        return
      }
      
      networkLayer.deleteNode(nodeId: item.nodeId)

    }
    
    if let node = networkLayer.createVirtualNode(virtualNodeType: .switchboardItemNode) as? SwitchboardItemNode {
      node.layoutNodeId = switchboardPanel.layoutNodeId
      node.panelId = switchboardPanel.nodeId
      node.itemType = partType
      node.userNodeName = partType.title
      
      if partType.requireUniqueName {
        
        var index = 0
        var isUnique = true
        var test = ""
        
        repeat {
          index += 1
          isUnique = true
          var prefix = ""
          if partType.isBlock {
            prefix = "B"
          }
          else if partType.isTurnout {
            prefix = "T"
          }
          else {
            prefix = "L"
          }
          test = " - \(prefix)\(index)"
          for (_, item) in switchboardPanel.switchboardItems {
            if test == item.userNodeName.suffix(test.count) {
              isUnique = false
              break
            }
          }
        } while !isUnique
        
        node.userNodeName = "\(node.userNodeName)\(test)"
        
      }
      
      node.xPos = UInt16(exactly: currentLocation.x)!
      node.yPos = UInt16(exactly: currentLocation.y)!
      node.saveMemorySpaces()
      selectedItems.removeAll()
      selectedItems.append(node)
    }
    
    needsDisplay = true
    
  }

}
