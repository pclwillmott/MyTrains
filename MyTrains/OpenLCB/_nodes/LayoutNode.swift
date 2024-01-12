//
//  LayoutNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/01/2024.
//

import Foundation

public class LayoutNode : OpenLCBNodeVirtual {
  
  public override init(nodeId:UInt64) {
    
    super.init(nodeId: nodeId)
    
    virtualNodeType = .layoutNode
    
  }
  
}
