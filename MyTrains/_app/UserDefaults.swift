//
//  UserDefaults.swift
//  MyTrains
//
//  Created by Paul Willmott on 28/11/2021.
//

import Foundation

enum DEFAULT {

  static let APP_NODE_ID                        = "APP_NODE_ID"
  static let APP_MODE                           = "APP_MODE"
  static let APP_LAYOUT_ID                      = "APP_LAYOUT_ID"

  static let DATABASE_PATH                      = "DATABASE_PATH"
  static let LAST_CSV_PATH                      = "LAST_CSV_PATH"
  static let LAST_DMF_PATH                      = "LAST_DMF_PATH"
  static let EULA_ACCEPTED                      = "EULA_ACCEPTED"

  static let SWITCHBOARD_EDITOR_MAG             = "SWITCHBOARD_EDITOR_MAG"
  static let MAIN_SWITCHBOARD_MAG               = "MAIN_SWITCHBOARD_MAG"

  static let MONITOR_INTERFACE_ID               = "MonitorInterfaceId"
  static let MONITOR_SEND_FILENAME              = "MonitorSendFileName"
  static let MONITOR_CAPTURE_FILENAME           = "MonitorCaptureFileName"
  static let MONITOR_TIMESTAMP_TYPE             = "MonitorTimeStampType"
  static let MONITOR_DATA_TYPE                  = "MonitorDataType"
  static let MONITOR_NUMBER_BASE                = "MonitorNumberBase"
  static let MONITOR_ADD_BYTE_NUMBER            = "MonitorAddByteNumber"
  static let MONITOR_ADD_LABELS                 = "MonitorAddLabels"
  static let MONITOR_MESSAGE1                   = "MonitorMessage1"
  static let MONITOR_MESSAGE2                   = "MonitorMessage2"
  static let MONITOR_MESSAGE3                   = "MonitorMessage3"
  static let MONITOR_MESSAGE4                   = "MonitorMessage4"
  static let MONITOR_NOTE                       = "MonitorNote"

  static let MAIN_CURRENT_LAYOUT_ID             = "MainCurrentLayoutId"
  static let PROGRAMMER_PROG_MODE               = "ProgrammerProgMode"
  static let IPL_INTERFACE_ID                   = "IPLInterfaceId"
  static let IPL_DMF_FILENAME                   = "IPLDMFFileName"
  static let SPEED_PROFILER_TRENDLINE           = "SPEED_PROFILER_TRENDLINE"
  static let SPEED_PROFILER_LENGTH_UNITS        = "SPEED_PROFILER_LENGTH_UNITS"
  static let SPEED_PROFILER_RESULTS_TYPE        = "SPEED_PROFILER_RESULTS_TYPE"
  static let SPEED_PROFILER_SPEED_UNITS         = "SPEED_PROFILER_SPEED_UNITS"
  static let SPEED_PROFILER_START_STEP          = "SPEED_PROFILER_START_STEP"
  static let SPEED_PROFILER_STOP_STEP           = "SPEED_PROFILER_STOP_STEP"
  static let SPEED_PROFILER_SAMPLE_SIZE         = "SPEED_PROFILER_SAMPLE_SIZE"
  static let SLOT_VIEW_COMMAND_STATION          = "SLOT_VIEW_COMMAND_STATION"
  static let PURGE_PROFILER_COMMAND_STATION     = "PURGE_PROFILER_COMMAND_STATION"
  static let LOCOMOTIVE_ROSTER_COMMAND_STATION  = "LOCOMOTIVE_ROSTER_COMMAND_STATION"
  static let ROUTE_MANAGER_HOST                 = "ROUTE_MANAGER_HOST"
  static let BRIDGE_THROTTLE_NETWORK            = "BRIDGE_THROTTLE_NETWORK"
  static let BRIDGE_SLAVE_NETWORK               = "BRIDGE_SLAVE_NETWORK"
  static let FAST_CLOCK_DAY_OF_WEEK             = "FAST_CLOCK_DAY_OF_WEEK"
  static let FAST_CLOCK_REFERENCE_TIME          = "FAST_CLOCK_REFERENCE_TIME"
  static let FAST_CLOCK_EPOCH                   = "FAST_CLOCK_EPOCH"
  static let FAST_CLOCK_SCALE_FACTOR            = "FAST_CLOCK_SCALE_FACTOR"
  static let FC_TESTER_NETWORK_ID               = "FC_TESTER_NETWORK_ID"
  static let FC_TESTER_SCALE_FACTOR             = "FC_TESTER_SCALE_FACTOR"
  static let FC_TESTER_SAMPLE_RATE              = "FC_TESTER_SAMPLE_RATE"
  static let FC_TESTER_DAYS                     = "FC_TESTER_DAYS"
  static let TC64_CONFIG_INTERFACE              = "TC64_CONFIG_INTERFACE"
  static let TC64_CONFIG_LAST_DEVICE            = "TC64_CONFIG_LAST_DEVICE"
  static let IODEVICE_MANAGER_NETWORK           = "IODEVICE_MANAGER_NETWORK"
  static let PROGRAMMING_TRACK_ID               = "PROGRAMMING_TRACK_ID"
}

public var appNodeId : UInt64? {
  get {
    let id = UserDefaults.standard.integer(forKey: DEFAULT.APP_NODE_ID)
    return id == 0 ? nil : UInt64(bitPattern: Int64(id))
  }
  set(value) {
    if value != appNodeId {
      UserDefaults.standard.set(Int64(bitPattern: value ?? 0), forKey: DEFAULT.APP_NODE_ID)
    }
  }
}

public var appNode : OpenLCBNodeMyTrains? {
  guard let networkLayer = myTrainsController.openLCBNetworkLayer else {
    return nil
  }
  return networkLayer.myTrainsNode
}

public var appLayoutId : UInt64? {
  get {
    let id = UserDefaults.standard.integer(forKey: DEFAULT.APP_LAYOUT_ID)
    return id == 0 ? nil : UInt64(bitPattern: Int64(id))
  }
  set(value) {
    if value != appLayoutId {
      UserDefaults.standard.set(Int64(bitPattern: value ?? 0), forKey: DEFAULT.APP_LAYOUT_ID)
    }
  }
}

public var appMode : AppMode {
  get {
    return AppMode(rawValue: UserDefaults.standard.integer(forKey: DEFAULT.APP_MODE))!
  }
  set(value) {
    UserDefaults.standard.set(value.rawValue, forKey: DEFAULT.APP_MODE)
    menuUpdate()
  }
}

public var eulaAccepted : Bool {
  get {
    return UserDefaults.standard.bool(forKey: DEFAULT.EULA_ACCEPTED)
  }
  set(value) {
    UserDefaults.standard.set(value, forKey: DEFAULT.EULA_ACCEPTED)
  }
}

public var appVersion : String {
  return "Version \(Bundle.main.releaseVersionNumber!) (Build \(Bundle.main.buildVersionNumber!))"
}

public var appCopyright : String {
  if let result = Bundle.main.infoDictionary!["NSHumanReadableCopyright"] as? String {
    return result
  }
  return ""
}

public var databasePath : String? {
  get {
    return UserDefaults.standard.string(forKey: DEFAULT.DATABASE_PATH)
  }
  set(path) {
    if path == nil {
      UserDefaults.standard.removeObject(forKey: DEFAULT.DATABASE_PATH)
    }
    else {
      UserDefaults.standard.set(path, forKey: DEFAULT.DATABASE_PATH)
    }
  }
}

public var documentsPath : String {
  let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
  return paths[0]
}

public var lastCSVPath : URL? {
  get {
    if let path = UserDefaults.standard.url(forKey: DEFAULT.LAST_CSV_PATH) {
      return path
    }
    return URL(fileURLWithPath: documentsPath)
  }
  set(path) {
    UserDefaults.standard.set(path, forKey: DEFAULT.LAST_CSV_PATH)
  }
}

public var lastDMFPath : URL? {
  get {
    if let path = UserDefaults.standard.url(forKey: DEFAULT.LAST_DMF_PATH) {
      return path
    }
    return URL(fileURLWithPath: documentsPath)
  }
  set(path) {
    UserDefaults.standard.set(path, forKey: DEFAULT.LAST_DMF_PATH)
  }
}

public var switchboardEditorMagnification : CGFloat {
  get {
    let result = UserDefaults.standard.double(forKey: DEFAULT.SWITCHBOARD_EDITOR_MAG)
    return result == 0.0 ? 1.0 : result
  }
  set(value) {
    UserDefaults.standard.set(value, forKey: DEFAULT.SWITCHBOARD_EDITOR_MAG)
  }
}

public var mainSwitchboardMagnification : CGFloat {
  get {
    let result = UserDefaults.standard.double(forKey: DEFAULT.MAIN_SWITCHBOARD_MAG)
    return result == 0.0 ? 1.0 : result
  }
  set(value) {
    UserDefaults.standard.set(value, forKey: DEFAULT.MAIN_SWITCHBOARD_MAG)
  }
}
