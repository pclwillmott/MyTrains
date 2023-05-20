//
//  LCCTransportLayerInternalNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 14/05/2023.
//

import Foundation

public class OpenLCBTransportLayerAlias {
  
  // MARK: Constructors
  
  init(node:OpenLCBNode) {
    self.node = node
  }
  
  // MARK: Public Properties
  
  public var node : OpenLCBNode
  
  public var alias : UInt16?
  
  public var transitionState : OpenLCBTransportTransitionStateCAN = .idle

  public var state : OpenLCBTransportLayerState = .inhibited
  
}
