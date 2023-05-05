//
//  LCCCDITreeViewDS.swift
//  MyTrains
//
//  Created by Paul Willmott on 05/05/2023.
//

import Foundation
import Cocoa

// Data Source for Outline View

class LCCCDITreeViewDS : NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
  
  var root : LCCCDIElement
  
  init(root:LCCCDIElement) {
    self.root = root
    super.init()
  }
  
  private func expand(_ node: LCCCDIElement) {
        
  }

  // DATA SOURCE
  
  // Returns the child item at the specified index of a given item
  func outlineView(_ outlineView: NSOutlineView,
                   child index: Int,
                   ofItem item: Any?) -> Any {
    
    if let node = item as? LCCCDIElement {
      return node.childElements[index]
    }

    return root.childElements[index]

  }
  
  // Returns a Boolean value that indicates whether the a given item is expandable
  func outlineView(_ outlineView: NSOutlineView,
                   isItemExpandable item: Any) -> Bool {
    
    if let node = item as? LCCCDIElement {
      expand(node)
      return node.childElements.count > 0
    }
    
    expand(root)
    return root.childElements.count > 0
    
  }
  
  // Returns the number of child items encompassed by a given item.
  func outlineView(_ outlineView: NSOutlineView,
                   numberOfChildrenOfItem item: Any?) -> Int {
    
    if let node = item as? LCCCDIElement {
      return node.childElements.count
    }
    
    return root.childElements.count
    
 }
  
  // DELEGATE
  
  func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    
    var view: NSTableCellView?

    view = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TreeViewNode"), owner: self) as? NSTableCellView
    
    if let node = item as? LCCCDIElement, let textField = view?.textField {
      switch node.type {
      case .cdi:
        textField.stringValue = "CDI"
      case .acdi:
        textField.stringValue = "ACDI"
      case .identification:
        textField.stringValue = "Identification"
      case .hardwareVersion:
        textField.stringValue = "Hardware Version: \(node.stringValue)"
      case .softwareVersion:
        textField.stringValue = "Software Version: \(node.stringValue)"
      case .manufacturer:
        textField.stringValue = "Manufacturer: \(node.stringValue)"
      case .model:
        textField.stringValue = "Model: \(node.stringValue)"
      default:
        textField.stringValue = node.name
      }
//      textField.font = NSFont(name: "Menlo", size: 12.0)
      textField.tag = node.tag
    }
    
    
    return view
    
  }
  
}

