//
//  LCCTransportLayer.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/04/2023.
//

import Foundation

public class OpenLCBTransportLayer : NSObject {
  
  // MARK: Private Properties
  
  internal var isActive : Bool = false
  
  internal var outputQueue : [OpenLCBMessage] = []
  
  internal var outputQueueLock : NSLock = NSLock()
  
  internal var inputQueue : [OpenLCBMessage] = []
  
  internal var inputQueueLock : NSLock = NSLock()
  
  internal var internalNodes : [UInt64:OpenLCBNode] = [:]
  
  // MARK: Public Properties
  
  public var delegate : OpenLCBTransportLayerDelegate?

//  public var state : LCCTransportLayerState {
//    get {
//      return _state
//    }
//  }
  
  // MARK: Private Methods
  
  internal func processQueues() {
    
  }
  
  // MARK: Public Methods
  
  public func start() {
    
    guard !isActive else {
      return
    }
    
    isActive = true
    
    for (_, node) in internalNodes {
      node.start()
    }
    
    delegate?.transportLayerStateChanged(transportLayer: self)
    
  }
  
  public func stop() {
    
    guard isActive else {
      return
    }
    
    isActive = false
    
    delegate?.transportLayerStateChanged(transportLayer: self)
    
  }

  public func addToOutputQueue(message: OpenLCBMessage) {
    message.timeStamp = Date.timeIntervalSinceReferenceDate
    outputQueueLock.lock()
    outputQueue.append(message)
    outputQueueLock.unlock()
    processQueues()
  }

  public func addToInputQueue(message: OpenLCBMessage) {
    message.timeStamp = Date.timeIntervalSinceReferenceDate
    inputQueueLock.lock()
    inputQueue.append(message)
    inputQueueLock.unlock()
    processQueues()
  }
  
  public func removeAlias(nodeId:UInt64) {
  }
  
  public func registerNode(node:OpenLCBNode) {
    internalNodes[node.nodeId] = node
  }
  
  public func deregisterNode(node:OpenLCBNode) {
    internalNodes.removeValue(forKey: node.nodeId)
  }
  
}
