//
//  OpenLCBMessage.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/04/2023.
//

import Foundation

public class OpenLCBMessage : NSObject {
  
  // MARK: Constructors
  
  public init(messageTypeIndicator: OpenLCBMTI) {
    
    self.messageTypeIndicator = messageTypeIndicator
    
    super.init()
    
  }
  
  // MARK: Public Properties
  
  public var messageTypeIndicator : OpenLCBMTI
  
  public var isSpecial : Bool {
    get {
      let mask : UInt16 = 0x2000
      return (messageTypeIndicator.rawValue & mask) == mask
    }
  }
  
  public var isStreamOrDatagram : Bool {
    get {
      let mask : UInt16 = 0x1000
      return (messageTypeIndicator.rawValue & mask) == mask
    }
  }
  
  public var priority : UInt16 {
    get {
      let mask : UInt16 = 0x0C00
      return (messageTypeIndicator.rawValue & mask) >> 10
    }
  }
  
  public var typeWithinPriority : UInt16 {
    get {
      let mask : UInt16 = 0x03E0
      return (messageTypeIndicator.rawValue & mask) >> 5
    }
  }
  
  public var isSimpleProtocol : Bool {
    get {
      let mask : UInt16 = 0x0010
      return (messageTypeIndicator.rawValue & mask) == mask
    }
  }

  public var isAddressPresent : Bool {
    get {
      let mask : UInt16 = 0x0008
      return (messageTypeIndicator.rawValue & mask) == mask
    }
  }

  public var isEventPresent : Bool {
    get {
      let mask : UInt16 = 0x0004
      return (messageTypeIndicator.rawValue & mask) == mask
    }
  }

  public var modifier : UInt16 {
    get {
      let mask : UInt16 = 0x0003
      return messageTypeIndicator.rawValue & mask
    }
  }
  
  public var sourceNodeId : UInt64?
  
  public var destinationNodeId : UInt64?
  
  public var eventId : UInt64?
  
  public var otherContent : [UInt8] = []
  
  public var canFrameType : Int {
    get {
      if !isSpecial && !isStreamOrDatagram {
        return 1
      }
      return 0 // PLACEHOLDER
    }
  }
  
}
