//
//  NetworkOutputQueueItem.swift
//  MyTrains
//
//  Created by Paul Willmott on 07/11/2021.
//

import Foundation

public class NetworkOutputQueueItem {
  
  init(message: NetworkMessage, delay:TimeInterval, response: [NetworkMessageType], delegate: NetworkMessengerDelegate?, retryCount: Int) {
    self.message = message
    self.delay = delay
    self.response = response
    self.delegate = delegate
    self.retryCount = retryCount
  }
  
  public var message : NetworkMessage
  
  public var delay : TimeInterval
  
  public var response : [NetworkMessageType]
  
  public var delegate : NetworkMessengerDelegate?
  
  public var responseExpected : Bool {
    get {
      return response.count > 0
    }
  }
  
  public var retryCount : Int
  
  public func isValidResponse(messageType: NetworkMessageType) -> Bool {
    for x in response {
      if x == messageType {
        return true
      }
    }
    return false
  }
  
}
