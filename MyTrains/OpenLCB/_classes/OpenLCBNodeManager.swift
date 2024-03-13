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
  
  internal var nodes : [UInt64:OpenLCBNodeVirtual] = [:]
  
  internal var freeNodes : Set<UInt64> = []
  
  internal var nodesInUse : Set<UInt64> = []
  
  // MARK: Public Properties
  
  public var numberOfFreeNodes : Int {
    return freeNodes.count
  }
  
  public var numberOfNodes : Int {
    return nodes.count
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
  
  public func getNode(virtualNodeType:MyTrainsVirtualNodeType) -> OpenLCBNodeVirtual? {
    
    if freeNodes.isEmpty {
      addNode(node: appDelegate.networkLayer.createVirtualNode(virtualNodeType:virtualNodeType))
    }
    
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
  }
  
}
