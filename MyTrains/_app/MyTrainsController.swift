//
//  MyTrainsController.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/11/2021.
//

import Foundation
import AppKit

public var appNodeId : UInt64? {
  get {
    let id = UserDefaults.standard.integer(forKey: DEFAULT.APP_NODE_ID)
    return id == 0 ? nil : UInt64(id)
  }
  set(value) {
    if value != appNodeId {
      UserDefaults.standard.set(Int(value ?? 0), forKey: DEFAULT.APP_NODE_ID)
    }
  }
}

public var appMode : AppMode {
  get {
    return AppMode(rawValue: UserDefaults.standard.integer(forKey: DEFAULT.APP_MODE))!
  }
  set(value) {
    UserDefaults.standard.set(value.rawValue, forKey: DEFAULT.APP_MODE)
    menuUpdate()
    if value != .initializing {
      myTrainsController.openLCBNetworkLayer?.stop()
      myTrainsController.openLCBNetworkLayer?.start()
    }
  }
}

// MARK: Global Declaration of MyTrainsController Instance

public var myTrainsController = MyTrainsController()

// MARK: MyTrainsController Class

public class MyTrainsController : NSObject, NSUserNotificationCenterDelegate {
  
  // MARK: Constructor
  
  override init() {
    
    super.init()

//    appNodeId = nil

    checkPortsTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkPortsTimerAction), userInfo: nil, repeats: true)
    
    RunLoop.current.add(checkPortsTimer!, forMode: .common)
    
    openLCBNetworkLayer = OpenLCBNetworkLayer(appNodeId: appNodeId)
    
  }
  
  // MARK: Destructor
  
  deinit {
    checkPortsTimer?.invalidate()
  }
  
  // MARK: Private Properties
  
  private var controllerDelegates : [Int:MyTrainsControllerDelegate] = [:]
  
  private var _nextControllerDelegateId : Int = 0
  
  private var checkPortsTimer : Timer?
  
  // MARK: Public Properties
  
  public var layouts : [Int:Layout] = Layout.layouts

  // 0x050101017b00
  // 05.01.01.01.7b.00

  public var openLCBNodeId : UInt64 {
    get {
      return 0x050101017b00 // Paul Willmott's Start of range
    }
  }
  
  public var openLCBNetworkLayer : OpenLCBNetworkLayer?
    
  public var layoutId : Int {
    get {
      let id = UserDefaults.standard.integer(forKey: DEFAULT.MAIN_CURRENT_LAYOUT_ID)
      return id == 0 ? -1 : id
    }
    set(value) {
      UserDefaults.standard.set(value, forKey: DEFAULT.MAIN_CURRENT_LAYOUT_ID)
    }
  }
  
  public var layout : Layout? {
    return layouts[layoutId]
  }
  
  public let manufacturer = "Paul C. L. Willmott"
  
  public let softwareVersion = "v0.X"
  
  public let hardwareVersion = "V0.X"
  
// MARK: Private Methods
  
  private func myTrainsControllerUpdated() {
    for (_, delegate) in controllerDelegates {
      delegate.myTrainsControllerUpdated?(myTrainsController: self)
    }
  }
  
  @objc func checkPortsTimerAction() {
    MTSerialPortManager.checkPorts()
  }
  
  // MARK: Public Methods

  public func switchBoardUpdated() {
    for (_, value) in controllerDelegates {
      value.switchBoardUpdated?()
    }
  }
  
  public func addLayout(layout: Layout) {
    layouts[layout.primaryKey] = layout
    myTrainsControllerUpdated()
  }
  
  public func removeLayout(primaryKey:Int) {
    layouts.removeValue(forKey: primaryKey)
    myTrainsControllerUpdated()
  }
  
  public func addDelegate(delegate:MyTrainsControllerDelegate) -> Int {
    let id = _nextControllerDelegateId
    _nextControllerDelegateId += 1
    controllerDelegates[id] = delegate
    delegate.myTrainsControllerUpdated?(myTrainsController: self)
    return id
  }
  
  public func removeDelegate(id:Int) {
    controllerDelegates.removeValue(forKey: id)
  }
  
  public func createApplicationNode(nodeId:UInt64) {
    openLCBNetworkLayer?.createAppNode(newNodeId: nodeId)
  }
  
}
