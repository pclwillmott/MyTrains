//
//  StringExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/05/2023.
//

import Foundation

extension String {
  
  public func padWithNull(length:Int) -> [UInt8] {
      
    var data : [UInt8] = []
    
    for byte in self.prefix(length - 1).utf8 {
      data.append(byte)
    }
    
    for _ in 1 ... length - data.count {
      data.append(0)
    }
      
    return data

  }
  
  public var sortValue : String {
    var temp = self
    var prefix = ""
    var suffix = ""
    while !temp.isEmpty {
      let test = temp.removeLast()
      if test.isNumber {
        suffix = "\(test)\(suffix)"
      }
      else {
        prefix = temp
        break
      }
    }
    if suffix.isEmpty {
      return self
    }
    suffix = "00000000" + suffix
    return "\(prefix)\(suffix.suffix(8))"
  }

  
}
