//
//  AppDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/10/2021.
//

import Cocoa
import Foundation
import ORSSerial

@main
class AppDelegate: NSObject, NSApplicationDelegate {
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    if let _ = UserDefaults.standard.string(forKey: DEFAULT.VERSION) {
    }
    else {
      
      let appFolder  = "/MyTrains"
      let dataFolder = "/MyTrains Database"
      
      UserDefaults.standard.set("Version 1.0", forKey: DEFAULT.VERSION)
      
      let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as [String]
      
      UserDefaults.standard.set(paths[0] + appFolder + dataFolder, forKey: DEFAULT.DATABASE_PATH)
      
    }

  }
  
  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  // Edit Menu
  
  @IBAction func mnuEditLayoutsAction(_ sender: NSMenuItem) {
    ModalWindow.EditLayouts.runModel()
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
 
  // View Menu
  
  @IBAction func mnuMonitorAction(_ sender: NSMenuItem) {
    let x = ModalWindow.Monitor
    let wc = x.windowController
 // let vc = x.viewController(windowController: wc) as! MonitorVC
    wc.showWindow(nil)
  }
  
}

