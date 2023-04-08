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
  
  // MARK: Public Properties
  
  public var delegate : LCCTransportLayerDelegate?
  
  public var state : LCCTransportLayerState {
    get {
      return _state
    }
  }
  
  // MARK: Private Methods
  
  internal func send() {
    
  }
  
  // MARK: Public Methods
  
  public func addToOutputQueue(message: OpenLCBMessage) {
    outputQueueLock.lock()
    outputQueue.append(message)
    outputQueueLock.unlock()
    send()
  }
  
}
