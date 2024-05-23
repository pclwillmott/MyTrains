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
    
    let dX = isDrag ? endMove!.x - startMove!.x : 0
    let dY = isDrag ? endMove!.y - startMove!.y : 0

    for (_, item) in switchboardPanel.switchboardItems {
      
      if isSelected(item: item) {
        
        if isDrag {
          
          let path = NSBezierPath()
          
          let x = CGFloat(item.location.x + dX) * cellSize
          let y = CGFloat(item.location.y + dY) * cellSize
          
          let rect = NSRect(x: x, y: y, width: cellSize, height: cellSize)
          
          path.appendRect(rect)
          
          path.lineWidth = lineWidth
          
          NSColor.setStrokeColor(color: .systemGreen)
          
          path.stroke()
          
        }
        else {
          
          let path = NSBezierPath()
          
          let x = CGFloat(item.location.x) * cellSize
          let y = CGFloat(item.location.y) * cellSize
          
          let rect = NSRect(x: x, y: y, width: cellSize, height: cellSize)
          
          path.appendRect(rect)
          
          path.lineWidth = lineWidth
          
          NSColor.setStrokeColor(color: .systemBlue)
          
          path.stroke()          

        }
        
      }
      
    }
    
    if selectedItems.isEmpty, let currentLocation {
      
      let path = NSBezierPath()
      
      let x = CGFloat(currentLocation.x) * cellSize
      let y = CGFloat(currentLocation.y) * cellSize
      
      let rect = NSRect(x: x, y: y, width: cellSize, height: cellSize)
      
      path.appendRect(rect)
      
      path.lineWidth = lineWidth
      
      NSColor.setStrokeColor(color: .systemBlue)
      
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

    startMove = gridSquare(from: event)
    
    switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
    case [.control]:
      debugLog("control")
      break
    case [.option]:
      debugLog("option")
      break
    case [.shift]:
      debugLog("shift")
      if let item = getItem(event: event), !isSelected(item: item) {
        selectedItems.append(item)
      }
      currentLocation = selectedItems.count > 1 ? nil : startMove

    default:
      debugLog("default")
      selectedItems.removeAll()
      currentLocation = startMove
      if let item = getItem(event: event), !isSelected(item: item) {
        selectedItems.append(item)
      }
      
    }
    
    delegate?.selectedItemChanged?(self, switchboardItem: nil)


    needsDisplay = true

  }

  override func mouseDragged(with event: NSEvent) {
    if isArrangeMode {
      endMove = gridSquare(from: event)
      var minX : Int?
      var minY : Int?
      for selectedItem in selectedItems {
        if minX == nil || selectedItem.location.x < minX! {
          minX = selectedItem.location.x
        }
        if minY == nil || selectedItem.location.y < minY! {
          minY = selectedItem.location.y
        }
      }
      if let minX, let minY, let endMove {
        let dX = endMove.x - startMove!.x + minX
        let dY = endMove.y - startMove!.y + minY
        self.endMove = (x: dX < 0 ? endMove.x - dX : endMove.x, y: dY < 0 ? endMove.y - dY : endMove.y)
      }
      isDrag = true
      needsDisplay = true
    }
  }
  
  override func mouseUp(with event: NSEvent) {
    
    guard let switchboardPanel, let networkLayer = appDelegate.networkLayer else {
      return
    }
    
    if isArrangeMode {
      
      if isDrag {
        
        let dX = endMove!.x - startMove!.x
        let dY = endMove!.y - startMove!.y

        var deleteList : [SwitchboardItemNode] = []
        
        for selectedItem in selectedItems {
          
          for (_, item) in switchboardPanel.switchboardItems {
            
            if !isSelected(item: item) && selectedItem.location.x + dX == item.location.x && selectedItem.location.y + dY == item.location.y {
              deleteList.append(item)
            }
            
          }
          
        }
        
        if !deleteList.isEmpty {
          
          let alert = NSAlert()
          
          alert.messageText = String(localized: "Are You Sure?")
          alert.informativeText = String(localized: "This move will overwrite one or more existing items. Do you want to proceed?")
          alert.addButton(withTitle: String(localized: "Yes"))
          alert.addButton(withTitle: String(localized: "No"))
          alert.alertStyle = .informational
          
          switch alert.runModal() {
          case .alertFirstButtonReturn:
            break
          default:
            return
          }
          
          while !deleteList.isEmpty {
            let item = deleteList.removeFirst()
            networkLayer.deleteNode(nodeId: item.nodeId)
          }

        }
        
        for selectedItem in selectedItems {
          selectedItem.xPos = UInt16(exactly: selectedItem.location.x + dX)!
          selectedItem.yPos = UInt16(exactly: selectedItem.location.y + dY)!
          selectedItem.saveMemorySpaces()
        }

        isDrag = false
        endMove = nil

        delegate?.selectedItemChanged?(self, switchboardItem: nil)

      }

      needsDisplay = true

    }
    
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
