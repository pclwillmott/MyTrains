//
//  IntExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 15/01/2022.
//

import Foundation

extension Int {

  public static func fromMultiBaseString(stringValue: String) -> Int? {
    
    let strVal = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
    
    if strVal.prefix(2) == "0x" {
      if let nn = Int(strVal.suffix(strVal.count-2), radix: 16) {
        return nn
      }
    }
    else if strVal.prefix(2) == "0b" {
      if let nn = Int(strVal.suffix(strVal.count-2), radix: 2) {
        return nn
      }
    }
    else if strVal.prefix(1) == "0" {
      if let nn = Int(strVal.suffix(strVal.count), radix: 8) {
        return nn
      }
    }
    else {
      if let nn = Int(strVal.suffix(strVal.count), radix: 10) {
        return nn
      }
    }
    
    return nil
    
  }
  
}
