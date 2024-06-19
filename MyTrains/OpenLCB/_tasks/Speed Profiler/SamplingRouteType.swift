//
//  SamplingRouteType.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2024.
//

import Foundation
import AppKit

public enum SamplingRouteType : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case loop     = 0
  case straight = 1
  
  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [SamplingRouteType:String] = [
      .loop : String(localized: "Loop"),
      .straight : String(localized: "Straight"),
    ]
    
    return titles[self]!
    
  }
  
}
