//
//  DCCCVAccessMode.swift
//  MyTrains
//
//  Created by Paul Willmott on 02/12/2023.
//

import Foundation

public enum DCCCVAccessMode : UInt8 {
  
  case readByte        = 0b0100
  case writeByte       = 0b1100
  
}
