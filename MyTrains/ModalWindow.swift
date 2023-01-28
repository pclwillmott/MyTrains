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
  case EditCommandStations               = "EditCommandStations"
  case EditNetworks                      = "EditNetworks"
  case EditLayouts                       = "EditLayouts"
  case EditLocomotives                   = "EditLocomotives"
  case EditWagons                        = "EditWagons"
  case EditTrains                        = "EditTrains"
  case EditSensors                       = "EditSensors"
  case EditSwitches                      = "EditSwitches"
  case EditInterfaces                    = "EditInterfaces"
  case Throttle                          = "Throttle"
  case ProgramDecoderAddress             = "ProgramDecoderAddress"
  case SlotView                          = "SlotView"
  case CommandStationConfiguration       = "CommandStationConfiguration"
  case DashBoard                         = "DashBoard"
  case GroupSetup                        = "GroupSetup"
  case SwitchBoardEditor                 = "SwitchBoardEditor"
  case UpdateFirmware                    = "UpdateFirmware"
  case SwitchBoardItemPropertySheet      = "SwitchBoardItemPropertySheet"
  case AddressManager                    = "AddressManager"
  case SpeedProfiler                     = "SpeedProfiler"
  case PlaceLocomotive                   = "PlaceLocomotive"
  case PurgeProfiler                     = "PurgeProfiler"
  case LocomotiveRoster                  = "LocomotiveRoster"
  case RouteManager                      = "RouteManager"
  case Bridge                            = "Bridge"
  case SetFastClock                      = "SetFastClock"
  case FastClockTester                   = "FastClockTester"
  case TC64Config                        = "TC64Config"
  case IODeviceManager                   = "IODeviceManager"
  case IODeviceNew                       = "IODeviceNew"
  case IODeviceDS64PropertySheet         = "IODeviceDS64PropertySheet"
  case IOFunctionDS64InputPropertySheet  = "IOFunctionDS64InputPropertySheet"
  case IOFunctionDS64OutputPropertySheet = "IOFunctionDS64OutputPropertySheet"
  case IODeviceBXP88PropertySheet        = "IODeviceBXP88PropertySheet"
  case IOFunctionBXP88InputPropertySheet = "IOFunctionBXP88InputPropertySheet"
  case IODeviceTC64MkIIPropertySheet     = "IODeviceTC64MkIIPropertySheet"
  case IOChannelTC64MkIIInputPropertySheet   = "IOChannelTC64MkIIInputPropertySheet"
  case IOChannelTC64MkIIOutputPropertySheet  = "IOChannelTC64MkIIOutputPropertySheet"
  case IOFunctionTC64MkIIInputPropertySheet  = "IOFunctionTC64MkIIInputPropertySheet"
  case IOFunctionTC64MkIIOutputPropertySheet = "IOFunctionTC64MkIIOutputPropertySheet"

  var instance : NSStoryboard {
    return NSStoryboard(name: self.rawValue, bundle: Bundle.main)
  }
  
}

let storyboardLookup : [String:AppStoryboard] = [
  "Monitor"                           : AppStoryboard.Monitor,
  "Main"                              : AppStoryboard.Main,
  "EditCommandStations"               : AppStoryboard.EditCommandStations,
  "EditNetworks"                      : AppStoryboard.EditNetworks,
  "EditLayouts"                       : AppStoryboard.EditLayouts,
  "EditLocomotives"                   : AppStoryboard.EditLocomotives,
  "EditWagons"                        : AppStoryboard.EditWagons,
  "EditTrains"                        : AppStoryboard.EditTrains,
  "EditSensors"                       : AppStoryboard.EditSensors,
  "EditSwitches"                      : AppStoryboard.EditSwitches,
  "EditInterfaces"                    : AppStoryboard.EditInterfaces,
  "Throttle"                          : AppStoryboard.Throttle,
  "ProgramDecoderAddress"             : AppStoryboard.ProgramDecoderAddress,
  "SlotView"                          : AppStoryboard.SlotView,
  "CommandStationConfiguration"       : AppStoryboard.CommandStationConfiguration,
  "DashBoard"                         : AppStoryboard.DashBoard,
  "GroupSetup"                        : AppStoryboard.GroupSetup,
  "SwitchBoardEditor"                 : AppStoryboard.SwitchBoardEditor,
  "UpdateFirmware"                    : AppStoryboard.UpdateFirmware,
  "SwitchBoardItemPropertySheet"      : AppStoryboard.SwitchBoardItemPropertySheet,
  "AddressManager"                    : AppStoryboard.AddressManager,
  "SpeedProfiler"                     : AppStoryboard.SpeedProfiler,
  "PlaceLocomotive"                   : AppStoryboard.PlaceLocomotive,
  "PurgeProfiler"                     : AppStoryboard.PurgeProfiler,
  "LocomotiveRoster"                  : AppStoryboard.LocomotiveRoster,
  "RouteManager"                      : AppStoryboard.RouteManager,
  "Bridge"                            : AppStoryboard.Bridge,
  "SetFastClock"                      : AppStoryboard.SetFastClock,
  "FastClockTester"                   : AppStoryboard.FastClockTester,
  "TC64Config"                        : AppStoryboard.TC64Config,
  "IODeviceManager"                   : AppStoryboard.IODeviceManager,
  "IODeviceNew"                       : AppStoryboard.IODeviceNew,
  "IODeviceDS64PropertySheet"         : AppStoryboard.IODeviceDS64PropertySheet,
  "IOFunctionDS64InputPropertySheet"  : AppStoryboard.IOFunctionDS64InputPropertySheet,
  "IOFunctionDS64OutputPropertySheet" : AppStoryboard.IOFunctionDS64OutputPropertySheet,
  "IODeviceBXP88PropertySheet"        : AppStoryboard.IODeviceBXP88PropertySheet,
  "IOFunctionBXP88InputPropertySheet" : AppStoryboard.IOFunctionBXP88InputPropertySheet,
  "IODeviceTC64MkIIPropertySheet"     : AppStoryboard.IODeviceTC64MkIIPropertySheet,
  "IOChannelTC64MkIIInputPropertySheet"   : AppStoryboard.IOChannelTC64MkIIInputPropertySheet,
  "IOChannelTC64MkIIOutputPropertySheet"  : AppStoryboard.IOChannelTC64MkIIOutputPropertySheet,
  "IOFunctionTC64MkIIInputPropertySheet"  : AppStoryboard.IOFunctionTC64MkIIInputPropertySheet,
  "IOFunctionTC64MkIIOutputPropertySheet" : AppStoryboard.IOFunctionTC64MkIIOutputPropertySheet,
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
  case EditCommandStations               = "EditCommandStations"
  case EditNetworks                      = "EditNetworks"
  case EditLayouts                       = "EditLayouts"
  case EditLocomotives                   = "EditLocomotives"
  case EditWagons                        = "EditWagons"
  case EditTrains                        = "EditTrains"
  case EditSensors                       = "EditSensors"
  case EditSwitches                      = "EditSwitches"
  case EditInterfaces                    = "EditInterfaces"
  case Throttle                          = "Throttle"
  case ProgramDecoderAddress             = "ProgramDecoderAddress"
  case SlotView                          = "SlotView"
  case CommandStationConfiguration       = "CommandStationConfiguration"
  case DashBoard                         = "DashBoard"
  case GroupSetup                        = "GroupSetup"
  case SwitchBoardEditor                 = "SwitchBoardEditor"
  case UpdateFirmware                    = "UpdateFirmware"
  case SwitchBoardItemPropertySheet      = "SwitchBoardItemPropertySheet"
  case AddressManager                    = "AddressManager"
  case SpeedProfiler                     = "SpeedProfiler"
  case PlaceLocomotive                   = "PlaceLocomotive"
  case PurgeProfiler                     = "PurgeProfiler"
  case LocomotiveRoster                  = "LocomotiveRoster"
  case RouteManager                      = "RouteManager"
  case Bridge                            = "Bridge"
  case SetFastClock                      = "SetFastClock"
  case FastClockTester                   = "FastClockTester"
  case TC64Config                        = "TC64Config"
  case IODeviceManager                   = "IODeviceManager"
  case IODeviceNew                       = "IODeviceNew"
  case IODeviceDS64PropertySheet         = "IODeviceDS64PropertySheet"
  case IOFunctionDS64InputPropertySheet  = "IOFunctionDS64InputPropertySheet"
  case IOFunctionDS64OutputPropertySheet = "IOFunctionDS64OutputPropertySheet"
  case IODeviceBXP88PropertySheet        = "IODeviceBXP88PropertySheet"
  case IOFunctionBXP88InputPropertySheet = "IOFunctionBXP88InputPropertySheet"
  case IODeviceTC64MkIIPropertySheet     = "IODeviceTC64MkIIPropertySheet"
  case IOChannelTC64MkIIInputPropertySheet   = "IOChannelTC64MkIIInputPropertySheet"
  case IOChannelTC64MkIIOutputPropertySheet  = "IOChannelTC64MkIIOutputPropertySheet"
  case IOFunctionTC64MkIIInputPropertySheet  = "IOFunctionTC64MkIIInputPropertySheet"
  case IOFunctionTC64MkIIOutputPropertySheet = "IOFunctionTC64MkIIOutputPropertySheet"

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
