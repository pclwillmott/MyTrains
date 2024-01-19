//
//  SwitchboardItemNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/01/2024.
//

import Foundation

public class SwitchboardItemNode : OpenLCBNodeVirtual {

  public override init(nodeId:UInt64) {
    
    super.init(nodeId: nodeId)
    
    virtualNodeType = .switchboardItemNode
    
    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }

  }

}
