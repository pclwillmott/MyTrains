//
//  MyTrainsController.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/11/2021.
//

import Foundation
import AppKit

// MARK: Global Declaration of MyTrainsController Instance

public var xmyTrainsController = MyTrainsController()

// MARK: MyTrainsController Class

public class MyTrainsController : NSObject, NSUserNotificationCenterDelegate {
  
  // MARK: Constructor
  
  override init() {
    
    super.init()

  
    openLCBNetworkLayer = OpenLCBNetworkLayer(appNodeId: appNodeId)
    
  }
  
  // MARK: Destructor
  
  
  // MARK: Private Properties
  
//  private var controllerDelegates : [Int:MyTrainsControllerDelegate] = [:]
  
//  private var _nextControllerDelegateId : Int = 0
  
  // MARK: Public Properties
  
  public var layouts : [Int:Layout] = Layout.layouts

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
  
  // MARK: Public Methods

//  public func switchBoardUpdated() {
//    for (_, value) in controllerDelegates {
//      value.switchBoardUpdated?()
//    }
//  }
  
//  public func addLayout(layout: Layout) {
//    layouts[layout.primaryKey] = layout
//    myTrainsControllerUpdated()
//  }
  
//  public func removeLayout(primaryKey:Int) {
//    layouts.removeValue(forKey: primaryKey)
//    myTrainsControllerUpdated()
//  }
  
//  public func addDelegate(delegate:MyTrainsControllerDelegate) -> Int {
//    let id = _nextControllerDelegateId
//    _nextControllerDelegateId += 1
//    controllerDelegates[id] = delegate
//    delegate.myTrainsControllerUpdated?(myTrainsController: self)
//    return id
//  }
  
//  public func removeDelegate(id:Int) {
//    controllerDelegates.removeValue(forKey: id)
//  }
  
  public func createApplicationNode(nodeId:UInt64) {
    openLCBNetworkLayer?.createAppNode(newNodeId: nodeId)
  }
  
}
