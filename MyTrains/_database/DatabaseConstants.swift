//
//  DatabaseConstants.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/12/2021.
//

import Foundation

enum TABLE {
  static let VERSION                     = "VERSION"
  static let MEMORY_SPACE                = "MEMORY_SPACE"
}

enum VERSION {
  static let VERSION_ID                  = "VERSION_ID"
  static let VERSION_NUMBER              = "VERSION_NUMBER"
}

enum MEMORY_SPACE {
  static let MEMORY_SPACE_ID             = "MEMORY_SPACE_ID"
  static let NODE_ID                     = "NODE_ID"
  static let SPACE                       = "SPACE"
  static let MEMORY                      = "MEMORY"
}
