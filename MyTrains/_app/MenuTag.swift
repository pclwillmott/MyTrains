//
//  MenuTag.swift
//  MyTrains
//
//  Created by Paul Willmott on 02/03/2024.
//

import Foundation
import AppKit

public enum MenuTag : Int {
  
  // Values below 1000 map to the MyTrainsVirtualNodeType raw values
  
  case newCANGateway            = 1
  case newClock                 = 2
  case newThrottle              = 3
  case newLocoNetGateway        = 4
  case newTrain                 = 5
  case newLocoNetMonitor        = 8
  case newDCCProgrammerTrack    = 10
  case newDigitraxBXP88         = 11
  case newLayout                = 12
  
  case myTrains                 = 1000
//  case file                   = 1001
  case new                      = 1002
  case edit                     = 1003
//  case format                 = 1004
  case view                     = 1005
  case operations               = 1006
  case configuration            = 1007
  case tools                    = 1008
  case window                   = 1009
//  case help                   = 1010
  case globalEmergencyStop      = 3011
  case clearGlobalEmergencyStop = 3012
  case globalPowerOff           = 3013
  case globalPowerOn            = 3014
  case throttle                 = 3015
  case selectLayout             = 3016
  case configLCCNetwork         = 3017
  case configClock              = 3018
  case dccProgrammerTool        = 3019
  case layoutBuilder            = 3020
  case trainSpeedProfiler       = 3021
  case locoNetFirmwareUpdate    = 3022
  case locoNetWirelessSetup     = 3023
  case lccTrafficMonitor        = 3024
  case locoNetSlotView          = 3025
  case locoNetTrafficMonitor    = 3026
  case locoNetDashboard         = 3027
  case about                    = 3028
  case preferences              = 3029
  case quit                     = 3030
  case separator                = 9999
  case hideMyTrains             = 3031
  case hideOthers               = 3032
  case showAll                  = 3033
  case cut                      = 3034
  case copy                     = 3035
  case paste                    = 3036
  case selectAll                = 3037
  case enterFullScreen          = 3038
  case minimize                 = 3039
  case bringAllToFront          = 3040
  case createApplicationNode    = 3041
  case resetToFactoryDefaults   = 3042
  case rebootApplication        = 3043
  case panelView                = 3044
  
  // MARK: Public Properties
  
  public var title : String {
    return MenuTag.titles[self]!
  }
  
  public var isSystem : Bool {
    
    let systemTags : Set<MenuTag> = [
      .quit,
      .hideMyTrains,
      .hideOthers,
      .showAll,
      .cut,
      .copy,
      .paste,
      .selectAll,
      .enterFullScreen,
      .minimize,
      .bringAllToFront,
    ]
    
    return systemTags.contains(self)
    
  }
  
  // MARK: Public Methods
  
  public func isValid(state:OpenLCBNetworkLayerState) -> Bool {
    
    guard let validStates = MenuTag.validStates[self] else {
      #if DEBUG
      debugLog("menu tag not found in \"validStates\"")
      #endif
      return false
    }
    
    var result = validStates.contains(state)
    
    if let networkLayer = appDelegate.networkLayer {
      
      if MenuTag.requireSelectedLayoutId.contains(self) {
        
        if (networkLayer.layoutNodeId == nil) {
          result = false
        }
        else if let layoutNodeId = networkLayer.layoutNodeId, !networkLayer.virtualNodeLookup.keys.contains(layoutNodeId) {
          result = false
        }
        
      }
      else if self == .newLayout && networkLayer.layoutNodeId != nil {
        result = false
      }
      
    }
    
    return result
    
  }
  
  private static let requireSelectedLayoutId : Set<MenuTag> = [
    .newClock,
    .newTrain,
    .newThrottle,
    .newDigitraxBXP88,
    .newLocoNetGateway,
    .newLocoNetMonitor,
    .newDCCProgrammerTrack,
  ]
  
  // MARK: Private Static Properties
  
  private static let titles : [MenuTag:String] = [
    .myTrains                 : String(localized: "MyTrains",                              comment: "Used for a menu title"),
//  .file                     : String(localized: "File",                                  comment: "Used for a menu title"),
    .new                      : String(localized: "New",                                   comment: "Used for a menu title"),
    .edit                     : String(localized: "Edit",                                  comment: "Used for a menu title"),
//  .format                   : String(localized: "Format",                                comment: "Used for a menu title"),
    .view                     : String(localized: "View",                                  comment: "Used for a menu title"),
    .operations               : String(localized: "Operations",                            comment: "Used for a menu title"),
    .configuration            : String(localized: "Configuration",                         comment: "Used for a menu title"),
    .tools                    : String(localized: "Tools",                                 comment: "Used for a menu title"),
    .window                   : String(localized: "Window",                                comment: "Used for a menu title"),
//  .help                     : String(localized: "Help",                                  comment: "Used for a menu title"),
    .newLayout                : String(localized: "Layout",                                comment: "Used for a menu title"),
    .newThrottle              : String(localized: "Throttle",                              comment: "Used for a menu title"),
    .newTrain                 : String(localized: "Train",                                 comment: "Used for a menu title"),
    .newCANGateway            : String(localized: "CAN Gateway",                           comment: "Used for a menu title"),
    .newClock                 : String(localized: "Clock",                                 comment: "Used for a menu title"),
    .newLocoNetGateway        : String(localized: "LocoNet Gateway",                       comment: "Used for a menu title"),
    .newDCCProgrammerTrack    : String(localized: "DCC Programmer Track",                  comment: "Used for a menu title"),
    .newDigitraxBXP88         : String(localized: "Digitrax BXP88",                        comment: "Used for a menu title"),
    .newLocoNetMonitor        : String(localized: "LocoNet Monitor",                       comment: "Used for a menu title"),
    .globalEmergencyStop      : String(localized: "Global Emergency Stop",                 comment: "Used for a menu title"),
    .clearGlobalEmergencyStop : String(localized: "Clear Global Emergency Stop",           comment: "Used for a menu title"),
    .globalPowerOff           : String(localized: "Global Power Off",                      comment: "Used for a menu title"),
    .globalPowerOn            : String(localized: "Global Power On",                       comment: "Used for a menu title"),
    .throttle                 : String(localized: "Throttle",                              comment: "Used for a menu title"),
    .selectLayout             : String(localized: "Select Layout",                         comment: "Used for a menu title"),
    .configLCCNetwork         : String(localized: "LCC/OpenLCB Network",                   comment: "Used for a menu title"),
    .configClock              : String(localized: "Clock",                                 comment: "Used for a menu title"),
    .dccProgrammerTool        : String(localized: "DCC Programmer Tool",                   comment: "Used for a menu title"),
    .layoutBuilder            : String(localized: "Layout Builder",                        comment: "Used for a menu title"),
    .trainSpeedProfiler       : String(localized: "Train Speed Profiler",                  comment: "Used for a menu title"),
    .locoNetFirmwareUpdate    : String(localized: "LocoNet Firmware Update",               comment: "Used for a menu title"),
    .locoNetWirelessSetup     : String(localized: "LocoNet Wireless Setup",                comment: "Used for a menu title"),
    .lccTrafficMonitor        : String(localized: "LCC/OpenLCB Traffic Monitor",           comment: "Used for a menu title"),
    .locoNetSlotView          : String(localized: "LocoNet Slot View",                     comment: "Used for a menu title"),
    .locoNetTrafficMonitor    : String(localized: "LocoNet Traffic Monitor",               comment: "Used for a menu title"),
    .locoNetDashboard         : String(localized: "LocoNet Dashboard",                     comment: "Used for a menu title"),
    .about                    : String(localized: "About MyTrains",                        comment: "Used for a menu title"),
    .preferences              : String(localized: "Preferences",                           comment: "Used for a menu title"),
    .quit                     : String(localized: "Quit MyTrains",                         comment: "Used for a menu title"),
    .hideMyTrains             : String(localized: "Hide MyTrains",                         comment: "Used for a menu title"),
    .hideOthers               : String(localized: "Hide Others",                           comment: "Used for a menu title"),
    .showAll                  : String(localized: "Show All",                              comment: "Used for a menu title"),
    .cut                      : String(localized: "Cut",                                   comment: "Used for a menu title"),
    .copy                     : String(localized: "Copy",                                  comment: "Used for a menu title"),
    .paste                    : String(localized: "Paste",                                 comment: "Used for a menu title"),
    .selectAll                : String(localized: "Select All",                            comment: "Used for a menu title"),
    .enterFullScreen          : String(localized: "Enter Full Screen",                     comment: "Used for a menu title"),
    .minimize                 : String(localized: "Minimize",                              comment: "Used for a menu title"),
    .bringAllToFront          : String(localized: "Bring All to Front",                    comment: "Used for a menu title"),
    .createApplicationNode    : String(localized: "Application Node",                      comment: "Used for a menu title"),
    .rebootApplication        : String(localized: "Reboot Application",                    comment: "Used for a menu title"),
    .resetToFactoryDefaults   : String(localized: "Reset Application to Factory Defaults", comment: "Used for a menu title"),
    .panelView                : String(localized: "Panel View",                            comment: "Used for a menu title"),
  ]
  
  private static let validStates : [MenuTag:Set<OpenLCBNetworkLayerState>] = [
    .newCANGateway            : [.runningLocal, .runningNetwork],
    .newClock                 : [.runningNetwork],
    .newThrottle              : [.runningNetwork],
    .newLocoNetGateway        : [.runningNetwork],
    .newTrain                 : [.runningNetwork],
    .newLocoNetMonitor        : [.runningNetwork],
    .newDCCProgrammerTrack    : [.runningNetwork],
    .newDigitraxBXP88         : [.runningNetwork],
    .newLayout                : [.runningNetwork],
    .myTrains                 : [.uninitialized, .runningLocal, .runningNetwork, .stopping, .stopped, .rebooting],
    .new                      : [.uninitialized, .runningLocal, .runningNetwork, .stopping, .stopped, .rebooting],
    .edit                     : [.uninitialized, .runningLocal, .runningNetwork, .stopping, .stopped, .rebooting],
    .view                     : [.uninitialized, .runningLocal, .runningNetwork, .stopping, .stopped, .rebooting],
    .operations               : [.runningLocal, .runningNetwork],
    .configuration            : [.runningLocal, .runningNetwork],
    .tools                    : [.runningLocal, .runningNetwork],
    .window                   : [.uninitialized, .runningLocal, .runningNetwork, .stopping, .stopped, .rebooting],
    .globalEmergencyStop      : [.runningLocal, .runningNetwork],
    .clearGlobalEmergencyStop : [.runningLocal, .runningNetwork],
    .globalPowerOff           : [.runningLocal, .runningNetwork],
    .globalPowerOn            : [.runningLocal, .runningNetwork],
    .throttle                 : [.runningLocal, .runningNetwork],
    .selectLayout             : [.runningLocal, .runningNetwork],
    .configLCCNetwork         : [.runningLocal, .runningNetwork],
    .configClock              : [.runningLocal, .runningNetwork],
    .dccProgrammerTool        : [.runningLocal, .runningNetwork],
    .layoutBuilder            : [.runningNetwork],
    .trainSpeedProfiler       : [.runningLocal, .runningNetwork],
    .locoNetFirmwareUpdate    : [.runningLocal, .runningNetwork],
    .locoNetWirelessSetup     : [.runningLocal, .runningNetwork],
    .lccTrafficMonitor        : [.runningLocal, .runningNetwork],
    .locoNetSlotView          : [.runningLocal, .runningNetwork],
    .locoNetTrafficMonitor    : [.runningLocal, .runningNetwork],
    .locoNetDashboard         : [.runningLocal, .runningNetwork],
    .about                    : [.uninitialized, .runningLocal, .runningNetwork, .stopping, .stopped, .rebooting],
    .preferences              : [.runningLocal, .runningNetwork],
    .quit                     : [.uninitialized, .runningLocal, .runningNetwork, .stopping, .stopped, .rebooting],
    .separator                : [.uninitialized, .runningLocal, .runningNetwork, .stopping, .stopped, .rebooting],
    .hideMyTrains             : [.uninitialized, .runningLocal, .runningNetwork, .stopping, .stopped, .rebooting],
    .hideOthers               : [.uninitialized, .runningLocal, .runningNetwork, .stopping, .stopped, .rebooting],
    .showAll                  : [.uninitialized, .runningLocal, .runningNetwork, .stopping, .stopped, .rebooting],
    .cut                      : [.uninitialized, .runningLocal, .runningNetwork, .stopping, .stopped, .rebooting],
    .copy                     : [.uninitialized, .runningLocal, .runningNetwork, .stopping, .stopped, .rebooting],
    .paste                    : [.uninitialized, .runningLocal, .runningNetwork, .stopping, .stopped, .rebooting],
    .selectAll                : [.uninitialized, .runningLocal, .runningNetwork, .stopping, .stopped, .rebooting],
    .enterFullScreen          : [.uninitialized, .runningLocal, .runningNetwork, .stopping, .stopped, .rebooting],
    .minimize                 : [.uninitialized, .runningLocal, .runningNetwork, .stopping, .stopped, .rebooting],
    .bringAllToFront          : [.uninitialized, .runningLocal, .runningNetwork, .stopping, .stopped, .rebooting],
    .createApplicationNode    : [.uninitialized],
    .resetToFactoryDefaults   : [.runningLocal, .runningNetwork],
    .rebootApplication        : [.runningLocal, .runningNetwork],
    .panelView                : [.runningLocal, .runningNetwork],
  ]
  
}
