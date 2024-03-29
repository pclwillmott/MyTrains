//
//  DateExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 11/12/2022.
//

import Foundation

extension Date {
  
  public var dateComponents : DateComponents {
    get {
      return Calendar.current.dateComponents(in: TimeZone.current, from: self)
    }
  }
  
}

