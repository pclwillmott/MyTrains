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
  static let TRAIN                       = "TRAIN"
  static let SWITCHBOARD_PANEL           = "SWITCHBOARD_PANEL"
  static let SWITCHBOARD_ITEM            = "SWITCHBOARD_ITEM"
  static let MEMORY_SPACE                = "MEMORY_SPACE"
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

enum SWITCHBOARD_PANEL {
  static let SWITCHBOARD_PANEL_ID        = "SWITCHBOARD_PANEL_ID"
  static let LAYOUT_ID                   = "LAYOUT_ID"
  static let PANEL_ID                    = "PANEL_ID"
  static let PANEL_NAME                  = "PANEL_NAME"
  static let NUMBER_OF_COLUMNS           = "NUMBER_OF_COLUMNS"
  static let NUMBER_OF_ROWS              = "NUMBER_OF_ROWS"
}

enum SWITCHBOARD_ITEM {
  static let SWITCHBOARD_ITEM_ID           = "SWITCHBOARD_ITEM_ID"
  static let LAYOUT_ID                     = "LAYOUT_ID"
  static let PANEL_ID                      = "PANEL_ID"
  static let GROUP_ID                      = "GROUP_ID"
  static let ITEM_PART_TYPE                = "ITEM_PART_TYPE"
  static let ORIENTATION                   = "ORIENTATION"
  static let XPOS                          = "XPOS"
  static let YPOS                          = "YPOS"
  static let BLOCK_NAME                    = "BLOCK_NAME"
  static let BLOCK_DIRECTION               = "BLOCK_DIRECTION"
  static let TRACK_PART_ID                 = "TRACK_PART_ID"
  static let DIMENSIONA                    = "DIMENSIONA"
  static let DIMENSIONB                    = "DIMENSIONB"
  static let DIMENSIONC                    = "DIMENSIONC"
  static let DIMENSIOND                    = "DIMENSIOND"
  static let DIMENSIONE                    = "DIMENSIONE"
  static let DIMENSIONF                    = "DIMENSIONF"
  static let DIMENSIONG                    = "DIMENSIONG"
  static let DIMENSIONH                    = "DIMENSIONH"
  static let UNITS_DIMENSION               = "UNITS_DIMENSION"
  static let ALLOW_SHUNT                   = "ALLOW_SHUNT"
  static let TRACK_GAUGE                   = "TRACK_GAUGE"
  static let TRACK_ELECTRIFICATION_TYPE    = "TRACK_ELECTRIFICATION_TYPE"
  static let GRADIENT                      = "GRADIENT"
  static let IS_CRITICAL                   = "IS_CRITICAL"
  static let UNITS_SPEED                   = "UNITS_SPEED"
  static let DN_UNITS_POSITION             = "DN_UNITS_POSITION"
  static let DP_UNITS_POSITION             = "DP_UNITS_POSITION"
  static let DN_BRAKE_POSITION             = "DN_BRAKE_POSITION"
  static let DN_STOP_POSITION              = "DN_STOP_POSITION"
  static let DN_SPEED_MAX                  = "DN_SPEED_MAX"
  static let DN_SPEED_STOP_EXPECTED        = "DN_SPEED_STOP_EXPECTED"
  static let DN_SPEED_RESTRICTED           = "DN_SPEED_RESTRICTED"
  static let DN_SPEED_BRAKE                = "DN_SPEED_BRAKE"
  static let DN_SPEED_SHUNT                = "DN_SPEED_SHUNT"
  static let DN_SPEED_MAX_UD               = "DN_SPEED_MAX_UD"
  static let DN_SPEED_STOP_EXPECTED_UD     = "DN_SPEED_STOP_EXPECTED_UD"
  static let DN_SPEED_RESTRICTED_UD        = "DN_SPEED_RESTRICTED_UD"
  static let DN_SPEED_BRAKE_UD             = "DN_SPEED_BRAKE_UD"
  static let DN_SPEED_SHUNT_UD             = "DN_SPEED_SHUNT_UD"
  static let DP_BRAKE_POSITION             = "DP_BRAKE_POSITION"
  static let DP_STOP_POSITION              = "DP_STOP_POSITION"
  static let DP_SPEED_MAX                  = "DP_SPEED_MAX"
  static let DP_SPEED_STOP_EXPECTED        = "DP_SPEED_STOP_EXPECTED"
  static let DP_SPEED_RESTRICTED           = "DP_SPEED_RESTRICTED"
  static let DP_SPEED_BRAKE                = "DP_SPEED_BRAKE"
  static let DP_SPEED_SHUNT                = "DP_SPEED_SHUNT"
  static let DP_SPEED_MAX_UD               = "DP_SPEED_MAX_UD"
  static let DP_SPEED_STOP_EXPECTED_UD     = "DP_SPEED_STOP_EXPECTED_UD"
  static let DP_SPEED_RESTRICTED_UD        = "DP_SPEED_RESTRICTED_UD"
  static let DP_SPEED_BRAKE_UD             = "DP_SPEED_BRAKE_UD"
  static let DP_SPEED_SHUNT_UD             = "DP_SPEED_SHUNT_UD"
  static let SW1_TURNOUT_MOTOR_TYPE        = "SW1_TURNOUT_MOTOR_TYPE"
  static let SW2_TURNOUT_MOTOR_TYPE        = "SW2_TURNOUT_MOTOR_TYPE"
  static let IS_SCENIC_SECTION             = "IS_SCENIC_SECTION"
  static let BLOCK_TYPE                    = "BLOCK_TYPE"
  static let LINK_ITEM                     = "LINK_ITEM"
  static let TURNOUT_CONNECTION            = "TURNOUT_CONNECTION"
  static let SENSOR_POSITION               = "SENSOR_POSITION"
  static let UNITS_SENSOR_POSITION         = "UNITS_SENSOR_POSITION"
  static let ENTER_OCCUPANCY_EVENT_ID      = "ENTER_OCCUPANCY_EVENT_ID"
  static let EXIT_OCCUPANCY_EVENT_ID       = "EXIT_OCCUPANCY_EVENT_ID"
  static let TRANSPONDER_EVENT_ID          = "TRANSPONDER_EVENT_ID"
  static let TRACK_FAULT_EVENT_ID          = "TRACK_FAULT_EVENT_ID"
  static let TRACK_FAULT_CLEARED_EVENT_ID  = "TRACK_FAULT_CLEARED_EVENT_ID"
  static let SW1_THROWN_EVENT_ID           = "SW1_THROWN_EVENT_ID"
  static let SW1_CLOSED_EVENT_ID           = "SW1_CLOSED_EVENT_ID"
  static let SW1_THROW_EVENT_ID            = "SW1_THROW_EVENT_ID"
  static let SW1_CLOSE_EVENT_ID            = "SW1_CLOSE_EVENT_ID"
  static let SW2_THROWN_EVENT_ID           = "SW2_THROWN_EVENT_ID"
  static let SW2_CLOSED_EVENT_ID           = "SW2_CLOSED_EVENT_ID"
  static let SW2_THROW_EVENT_ID            = "SW2_THROW_EVENT_ID"
  static let SW2_CLOSE_EVENT_ID            = "SW2_CLOSE_EVENT_ID"
  static let SW1_COMMANDED_THROWN_EVENT_ID = "SW1_COMMANDED_THROWN_EVENT_ID"
  static let SW1_COMMANDED_CLOSED_EVENT_ID = "SW1_COMMANDED_CLOSED_EVENT_ID"
  static let SW2_COMMANDED_THROWN_EVENT_ID = "SW2_COMMANDED_THROWN_EVENT_ID"
  static let SW2_COMMANDED_CLOSED_EVENT_ID = "SW2_COMMANDED_CLOSED_EVENT_ID"
}

enum MEMORY_SPACE {
  static let MEMORY_SPACE_ID             = "MEMORY_SPACE_ID"
  static let NODE_ID                     = "NODE_ID"
  static let SPACE                       = "SPACE"
  static let MEMORY                      = "MEMORY"
}
