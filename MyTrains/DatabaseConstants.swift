//
//  DatabaseConstants.swift
//  MyTrains
//
//  Created by Paul Willmott on 19/12/2021.
//

import Foundation

enum TABLE {
  static let VERSION                     = "VERSION"
  static let LAYOUT                      = "LAYOUT"
  static let NETWORK                     = "NETWORK"
  static let LOCONET_DEVICE              = "LOCONET_DEVICE"
  static let ROLLING_STOCK               = "ROLLING_STOCK"
  static let DECODER_FUNCTION            = "DECODER_FUNCTION"
  static let DECODER_CV                  = "DECODER_CV"
  static let SPEED_PROFILE               = "SPEED_PROFILE"
  static let TRAIN                       = "TRAIN"
  static let SWITCHBOARD_PANEL           = "SWITCHBOARD_PANEL"
  static let SWITCHBOARD_ITEM            = "SWITCHBOARD_ITEM"
  static let SENSOR                      = "SENSOR"
  static let TURNOUT_SWITCH              = "TURNOUT_SWITCH"
}

enum VERSION {
  static let VERSION_ID                  = "VERSION_ID"
  static let VERSION_NUMBER              = "VERSION_NUMBER"
}

enum LAYOUT {
  static let LAYOUT_ID                   = "LAYOUT_ID"
  static let LAYOUT_NAME                 = "LAYOUT_NAME"
  static let LAYOUT_DESCRIPTION          = "LAYOUT_DESCRIPTION"
  static let LAYOUT_SCALE                = "LAYOUT_SCALE"
}

enum NETWORK {
  static let NETWORK_ID                  = "NETWORK_ID"
  static let NETWORK_NAME                = "NETWORK_NAME"
  static let INTERFACE_ID                = "INTERFACE_ID"
  static let LAYOUT_ID                   = "LAYOUT_ID"
  static let LOCONET_ID                  = "LOCONET_ID"
  static let DUPLEX_GROUP_NAME           = "DUPLEX_GROUP_NAME"
  static let DUPLEX_GROUP_PASSWORD       = "DUPLEX_GROUP_PASSWORD"
  static let DUPLEX_GROUP_CHANNEL        = "DUPLEX_GROUP_CHANNEL"
  static let DUPLEX_GROUP_ID             = "DUPLEX_GROUP_ID"
  static let COMMAND_STATION_ID          = "COMMAND_STATION_ID"
}

enum LOCONET_DEVICE {
  static let LOCONET_DEVICE_ID           = "LOCONET_DEVICE_ID"
  static let NETWORK_ID                  = "NETWORK_ID"
  static let SERIAL_NUMBER               = "SERIAL_NUMBER"
  static let SOFTWARE_VERSION            = "SOFTWARE_VERSION"
  static let HARDWARE_VERSION            = "HARDWARE_VERSION"
  static let BOARD_ID                    = "BOARD_ID"
  static let LOCONET_PRODUCT_ID          = "LOCONET_PRODUCT_ID"
  static let OPTION_SWITCHES_0           = "OPTION_SWITCHES_0"
  static let OPTION_SWITCHES_1           = "OPTION_SWITCHES_1"
  static let OPTION_SWITCHES_2           = "OPTION_SWITCHES_2"
  static let OPTION_SWITCHES_3           = "OPTION_SWITCHES_3"
  static let DEVICE_PATH                 = "DEVICE_PATH"
  static let BAUD_RATE                   = "BAUD_RATE"
  static let DEVICE_NAME                 = "DEVICE_NAME"
  static let FLOW_CONTROL                = "FLOW_CONTROL"
  static let IS_STAND_ALONE_LOCONET      = "IS_STAND_ALONE_LOCONET"
  static let FLAGS                       = "FLAGS"
}

enum ROLLING_STOCK {
  static let ROLLING_STOCK_ID            = "ROLLING_STOCK_ID"
  static let ROLLING_STOCK_NAME          = "ROLLING_STOCK_NAME"
  static let NETWORK_ID                  = "NETWORK_ID"
  static let LENGTH                      = "LENGTH"
  static let ROLLING_STOCK_TYPE          = "ROLLING_STOCK_TYPE"
  static let MANUFACTURER_ID             = "MANUFACTURER_ID"
  static let MDECODER_MANUFACTURER_ID    = "MDECODER_MANUFACTURER_ID"
  static let MDECODER_MODEL              = "MDECODER_MODEL"
  static let MDECODER_ADDRESS            = "MDECODER_ADDRESS"
  static let ADECODER_MANUFACTURER_ID    = "ADECODER_MANUFACTURER_ID"
  static let ADECODER_MODEL              = "ADECODER_MODEL"
  static let ADECODER_ADDRESS            = "ADECODER_ADDRESS"
  static let SPEED_STEPS                 = "SPEED_STEPS"
  static let FBOFF_OCC_FRONT             = "FBOFF_OCC_FRONT"
  static let FBOFF_OCC_REAR              = "FBOFF_OCC_REAR"
  static let SCALE                       = "SCALE"
  static let TRACK_GAUGE                 = "TRACK_GUAGE"
  static let MAX_FORWARD_SPEED           = "MAX_FORWARD_SPEED"
  static let MAX_BACKWARD_SPEED          = "MAX_BACKWARD_SPEED"
  static let UNITS_LENGTH                = "UNITS_LENGTH"
  static let UNITS_FBOFF_OCC             = "UNITS_FBOFF_OCC"
  static let UNITS_SPEED                 = "UNITS_SPEED"
  static let INVENTORY_CODE              = "INVENTORY_CODE"
  static let PURCHASE_DATE               = "PURCHASE_DATE"
  static let NOTES                       = "NOTES"
  static let LOCOMOTIVE_TYPE             = "LOCOMOTIVE_TYPE"
  static let MDECODER_INSTALLED          = "MDECODER_INSTALLED"
  static let ADECODER_INSTALLED          = "ADECODER_INSTALLED"
  static let FLAGS                       = "FLAGS"
  static let BEST_FIT_METHOD             = "BEST_FIT_METHOD"
}

enum DECODER_FUNCTION {
  static let DECODER_FUNCTION_ID         = "DECODER_FUNCTION_ID"
  static let ROLLING_STOCK_ID            = "ROLLING_STOCK_ID"
  static let DECODER_TYPE                = "DECODER_TYPE"
  static let FUNCTION_NUMBER             = "FUNCTION_NUMBER"
  static let ENABLED                     = "ENABLED"
  static let FUNCTION_DESCRIPTION        = "FUNCTION_DESCRIPTION"
  static let MOMENTARY                   = "MOMENTARY"
  static let DURATION                    = "DURATION"
  static let INVERTED                    = "INVERTED"
  static let STATE                       = "STATE"
}

enum DECODER_CV {
  static let DECODER_CV_ID               = "DECODER_CV_ID"
  static let ROLLING_STOCK_ID            = "ROLLING_STOCK_ID"
  static let DECODER_TYPE                = "DECODER_TYPE"
  static let CV_NUMBER                   = "CV_NUMBER"
  static let CV_VALUE                    = "CV_VALUE"
  static let DEFAULT_VALUE               = "DEFAULT_VALUE"
  static let CUSTOM_DESCRIPTION          = "CUSTOM_DESCRIPTION"
  static let CUSTOM_NUMBER_BASE          = "CUSTOM_NUMBER_BASE"
  static let ENABLED                     = "ENABLED"
}

enum SPEED_PROFILE {
  static let SPEED_PROFILE_ID            = "SPEED_PROFILE_ID"
  static let ROLLING_STOCK_ID            = "ROLLING_STOCK_ID"
  static let STEP_NUMBER                 = "STEP_NUMBER"
  static let SPEED_FORWARD               = "SPEED_FORWARD"
  static let SPEED_REVERSE               = "SPEED_REVERSE"
}

enum SWITCHBOARD_PANEL {
  static let SWITCHBOARD_PANEL_ID        = "SWITCHBOARD_PANEL_ID"
  static let LAYOUT_ID                   = "LAYOUT_ID"
  static let PANEL_ID                    = "PANEL_ID"
  static let PANEL_NAME                  = "PANEL_NAME"
  static let NUMBER_OF_COLUMNS           = "NUMBER_OF_COLUMNS"
  static let NUMBER_OF_ROWS              = "NUMBER_OF_ROWS"
}

enum SWITCHBOARD_ITEM {
  static let SWITCHBOARD_ITEM_ID         = "SWITCHBOARD_ITEM_ID"
  static let LAYOUT_ID                   = "LAYOUT_ID"
  static let PANEL_ID                    = "PANEL_ID"
  static let GROUP_ID                    = "GROUP_ID"
  static let ITEM_PART_TYPE              = "ITEM_PART_TYPE"
  static let ORIENTATION                 = "ORIENTATION"
  static let XPOS                        = "XPOS"
  static let YPOS                        = "YPOS"
  static let BLOCK_NAME                  = "BLOCK_NAME"
  static let BLOCK_DIRECTION             = "BLOCK_DIRECTION"
  static let TRACK_PART_ID               = "TRACK_PART_ID"
  static let DIMENSIONA                  = "DIMENSIONA"
  static let DIMENSIONB                  = "DIMENSIONB"
  static let DIMENSIONC                  = "DIMENSIONC"
  static let DIMENSIOND                  = "DIMENSIOND"
  static let DIMENSIONE                  = "DIMENSIONE"
  static let DIMENSIONF                  = "DIMENSIONF"
  static let DIMENSIONG                  = "DIMENSIONG"
  static let DIMENSIONH                  = "DIMENSIONH"
  static let UNITS_DIMENSION             = "UNITS_DIMENSION"
  static let ALLOW_SHUNT                 = "ALLOW_SHUNT"
  static let TRACK_GAUGE                 = "TRACK_GAUGE"
  static let TRACK_ELECTRIFICATION_TYPE  = "TRACK_ELECTRIFICATION_TYPE"
  static let GRADIENT                    = "GRADIENT"
  static let IS_CRITICAL                 = "IS_CRITICAL"
  static let UNITS_SPEED                 = "UNITS_SPEED"
  static let DN_UNITS_POSITION           = "DN_UNITS_POSITION"
  static let DP_UNITS_POSITION           = "DP_UNITS_POSITION"
  static let DN_BRAKE_POSITION           = "DN_BRAKE_POSITION"
  static let DN_STOP_POSITION            = "DN_STOP_POSITION"
  static let DN_SPEED_MAX                = "DN_SPEED_MAX"
  static let DN_SPEED_STOP_EXPECTED      = "DN_SPEED_STOP_EXPECTED"
  static let DN_SPEED_RESTRICTED         = "DN_SPEED_RESTRICTED"
  static let DN_SPEED_BRAKE              = "DN_SPEED_BRAKE"
  static let DN_SPEED_SHUNT              = "DN_SPEED_SHUNT"
  static let DN_SPEED_MAX_UD             = "DN_SPEED_MAX_UD"
  static let DN_SPEED_STOP_EXPECTED_UD   = "DN_SPEED_STOP_EXPECTED_UD"
  static let DN_SPEED_RESTRICTED_UD      = "DN_SPEED_RESTRICTED_UD"
  static let DN_SPEED_BRAKE_UD           = "DN_SPEED_BRAKE_UD"
  static let DN_SPEED_SHUNT_UD           = "DN_SPEED_SHUNT_UD"
  static let DP_BRAKE_POSITION           = "DP_BRAKE_POSITION"
  static let DP_STOP_POSITION            = "DP_STOP_POSITION"
  static let DP_SPEED_MAX                = "DP_SPEED_MAX"
  static let DP_SPEED_STOP_EXPECTED      = "DP_SPEED_STOP_EXPECTED"
  static let DP_SPEED_RESTRICTED         = "DP_SPEED_RESTRICTED"
  static let DP_SPEED_BRAKE              = "DP_SPEED_BRAKE"
  static let DP_SPEED_SHUNT              = "DP_SPEED_SHUNT"
  static let DP_SPEED_MAX_UD             = "DP_SPEED_MAX_UD"
  static let DP_SPEED_STOP_EXPECTED_UD   = "DP_SPEED_STOP_EXPECTED_UD"
  static let DP_SPEED_RESTRICTED_UD      = "DP_SPEED_RESTRICTED_UD"
  static let DP_SPEED_BRAKE_UD           = "DP_SPEED_BRAKE_UD"
  static let DP_SPEED_SHUNT_UD           = "DP_SPEED_SHUNT_UD"
  static let SW1_LOCONET_DEVICE_ID       = "SW1_LOCONET_DEVICE_ID"
  static let SW1_PORT                    = "SW1_PORT"
  static let SW1_TURNOUT_MOTOR_TYPE      = "SW1_TURNOUT_MOTOR_TYPE"
  static let SW1_SENSOR_ID               = "SW1_SENSOR_ID"
  static let SW2_LOCONET_DEVICE_ID       = "SW2_LOCONET_DEVICE_ID"
  static let SW2_PORT                    = "SW2_PORT"
  static let SW2_TURNOUT_MOTOR_TYPE      = "SW2_TURNOUT_MOTOR_TYPE"
  static let SW2_SENSOR_ID               = "SW2_SENSOR_ID"
  static let IS_SCENIC_SECTION           = "IS_SCENIC_SECTION"
  static let BLOCK_TYPE                  = "BLOCK_TYPE"
  static let LINK_ITEM                   = "LINK_ITEM"
  static let TURNOUT_CONNECTION          = "TURNOUT_CONNECTION"
}

enum SENSOR {
  static let SENSOR_ID                   = "SENSOR_ID"
  static let SWITCHBOARD_ITEM_ID         = "SWITCHBOARD_ITEM_ID"
  static let LOCONET_DEVICE_ID           = "LOCONET_DEVICE_ID"
  static let CHANNEL_NUMBER              = "CHANNEL_NUMBER"
  static let MESSAGE_TYPE                = "MESSAGE_TYPE"
  static let SENSOR_TYPE                 = "SENSOR_TYPE"
  static let POSITION                    = "POSITION"
  static let UNITS_POSITION              = "UNITS_POSITION"
}

enum TURNOUT_SWITCH {
  static let TURNOUT_SWITCH_ID           = "TURNOUT_SWITCH_ID"
  static let LOCONET_DEVICE_ID           = "LOCONET_DEVICE_ID"
  static let SWITCHBOARD_ITEM_ID         = "SWITCHBOARD_ITEM_ID"
  static let TURNOUT_INDEX               = "TURNOUT_INDEX"
  static let CHANNEL_NUMBER              = "CHANNEL_NUMBER"
  static let FEEDBACK_TYPE               = "FEEDBACK_TYPE"
  static let SWITCH_TYPE                 = "SWITCH_TYPE"
}
