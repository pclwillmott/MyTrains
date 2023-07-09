//
//  LCCTransportLayerInternalNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 14/05/2023.
//

import Foundation

public class OpenLCBTransportLayerAlias {
  
  // MARK: Constructors
  
  init(nodeId:UInt64) {
    self.nodeId = nodeId
  }
  
  // MARK: Public Properties
  
  public var nodeId : UInt64
  
  public var alias : UInt16?
  
  public var transitionState : OpenLCBTransportTransitionStateCAN = .idle

  public var state : OpenLCBTransportLayerState = .inhibited
  
}
