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

    virtualNodeType = MyTrainsVirtualNodeType.applicationNode
    
    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }
    
  }
  
  // MARK: Private Properties
  
  // MARK: Public Properties
  
  // MARK: Private Methods
  
  internal override func resetToFactoryDefaults() {
    
    acdiManufacturerSpaceVersion = 4
    
    manufacturerName    = virtualNodeType.manufacturerName
    nodeModelName       = virtualNodeType.name
    nodeHardwareVersion = "\(Bundle.main.releaseVersionNumberPretty)"
    nodeSoftwareVersion = "\(Bundle.main.releaseVersionNumberPretty)"
    
    acdiUserSpaceVersion = 2
    
    userNodeName         = ""
    userNodeDescription  = ""
    
    saveMemorySpaces()
    
  }

  // MARK: Public Methods
  
  // MARK: OpenLCBMemorySpaceDelegate Methods
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
}
