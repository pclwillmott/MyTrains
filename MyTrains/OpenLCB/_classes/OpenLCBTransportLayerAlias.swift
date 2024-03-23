//
//  LCCTransportLayerInternalNode.swift
//  MyTrains
//
//  Created by Paul Willmott on 14/05/2023.
//

import Foundation

public class OpenLCBTransportLayerAlias {
  
  // MARK: Constructors
  
  init(alias:UInt16, nodeId:UInt64) {
    self.alias = alias
    self.nodeId = nodeId
    self.timeStamp = Date.timeIntervalSinceReferenceDate
    #if DEBUG
    addInit()
    #endif
  }
  
  #if DEBUG
  deinit {
    addDeinit()
  }
  #endif
  
  // MARK: Public Properties
  
  public var nodeId : UInt64
  
  public var alias : UInt16
  
  public var state : OpenLCBAliasState = .testingAlias
  
  public var timeStamp : TimeInterval

}
