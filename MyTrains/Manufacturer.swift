//
//  Manufacturer.swift
//  MyTrains
//
//  Created by Paul Willmott on 25/06/2022.
//

import Foundation

public enum Manufacturer : Int {
  
  case peco = 163
  
  public var title : String {
    get {
      return NMRA.manufacturerName(code: self.rawValue)
    }
  }
  
}
