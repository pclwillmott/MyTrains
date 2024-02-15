//
//  OpenLCBNodeVisibility.swift
//  MyTrains
//
//  Created by Paul Willmott on 15/02/2024.
//

import Foundation

public enum OpenLCBNodeVisibility {
  
  case visibilityNone     // Used for dumb placeholder nodes that do not talk
  case visibilityPrivate  // Used for nodes that only talk inside the App
  case visibilityInternal // Used for nodes that talk over tcp/ip
  case visibilityPublic   // Used for nodes that have to talk via the CAN
  
}
