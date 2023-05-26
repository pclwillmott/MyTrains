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
    
    fastClock = OpenLCBClock(node: self, type: .fastClock)
    
  }
  
  // MARK: Private Properties
  
  // MARK: Public Properties
  
  public var fastClock : OpenLCBClock?
  
  // MARK: Public Methods
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    super.openLCBMessageReceived(message: message)
    
    fastClock?.openLCBMessageReceived(message: message)
    
  }
  
}
