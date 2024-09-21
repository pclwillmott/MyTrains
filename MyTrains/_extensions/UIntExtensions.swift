//
//  UIntExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 09/04/2023.
//

import Foundation

extension UInt64 {
   
  public var nodeIdBigEndianData : [UInt8] {
    return [UInt8](self.bigEndianData.suffix(6))
  }

}

