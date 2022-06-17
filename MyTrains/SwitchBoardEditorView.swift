//
//  SwitchBoardEditorView.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/04/2022.
//

import Foundation
import Cocoa

@IBDesignable
class SwitchBoardEditorView: SwitchBoardView {
  
  // MARK: Drawing Stuff
  
  override func draw(_ dirtyRect: NSRect) {
   
    if isGroupMode && groupId != -1 {
      
      for kv in items {
        
        let item = kv.value
        
        if item.panelId == panelId && item.groupId != -1 {
        
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
        
    NSColor.setStrokeColor(color: .blue)
    
    for kv in items {
      
      let item = kv.value
      
      if item.panelId == panelId && isSelected(item: item) {
        
        let path = NSBezierPath()
        
        let x = CGFloat(item.location.x) * cellSize
        let y = CGFloat(item.location.y) * cellSize
        
        let rect = NSRect(x: x, y: y, width: cellSize, height: cellSize)
        
        path.appendRect(rect)
        
        path.lineWidth = lineWidth
        
        path.stroke()
        
      }
      
    }
        
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
    
  }
  
  // MARK: Private Properties
    
  private var startMove : SwitchBoardLocation?
  
  private var endMove : SwitchBoardLocation?
  
  private var selectedItems : [SwitchBoardItem] = []
  
  private var isDrag : Bool = false
  
  // MARK: Public Properties
  
  public var groupId : Int = -1 {
    didSet {
      
      updateCombo()
      
    }
  }
  
  public var mode : SwitchBoardMode = .arrange {
    didSet {
      needsDisplay = true
    }
  }
  
  public var nextPart : SwitchBoardItemPartType = .none
  
  public var isGroupMode : Bool {
    get {
      return mode == .group
    }
  }
  
  public var isArrangeMode : Bool {
    get {
      return mode == .arrange
    }
  }
  
  // MARK: Private Methods
  
  private func updateCombo() {
    
    var groups : [Int] = []
    
    for kv in items {
      
      let gid = kv.value.groupId
      
      if gid != -1 {
        var duplicate = false
        for group in groups {
          if group == gid {
            duplicate = true
            break
          }
        }
        if !duplicate {
          groups.append(gid)
        }
      }
      
    }
    
    var groupNames : [String] = ["0"]
    
    for group in groups {
      groupNames.append("\(group)")
    }
    
    groupNames.sort() {
      $0 < $1
    }
    
    var selectedIndex = 0
   
    if groupId != -1 {
      for group in groupNames {
        if group == "\(groupId)" {
          break
        }
        selectedIndex += 1
      }
    }
    
    groupNames[0] = "(new group)"
    
    if selectedIndex == groupNames.count {
      groupId = -1
    }
    else {
      delegate?.groupChanged?(groupNames: groupNames, selectedIndex: selectedIndex)
      needsDisplay = true
    }
    
  }
  
  private func newGroup() -> Int {
    var candidate : Int = 1
    while true {
      var used = false
      for kv in items {
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
  }
  
  private func isSelected(item:SwitchBoardItem) -> Bool {
    let key = item.key
    for selectedItem in selectedItems {
      if selectedItem.key == key {
        return true
      }
    }
    return false
  }

  override func mouseDown(with event: NSEvent) {

    switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
      
    case [.control]:
      
      startMove = gridSquare(from: event)
      if let item = getItem(event: event) {
        selectedItems.append(item)
      }
      else {
        
        let blank = SwitchBoardItem(location: startMove!, itemPartType: .none, orientation: 0, groupId: -1, panelId: panelId, layoutId: -1)
        
        items[blank.key] = blank
        selectedItems.append(blank)
         
      }
      
    case [.shift]:
      
      if startMove == nil {
        startMove = gridSquare(from: event)
        selectedItems.removeAll()
        if let item = getItem(event: event) {
          selectedItems.append(item)
        }
        else {
          
          let blank = SwitchBoardItem(location: startMove!, itemPartType: .none, orientation: 0, groupId: -1, panelId: panelId, layoutId: -1)
          items[blank.key] = blank
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
              let blank = SwitchBoardItem(location: (x:x, y:y), itemPartType: .none, orientation: 0, groupId: -1, panelId: panelId, layoutId: -1)
              items[blank.key] = blank
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
        let blank = SwitchBoardItem(location: startMove!, itemPartType: .none, orientation: 0, groupId: -1, panelId: panelId, layoutId: -1)
        if isArrangeMode && nextPart != .none {
          blank.itemPartType = nextPart
        }
        items[blank.key] = blank
        selectedItems.append(blank)
         
      }
      
      if selectedItems[0].groupId != -1 {
        groupId = selectedItems[0].groupId
      }

    }

    needsDisplay = true
    
  }

  override func mouseDragged(with event: NSEvent) {
    if isArrangeMode {
      let square = gridSquare(from: event)
      endMove = square
      isDrag = true
      needsDisplay = true
    }
  }
  
  override func mouseUp(with event: NSEvent) {
    
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
        
        items[item.key] = nil
        
        let newX = item.location.x + dx
        let newY = item.location.y + dy
        
        if let occupant = getItem(x: newX, y: newY) {
          
          if occupant.itemPartType == .none {
            items[item.key] = nil
          }
          else {
            occupant.nextAction = .delete
          }
           
        }
        
        item.location.x = newX
        item.location.y = newY
        
        items[item.key] = item
        
      }
      
      selectedItems.removeAll()
      
      startMove = nil
      endMove = nil
      
      isDrag = false
      
    }
    
    needsDisplay = true
    
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

  }

  public func removeFromGroup() {
    
    for item in selectedItems {
      item.groupId = -1
    }
    
    updateCombo()
    
  }
  
  public func delete() {
    for item in selectedItems {
      if item.isDatabaseItem {
        item.nextAction = .delete
      }
      else {
        items.removeValue(forKey: item.key)
      }
    }
    selectedItems.removeAll()
  }

}
