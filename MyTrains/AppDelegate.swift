//
//  AppDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/10/2021.
//

import Cocoa
import Foundation

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
  
  // MARK: App Control
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {

    if let _ = UserDefaults.standard.string(forKey: DEFAULT.VERSION) {
    }
    else {
      
      let appFolder  = "/MyTrains"
      let dataFolder = "/MyTrains Database"
      let savedCVsFolder = "/MyTrains Saved CVs"
      let DMFFolder = "/MyTrains DMF Files"

      UserDefaults.standard.set("Version 1.0", forKey: DEFAULT.VERSION)
      
      let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
      
      UserDefaults.standard.set(paths[0] + appFolder + dataFolder, forKey: DEFAULT.DATABASE_PATH)
      UserDefaults.standard.set(paths[0] + appFolder + savedCVsFolder, forKey: DEFAULT.SAVED_CVS_PATH)
      UserDefaults.standard.set(paths[0] + appFolder + DMFFolder, forKey: DEFAULT.DMF_PATH)
      UserDefaults.standard.set(LengthUnit.centimeters.rawValue, forKey: DEFAULT.UNITS_LENGTH)
      UserDefaults.standard.set(LengthUnit.centimeters.rawValue, forKey: DEFAULT.UNITS_FBOFF_OCC)
      UserDefaults.standard.set(SpeedUnit.kilometersPerHour.rawValue, forKey: DEFAULT.UNITS_SPEED)
      UserDefaults.standard.set(76.2, forKey: DEFAULT.SCALE)
      UserDefaults.standard.set(TrackGauge.oo.rawValue, forKey: DEFAULT.TRACK_GAUGE)

    }

  }
  
  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  // MARK: Edit Menu
  
  @IBAction func mnuEditLayoutsAction(_ sender: NSMenuItem) {
    ModalWindow.EditLayouts.runModel()
  }
  
  @IBAction func mnuEditComputerInterfaces(_ sender: NSMenuItem) {
    ModalWindow.EditInterfaces.runModel()
  }
  
  @IBAction func mnuEditNetworksAction(_ sender: NSMenuItem) {
    ModalWindow.EditNetworks.runModel()
  }
  
  @IBAction func mnuEditLocomotivesAction(_ sender: NSMenuItem) {
    ModalWindow.EditLocomotives.runModel()
  }
  
  @IBAction func mnuEditWagonsAction(_ sender: NSMenuItem) {
    ModalWindow.EditWagons.runModel()
  }
  
  @IBAction func mnuEditTrainsAction(_ sender: NSMenuItem) {
    ModalWindow.EditTrains.runModel()
  }
  
  @IBAction func mnuEditSensorsAction(_ sender: NSMenuItem) {
    ModalWindow.EditSensors.runModel()
  }
  
  @IBAction func mnuEditSwitchesAction(_ sender: NSMenuItem) {
    ModalWindow.EditSwitches.runModel()
  }
  
  @IBAction func mnuSwitchBoardEditor(_ sender: NSMenuItem) {
    ModalWindow.SwitchBoardEditor.runModel()
  }
  
  // MARK: Control Menu
  
  @IBAction func mnuThrottleAction(_ sender: Any) {
    let x = ModalWindow.Throttle
    let wc = x.windowController
    wc.showWindow(nil)
  }
  
  // MARK: View Menu
  
  @IBAction func mnuMonitorAction(_ sender: NSMenuItem) {
    let x = ModalWindow.Monitor
    let wc = x.windowController
 // let vc = x.viewController(windowController: wc) as! MonitorVC
    wc.showWindow(nil)
  }
  
  @IBAction func mnuSlotView(_ sender: NSMenuItem) {
    let x = ModalWindow.SlotView
    let wc = x.windowController
    wc.showWindow(nil)
  }
  
  @IBAction func mnuProgramMobileDecoderAddress(_ sender: NSMenuItem) {
    let x = ModalWindow.ProgramDecoderAddress
    let wc = x.windowController
    wc.showWindow(nil)
  }
  
  @IBAction func mnuCommandStationConfiguration(_ sender: NSMenuItem) {
    let x = ModalWindow.CommandStationConfiguration
    let wc = x.windowController
    wc.showWindow(nil)
  }
  
  @IBAction func mnuDashBoardAction(_ sender: NSMenuItem) {
    let x = ModalWindow.DashBoard
    let wc = x.windowController
    wc.showWindow(nil)
  }
  
  @IBAction func SetupGroupAction(_ sender: NSMenuItem) {
    let x = ModalWindow.GroupSetup
    let wc = x.windowController
    wc.showWindow(nil)
  }
  
  @IBAction func mnuUpdateFirmware(_ sender: NSMenuItem) {
    let x = ModalWindow.UpdateFirmware
    let wc = x.windowController
    wc.showWindow(nil)
  }
}

