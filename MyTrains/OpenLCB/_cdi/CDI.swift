//
//  CDI.swift
//  MyTrains
//
//  Created by Paul Willmott on 14/01/2024.
//

import Foundation

enum CDI {
  static let ACDI                       = "%%ACDI%%"
  static let MANUFACTURER               = "%%MANUFACTURER%%"
  static let MODEL                      = "%%MODEL%%"
  static let HARDWARE_VERSION           = "%%HARDWARE_VERSION%%"
  static let SOFTWARE_VERSION           = "%%SOFTWARE_VERSION%%"
  static let LAYOUT_SCALE               = "%%LAYOUT_SCALE"
  static let PORTS                      = "%%PORTS%%"
  static let LOCONET_GATEWAYS           = "%%LOCONET_GATEWAYS%%"
  static let FUNCTIONS_MAP              = "%%FUNCTIONS_MAP%%"
  static let PARITY                     = "%%PARITY%%"
  static let FLOW_CONTROL               = "%%FLOW_CONTROL%%"
  static let BAUD_RATE                  = "%%BAUD_RATE%%"
  static let CLOCK_OPERATING_MODE       = "%%CLOCK_OPERATING_MODE%%"
  static let CLOCK_TYPE                 = "%%CLOCK_TYPE%%"
  static let CLOCK_STATE                = "%%CLOCK_STATE%%"
  static let CLOCK_INITIAL_DATE_TIME    = "%%CLOCK_INITIAL_DATE_TIME%%"
  static let CLOCK_CUSTOM_ID_TYPE       = "%%CLOCK_CUSTOM_ID_TYPE%%"
  static let ENABLE_STATE               = "%%ENABLE_STATE%%"
  static let LAYOUT_STATE               = "%%LAYOUT_STATE%%"
  static let VIRTUAL_NODE_TYPE          = "%%VIRTUAL_NODE_TYPE%%"
  static let LAYOUT_NODES               = "%%LAYOUT_NODES%%"
  static let VIRTUAL_NODE_CONFIG        = "%%VIRTUAL_NODE_CONFIG%%"
  static let TURNOUT_MOTOR_TYPE         = "%%TURNOUT_MOTOR_TYPE%%"
  static let UNIT_LENGTH                = "%%UNIT_LENGTH%%"
  static let UNIT_SPEED                 = "%%UNIT_SPEED%%"
  static let TRACK_CODE                 = "%%TRACK_CODE%%"
  static let TRACK_GAUGE                = "%%TRACK_GAUGE%%"
  static let ALL_TRACK_GAUGES           = "%%ALL_TRACK_GAUGES%%"
  static let TRACK_ELECTRIFICATION_TYPE = "%%TRACK_ELECTRIFICATION_TYPE%%"
  static let ORIENTATION                = "%%ORIENTATION%%"
  static let COUNTRY_CODE               = "%%COUNTRY_CODE%%"
  static let SWITCHBOARD_ITEM_TYPE      = "%%SWITCHBOARD_ITEM_TYPE%%"
  static let SWITCHBOARD_PANEL_NODES    = "%%SWITCHBOARD_PANEL_NODES%%"
  static let DIRECTIONALITY             = "%%DIRECTIONALITY%%"
  static let YES_NO                     = "%%YES_NO%%"
  static let SWITCHBOARD_GROUP_NODES    = "%%SWITCHBOARD_GROUP_NODES%%"
  static let TRACK_PART                 = "%%TRACK_PART%%"
  static let ACTUAL_LENGTH_UNITS        = "%%ACTUAL_LENGTH_UNITS%%"
  static let ROUTE_DIMENSION            = "%%ROUTE_DIMENSION%%"
  static let TURNOUT_SWITCHES           = "%%TURNOUT_SWITCHES%%"
  static let UNIT_TIME                  = "%%UNIT_TIME%%"
}

