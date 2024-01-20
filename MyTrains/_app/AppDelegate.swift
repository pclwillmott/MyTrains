//
//  AppDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/10/2021.
//

import Cocoa
import Foundation
import AppKit

public var mainMenuItems : [AppMode:[NSMenuItem]] = [:]

public func menuUpdate() {

  if !mainMenuItems.isEmpty, let mainMenu = NSApplication.shared.mainMenu {
    mainMenu.items = mainMenuItems[appMode]!
  }
  
}

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
  
  // MARK: App Control
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    
 //   appMode = .initializing
 //   appNodeId = nil
    
    if let mainMenu = NSApplication.shared.mainMenu {
      
      mainMenuItems[.initializing] = []
      mainMenuItems[.master]       = []
      mainMenuItems[.delegate]     = []

      for item in mainMenu.items {
        
        switch item.title {
          
        case "MyTrains":
          
          // Add back in the MyTrains Menu
 
          mainMenuItems[.initializing]!.append(item)
          mainMenuItems[.master]!.append(item)
          mainMenuItems[.delegate]!.append(item)
          
          // Create the File Menu
          
          /*
          let fileMenuMaster = NSMenuItem()
          fileMenuMaster.title = String(localized: "File", comment: "Used for the File menu item title")
          fileMenuMaster.submenu = NSMenu()
          mainMenuItems[.master]!.append(fileMenuMaster)

          let fileMenuDelegate = NSMenuItem()
          fileMenuDelegate.title = fileMenuMaster.title
          fileMenuDelegate.submenu = NSMenu()
          mainMenuItems[.delegate]!.append(fileMenuDelegate)
          */
          
          // Create the New Menu

          let newMenuMaster = NSMenuItem()
          newMenuMaster.title = String(localized: "New", comment: "Used for the New menu item title")
          newMenuMaster.submenu = NSMenu()
          for menuItem in MyTrainsVirtualNodeType.newSubMenuItems(appMode: .master) {
            newMenuMaster.submenu?.addItem(menuItem)
            menuItem.target = self
            menuItem.action = #selector(self.mnuCreateNewNodeAction(_:))
          }
          mainMenuItems[.master]!.append(newMenuMaster)

          let newMenuDelegate = NSMenuItem()
          newMenuDelegate.title = newMenuMaster.title
          newMenuDelegate.submenu = NSMenu()
          for menuItem in MyTrainsVirtualNodeType.newSubMenuItems(appMode: .delegate) {
            newMenuDelegate.submenu?.addItem(menuItem)
            menuItem.target = self
            menuItem.action = #selector(self.mnuCreateNewNodeAction(_:))
          }
          mainMenuItems[.delegate]!.append(newMenuDelegate)

        case "Edit":
  
          // Add back in the Menu item
          
          item.title = String(localized: "Edit", comment: "Used for the Edit menu item title")

          mainMenuItems[.initializing]!.append(item)
          mainMenuItems[.master]!.append(item)
          mainMenuItems[.delegate]!.append(item)

          // Create the Operations Menu
          
          let operationsMenuMaster = NSMenuItem()
          operationsMenuMaster.title = String(localized: "Operations", comment: "Used for the Operations menu item title")
          operationsMenuMaster.submenu = NSMenu()
          mainMenuItems[.master]!.append(operationsMenuMaster)

          let operationsMenuDelegate = NSMenuItem()
          operationsMenuDelegate.title = operationsMenuMaster.title
          operationsMenuDelegate.submenu = NSMenu()
          mainMenuItems[.delegate]!.append(operationsMenuDelegate)

          // Create the Throttle Menu Item

          let throttleMenuItemMaster = NSMenuItem()
          throttleMenuItemMaster.title = String(localized: "Throttle", comment: "Used for the Throttle menu item title")
          throttleMenuItemMaster.target = self
          throttleMenuItemMaster.action = #selector(self.mnuThrottleAction(_:))
          operationsMenuMaster.submenu?.addItem(throttleMenuItemMaster)

          let throttleMenuItemDelegate = NSMenuItem()
          throttleMenuItemDelegate.title = throttleMenuItemMaster.title
          throttleMenuItemDelegate.target = self
          throttleMenuItemDelegate.action = #selector(self.mnuThrottleAction(_:))
          operationsMenuDelegate.submenu?.addItem(throttleMenuItemDelegate)

          let appModeMenuItemMaster = NSMenuItem()
          appModeMenuItemMaster.title = String(localized: "Switch to Delegate Mode")
          appModeMenuItemMaster.target = self
          appModeMenuItemMaster.action = #selector(self.mnuAppModeAction(_:))
          operationsMenuMaster.submenu?.addItem(appModeMenuItemMaster)

          let appModeMenuItemDelegate = NSMenuItem()
          appModeMenuItemDelegate.title = String(localized: "Switch to Master Mode")
          appModeMenuItemDelegate.target = self
          appModeMenuItemDelegate.action = #selector(self.mnuAppModeAction(_:))
          operationsMenuDelegate.submenu?.addItem(appModeMenuItemDelegate)

          // Create the Configuration Menu
          
          
          let configurationMenuInitializing = NSMenuItem()
          configurationMenuInitializing.title = String(localized: "Configuration", comment: "Used for the Configuration menu item title")
          configurationMenuInitializing.submenu = NSMenu()
          mainMenuItems[.initializing]!.append(configurationMenuInitializing)
          
          
          let configurationMenuMaster = NSMenuItem()
          configurationMenuMaster.title = String(localized: "Configuration", comment: "Used for the Configuration menu item title")
          configurationMenuMaster.submenu = NSMenu()
          mainMenuItems[.master]!.append(configurationMenuMaster)

          let configurationMenuDelegate = NSMenuItem()
          configurationMenuDelegate.title = configurationMenuMaster.title
          configurationMenuDelegate.submenu = NSMenu()
          mainMenuItems[.delegate]!.append(configurationMenuDelegate)

          // Create the Master Node Menu Item

          let createAppNodeMenuItem = NSMenuItem()
          createAppNodeMenuItem.title = String(localized: "Create Application Node", comment: "Used for the Create Application Node menu item title")
          createAppNodeMenuItem.target = self
          createAppNodeMenuItem.action = #selector(self.mnuCreateApplicationNodeAction(_:))
          configurationMenuInitializing.submenu?.addItem(createAppNodeMenuItem)
          
          let networkMenuItemMaster = NSMenuItem()
          networkMenuItemMaster.title = String(localized: "LCC/OpenLCB Network", comment: "Used for the LCC/OpenLCB Network menu item title")
          networkMenuItemMaster.target = self
          networkMenuItemMaster.action = #selector(self.mnuViewLCCNetwork(_:))
          configurationMenuMaster.submenu?.addItem(networkMenuItemMaster)

          let networkMenuItemDelegate = NSMenuItem()
          networkMenuItemDelegate.title = networkMenuItemMaster.title
          networkMenuItemDelegate.target = self
          networkMenuItemDelegate.action = #selector(self.mnuViewLCCNetwork(_:))
          configurationMenuDelegate.submenu?.addItem(networkMenuItemDelegate)

          // Create the Fast Clock Menu Item

          let fastClockMenuItemMaster = NSMenuItem()
          fastClockMenuItemMaster.title = String(localized: "Fast Clock", comment: "Used for the Fast Clock menu item title")
          fastClockMenuItemMaster.target = self
          fastClockMenuItemMaster.action = #selector(self.mnuSetFastClock(_:))
          configurationMenuMaster.submenu?.addItem(fastClockMenuItemMaster)

          let fastClockMenuItemDelegate = NSMenuItem()
          fastClockMenuItemDelegate.title = fastClockMenuItemMaster.title
          fastClockMenuItemDelegate.target = self
          fastClockMenuItemDelegate.action = #selector(self.mnuSetFastClock(_:))
          configurationMenuDelegate.submenu?.addItem(fastClockMenuItemDelegate)

          // Create the DCC Programmer Tool Menu Item

          let dccProgrammerToolMenuItemMaster = NSMenuItem()
          dccProgrammerToolMenuItemMaster.title = String(localized: "DCC Programmer Tool", comment: "Used for the DCC Programmer Tool menu item title")
          dccProgrammerToolMenuItemMaster.target = self
          dccProgrammerToolMenuItemMaster.action = #selector(self.mnuProgrammerToolAction(_:))
          configurationMenuMaster.submenu?.addItem(dccProgrammerToolMenuItemMaster)

          let dccProgrammerToolMenuItemDelegate = NSMenuItem()
          dccProgrammerToolMenuItemDelegate.title = dccProgrammerToolMenuItemMaster.title
          dccProgrammerToolMenuItemDelegate.target = self
          dccProgrammerToolMenuItemDelegate.action = #selector(self.mnuProgrammerToolAction(_:))
          configurationMenuDelegate.submenu?.addItem(dccProgrammerToolMenuItemDelegate)

          // Create the Switch Board Menu Item

          let switchBoardMenuItem = NSMenuItem()
          switchBoardMenuItem.title = String(localized: "Switch Board", comment: "Used for the Switch Board menu item title")
          switchBoardMenuItem.target = self
          switchBoardMenuItem.action = #selector(self.mnuSwitchBoardEditor(_:))
          configurationMenuMaster.submenu?.addItem(switchBoardMenuItem)

          // Create the Train Speed Profiler Menu Item

          let speedProfilerMenuItemMaster = NSMenuItem()
          speedProfilerMenuItemMaster.title = String(localized: "Train Speed Profiler", comment: "Used for the Train Speed Profiler menu item title")
          speedProfilerMenuItemMaster.target = self
          speedProfilerMenuItemMaster.action = #selector(self.mnuSpeedProfiler(_:))
          configurationMenuMaster.submenu?.addItem(speedProfilerMenuItemMaster)

          let speedProfilerMenuItemDelegate = NSMenuItem()
          speedProfilerMenuItemDelegate.title = speedProfilerMenuItemMaster.title
          speedProfilerMenuItemDelegate.target = self
          speedProfilerMenuItemDelegate.action = #selector(self.mnuSpeedProfiler(_:))
          configurationMenuDelegate.submenu?.addItem(speedProfilerMenuItemDelegate)

          configurationMenuMaster.submenu?.addItem(.separator())
          configurationMenuDelegate.submenu?.addItem(.separator())

          // Create the LocoNet Firmware Update Menu Item

          let locoNetFirmwareUpdateMenuItemMaster = NSMenuItem()
          locoNetFirmwareUpdateMenuItemMaster.title = String(localized: "LocoNet Firmware Update", comment: "Used for the LocoNet Firmware Update menu item title")
          locoNetFirmwareUpdateMenuItemMaster.target = self
          locoNetFirmwareUpdateMenuItemMaster.action = #selector(self.mnuUpdateFirmware(_:))
          configurationMenuMaster.submenu?.addItem(locoNetFirmwareUpdateMenuItemMaster)

          let locoNetFirmwareUpdateMenuItemDelegate = NSMenuItem()
          locoNetFirmwareUpdateMenuItemDelegate.title = locoNetFirmwareUpdateMenuItemMaster.title
          locoNetFirmwareUpdateMenuItemDelegate.target = self
          locoNetFirmwareUpdateMenuItemDelegate.action = #selector(self.mnuUpdateFirmware(_:))
          configurationMenuDelegate.submenu?.addItem(locoNetFirmwareUpdateMenuItemDelegate)

          // Create the LocoNet Wireless Setup Menu Item

          let locoNetWirelessSetupMenuItemMaster = NSMenuItem()
          locoNetWirelessSetupMenuItemMaster.title = String(localized: "LocoNet Wireless Setup", comment: "Used for the LocoNet Wireless Setup menu item title")
          locoNetWirelessSetupMenuItemMaster.target = self
          locoNetWirelessSetupMenuItemMaster.action = #selector(self.SetupGroupAction(_:))
          configurationMenuMaster.submenu?.addItem(locoNetWirelessSetupMenuItemMaster)

          let locoNetWirelessSetupMenuItemDelegate = NSMenuItem()
          locoNetWirelessSetupMenuItemDelegate.title = locoNetWirelessSetupMenuItemMaster.title
          locoNetWirelessSetupMenuItemDelegate.target = self
          locoNetWirelessSetupMenuItemDelegate.action = #selector(self.SetupGroupAction(_:))
          configurationMenuDelegate.submenu?.addItem(locoNetWirelessSetupMenuItemDelegate)

          // Create the Tools Menu
          
          let toolsMenuMaster = NSMenuItem()
          toolsMenuMaster.title = String(localized: "Tools", comment: "Used for the Tools menu item title")
          toolsMenuMaster.submenu = NSMenu()
          mainMenuItems[.master]!.append(toolsMenuMaster)

          let toolsMenuDelegate = NSMenuItem()
          toolsMenuDelegate.title = toolsMenuMaster.title
          toolsMenuDelegate.submenu = NSMenu()
          mainMenuItems[.delegate]!.append(toolsMenuDelegate)

          // Create the OpenLCB Traffic Monitor Menu Item

          let openLCBTrafficMonitorMenuItemMaster = NSMenuItem()
          openLCBTrafficMonitorMenuItemMaster.title = String(localized: "LCC/OpenLCB Traffic Monitor", comment: "Used for the LCC/OpenLCB Traffic Monitor menu item title")
          openLCBTrafficMonitorMenuItemMaster.target = self
          openLCBTrafficMonitorMenuItemMaster.action = #selector(self.mnuLCCNetworkTrafficMonitor(_:))
          toolsMenuMaster.submenu?.addItem(openLCBTrafficMonitorMenuItemMaster)

          let openLCBTrafficMonitorMenuItemDelegate = NSMenuItem()
          openLCBTrafficMonitorMenuItemDelegate.title = openLCBTrafficMonitorMenuItemMaster.title
          openLCBTrafficMonitorMenuItemDelegate.target = self
          openLCBTrafficMonitorMenuItemDelegate.action = #selector(self.mnuLCCNetworkTrafficMonitor(_:))
          toolsMenuDelegate.submenu?.addItem(openLCBTrafficMonitorMenuItemDelegate)

          toolsMenuMaster.submenu?.addItem(.separator())
          toolsMenuDelegate.submenu?.addItem(.separator())

          // Create the LocoNet Traffic Monitor Menu Item

          let locoNetTrafficMonitorMenuItemMaster = NSMenuItem()
          locoNetTrafficMonitorMenuItemMaster.title = String(localized: "LocoNet Traffic Monitor", comment: "Used for the LocoNet Traffic Monitor menu item title")
          locoNetTrafficMonitorMenuItemMaster.target = self
          locoNetTrafficMonitorMenuItemMaster.action = #selector(self.mnuMonitorAction(_:))
          toolsMenuMaster.submenu?.addItem(locoNetTrafficMonitorMenuItemMaster)

          let locoNetTrafficMonitorMenuItemDelegate = NSMenuItem()
          locoNetTrafficMonitorMenuItemDelegate.title = locoNetTrafficMonitorMenuItemMaster.title
          locoNetTrafficMonitorMenuItemDelegate.target = self
          locoNetTrafficMonitorMenuItemDelegate.action = #selector(self.mnuMonitorAction(_:))
          toolsMenuDelegate.submenu?.addItem(locoNetTrafficMonitorMenuItemDelegate)

          // Create the LocoNet Slot View Menu Item

          let locoNetSlotViewMenuItemMaster = NSMenuItem()
          locoNetSlotViewMenuItemMaster.title = String(localized: "LocoNet Slot View", comment: "Used for the LocoNet Slot View menu item title")
          locoNetSlotViewMenuItemMaster.target = self
          locoNetSlotViewMenuItemMaster.action = #selector(self.mnuSlotView(_:))
          toolsMenuMaster.submenu?.addItem(locoNetSlotViewMenuItemMaster)

          let locoNetSlotViewMenuItemDelegate = NSMenuItem()
          locoNetSlotViewMenuItemDelegate.title = locoNetSlotViewMenuItemMaster.title
          locoNetSlotViewMenuItemDelegate.target = self
          locoNetSlotViewMenuItemDelegate.action = #selector(self.mnuSlotView(_:))
          toolsMenuDelegate.submenu?.addItem(locoNetSlotViewMenuItemDelegate)

          // Create the LocoNet Dashboard Menu Item

          let locoNetDashboardMenuItemMaster = NSMenuItem()
          locoNetDashboardMenuItemMaster.title = String(localized: "LocoNet Dashboard", comment: "Used for the LocoNet Dashboard menu item title")
          locoNetDashboardMenuItemMaster.target = self
          locoNetDashboardMenuItemMaster.action = #selector(self.mnuDashBoardAction(_:))
          toolsMenuMaster.submenu?.addItem(locoNetDashboardMenuItemMaster)

          let locoNetDashboardMenuItemDelegate = NSMenuItem()
          locoNetDashboardMenuItemDelegate.title = locoNetDashboardMenuItemMaster.title
          locoNetDashboardMenuItemDelegate.target = self
          locoNetDashboardMenuItemDelegate.action = #selector(self.mnuDashBoardAction(_:))
          toolsMenuDelegate.submenu?.addItem(locoNetDashboardMenuItemDelegate)

        case "File", "Format", "Help":
         
          // Eat these ones up!
          
          break
          
        default:
          
          // Add back in the Menu item
          
          mainMenuItems[.initializing]!.append(item)
          mainMenuItems[.master]!.append(item)
          mainMenuItems[.delegate]!.append(item)

        }
        
      }
      
    }
    
    menuUpdate()

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
      UserDefaults.standard.set(UnitLength.defaultValue, forKey: DEFAULT.UNITS_LENGTH)
      UserDefaults.standard.set(UnitLength.defaultValue.rawValue, forKey: DEFAULT.UNITS_FBOFF_OCC)
      UserDefaults.standard.set(UnitSpeed.defaultValue.rawValue, forKey: DEFAULT.UNITS_SPEED)
      UserDefaults.standard.set(76.2, forKey: DEFAULT.SCALE)
      UserDefaults.standard.set(TrackGauge.defaultValue.rawValue, forKey: DEFAULT.TRACK_GAUGE)
      UserDefaults.standard.set(1.0, forKey: DEFAULT.SWITCHBOARD_EDITOR_MAG)

    }
    
    // KEEP ALIVE
    
    activity = ProcessInfo.processInfo.beginActivity(options: .userInitiatedAllowingIdleSystemSleep, reason: "Good Reason")

//    ProcessInfo.processInfo.endActivity(activity)

    
  }
  
  var activity: NSObjectProtocol?
  
  func applicationWillTerminate(_ aNotification: Notification) {
    myTrainsController.openLCBNetworkLayer?.stop()
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  // MARK: File Menu
  
  func newNodeCompletion(node:OpenLCBNodeVirtual) {
    
    guard let networkLayer = myTrainsController.openLCBNetworkLayer else {
      return
    }

    if node.isConfigurationDescriptionInformationProtocolSupported {
      let x = ModalWindow.ConfigurationTool
      let wc = x.windowController
      let vc = x.viewController(windowController: wc) as! ConfigurationToolVC
      vc.configurationTool = networkLayer.getConfigurationTool()
      vc.configurationTool?.delegate = vc
      vc.node = node
      wc.showWindow(nil)
    }
    
  }
  
  @IBAction func mnuCreateNewNodeAction(_ sender: NSMenuItem) {
    
    guard let networkLayer = myTrainsController.openLCBNetworkLayer, let virtualNodeType = MyTrainsVirtualNodeType(rawValue: UInt16(sender.tag)) else {
      return
    }
    
    networkLayer.createVirtualNode(virtualNodeType: virtualNodeType, completion: newNodeCompletion(node:))
    
  }

  // MARK: Operations Menu
  
  @IBAction func mnuThrottleAction(_ sender: Any) {
    
    guard let networkLayer = myTrainsController.openLCBNetworkLayer, let throttle = networkLayer.getThrottle()  else {
      return
    }
    
    let x = ModalWindow.Throttle
    let wc = x.windowController
    let vc = x.viewController(windowController: wc) as! ThrottleVC
    vc.throttle = throttle
    throttle.delegate = vc
    wc.showWindow(nil)
    
  }

  @IBAction func mnuAppModeAction(_ sender: Any) {
    appMode = (appMode == .master) ? .delegate : .master
  }
  
  // MARK: Configuration Menu
  
  @IBAction func mnuViewLCCNetwork(_ sender: NSMenuItem) {

    guard let networkLayer = myTrainsController.openLCBNetworkLayer else {
      return
    }

    let x = ModalWindow.ViewLCCNetwork
    let wc = x.windowController
    let vc = x.viewController(windowController: wc) as! ViewLCCNetworkVC
    vc.configurationTool = networkLayer.getConfigurationTool()
    vc.configurationTool?.delegate = vc
    wc.showWindow(nil)
    
  }
  
  @IBAction func mnuSetFastClock(_ sender: NSMenuItem) {
    
    guard let networkLayer = myTrainsController.openLCBNetworkLayer else {
      return
    }

    let x = ModalWindow.SetFastClock
    let wc = x.windowController
    let vc = x.viewController(windowController: wc) as! SetFastClockVC
    vc.configurationTool = networkLayer.getConfigurationTool()
    vc.configurationTool?.delegate = vc
    wc.showWindow(nil)
    
  }

  @IBAction func mnuProgrammerToolAction(_ sender: NSMenuItem) {
    
    guard let networkLayer = myTrainsController.openLCBNetworkLayer, let programmerTool = networkLayer.getProgrammerTool() else {
      return
    }
    
    let x = ModalWindow.ProgrammerTool
    let wc = x.windowController
    let vc = x.viewController(windowController: wc) as! ProgrammerToolVC
    vc.programmerTool = programmerTool
    programmerTool.delegate = vc
    wc.showWindow(nil)

  }
  
  @IBAction func mnuSwitchBoardEditor(_ sender: NSMenuItem) {
    if let _ = myTrainsController.layout {
      let x = ModalWindow.SwitchBoardEditor
      let wc = x.windowController
      wc.showWindow(nil)
    }
  }
  
  @IBAction func mnuSpeedProfiler(_ sender: NSMenuItem) {
    let x = ModalWindow.SpeedProfiler
    let wc = x.windowController
    wc.showWindow(nil)
  }
  
  @IBAction func mnuUpdateFirmware(_ sender: NSMenuItem) {
    let x = ModalWindow.UpdateFirmware
    let wc = x.windowController
    wc.showWindow(nil)
  }
  
  @IBAction func SetupGroupAction(_ sender: NSMenuItem) {
    let x = ModalWindow.GroupSetup
    let wc = x.windowController
    wc.showWindow(nil)
  }
  
  // MARK: Tools Menu
  
  @IBAction func mnuLCCNetworkTrafficMonitor(_ sender: NSMenuItem) {
    
    let x = ModalWindow.OpenLCBMonitor
    let wc = x.windowController
    let vc = x.viewController(windowController: wc) as! OpenLCBMonitorVC
    wc.showWindow(nil)
  }
  
  @IBAction func mnuMonitorAction(_ sender: NSMenuItem) {
    
    guard let networkLayer = myTrainsController.openLCBNetworkLayer, let monitorNode = networkLayer.getLocoNetMonitor() else {
      return
    }
    
    let x = ModalWindow.Monitor
    let wc = x.windowController
    let vc = x.viewController(windowController: wc) as! MonitorVC
    vc.monitorNode = monitorNode
    monitorNode.delegate = vc
    wc.showWindow(nil)
    
  }

  @IBAction func mnuSlotView(_ sender: NSMenuItem) {
    
    guard let networkLayer = myTrainsController.openLCBNetworkLayer, let monitorNode = networkLayer.getLocoNetMonitor() else {
      return
    }
    
    let x = ModalWindow.SlotView
    let wc = x.windowController
    let vc = x.viewController(windowController: wc) as! SlotViewVC
    vc.monitorNode = monitorNode
    monitorNode.delegate = vc
    wc.showWindow(nil)
    
  }
  
  @IBAction func mnuDashBoardAction(_ sender: NSMenuItem) {
    let x = ModalWindow.DashBoard
    let wc = x.windowController
    wc.showWindow(nil)
  }

  @IBAction func mnuCreateApplicationNodeAction(_ sender: NSMenuItem) {
    let x = ModalWindow.SelectMasterNode
    let wc = x.windowController
    let vc = x.viewController(windowController: wc) as! SelectMasterNodeVC
    vc.controller = myTrainsController
    wc.showWindow(nil)
  }

}

