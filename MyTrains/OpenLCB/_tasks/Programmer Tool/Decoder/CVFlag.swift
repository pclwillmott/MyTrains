//
//  CVFlag.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/07/2024.
//

import Foundation

public enum CVFlag : UInt64, CaseIterable {
  
  // MARK: Enumeration
  
  case isHidden   = 0x0000000000000100
  case isReadOnly = 0x0000000000000200
  
}
