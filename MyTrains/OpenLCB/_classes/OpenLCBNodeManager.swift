//
//  OpenLCBNodeManager.swift
//  MyTrains
//
//  Created by Paul Willmott on 02/08/2023.
//

import Foundation
import AppKit

public class OpenLCBNodeManager {
  
  // MARK: Constructors & Destructors
  
  deinit {
    removeAll()
  }
  
  // MARK: Private Properties
  
  private var nodes : [UInt64:OpenLCBNodeVirtual] = [:]
  
  private var freeNodes : Set<UInt64> = []
  
  private var nodesInUse : Set<UInt64> = []
  
  private var exclusiveLock : Bool = false
  
  // MARK: Public Properties
  
  public var numberOfFreeNodes : Int {
    return freeNodes.count
  }
  
  public var isLocked : Bool {
    return exclusiveLock
  }
  
  public var members : [OpenLCBNodeVirtual] {
    
    var result : [OpenLCBNodeVirtual] = []
    
    for (_, item) in nodes {
      result.append(item)
    }
    
    result.sort {$0.userNodeName < $1.userNodeName}
    
    return result
    
  }
  
  // MARK: Public Methods

  public func removeAll() {
    freeNodes.removeAll()
    nodesInUse.removeAll()
    nodes.removeAll()
    exclusiveLock = false
  }
  
  public func addNode(node:OpenLCBNodeVirtual) {
    nodes[node.nodeId] = node
    freeNodes.insert(node.nodeId)
  }
  
  public func removeNode(node:OpenLCBNodeVirtual) {
    freeNodes.remove(node.nodeId)
    nodesInUse.remove(node.nodeId)
    nodes.removeValue(forKey: node.nodeId)
  }
  
  public func getNode(exclusive:Bool = false) -> OpenLCBNodeVirtual? {
    
    if exclusive {
      
      if nodesInUse.count <= 1 {
        exclusiveLock = true
      }
      else {
        
        let alert = NSAlert()
        
        alert.messageText = String(localized: "Configuration Tool Unavailable")
        alert.informativeText = String(localized: "This device requires exclusive use of the configuration mechanism. If you have any other configuration tools open for other devices please close them all and try again.")
        alert.addButton(withTitle: String(localized: "OK"))
        alert.alertStyle = .informational
        
        alert.runModal()

        return nil
        
      }
      
    }
    else if exclusiveLock {

      let alert = NSAlert()
      
      alert.messageText = String(localized: "Configuration Tool Unavailable")
      alert.informativeText = String(localized: "Another configuration tool has exclusive use of the configuration mechanism. Try again after you have finished with the other configuration tool.")
      alert.addButton(withTitle: String(localized: "OK"))
      alert.alertStyle = .informational
      
      alert.runModal()

      return nil

    }
    
    debugLog("\(nodesInUse) - \(freeNodes)")
    if let id = freeNodes.first {
      nodesInUse.insert(id)
      freeNodes.remove(id)
      return nodes[id]
    }
    
    return nil
    
  }
  
  public func releaseNode(node:OpenLCBNodeVirtual) {
    freeNodes.insert(node.nodeId)
    nodesInUse.remove(node.nodeId)
    exclusiveLock = false
  }
  
}
