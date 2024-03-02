//
//  AppDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/10/2021.
//

import Cocoa
import Foundation
import AppKit

private var menuItems : [MenuTag:NSMenuItem] = [:]

public enum MenuItemProperty {
  
  case isEnabled
  case isHidden
  
}

public func setMenuItemProperty(menuTag:MenuTag, property:MenuItemProperty, value:Bool) {
  
  if let item = menuItems[menuTag] {
    switch property {
    case .isEnabled:
      item.isEnabled = value
    case .isHidden:
      item.isHidden = value
    }
  }
  
}

public var appDelegate : AppDelegate? {
  return NSApplication.shared.delegate as? AppDelegate
}

@main
public class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

  // MARK: Private Properties
  
  private var activity: NSObjectProtocol?
  
  internal var activeViewControllers : [MyTrainsViewController] = []

  private var createVirtualNodeVC : CreateVirtualNodeVC?
  
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
    
  }
  
  #if DEBUG
  
  /*
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    debugLog("applicationShouldTerminateAfterLastWindowClosed")
    return false
  }
  */
  
  #endif

  public func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
    
    #if DEBUG
    debugLog("applicationShouldTerminate")
    #endif
    
    var isSafeToTerminate = true
    
    for vc in activeViewControllers {
      if let window = vc.view.window {
        let isSafe = vc.windowShouldClose(window)
        isSafeToTerminate = isSafeToTerminate && isSafe
      }
    }
    
    return isSafeToTerminate ? .terminateNow : .terminateCancel
    
  }

  public func applicationWillTerminate(_ aNotification: Notification) {
    
    #if DEBUG
    debugLog("applicationWillTerminate")
    #endif
    
    myTrainsController.openLCBNetworkLayer?.stop()
    
    if let activity {
      ProcessInfo.processInfo.endActivity(activity)
    }

  }

//  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
//    return true
//  }

  // MARK: Private Methods
  
  func newNodeCompletion(node:OpenLCBNodeVirtual) {
    
    guard let networkLayer = myTrainsController.openLCBNetworkLayer else {
      return
    }
    
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
      let x = ModalWindow.ConfigurationTool
      let wc = x.windowController
      let vc = x.viewController(windowController: wc) as! ConfigurationToolVC
      vc.configurationTool = networkLayer.getConfigurationTool()
      vc.configurationTool?.delegate = vc
      vc.node = node
      wc.showWindow(nil)
    }
    
    createVirtualNodeVC?.stop()
    
  }
  
  // MARK: Actions
  
  @objc func menuAction(_ sender: NSMenuItem) {
    
    if let tag = MenuTag(rawValue: sender.tag) {
      
      switch tag {

      case .globalEmergencyStop:
        guard let appNode = myTrainsController.openLCBNetworkLayer?.myTrainsNode else {
          return
        }
        appNode.sendGlobalEmergencyStop()
        
      case .clearGlobalEmergencyStop:
        guard let appNode = myTrainsController.openLCBNetworkLayer?.myTrainsNode else {
          return
        }
        appNode.sendClearGlobalEmergencyStop()
        
      case .globalPowerOff:
        guard let appNode = myTrainsController.openLCBNetworkLayer?.myTrainsNode else {
          return
        }
        appNode.sendGlobalPowerOff()
        
      case .globalPowerOn:
        guard let appNode = myTrainsController.openLCBNetworkLayer?.myTrainsNode else {
          return
        }
        appNode.sendGlobalPowerOn()

      case .throttle:
        guard let networkLayer = myTrainsController.openLCBNetworkLayer, let throttle = networkLayer.getThrottle()  else {
          return
        }
        let x = ModalWindow.Throttle
        let wc = x.windowController
        let vc = x.viewController(windowController: wc) as! ThrottleVC
        vc.throttle = throttle
        throttle.delegate = vc
        wc.showWindow(nil)
        
      case .selectLayout:
        let x = ModalWindow.SelectLayout
        let wc = x.windowController
        wc.showWindow(nil)
        
      case .configLCCNetwork:
        guard let networkLayer = myTrainsController.openLCBNetworkLayer else {
          return
        }
        let x = ModalWindow.ViewLCCNetwork
        let wc = x.windowController
        let vc = x.viewController(windowController: wc) as! ViewLCCNetworkVC
        vc.configurationTool = networkLayer.getConfigurationTool()
        vc.configurationTool?.delegate = vc
        wc.showWindow(nil)
        
      case .configClock:
        guard let networkLayer = myTrainsController.openLCBNetworkLayer else {
          return
        }
        let x = ModalWindow.SetFastClock
        let wc = x.windowController
        let vc = x.viewController(windowController: wc) as! SetFastClockVC
        vc.configurationTool = networkLayer.getConfigurationTool()
        vc.configurationTool?.delegate = vc
        wc.showWindow(nil)
        
      case .dccProgrammerTool:
        guard let networkLayer = myTrainsController.openLCBNetworkLayer, let programmerTool = networkLayer.getProgrammerTool() else {
          return
        }
        let x = ModalWindow.ProgrammerTool
        let wc = x.windowController
        let vc = x.viewController(windowController: wc) as! ProgrammerToolVC
        vc.programmerTool = programmerTool
        programmerTool.delegate = vc
        wc.showWindow(nil)
        
      case .configSwitchboard:
        if let _ = myTrainsController.layout {
          let x = ModalWindow.SwitchBoardEditor
          let wc = x.windowController
          wc.showWindow(nil)
        }

      case .trainSpeedProfiler:
        let x = ModalWindow.SpeedProfiler
        let wc = x.windowController
        wc.showWindow(nil)

      case .loocoNetFirmwareUpdate:
        let x = ModalWindow.UpdateFirmware
        let wc = x.windowController
        wc.showWindow(nil)

      case .locoNetWirelessSEtup:
        let x = ModalWindow.GroupSetup
        let wc = x.windowController
        wc.showWindow(nil)
        
      case .lccTrafficMonitor:
        let x = ModalWindow.OpenLCBMonitor
        let wc = x.windowController
        wc.showWindow(nil)
        
      case .locoNetSlotView:
        guard let networkLayer = myTrainsController.openLCBNetworkLayer, let monitorNode = networkLayer.getLocoNetMonitor() else {
          return
        }
        let x = ModalWindow.SlotView
        let wc = x.windowController
        let vc = x.viewController(windowController: wc) as! SlotViewVC
        vc.monitorNode = monitorNode
        monitorNode.delegate = vc
        wc.showWindow(nil)
        
      case .locoNetTrafficMonitor:
        guard let networkLayer = myTrainsController.openLCBNetworkLayer, let monitorNode = networkLayer.getLocoNetMonitor() else {
          return
        }
        let x = ModalWindow.Monitor
        let wc = x.windowController
        let vc = x.viewController(windowController: wc) as! MonitorVC
        vc.monitorNode = monitorNode
        monitorNode.delegate = vc
        wc.showWindow(nil)

      case .locoNetDashboard:
        let x = ModalWindow.DashBoard
        let wc = x.windowController
        wc.showWindow(nil)

      case .about:
        ModalWindow.About.windowController.showWindow(nil)
        
      case .createApplicationNode:
        if !eulaAccepted {
          ModalWindow.License.runModel()
        }
        let x = ModalWindow.SelectMasterNode
        let wc = x.windowController
        let vc = x.viewController(windowController: wc) as! SelectMasterNodeVC
        vc.controller = myTrainsController
        wc.showWindow(nil)

      default:
        
        if let virtualNodeType = MyTrainsVirtualNodeType(rawValue: UInt16(sender.tag)) {
          
          guard let networkLayer = myTrainsController.openLCBNetworkLayer else {
            return
          }
          
          if virtualNodeType == .switchboardPanelNode || virtualNodeType == .switchboardItemNode, appLayoutId == nil {
            
            let alert = NSAlert()
            
            alert.messageText = String(localized: "Layout Not Selected")
            alert.informativeText = "You must create and select a layout before you can add switchboard panels and items."
            alert.addButton(withTitle: "OK")
            alert.alertStyle = .informational
            
            alert.runModal()

            return
            
          }
          
          if networkLayer.configurationToolManager.isLocked {
            
            let alert = NSAlert()
            
            alert.messageText = String(localized: "Configuration Tool Unavailable")
            alert.informativeText = "A configuration tool has exclusive use of the configuration mechanism. Try again after you have finished with the configuration tool."
            alert.addButton(withTitle: "OK")
            alert.alertStyle = .informational
            
            alert.runModal()

            return
            
          }
          
          if virtualNodeType == .canGatewayNode {
            networkLayer.createGatewayNode()
            return
          }
              
          let x = ModalWindow.CreateVirtualNode
          let wc = x.windowController
          createVirtualNodeVC = x.viewController(windowController: wc) as? CreateVirtualNodeVC
          wc.showWindow(nil)

          networkLayer.createVirtualNode(virtualNodeType: virtualNodeType, completion: newNodeCompletion(node:))

        }
        
      }
    }
    
  }

}

