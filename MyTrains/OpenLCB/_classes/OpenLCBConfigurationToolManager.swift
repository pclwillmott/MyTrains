//
//  OpenLCBConfigurationToolManager.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/03/2024.
//

import Foundation
import AppKit

public class OpenLCBConfigurationToolManager : OpenLCBNodeManager {
  
  // MARK: Private Properties
  
  private var exclusiveLock : Bool = false
  
  // MARK: Public Properties
  
  public var isLocked : Bool {
    return exclusiveLock
  }
  
  // MARK: Public Methods

  public override func removeAll() {
    super.removeAll()
    exclusiveLock = false
  }
  
  public func getNode(virtualNodeType:MyTrainsVirtualNodeType, exclusive:Bool = false) -> OpenLCBNodeVirtual? {

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
    
    if freeNodes.isEmpty {
      addNode(node: appDelegate.networkLayer.createVirtualNode(virtualNodeType: virtualNodeType))
    }
    
    if let id = freeNodes.first {
      nodesInUse.insert(id)
      freeNodes.remove(id)
      return nodes[id]
    }
    
    return nil
    
  }
  
  public override func releaseNode(node:OpenLCBNodeVirtual) {
    super.releaseNode(node: node)
    exclusiveLock = false
  }

}
