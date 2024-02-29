//
//  OpenLCBNodeVisibility.swift
//  MyTrains
//
//  Created by Paul Willmott on 15/02/2024.
//

import Foundation

public enum OpenLCBNodeVisibility : UInt8 {
  
  case visibilityNone       = 0 // Used for dumb placeholder nodes that do not talk
  case visibilityPrivate    = 1 // Used for nodes that only talk inside the App
  case visibilityInternal   = 2 // Used for nodes that talk over tcp/ip
  case visibilitySemiPublic = 3 // User for nodes that talk over tcp/ip with own nodeId
                                // and over the CAN with the appNode Id
  case visibilityPublic     = 4 // Used for nodes that have to talk via the CAN
  
  // MARK: Public Properties
  
  public var bigEndianData : [UInt8] {
    return [self.rawValue]
  }
  
}
