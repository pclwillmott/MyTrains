//
//  LCCCDIDataElementType.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/04/2023.
//

import Foundation

public enum OpenLCBCDIElementType : String {
  
  case cdi             = "cdi"
  case name            = "name"
  case description     = "description"
  case repname         = "repname"
  case group           = "group"
  case string          = "string"
  case int             = "int"
  case eventid         = "eventid"
  case float           = "float"
  case map             = "map"
  case min             = "min"
  case max             = "max"
  case defaultValue    = "default"
  case relation        = "relation"
  case property        = "property"
  case value           = "value"
  case identification  = "identification"
  case manufacturer    = "manufacturer"
  case model           = "model"
  case hardwareVersion = "hardwareVersion"
  case softwareVersion = "softwareVersion"
  case acdi            = "acdi"
  case segment         = "segment"
  case none            = "none"
  
  public var isNode : Bool {
    
    let nodeTypes : Set<OpenLCBCDIElementType> = [
      .cdi,
      .identification,
      .acdi,
      .segment,
      .group,
      .int,
      .string,
      .eventid,
      .float,
      .manufacturer,
      .model,
      .hardwareVersion,
      .softwareVersion
    ]
    
    return nodeTypes.contains(self)
    
  }

  public var isData : Bool {
    
    let dataTypes : Set<OpenLCBCDIElementType> = [
      .int,
      .string,
      .eventid,
      .float
    ]
    
    return dataTypes.contains(self)
    
  }

}
