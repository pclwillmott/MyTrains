//
//  ModalWindow.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/11/2021.
//

import Foundation
import Cocoa

enum AppStoryboard : String {
  
  case Main                              = "Main"
  case Monitor                           = "Monitor"
  case EditLayouts                       = "EditLayouts"
  case EditWagons                        = "EditWagons"
  case EditTrains                        = "EditTrains"
  case EditSensors                       = "EditSensors"
  case EditSwitches                      = "EditSwitches"
  case Throttle                          = "Throttle"
  case SlotView                          = "SlotView"
  case DashBoard                         = "DashBoard"
  case GroupSetup                        = "GroupSetup"
  case SwitchBoardEditor                 = "SwitchBoardEditor"
  case UpdateFirmware                    = "UpdateFirmware"
  case SwitchBoardItemPropertySheet      = "SwitchBoardItemPropertySheet"
  case SpeedProfiler                     = "SpeedProfiler"
  case PlaceLocomotive                   = "PlaceLocomotive"
  case SetFastClock                      = "SetFastClock"
  case ViewLCCNetwork                    = "ViewLCCNetwork"
  case ViewNodeInfo                      = "ViewNodeInfo"
  case ProgrammerTool                    = "ProgrammerTool"
  case OpenLCBFirmwareUpdate             = "OpenLCBFirmwareUpdate"
  case OpenLCBMonitor                    = "OpenLCBMonitor"
  case ConfigurationTool                 = "ConfigurationTool"
  case CDITextView                       = "CDITextView"
  case SelectMasterNode                  = "SelectMasterNode"
  case CreateVirtualNode                 = "CreateVirtualNode"
  case SelectLayout                      = "SelectLayout"

  var instance : NSStoryboard {
    return NSStoryboard(name: self.rawValue, bundle: Bundle.main)
  }
  
}

let storyboardLookup : [String:AppStoryboard] = [
  "Monitor"                           : AppStoryboard.Monitor,
  "Main"                              : AppStoryboard.Main,
  "EditLayouts"                       : AppStoryboard.EditLayouts,
  "EditWagons"                        : AppStoryboard.EditWagons,
  "EditTrains"                        : AppStoryboard.EditTrains,
  "EditSensors"                       : AppStoryboard.EditSensors,
  "EditSwitches"                      : AppStoryboard.EditSwitches,
  "Throttle"                          : AppStoryboard.Throttle,
  "SlotView"                          : AppStoryboard.SlotView,
  "DashBoard"                         : AppStoryboard.DashBoard,
  "GroupSetup"                        : AppStoryboard.GroupSetup,
  "SwitchBoardEditor"                 : AppStoryboard.SwitchBoardEditor,
  "UpdateFirmware"                    : AppStoryboard.UpdateFirmware,
  "SwitchBoardItemPropertySheet"      : AppStoryboard.SwitchBoardItemPropertySheet,
  "SpeedProfiler"                     : AppStoryboard.SpeedProfiler,
  "PlaceLocomotive"                   : AppStoryboard.PlaceLocomotive,
  "SetFastClock"                      : AppStoryboard.SetFastClock,
  "ViewLCCNetwork"                    : AppStoryboard.ViewLCCNetwork,
  "ViewNodeInfo"                      : AppStoryboard.ViewNodeInfo,
  "ProgrammerTool"                    : AppStoryboard.ProgrammerTool,
  "OpenLCBFirmwareUpdate"             : AppStoryboard.OpenLCBFirmwareUpdate,
  "OpenLCBMonitor"                    : AppStoryboard.OpenLCBMonitor,
  "ConfigurationTool"                 : AppStoryboard.ConfigurationTool,
  "CDITextView"                       : AppStoryboard.CDITextView,
  "SelectMasterNode"                  : AppStoryboard.SelectMasterNode,
  "CreateVirtualNode"                 : AppStoryboard.CreateVirtualNode,
  "SelectLayout"                      : AppStoryboard.SelectLayout,
]

/*
 * 1) No spaces in identifiers
 * 2) Storyboard ID of WINDOW not VIEW of xxxWindowController
 * 3) Remember to ctrl+drag button to controller icon and select class to destroy instance
 * 4) View and Window controller instances named xxxViewController and xxxWindowController
 * 5) Turn off Minimize, Maxmize, Resize on Window Controller
 * 6) Add the turn off modal code
 */

enum ModalWindow : String {
  
  case Monitor                           = "Monitor"
  case Main                              = "Main"
  case EditLayouts                       = "EditLayouts"
  case EditWagons                        = "EditWagons"
  case EditTrains                        = "EditTrains"
  case EditSensors                       = "EditSensors"
  case EditSwitches                      = "EditSwitches"
  case Throttle                          = "Throttle"
  case SlotView                          = "SlotView"
  case DashBoard                         = "DashBoard"
  case GroupSetup                        = "GroupSetup"
  case SwitchBoardEditor                 = "SwitchBoardEditor"
  case UpdateFirmware                    = "UpdateFirmware"
  case SwitchBoardItemPropertySheet      = "SwitchBoardItemPropertySheet"
  case SpeedProfiler                     = "SpeedProfiler"
  case PlaceLocomotive                   = "PlaceLocomotive"
  case SetFastClock                      = "SetFastClock"
  case ViewLCCNetwork                    = "ViewLCCNetwork"
  case ViewNodeInfo                      = "ViewNodeInfo"
  case ProgrammerTool                    = "ProgrammerTool"
  case OpenLCBFirmwareUpdate             = "OpenLCBFirmwareUpdate"
  case OpenLCBMonitor                    = "OpenLCBMonitor"
  case ConfigurationTool                 = "ConfigurationTool"
  case CDITextView                       = "CDITextView"
  case SelectMasterNode                  = "SelectMasterNode"
  case CreateVirtualNode                 = "CreateVirtualNode"
  case SelectLayout                      = "SelectLayout"

  var windowController : NSWindowController {
    let storyboard = storyboardLookup[self.rawValue]!
    let wc = storyboard.instance.instantiateController(withIdentifier: "\(self.rawValue)WC") as! NSWindowController
    return wc
  }
  
  public func runModal(windowController: NSWindowController) {
    if let window = windowController.window {
      NSApplication.shared.runModal(for: window)
      window.close()
    }
  }

  public func runModel() {
    runModal(windowController: self.windowController)
  }
  
  public func viewController(windowController: NSWindowController) -> NSViewController {
    return windowController.window!.contentViewController! // as! xxxViewController
  }
  
}

func stopModal() {
  NSApplication.shared.stopModal()
}
