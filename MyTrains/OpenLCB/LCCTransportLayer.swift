//
//  LCCTransportLayer.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/04/2023.
//

import Foundation

public class LCCTransportLayer : NSObject {
  
  // MARK: Private Properties
  
  internal var _state : LCCTransportLayerState = .inhibited
  
  internal var outputQueue : [OpenLCBMessage] = []
  
  internal var outputQueueLock : NSLock = NSLock()
  
  internal var inputQueue : [OpenLCBMessage] = []
  
  internal var inputQueueLock : NSLock = NSLock()
  
  // MARK: Public Properties
  
  public var delegate : LCCTransportLayerDelegate?
  
  public var state : LCCTransportLayerState {
    get {
      return _state
    }
  }
  
  // MARK: Private Methods
  
  internal func processQueues() {
    
  }
  
  // MARK: Public Methods
  
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
  
  public func transitionToPermittedState() {
  }

  public func transitionToInhibitedState() {
  }
  
  public func removeAlias(destinationNodeId:UInt64) {
    
  }
  
}
