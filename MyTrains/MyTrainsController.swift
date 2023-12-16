//
//  MyTrainsController.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/11/2021.
//

import Foundation

public class MyTrainsController : NSObject, NSUserNotificationCenterDelegate, MTSerialPortManagerDelegate {
  
  // MARK: Constructor
  
  override init() {
    
    super.init()
    
    openLCBNetworkLayer = OpenLCBNetworkLayer(nodeId: openLCBNodeId)
    
    let _ = MTSerialPortManager.addObserver(observer: self)
    
    checkPortsTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkPortsTimerAction), userInfo: nil, repeats: true)
    
    RunLoop.current.add(checkPortsTimer!, forMode: .common)
    
  }
  
  // MARK: Destructor
  
  deinit {
    checkPortsTimer?.invalidate()
    checkPortsTimer = nil
  }
  
  // MARK: Private Properties
  
  private var controllerDelegates : [Int:MyTrainsControllerDelegate] = [:]
  
  private var _nextControllerDelegateId : Int = 0
  
  private var _nextMessengerId : Int = 1
  
  private var _nextIdLock : NSLock = NSLock()
  
  private var checkPortsTimer : Timer?
  
  private var nextMessengerId : String {
    get {
      _nextIdLock.lock()
      let id = _nextMessengerId
      _nextMessengerId += 1
      _nextIdLock.unlock()
      return "id\(id)"
    }
  }
  
  private var _observerIds : [String:Int] = [:]
  
  // MARK: Public Properties
  
  public var layouts : [Int:Layout] = Layout.layouts

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
    get {
      return layouts[layoutId]
    }
  }
  
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
  
  // MARK: MTSerialPortManagerDelegate Methods
  
  public func serialPortWasAdded(path: String) {
  }
  
  public func serialPortWasRemoved(path: String) {
  }
  
}
