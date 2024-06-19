//
//  LocomotiveControlBasis.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2024.
//

import Foundation
import AppKit

public enum LocomotiveControlBasis : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case defaultValues = 0
  case bestFitValues = 1
  case actualValues  = 2
  
  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [LocomotiveControlBasis:String] = [
      .defaultValues : String(localized: "Default Values"),
      .actualValues  : String(localized: "Actual Values"),
      .bestFitValues : String(localized: "Best Fit Values"),
    ]
    
    return titles[self]!
    
  }
  
}
