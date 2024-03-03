//
//  AppDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/10/2021.
//

import Foundation
import AppKit

// 05.01.01.01.7b.00

private var menuItems : [MenuTag:NSMenuItem] = [:]

public enum MenuItemProperty {
  case isEnabled
  case isHidden
}

public func setMenuItemProperty(menuTag:MenuTag, properties:Set<MenuItemProperty>) {
  
  if let item = menuItems[menuTag] {
    item.isEnabled = properties.contains(.isEnabled)
    item.isHidden = properties.contains(.isHidden)
  }
  
}

public var appDelegate : AppDelegate {
  return NSApplication.shared.delegate as! AppDelegate
}

@main
public class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

  // MARK: Private Properties
  
  private var activity: NSObjectProtocol?
  
  private var activeViewControllers : [ObjectIdentifier:MyTrainsViewController] = [:]

  private var createVirtualNodeVC : CreateVirtualNodeVC?

  private var checkPortsTimer : Timer?
  
  // MARK: Public Properties
  
  public var networkLayer = OpenLCBNetworkLayer(appNodeId: appNodeId)
  
  public var isSafeToTerminate : Bool {
  
    var isSafeToTerminate = true
    
    for (_, vc) in activeViewControllers {
      if let wc = vc.view.window {
        let isSafe = vc.windowShouldClose(wc)
        isSafeToTerminate = isSafeToTerminate && isSafe
      }
    }
    
    return isSafeToTerminate

  }
  
  // MARK: App Control
  
  #if DEBUG
  public func applicationWillFinishLaunching(_ notification: Notification) {
    debugLog("applicationWillFinishLaunching")
  }
  #endif

  public func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    #if DEBUG
    debugLog("applicationDidFinishLaunching")
    #endif
    
    func gatherMenuItems(menu:NSMenu) {
      
      var index = 0
      
      for item in menu.items {
        if let tag = MenuTag(rawValue: item.tag) {
          if let subMenu = item.submenu {
            gatherMenuItems(menu: subMenu)
          }
          if tag != .separator {
            item.title = tag.title
            if !tag.isSystem {
              item.target = self
              item.action = #selector(self.menuAction(_:))
            }
          }
          menuItems[tag] = item
          index += 1
        }
        else {
          menu.items.remove(at: index)
        }
      }
      
    }

    // KEEP ALIVE - This is to stop the app and the timers going to sleep when
    // app is not in view.
    
    activity = ProcessInfo.processInfo.beginActivity(options: .userInitiatedAllowingIdleSystemSleep, reason: "Good Reason")

    if let mainMenu = NSApplication.shared.mainMenu {
      gatherMenuItems(menu: mainMenu)
    }
    
    checkPortsTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkPortsTimerAction), userInfo: nil, repeats: true)
    if let checkPortsTimer {
      RunLoop.current.add(checkPortsTimer, forMode: .common)
    }
    else {
      #if DEBUG
      debugLog("failed to create checkPortsTimer")
      #endif
    }

    if databasePath == nil {
      databasePath = documentsPath + "/MyTrains/database"
    }

    networkLayer.initialStart()

  }
  
  /*
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    debugLog("applicationShouldTerminateAfterLastWindowClosed")
    return false
  }
  */
  
  public func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
    
    #if DEBUG
    debugLog("applicationShouldTerminate")
    #endif
    
    return isSafeToTerminate ? .terminateNow : .terminateCancel
    
  }

  public func applicationWillTerminate(_ aNotification: Notification) {
    
    #if DEBUG
    debugLog("applicationWillTerminate")
    #endif
    
    networkLayer.stop()
    
    checkPortsTimer?.invalidate()

    if let activity {
      ProcessInfo.processInfo.endActivity(activity)
    }

  }

  // MARK: Private Methods
  
  @objc func checkPortsTimerAction() {
    MTSerialPortManager.checkPorts()
  }

  func newNodeCompletion(node:OpenLCBNodeVirtual) {
    
    let networkLayer = appDelegate.networkLayer
    
    node.hostAppNodeId = node.virtualNodeType == .applicationNode ? node.nodeId : appNodeId!
    
    switch node.virtualNodeType {
    case .layoutNode:
      node.layoutNodeId = node.nodeId
      node.saveMemorySpaces()
    case .switchboardItemNode, .switchboardPanelNode:
      node.layoutNodeId = appLayoutId!
      node.saveMemorySpaces()
    default:
      break
    }

    if node.isConfigurationDescriptionInformationProtocolSupported {
      let vc = MyTrainsWindow.configurationTool.viewController as! ConfigurationToolVC
      vc.configurationTool = networkLayer.getConfigurationTool()
      vc.configurationTool?.delegate = vc
      vc.node = node
      vc.showWindow()
    }
    
    createVirtualNodeVC?.stop()
    
  }
  
  // MARK: Public Methods
  
  public func addViewController(_ viewController:MyTrainsViewController) {
    activeViewControllers[viewController.objectIdentifier!] = viewController
  }
  
  public func removeViewController(_ viewController:MyTrainsViewController) {
    debugLog("\(viewController.objectIdentifier!)")
    activeViewControllers.removeValue(forKey: viewController.objectIdentifier!)
  }
  
  public func closeAllWindows() {
    if isSafeToTerminate {
      for (_, vc) in activeViewControllers {
        vc.closeWindow()
      }
    }
  }
  
  // MARK: Actions
  
  @objc func menuAction(_ sender: NSMenuItem) {
    
    if let tag = MenuTag(rawValue: sender.tag) {
      
      switch tag {

      case .globalEmergencyStop:
        guard let appNode else {
          return
        }
        appNode.sendGlobalEmergencyStop()
        
      case .clearGlobalEmergencyStop:
        guard let appNode else {
          return
        }
        appNode.sendClearGlobalEmergencyStop()
        
      case .globalPowerOff:
        guard let appNode else {
          return
        }
        appNode.sendGlobalPowerOff()
        
      case .globalPowerOn:
        guard let appNode else {
          return
        }
        appNode.sendGlobalPowerOn()

      case .throttle:
        let networkLayer = appDelegate.networkLayer
        guard let throttle = networkLayer.getThrottle()  else {
          return
        }
        let vc = MyTrainsWindow.throttle.viewController as! ThrottleVC
        vc.throttle = throttle
        throttle.delegate = vc
        vc.showWindow()
        
      case .selectLayout:
        MyTrainsWindow.selectLayout.showWindow()
        
      case .configLCCNetwork:
        let networkLayer = appDelegate.networkLayer
        
        let vc = MyTrainsWindow.viewLCCNetwork.viewController as! ViewLCCNetworkVC
        vc.configurationTool = networkLayer.getConfigurationTool()
        vc.configurationTool?.delegate = vc
        vc.showWindow()
        
      case .configClock:
        let networkLayer = appDelegate.networkLayer
        
        let vc = MyTrainsWindow.setFastClock.viewController as! SetFastClockVC
        vc.configurationTool = networkLayer.getConfigurationTool()
        vc.configurationTool?.delegate = vc
        vc.showWindow()
        
      case .dccProgrammerTool:
        guard let programmerTool = networkLayer.getProgrammerTool() else {
          return
        }
        let vc = MyTrainsWindow.programmerTool.viewController as! ProgrammerToolVC
        vc.programmerTool = programmerTool
        programmerTool.delegate = vc
        vc.showWindow()
        
      case .configSwitchboard:
    //    if let _ = myTrainsController.layout {
          MyTrainsWindow.switchBoardEditor.showWindow()
     //   }

      case .trainSpeedProfiler:
        MyTrainsWindow.speedProfiler.showWindow()

      case .locoNetFirmwareUpdate:
        MyTrainsWindow.updateFirmware.showWindow()

      case .locoNetWirelessSetup:
        MyTrainsWindow.groupSetup.showWindow()
        
      case .lccTrafficMonitor:
        MyTrainsWindow.openLCBMonitor.showWindow()
        
      case .locoNetSlotView:
        guard let monitorNode = networkLayer.getLocoNetMonitor() else {
          return
        }
        let vc = MyTrainsWindow.slotView.viewController as! SlotViewVC
        vc.monitorNode = monitorNode
        monitorNode.delegate = vc
        vc.showWindow()
        
      case .locoNetTrafficMonitor:
        guard let monitorNode = networkLayer.getLocoNetMonitor() else {
          return
        }
        let vc = MyTrainsWindow.monitor.viewController as! MonitorVC
        vc.monitorNode = monitorNode
        monitorNode.delegate = vc
        vc.showWindow()

      case .locoNetDashboard:
        MyTrainsWindow.dashBoard.showWindow()

      case .about:
        MyTrainsWindow.about.showWindow()
        
      case .createApplicationNode:
        if !eulaAccepted {
          MyTrainsWindow.license.runModel()
        }
        let vc = MyTrainsWindow.selectMasterNode.viewController as! SelectMasterNodeVC
   //     vc.controller = myTrainsController
        vc.showWindow()

      default:
        
        if let virtualNodeType = MyTrainsVirtualNodeType(rawValue: UInt16(sender.tag)) {
          
          if virtualNodeType == .switchboardPanelNode || virtualNodeType == .switchboardItemNode, appLayoutId == nil {
            
            let alert = NSAlert()
            
            alert.messageText = String(localized: "Layout Not Selected")
            alert.informativeText = String(localized: "You must create and select a layout before you can add switchboard panels and items.")
            alert.addButton(withTitle: String(localized: "OK"))
            alert.alertStyle = .informational
            
            alert.runModal()

            return
            
          }
          
          if networkLayer.configurationToolManager.isLocked {
            
            let alert = NSAlert()
            
            alert.messageText = String(localized: "Configuration Tool Unavailable")
            alert.informativeText = String(localized: "A configuration tool has exclusive use of the configuration mechanism. Try again after you have finished with the configuration tool.")
            alert.addButton(withTitle: String(localized: "OK"))
            alert.alertStyle = .informational
            
            alert.runModal()

            return
            
          }
          
          if virtualNodeType == .canGatewayNode {
            networkLayer.createGatewayNode()
            return
          }
              
          let vc = MyTrainsWindow.createVirtualNode.viewController as? CreateVirtualNodeVC
          createVirtualNodeVC = vc
          vc?.showWindow()

          networkLayer.createVirtualNode(virtualNodeType: virtualNodeType, completion: newNodeCompletion(node:))

        }
        
      }
    }
    
  }
  
}

public enum MyTrainsWindow : String {
  
  case monitor                           = "Monitor"
  case main                              = "Main"                         
  case editLayouts                       = "EditLayouts"                  
  case throttle                          = "Throttle"                     
  case slotView                          = "SlotView"                     
  case dashBoard                         = "DashBoard"                   
  case groupSetup                        = "GroupSetup"                   
  case switchBoardEditor                 = "SwitchBoardEditor"            
  case updateFirmware                    = "UpdateFirmware"               
  case switchBoardItemPropertySheet      = "SwitchBoardItemPropertySheet" 
  case speedProfiler                     = "SpeedProfiler"               
  case placeLocomotive                   = "PlaceLocomotive"              
  case setFastClock                      = "SetFastClock"                 
  case viewLCCNetwork                    = "ViewLCCNetwork"               
  case viewNodeInfo                      = "ViewNodeInfo"                
  case programmerTool                    = "ProgrammerTool"               
  case openLCBFirmwareUpdate             = "OpenLCBFirmwareUpdate"        
  case openLCBMonitor                    = "OpenLCBMonitor"               
  case configurationTool                 = "ConfigurationTool"           
  case cdiTextView                       = "CDITextView"                 
  case selectMasterNode                  = "SelectMasterNode"             
  case createVirtualNode                 = "CreateVirtualNode"            
  case selectLayout                      = "SelectLayout"                 
  case license                           = "License"                      
  case about                             = "About"                        
  case textView                          = "TextView"
  
  // MARK: Private Properties
  
  private var windowController : NSWindowController {
    let storyboard = NSStoryboard(name: self.rawValue, bundle: Bundle.main)
    let wc = storyboard.instantiateController(withIdentifier: "\(self.rawValue)WC") as! NSWindowController
    let vc = viewController(windowController: wc)
    vc.objectIdentifier = ObjectIdentifier(vc)
    appDelegate.addViewController(vc)
    return wc
  }
  
  // MARK: Public Properties
  
  public var viewController : MyTrainsViewController {
    let wc = windowController
    return viewController(windowController: wc)
  }

  // MARK: Private Methods
  
  private func viewController(windowController: NSWindowController) -> MyTrainsViewController {
    return windowController.window!.contentViewController! as! MyTrainsViewController
  }

  private func runModal(windowController: NSWindowController) {
    if let wc = windowController.window {
      NSApplication.shared.runModal(for: wc)
      wc.close()
    }
  }
  
  // MARK: Public Methods
  
  public func showWindow() {
    windowController.showWindow(nil)
  }
  
  public func runModel() {
    runModal(windowController: self.windowController)
  }
  
}

func stopModal() {
  NSApplication.shared.stopModal()
}

