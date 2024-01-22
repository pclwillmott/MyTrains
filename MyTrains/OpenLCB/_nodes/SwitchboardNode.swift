//
//  SwitchboardNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/01/2024.
//

import Foundation

public class SwitchboardNode : OpenLCBNodeVirtual {
 
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    super.init(nodeId: nodeId)
    
    virtualNodeType = .switchboardNode

    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }

  }

  // MARK: Private Methods

  internal override func resetToFactoryDefaults() {
    super.resetToFactoryDefaults()
    saveMemorySpaces()
  }

}
