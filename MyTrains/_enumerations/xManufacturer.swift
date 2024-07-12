//
//  Manufacturer.swift
//  MyTrains
//
//  Created by Paul Willmott on 25/06/2022.
//

import Foundation

public enum xManufacturer : Int {
  
  case digitrax = 118
  case rrCirKits = 77
  case trainControlSystems = 141
  case peco = 163
  
  public var title : String {
    get {
      return NMRA.manufacturerName(code: self.rawValue)
    }
  }
  
}
