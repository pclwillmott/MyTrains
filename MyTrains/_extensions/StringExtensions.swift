//
//  StringExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/05/2023.
//

import Foundation

extension String {
  
  public func padWithNull(length:Int) -> [UInt8] {
    let data = [UInt8](self.prefix(length).utf8)
    return data + [UInt8](repeating: 0, count: length - data.count)
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
