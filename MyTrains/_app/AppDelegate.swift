//
//  AppDelegate.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/10/2021.
//

import Foundation
import AppKit

// 05.01.01.01.7b.00

public var appDelegate : AppDelegate {
  return NSApplication.shared.delegate as! AppDelegate
}

@main
public class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {

  // MARK: Destructors
  
  deinit {
    networkLayer = nil
  }
  
  // MARK: Private Properties

  private var menuItems : [MenuTag:NSMenuItem] = [:]

  private var activity: NSObjectProtocol?
  
  private var activeViewControllers : [ObjectIdentifier:MyTrainsViewController] = [:]

  private var createVirtualNodeVC : CreateVirtualNodeVC?

  private var checkPortsTimer : Timer?
  
  private var state : OpenLCBNetworkLayerState = .uninitialized {
    didSet {
      updateMenuItems(state: state)
    }
  }
  
  // MARK: Public Properties
  
  public var networkLayer : OpenLCBNetworkLayer? = OpenLCBNetworkLayer()
  
  public var windowsLoaded = false
  
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

  public func startApp() {

    showInitAppWindow()
    
    // KEEP ALIVE - This is to stop the app and the timers going to sleep when
    // app is not in view.
    
    activity = ProcessInfo.processInfo.beginActivity(options: .userInitiatedAllowingIdleSystemSleep, reason: "Good Reason")

    checkPortsTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkPortsTimerAction), userInfo: nil, repeats: true)
    
    if let checkPortsTimer {
      RunLoop.current.add(checkPortsTimer, forMode: .common)
    }
    else {
      #if DEBUG
      debugLog("failed to create checkPortsTimer")
      #endif
    }

    state = .uninitialized
    
    networkLayer?.start()

  }
  
  public func applicationDidFinishLaunching(_ aNotification: Notification) {
    
    #if DEBUG
    debugLog("applicationDidFinishLaunching")
    #endif
    
    // Do the legal stuff, if they don't accept the agreement stop the app.
    
    if !eulaAccepted! {
      
      let alert = NSAlert()

      if let filepath = Bundle.main.path(forResource: "License", ofType: "txt") {
        do {
          let text = try String(contentsOfFile: filepath)
          alert.informativeText = text.replacingOccurrences(of: "%%COPYRIGHT%%", with: appCopyright)
        }
        catch {
        }
      }
 
      alert.messageText = String(localized: "Agreement")
      alert.addButton(withTitle: String(localized: "Decline"))
      alert.addButton(withTitle: String(localized: "Accept"))
      alert.alertStyle = .informational
      
      switch alert.runModal() {
      case .alertFirstButtonReturn:
        exit(0)
      default:
        eulaAccepted = true
        break
      }

    }

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

    if let mainMenu = NSApplication.shared.mainMenu {
      gatherMenuItems(menu: mainMenu)
    }
    
    if databasePath == nil {
      databasePath = documentsPath + "/MyTrains/database"
    }
    
    state = .uninitialized
 
    if Database.isEmpty() {
      let vc = MyTrainsWindow.selectMasterNode.viewController as! SelectMasterNodeVC
      vc.showWindow()
    }
    else {
      startApp()
    }
    
//    var temp4 = SoftUIntX("340282366920938463463374607431768211455")
  
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
    
    if isSafeToTerminate {
      if appNode == nil {
        return .terminateNow
      }
      state = .terminating
      closeAllWindows()
    }
    
    return .terminateCancel

  }

  public func applicationWillTerminate(_ aNotification: Notification) {
    
    #if DEBUG
    debugLog("applicationWillTerminate")
    #endif
    
  }

  // MARK: Private Methods
  
  private var initAppVC : InitAppVC?
  
  private func showInitAppWindow() {
    let storyboard = NSStoryboard(name: "InitApp", bundle: Bundle.main)
    let wc = storyboard.instantiateController(withIdentifier: "InitAppWC") as! NSWindowController
    initAppVC = wc.window!.contentViewController! as? InitAppVC
    initAppVC!.showWindow()
  }
  
  private func closeInitAppWindow() {
    initAppVC?.closeWindow()
  }
  
  private func isWindowOpen(viewType:MyTrainsViewType) -> Bool {
    for (_, view) in activeViewControllers {
      if view.viewType == viewType {
        return true
      }
    }
    return false
  }
  
  private func openWindow(viewType:MyTrainsViewType) {
    
    switch viewType {
    case .openLCBNetworkView:
      if isWindowOpen(viewType: viewType) {
        return
      }
      let networkLayer = appDelegate.networkLayer
      
      let vc = MyTrainsWindow.viewLCCNetwork.viewController as! ViewLCCNetworkVC
      vc.configurationTool = networkLayer!.getConfigurationTool()
      vc.configurationTool?.delegate = vc
      vc.showWindow()

    case .openLCBTrafficMonitor:
      if isWindowOpen(viewType: viewType) {
        return
      }
      MyTrainsWindow.openLCBMonitor.showWindow()

    case .throttle:
      let networkLayer = appDelegate.networkLayer
      guard let throttle = networkLayer!.getThrottle()  else {
        return
      }
      let vc = MyTrainsWindow.throttle.viewController as! ThrottleVC
      vc.throttle = throttle
      throttle.delegate = vc
      vc.showWindow()

    case .switchboardPanel:
      for (_, panel) in appNode!.panelList {
        if panel.panelIsVisible {
          let wc = MyTrainsWindow.panelView.windowController
          wc.window?.setFrameAutosaveName("PanelView-\(panel.nodeId.toHexDotFormat(numberOfBytes: 6))") 
          let vc = MyTrainsWindow.panelView.viewController(windowController: wc) as! PanelViewVC
          vc.switchboardView.switchboardPanel = panel
          vc.showWindow()
        }
      }
    case .clock:
      break
    case .locoNetTrafficMonitor:
      guard let monitorNode = networkLayer!.getLocoNetMonitor() else {
        return
      }
      let vc = MyTrainsWindow.monitor.viewController as! MonitorVC
      vc.monitorNode = monitorNode
      monitorNode.delegate = vc
      vc.showWindow()

    case .locoNetSlotView:
      guard let monitorNode = networkLayer!.getLocoNetMonitor() else {
        return
      }
      let vc = MyTrainsWindow.slotView.viewController as! SlotViewVC
      vc.monitorNode = monitorNode
      monitorNode.delegate = vc
      vc.showWindow()

    case .locoNetDashboard:
      MyTrainsWindow.dashBoard.showWindow()

    }
    
  }
  
  public func refreshRequired() {
    for (_, view) in activeViewControllers {
      if view.viewType == .openLCBNetworkView {
        view.refreshRequired()
      }
    }
  }
  
  public func openWindows() {
    
    guard (state == .runningLocal || state == .runningNetwork) && !windowsLoaded else {
      return
    }
    
    closeInitAppWindow()

    for rawValue in 0 ... MyTrainsViewType.numberOfTypes - 1 {
      if let viewType = MyTrainsViewType(rawValue: rawValue), let appNode {
        let option = appNode.getViewOption(type: viewType)
        if option == .open || (option == .restorePreviousState && (viewType == .switchboardPanel || appNode.getViewState(type: viewType))) {
          openWindow(viewType: viewType)
        }
      }
    }
    
    windowsLoaded = true
    
//    showInstances()
    
  }
  
  @objc func checkPortsTimerAction() {
    MTSerialPortManager.checkPorts()
  }
  
  func updateMenuItems(state:OpenLCBNetworkLayerState) {
    for (key, menuItem) in menuItems {
      menuItem.isHidden = !key.isValid(state: state)
    }
  }
  
  func initiateRebootApplication() {
    
    if isSafeToTerminate {
      state = .rebooting
      closeAllWindows()
      showInitAppWindow()
    }
    
  }
  
  func initiateResetToFactoryDefaults() {
    
    if isSafeToTerminate {
 
      let alert = NSAlert()
      
      alert.messageText = String(localized: "Are You Sure?")
      alert.informativeText = String(localized: "Are you sure that you want to reset MyTrains to the factory defaults? This will delete all layouts and all virtual nodes managed by this workstation. This action cannot be undone!")
      alert.addButton(withTitle: String(localized: "Yes"))
      alert.addButton(withTitle: String(localized: "No"))
      alert.alertStyle = .informational
      
      switch alert.runModal() {
      case .alertFirstButtonReturn:
        state = .resetToFactoryDefaults
        closeAllWindows()
      default:
        break
      }
      
    }
    else {
      
      let alert = NSAlert()
      
      alert.messageText = String(localized: "Critical Task Running")
      alert.informativeText = String(localized: "A critical task is running that cannot be interrupted. Try again when the task has completed.")
      alert.addButton(withTitle: String(localized: "OK"))
      alert.alertStyle = .informational
      
      alert.runModal()

    }
    
  }
  
  func completeResetToFactoryDefaults() {
    
    guard state == .resetToFactoryDefaults else {
      return
    }
    
    checkPortsTimer?.invalidate()

    Database.deleteAllRows()
    
    appLayoutId = nil
    lastCSVPath = nil
    lastDMFPath = nil
    appMode = nil
    
    networkLayer = OpenLCBNetworkLayer()

    state = .uninitialized
    
  }

  // MARK: Public Methods
  
  public func addViewController(_ viewController:MyTrainsViewController) {
    activeViewControllers[viewController.objectIdentifier!] = viewController
  }
  
  public func removeViewController(_ viewController:MyTrainsViewController) {
    activeViewControllers.removeValue(forKey: viewController.objectIdentifier!)
    if activeViewControllers.isEmpty {
      windowsDidClose()
    }
  }
  
  public func createAppNodeComplete() {
    state = .uninitialized
    startApp()
  }
  
  public func rebootRequest() {
    initiateRebootApplication()
  }
  
  public func windowsDidClose() {
    windowsLoaded = false
    switch state {
    case .stopping, .rebooting, .resetToFactoryDefaults, .terminating:
      networkLayer?.stop()
    default:
      break
    }
  }
  
  public func closeAllPanels() {
    for (_, vc) in activeViewControllers {
      vc.closeWindow()
    }
    openWindows()
  }
  
  public func closeAllWindows() {
    if isSafeToTerminate {
      if activeViewControllers.isEmpty {
        windowsDidClose()
      }
      else {
        for (_, vc) in activeViewControllers {
          vc.closeWindow()
        }
      }
    }
  }
  
  public func networkLayerStateHasChanged(networkLayer:OpenLCBNetworkLayer) {
    
    switch networkLayer.state {
    case .runningLocal, .runningNetwork:
      switch self.state {
      case .uninitialized, .runningLocal, .runningNetwork:
        self.state = networkLayer.state
      default:
        break
      }
    case .stopped:
      switch self.state {
      case .stopping:
        self.state = .stopped
      case .rebooting:
        self.state = .uninitialized
        networkLayer.start()
      case .resetToFactoryDefaults:
        completeResetToFactoryDefaults()
      case .terminating:
        self.networkLayer = nil
        checkPortsTimer?.invalidate()
        if let activity {
          ProcessInfo.processInfo.endActivity(activity)
        }
        
      default:
        break
      }
    default:
      break
    }

    updateMenuItems(state: state)
    
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
        openWindow(viewType: .throttle)
        
      case .selectLayout:
        MyTrainsWindow.selectLayout.showWindow()
        
      case .configLCCNetwork:
        openWindow(viewType: .openLCBNetworkView)
        
      case .configClock:
        let networkLayer = appDelegate.networkLayer
        
        let vc = MyTrainsWindow.setFastClock.viewController as! SetFastClockVC
        vc.configurationTool = networkLayer!.getConfigurationTool()
        vc.configurationTool?.delegate = vc
        vc.showWindow()
        
      case .dccProgrammerTool:
        guard let programmerTool = networkLayer!.getProgrammerTool() else {
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
        openWindow(viewType: .openLCBTrafficMonitor)
        
      case .locoNetSlotView:
        openWindow(viewType: .locoNetSlotView)
        
      case .locoNetTrafficMonitor:
        openWindow(viewType: .locoNetTrafficMonitor)

      case .locoNetDashboard:
        openWindow(viewType: .locoNetDashboard)

      case .about:
        MyTrainsWindow.about.showWindow()
        
      case .createApplicationNode:
        
        let vc = MyTrainsWindow.selectMasterNode.viewController as! SelectMasterNodeVC
        vc.showWindow()

      case .resetToFactoryDefaults:
        initiateResetToFactoryDefaults()
        
      case .rebootApplication:
        initiateRebootApplication()
        
      case .switchboardPanel:
        MyTrainsWindow.panelView.showWindow()
        
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
          
          if networkLayer!.configurationToolManager!.isLocked {
            
            let alert = NSAlert()
            
            alert.messageText = String(localized: "Configuration Tool Unavailable")
            alert.informativeText = String(localized: "A configuration tool has exclusive use of the configuration mechanism. Try again after you have finished with the configuration tool.")
            alert.addButton(withTitle: String(localized: "OK"))
            alert.alertStyle = .informational
            
            alert.runModal()

            return
            
          }
          
          if virtualNodeType == .canGatewayNode {
            networkLayer!.createGatewayNode()
            return
          }
              
          let node = networkLayer!.createVirtualNode(virtualNodeType: virtualNodeType)

      //    let networkLayer = appDelegate.networkLayer
          
    //      node.hostAppNodeId = node.virtualNodeType == .applicationNode ? node.nodeId : appNode!.nodeId
          
    //      switch node.virtualNodeType {
    //      case .layoutNode:
    //        node.layoutNodeId = node.nodeId
    //      case .applicationNode:
    //        node.layoutNodeId = 0
    //      default:
    //        node.layoutNodeId = appLayoutId!
    //      }

          if node.isConfigurationDescriptionInformationProtocolSupported {
            let vc = MyTrainsWindow.configurationTool.viewController as! ConfigurationToolVC
            vc.configurationTool = networkLayer!.getConfigurationTool()
            vc.configurationTool?.delegate = vc
            vc.node = node
            vc.showWindow()
          }

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
  case about                             = "About"
  case textView                          = "TextView"
  case initApp                           = "InitApp"
  case panelView                         = "PanelView"
  
  // MARK: Public Properties
  
  public var windowController : NSWindowController {
    let storyboard = NSStoryboard(name: self.rawValue, bundle: Bundle.main)
    let wc = storyboard.instantiateController(withIdentifier: "\(self.rawValue)WC") as! NSWindowController
    let vc = viewController(windowController: wc)
    vc.objectIdentifier = ObjectIdentifier(vc)
    appDelegate.addViewController(vc)
    return wc
  }
  
  public var viewController : MyTrainsViewController {
    let wc = windowController
    return viewController(windowController: wc)
  }

  // MARK: Private Methods
  
  internal func viewController(windowController: NSWindowController) -> MyTrainsViewController {
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

