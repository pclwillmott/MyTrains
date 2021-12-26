//
//  DatabaseConstants.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/12/2021.
//

import Foundation

enum TABLE {
  static let VERSION              = "VERSION"
  static let LAYOUT               = "LAYOUT"
  static let NETWORK              = "NETWORK"
  static let LOCOMOTIVE           = "LOCOMOTIVE"
  static let SENSOR               = "SENSOR"
  static let SWITCH               = "SWITCH"
  static let BLOCK                = "BLOCK"
  static let TRAIN                = "TRAIN"
  static let WAGON                = "WAGON"
  static let COMMAND_STATION      = "COMMAND_STATION"
}

enum VERSION {
  static let VERSION_ID           = "VERSION_ID"
  static let VERSION_NUMBER       = "VERSION_NUMBER"
}

enum NETWORK {
  static let NETWORK_ID           = "NETWORK_ID"
  static let NETWORK_NAME         = "NETWORK_NAME"
  static let COMMAND_STATION_ID   = "COMMAND_STATION_ID"
  static let LAYOUT_ID            = "LAYOUT_ID"
}

enum COMMAND_STATION {
  static let COMMAND_STATION_ID   = "COMMAND_STATION_ID"
  static let COMMAND_STATION_NAME = "COMMAND_STATION_NAME"
  static let MANUFACTURER         = "MANUFACTURER"
  static let PRODUCT_CODE         = "PRODUCT_CODE"
  static let SERIAL_NUMBER        = "SERIAL_NUMBER"
  static let HARDWARE_VERSION     = "HARDWARE_VERSION"
  static let SOFTWARE_VERSION     = "SOFTWARE_VERSION"
}

enum LAYOUT {
  static let LAYOUT_ID            = "LAYOUT_ID"
  static let LAYOUT_NAME          = "LAYOUT_NAME"
  static let LAYOUT_DESCRIPTION   = "LAYOUT_DESCRIPTION"
}
