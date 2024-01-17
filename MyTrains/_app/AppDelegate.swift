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
    
    if let mainMenu = NSApplication.shared.mainMenu {
      
      var menuItems = mainMenu.items
      
      mainMenu.removeAllItems()
      
      for item in menuItems {
        
        switch item.title {
          
        case "MyTrains":
          
          // Add back in the MyTrains Menu
          
          mainMenu.addItem(item)
          
          // Create the File Menu
          
          let fileMenu = NSMenuItem()
          fileMenu.title = String(localized: "File", comment: "Used for the File menu item title")
          fileMenu.submenu = NSMenu()
          mainMenu.addItem(fileMenu)
          
          // Create the New Menu

          let newMenu = NSMenuItem()
          newMenu.title = String(localized: "New", comment: "Used for the New menu item title")
          newMenu.submenu = NSMenu()
          fileMenu.submenu?.addItem(newMenu)
          
          // Add the Layout Menu Item
          
          let layoutMenuItem = NSMenuItem()
          layoutMenuItem.title = String(localized: "Layout", comment: "Used for the New Layout menu item title")
          newMenu.submenu?.addItem(layoutMenuItem)
          layoutMenuItem.target = self
          layoutMenuItem.action = #selector(self.mnuCreateNewNodeAction(_:))
          layoutMenuItem.tag = Int(MyTrainsVirtualNodeType.layoutNode.rawValue)

          // Add the LCC/OpenLCB Menu Items
          
          for nodeType in MyTrainsVirtualNodeType.newFileOpenLCBItems {
            let menuItem = NSMenuItem()
            menuItem.title = nodeType.title
            menuItem.tag = Int(nodeType.rawValue)
            menuItem.target = self
            menuItem.action = #selector(self.mnuCreateNewNodeAction(_:))
            newMenu.submenu?.addItem(menuItem)
          }

          // Add the LocoNet Menu Items
          
          for nodeType in MyTrainsVirtualNodeType.newFileLocoNetItems {
            let menuItem = NSMenuItem()
            menuItem.title = nodeType.title
            menuItem.tag = Int(nodeType.rawValue)
            menuItem.target = self
            menuItem.action = #selector(self.mnuCreateNewNodeAction(_:))
            newMenu.submenu?.addItem(menuItem)
          }
        
        case "Edit":
  
          // Add back in the Menu item
          
          mainMenu.addItem(item)
          item.title = String(localized: "Edit", comment: "Used for the Edit menu item title")

          // Create the Operations Menu
          
          let operationsMenu = NSMenuItem()
          operationsMenu.title = String(localized: "Operations", comment: "Used for the Operations menu item title")
          operationsMenu.submenu = NSMenu()
          mainMenu.addItem(operationsMenu)

          // Create the Throttle Menu Item

          let throttleMenuItem = NSMenuItem()
          throttleMenuItem.title = String(localized: "Throttle", comment: "Used for the Throttle menu item title")
          throttleMenuItem.target = self
          throttleMenuItem.action = #selector(self.mnuThrottleAction(_:))
          operationsMenu.submenu?.addItem(throttleMenuItem)

          // Create the Configuration Menu
          
          let configurationMenu = NSMenuItem()
          configurationMenu.title = String(localized: "Configuration", comment: "Used for the Configuration menu item title")
          configurationMenu.submenu = NSMenu()
          mainMenu.addItem(configurationMenu)

          // Create the Master Node Menu Item

          let workstationMenuItem = NSMenuItem()
          workstationMenuItem.title = String(localized: "Workstation", comment: "Used for the Workstation menu item title")
          workstationMenuItem.target = self
          workstationMenuItem.action = #selector(self.mnuWorkstationAction(_:))
          configurationMenu.submenu?.addItem(workstationMenuItem)

          let networkMenuItem = NSMenuItem()
          networkMenuItem.title = String(localized: "LCC/OpenLCB Network", comment: "Used for the LCC/OpenLCB Network menu item title")
          networkMenuItem.target = self
          networkMenuItem.action = #selector(self.mnuViewLCCNetwork(_:))
          configurationMenu.submenu?.addItem(networkMenuItem)

          // Create the Fast Clock Menu Item

          let fastClockMenuItem = NSMenuItem()
          fastClockMenuItem.title = String(localized: "Fast Clock", comment: "Used for the Fast Clock menu item title")
          fastClockMenuItem.target = self
          fastClockMenuItem.action = #selector(self.mnuSetFastClock(_:))
          configurationMenu.submenu?.addItem(fastClockMenuItem)

          // Create the DCC Programmer Tool Menu Item

          let dccProgrammerToolMenuItem = NSMenuItem()
          dccProgrammerToolMenuItem.title = String(localized: "DCC Programmer Tool", comment: "Used for the DCC Programmer Tool menu item title")
          dccProgrammerToolMenuItem.target = self
          dccProgrammerToolMenuItem.action = #selector(self.mnuProgrammerToolAction(_:))
          configurationMenu.submenu?.addItem(dccProgrammerToolMenuItem)

          // Create the Switch Board Menu Item

          let switchBoardMenuItem = NSMenuItem()
          switchBoardMenuItem.title = String(localized: "Switch Board", comment: "Used for the Switch Board menu item title")
          switchBoardMenuItem.target = self
          switchBoardMenuItem.action = #selector(self.mnuSwitchBoardEditor(_:))
          configurationMenu.submenu?.addItem(switchBoardMenuItem)

          // Create the Train Speed Profiler Menu Item

          let speedProfilerMenuItem = NSMenuItem()
          speedProfilerMenuItem.title = String(localized: "Train Speed Profiler", comment: "Used for the Train Speed Profiler menu item title")
          speedProfilerMenuItem.target = self
          speedProfilerMenuItem.action = #selector(self.mnuSpeedProfiler(_:))
          configurationMenu.submenu?.addItem(speedProfilerMenuItem)

          configurationMenu.submenu?.addItem(.separator())

          // Create the LocoNet Firmware Update Menu Item

          let locoNetFirmwareUpdateMenuItem = NSMenuItem()
          locoNetFirmwareUpdateMenuItem.title = String(localized: "LocoNet Firmware Update", comment: "Used for the LocoNet Firmware Update menu item title")
          locoNetFirmwareUpdateMenuItem.target = self
          locoNetFirmwareUpdateMenuItem.action = #selector(self.mnuUpdateFirmware(_:))
          configurationMenu.submenu?.addItem(locoNetFirmwareUpdateMenuItem)

          // Create the LocoNet Wireless Setup Menu Item

          let locoNetWirelessSetupMenuItem = NSMenuItem()
          locoNetWirelessSetupMenuItem.title = String(localized: "LocoNet Wireless Setup", comment: "Used for the LocoNet Wireless Setup menu item title")
          locoNetWirelessSetupMenuItem.target = self
          locoNetWirelessSetupMenuItem.action = #selector(self.SetupGroupAction(_:))
          configurationMenu.submenu?.addItem(locoNetWirelessSetupMenuItem)

          // Create the Tools Menu
          
          let toolsMenu = NSMenuItem()
          toolsMenu.title = String(localized: "Tools", comment: "Used for the Tools menu item title")
          toolsMenu.submenu = NSMenu()
          mainMenu.addItem(toolsMenu)

          // Create the OpenLCB Traffic Monitor Menu Item

          let openLCBTrafficMonitorMenuItem = NSMenuItem()
          openLCBTrafficMonitorMenuItem.title = String(localized: "LCC/OpenLCB Traffic Monitor", comment: "Used for the LCC/OpenLCB Traffic Monitor menu item title")
          openLCBTrafficMonitorMenuItem.target = self
          openLCBTrafficMonitorMenuItem.action = #selector(self.mnuLCCNetworkTrafficMonitor(_:))
          toolsMenu.submenu?.addItem(openLCBTrafficMonitorMenuItem)

          toolsMenu.submenu?.addItem(.separator())

          // Create the LocoNet Traffic Monitor Menu Item

          let locoNetTrafficMonitorMenuItem = NSMenuItem()
          locoNetTrafficMonitorMenuItem.title = String(localized: "LocoNet Traffic Monitor", comment: "Used for the LocoNet Traffic Monitor menu item title")
          locoNetTrafficMonitorMenuItem.target = self
          locoNetTrafficMonitorMenuItem.action = #selector(self.mnuMonitorAction(_:))
          toolsMenu.submenu?.addItem(locoNetTrafficMonitorMenuItem)

          // Create the LocoNet Slot View Menu Item

          let locoNetSlotViewMenuItem = NSMenuItem()
          locoNetSlotViewMenuItem.title = String(localized: "LocoNet Slot View", comment: "Used for the LocoNet Slot View menu item title")
          locoNetSlotViewMenuItem.target = self
          locoNetSlotViewMenuItem.action = #selector(self.mnuSlotView(_:))
          toolsMenu.submenu?.addItem(locoNetSlotViewMenuItem)

          // Create the LocoNet Dashboard Menu Item

          let locoNetDashboardMenuItem = NSMenuItem()
          locoNetDashboardMenuItem.title = String(localized: "LocoNet Dashboard", comment: "Used for the LocoNet Dashboard menu item title")
          locoNetDashboardMenuItem.target = self
          locoNetDashboardMenuItem.action = #selector(self.mnuDashBoardAction(_:))
          toolsMenu.submenu?.addItem(locoNetDashboardMenuItem)

        case "File", "Format", "Help":
         
          // Eat these ones up!
          
          break
          
        default:
          
          // Add back in the Menu item
          
          mainMenu.addItem(item)
          
        }
        
      }
      
    }

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
  
  @IBAction func mnuCreateNewNodeAction(_ sender: NSMenuItem) {
    
    guard let networkLayer = myTrainsController.openLCBNetworkLayer, let virtualNodeType = MyTrainsVirtualNodeType(rawValue: UInt16(sender.tag)) else {
      return
    }
    
    let newNodeId = networkLayer.getNewNodeId(virtualNodeType: virtualNodeType)
    
    var node : OpenLCBNodeVirtual?
    
    switch virtualNodeType {
    case .clockNode:
      node = OpenLCBClock(nodeId: newNodeId)
    case .throttleNode:
      node = OpenLCBThrottle(nodeId: newNodeId)
    case .locoNetGatewayNode:
      node = OpenLCBLocoNetGateway(nodeId: newNodeId)
    case .trainNode:
      node = OpenLCBNodeRollingStockLocoNet(nodeId: newNodeId)
    case .canGatewayNode:
      node = OpenLCBCANGateway(nodeId: newNodeId)
    case .applicationNode:
      node = OpenLCBNodeMyTrains(nodeId: newNodeId)
    case .configurationToolNode:
      node = OpenLCBNodeConfigurationTool(nodeId: newNodeId)
    case .locoNetMonitorNode:
      node = OpenLCBLocoNetMonitorNode(nodeId: newNodeId)
    case .programmerToolNode:
      node = OpenLCBProgrammerToolNode(nodeId: newNodeId)
    case .programmingTrackNode:
      node = OpenLCBProgrammingTrackNode(nodeId: newNodeId)
    case .genericVirtualNode:
      break
    case .digitraxBXP88Node:
      node = OpenLCBDigitraxBXP88Node(nodeId: newNodeId)
    case .layoutNode:
      node = LayoutNode(nodeId: newNodeId)
    case .switchboardNode:
      node = SwitchboardNode(nodeId: newNodeId)
    case .switchboardItemNode:
      node = SwitchboardItemNode(nodeId: newNodeId)
    }

    if let node {
      node.userNodeName = node.virtualNodeType.defaultUserNodeName(nodeId: node.nodeId)
      node.saveMemorySpaces()
      networkLayer.registerNode(node: node)
      let x = ModalWindow.ConfigurationTool
      let wc = x.windowController
      let vc = x.viewController(windowController: wc) as! ConfigurationToolVC
      vc.configurationTool = networkLayer.getConfigurationTool()
      vc.configurationTool?.delegate = vc
      vc.node = node
      wc.showWindow(nil)
    }

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

  @IBAction func mnuWorkstationAction(_ sender: NSMenuItem) {
    let x = ModalWindow.SelectMasterNode
    let wc = x.windowController
    let vc = x.viewController(windowController: wc) as! SelectMasterNodeVC
    vc.controller = myTrainsController
    wc.showWindow(nil)
  }

}

