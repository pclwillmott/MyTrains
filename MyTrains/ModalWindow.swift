//
//  ModalWindow.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/11/2021.
//

import Foundation
import Cocoa

enum AppStoryboard : String {
  
  case Main                         = "Main"
  case Monitor                      = "Monitor"
  case EditCommandStations          = "EditCommandStations"
  case EditNetworks                 = "EditNetworks"
  case EditLayouts                  = "EditLayouts"
  case EditLocomotives              = "EditLocomotives"
  case EditWagons                   = "EditWagons"
  case EditTrains                   = "EditTrains"
  case EditSensors                  = "EditSensors"
  case EditSwitches                 = "EditSwitches"
  case EditInterfaces               = "EditInterfaces"
  case Throttle                     = "Throttle"
  case ProgramDecoderAddress        = "ProgramDecoderAddress"
  case SlotView                     = "SlotView"
  case CommandStationConfiguration  = "CommandStationConfiguration"
  case DashBoard                    = "DashBoard"
  case GroupSetup                   = "GroupSetup"
  case SwitchBoardEditor            = "SwitchBoardEditor"
  case UpdateFirmware               = "UpdateFirmware"
  case SwitchBoardItemPropertySheet = "SwitchBoardItemPropertySheet"
  case AddressManager               = "AddressManager"
  case SpeedProfiler                = "SpeedProfiler"
  case PlaceLocomotive              = "PlaceLocomotive"
  case PurgeProfiler                = "PurgeProfiler"
  
  var instance : NSStoryboard {
    return NSStoryboard(name: self.rawValue, bundle: Bundle.main)
  }
  
}

let storyboardLookup             : [String:AppStoryboard] = [
  "Monitor"                      : AppStoryboard.Monitor,
  "Main"                         : AppStoryboard.Main,
  "EditCommandStations"          : AppStoryboard.EditCommandStations,
  "EditNetworks"                 : AppStoryboard.EditNetworks,
  "EditLayouts"                  : AppStoryboard.EditLayouts,
  "EditLocomotives"              : AppStoryboard.EditLocomotives,
  "EditWagons"                   : AppStoryboard.EditWagons,
  "EditTrains"                   : AppStoryboard.EditTrains,
  "EditSensors"                  : AppStoryboard.EditSensors,
  "EditSwitches"                 : AppStoryboard.EditSwitches,
  "EditInterfaces"               : AppStoryboard.EditInterfaces,
  "Throttle"                     : AppStoryboard.Throttle,
  "ProgramDecoderAddress"        : AppStoryboard.ProgramDecoderAddress,
  "SlotView"                     : AppStoryboard.SlotView,
  "CommandStationConfiguration"  : AppStoryboard.CommandStationConfiguration,
  "DashBoard"                    : AppStoryboard.DashBoard,
  "GroupSetup"                   : AppStoryboard.GroupSetup,
  "SwitchBoardEditor"            : AppStoryboard.SwitchBoardEditor,
  "UpdateFirmware"               : AppStoryboard.UpdateFirmware,
  "SwitchBoardItemPropertySheet" : AppStoryboard.SwitchBoardItemPropertySheet,
  "AddressManager"               : AppStoryboard.AddressManager,
  "SpeedProfiler"                : AppStoryboard.SpeedProfiler,
  "PlaceLocomotive"              : AppStoryboard.PlaceLocomotive,
  "PurgeProfiler"                : AppStoryboard.PurgeProfiler,
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
  
  case Monitor                      = "Monitor"
  case Main                         = "Main"
  case EditCommandStations          = "EditCommandStations"
  case EditNetworks                 = "EditNetworks"
  case EditLayouts                  = "EditLayouts"
  case EditLocomotives              = "EditLocomotives"
  case EditWagons                   = "EditWagons"
  case EditTrains                   = "EditTrains"
  case EditSensors                  = "EditSensors"
  case EditSwitches                 = "EditSwitches"
  case EditInterfaces               = "EditInterfaces"
  case Throttle                     = "Throttle"
  case ProgramDecoderAddress        = "ProgramDecoderAddress"
  case SlotView                     = "SlotView"
  case CommandStationConfiguration  = "CommandStationConfiguration"
  case DashBoard                    = "DashBoard"
  case GroupSetup                   = "GroupSetup"
  case SwitchBoardEditor            = "SwitchBoardEditor"
  case UpdateFirmware               = "UpdateFirmware"
  case SwitchBoardItemPropertySheet = "SwitchBoardItemPropertySheet"
  case AddressManager               = "AddressManager"
  case SpeedProfiler                = "SpeedProfiler"
  case PlaceLocomotive              = "PlaceLocomotive"
  case PurgeProfiler                = "PurgeProfiler"

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
