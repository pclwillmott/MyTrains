//
//  OpenLCBNodeConfigurationTool.swift
//  MyTrains
//
//  Created by Paul Willmott on 26/05/2023.
//

import Foundation

public class OpenLCBNodeConfigurationTool : OpenLCBNodeVirtual {
  
  // MARK: Constructors
  
  public override init(nodeId:UInt64) {
    
    super.init(nodeId: nodeId)

    manufacturerName = "Paul Willmott"
    
    nodeModelName = "Configuration Tool"
    
    nodeHardwareVersion = ""
    
    nodeSoftwareVersion = "\(Bundle.main.releaseVersionNumberPretty)"
    
    isDatagramProtocolSupported = true
    
  }
  
  // MARK: Private Properties
  
  // MARK: Public Properties
  
  // MARK: Public Methods
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
}
