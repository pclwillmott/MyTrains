//
//  SamplingDirection.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/06/2024.
//

import Foundation
import AppKit

public enum SamplingDirection : UInt8, CaseIterable {
  
  // MARK: Enumeration
  
  case bothDirections
  case forward
  case reverse
  
  // MARK: Public Properties
  
  public var title : String {
    
    let titles : [SamplingDirection:String] = [
      .bothDirections : String(localized: "Both Forward & Reverse"),
      .forward        : String(localized: "Forward Only"),
      .reverse        : String(localized: "Reverese Only"),
    ]
    
    return titles[self]!
    
  }
}
