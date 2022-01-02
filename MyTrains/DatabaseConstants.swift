//
//  DatabaseConstants.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/12/2021.
//

import Foundation

enum TABLE {
  static let VERSION               = "VERSION"
  static let LAYOUT                = "LAYOUT"
  static let NETWORK               = "NETWORK"
  static let LOCOMOTIVE            = "LOCOMOTIVE"
  static let LOCOMOTIVE_FUNCTION   = "LOCOMOTIVE_FUNCTION"
  static let LOCOMOTIVE_SPEED      = "LOCOMOTIVE_SPEED"
  static let LOCOMOTIVE_CV         = "LOCOMOTIVE_CV"
  static let LOCOMOTIVE_PERMISSION = "LOCOMOTIVE_PERMISSION"
  static let SENSOR                = "SENSOR"
  static let SWITCH                = "SWITCH"
  static let BLOCK                 = "BLOCK"
  static let TRAIN                 = "TRAIN"
  static let WAGON                 = "WAGON"
  static let COMMAND_STATION       = "COMMAND_STATION"
  static let INTERFACE             = "INTERFACE"
}

enum VERSION {
  static let VERSION_ID            = "VERSION_ID"
  static let VERSION_NUMBER        = "VERSION_NUMBER"
}

enum NETWORK {
  static let NETWORK_ID            = "NETWORK_ID"
  static let NETWORK_NAME          = "NETWORK_NAME"
  static let COMMAND_STATION_ID    = "COMMAND_STATION_ID"
  static let LAYOUT_ID             = "LAYOUT_ID"
}

enum COMMAND_STATION {
  static let COMMAND_STATION_ID    = "COMMAND_STATION_ID"
  static let COMMAND_STATION_NAME  = "COMMAND_STATION_NAME"
  static let MANUFACTURER          = "MANUFACTURER"
  static let PRODUCT_CODE          = "PRODUCT_CODE"
  static let SERIAL_NUMBER         = "SERIAL_NUMBER"
  static let HARDWARE_VERSION      = "HARDWARE_VERSION"
  static let SOFTWARE_VERSION      = "SOFTWARE_VERSION"
}

enum INTERFACE {
  static let INTERFACE_ID          = "INTERFACE_ID"
  static let INTERFACE_NAME        = "INTERFACE_NAME"
  static let MANUFACTURER          = "MANUFACTURER"
  static let PRODUCT_CODE          = "PRODUCT_CODE"
  static let SERIAL_NUMBER         = "SERIAL_NUMBER"
  static let DEVICE_PATH           = "DEVICE_PATH"
  static let BAUD_RATE             = "BAUD_RATE"
}

enum LAYOUT {
  static let LAYOUT_ID             = "LAYOUT_ID"
  static let LAYOUT_NAME           = "LAYOUT_NAME"
  static let LAYOUT_DESCRIPTION    = "LAYOUT_DESCRIPTION"
  static let LAYOUT_SCALE          = "LAYOUT_SCALE"
}

enum LOCOMOTIVE {
  static let LOCOMOTIVE_ID         = "LOCOMOTIVE_ID"
  static let LOCOMOTIVE_NAME       = "LOCOMOTIVE_NAME"
  static let LOCOMOTIVE_TYPE       = "LOCOMOTIVE_TYPE"
  static let LENGTH                = "LENGTH"
  static let DECODER_TYPE          = "DECODER_TYPE"
  static let ADDRESS               = "ADDRESS"
  static let FBOFF_OCC_FRONT       = "FBOFF_OCC_FRONT"
  static let FBOFF_OCC_REAR        = "FBOFF_OCC_REAR"
  static let TRACK_GAUGE           = "TRACK_GUAGE"
  static let TRACK_RESTRICTION     = "TRACK_RESTRICTION"
  static let LOCOMOTIVE_SCALE      = "LOCOMOTIVE_SCALE"
  static let MAX_FORWARD_SPEED     = "MAX_FORWARD_SPEED"
  static let MAX_BACKWARD_SPEED    = "MAX_BACKWARD_SPEED"
  static let UNITS_LENGTH          = "UNITS_LENGTH"
  static let UNITS_FBOFF_OCC       = "UNITS_FBOFF_OCC"
  static let UNITS_SPEED           = "UNITS_SPEED"
  static let NETWORK_ID            = "NETWORK_ID"
}

enum LOCOMOTIVE_FUNCTION {
  static let FUNCTION_ID           = "FUNCTION_ID"
  static let LOCOMOTIVE_ID         = "LOCOMOTIVE_ID"
  static let FUNCTION_NUMBER       = "FUNCTION_NUMBER"
  static let ENABLED               = "ENABLED"
  static let FUNCTION_DESCRIPTION  = "FUNCTION_DESCRIPTION"
  static let MOMENTARY             = "MOMENTARY"
  static let DURATION              = "DURATION"
  static let INVERTED              = "INVERTED"
  static let STATE                 = "STATE"
}
