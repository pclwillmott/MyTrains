//
//  NetworkOutputQueueItem.swift
//  MyTrains
//
//  Created by Paul Willmott on 07/11/2021.
//

import Foundation

public class NetworkOutputQueueItem {
  
  init(message: LocoNetMessage, delay:TimeInterval, responses: Set<NetworkMessageType>, retryCount: Int, timeoutCode: TimeoutCode) {
    self.message = message
    self.delay = delay
    self.responses = responses
    self.retryCount = retryCount + 1
    self.timeoutCode = timeoutCode
  }
  
  public var message : LocoNetMessage
  
  public var delay : TimeInterval
  
  public var responses : Set<NetworkMessageType>
  
  public var responseExpected : Bool {
    get {
      return responses.count > 0
    }
  }
  
  public var retryCount : Int
  
  public var timeoutCode : TimeoutCode
  
  public func isValidResponse(messageType: NetworkMessageType) -> Bool {
    return responses.contains(messageType)
  }
  
}
