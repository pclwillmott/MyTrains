//
//  OpenLCBNodeMyTrains.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/05/2023.
//

import Foundation

public class OpenLCBNodeMyTrains : OpenLCBNodeVirtual {
  
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    super.init(nodeId: nodeId)

    isDatagramProtocolSupported = true

    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }

  }
  
  // MARK: Private Properties
  
  // MARK: Public Properties
  
  // MARK: Private Methods
  
  internal override func resetToFactoryDefaults() {
    
    acdiManufacturerSpaceVersion = 4
    
    manufacturerName    = "Paul Willmott"
    nodeModelName       = "MyTrains"
    nodeHardwareVersion = ""
    nodeSoftwareVersion = "\(Bundle.main.releaseVersionNumberPretty)"
    

    acdiUserSpaceVersion = 2
    
    userNodeName         = ""
    userNodeDescription  = ""
    
    for (_, memorySpace) in memorySpaces {
      if memorySpace.space != OpenLCBNodeMemoryAddressSpace.cdi.rawValue {
        memorySpace.save()
      }
    }

  }

  // MARK: Public Methods
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
}
