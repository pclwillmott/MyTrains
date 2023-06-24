//
//  OpenLCBThrottle.swift
//  MyTrains
//
//  Created by Paul Willmott on 24/06/2023.
//

import Foundation

public class OpenLCBThrottle : OpenLCBNodeVirtual {
 
  // MARK: Constructors & Destructors
  
  public init(throttleId:UInt8) {
    
    self.throttleId = throttleId
    
    let nodeId = 0x0801000dff00 + UInt64(throttleId)

    super.init(nodeId: nodeId)
    
    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }
    
  }
  
  // MARK: Public Properties
  
  public var throttleId : UInt8
  
  // MARK: Private Methods
  
  internal override func resetToFactoryDefaults() {
    
    acdiManufacturerSpaceVersion = 4
    
    manufacturerName    = "Paul Willmott"
    nodeModelName       = "MyTrains Throttle"
    nodeHardwareVersion = "v0.1"
    nodeSoftwareVersion = "v0.1"
    
    acdiUserSpaceVersion = 2
    
    userNodeName        = "Throttle #\(throttleId)"
    userNodeDescription = ""
    
    saveMemorySpaces()
    
  }
  
}
