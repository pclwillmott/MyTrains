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

    manufacturerName = "Paul Willmott"
    
    nodeModelName = "MyTrains"
    
    nodeHardwareVersion = ""
    
    nodeSoftwareVersion = "\(Bundle.main.releaseVersionNumberPretty)"
    
    isDatagramProtocolSupported = true
    
  }
  
  // MARK: Private Properties
  
  // MARK: Public Properties
  
  // MARK: Public Methods
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
}
