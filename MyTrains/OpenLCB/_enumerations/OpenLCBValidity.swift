//
//  OpenLCBValidity.swift
//  MyTrains
//
//  Created by Paul Willmott on 03/08/2023.
//

import Foundation

public enum OpenLCBValidity : UInt16 {
  
  case valid   = 0
  case invalid = 1
  case unknown = 3
  
  public var consumerMTI : OpenLCBMTI {
    let rawValue = OpenLCBMTI.consumerIdentifiedAsCurrentlyValid.rawValue + self.rawValue
    return OpenLCBMTI(rawValue: rawValue)!
  }
  
  public var producerMTI : OpenLCBMTI {
    let rawValue = OpenLCBMTI.producerIdentifiedAsCurrentlyValid.rawValue + self.rawValue
    return OpenLCBMTI(rawValue: rawValue)!
  }
  
}
