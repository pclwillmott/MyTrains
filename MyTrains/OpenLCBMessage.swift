//
//  OpenLCBMessage.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/04/2023.
//

import Foundation

public class OpenLCBMessage : NSObject {
  
  // MARK: Constructors
  
  init(messageTypeIndicator: OpenLCBMTI) {
    
    self.messageTypeIndicator = messageTypeIndicator
    
    self.canFrameType = .globalAndAddressedMTI
    
    super.init()
    
  }
  
  init?(frame:LCCCANFrame) {

    if let canFrameType = OpenLCBMessageCANFrameType(rawValue: (frame.header & 0x07000000) >> 24) {
      
      self.canFrameType = canFrameType
      
      switch canFrameType {
      case .globalAndAddressedMTI:
        
        messageTypeIndicator = OpenLCBMTI(rawValue: UInt16((frame.header >> 12) & 0xfff))!
        
        sourceNIDAlias = UInt16(frame.header & 0xfff)
        
        otherContent = frame.data
        
        var mask : UInt16 = 0x0008
        
        if (messageTypeIndicator.rawValue & mask) == mask { // isAddressPresent
          destinationNIDAlias = UInt16(otherContent[1]) | (UInt16(otherContent[0] & 0x0f) << 8)
          flags = LCCCANFrameFlag(rawValue: (otherContent[0] & 0xf0) >> 4)!
          otherContent.removeFirst(2)
        }
        
        mask = 0x0004
        
        if (messageTypeIndicator.rawValue & mask) == mask { // isEventPresent
          
          var id : UInt64 = 0
          
          for index in 0...7 {
            id <<= 8
            id |= UInt64(otherContent[index])
          }
          
          eventId = id
          
          otherContent.removeFirst(8)
          
        }
        
      default: // Reserved
        messageTypeIndicator = .unknown
      }
      
      super.init()
      
    }
    else {
      return nil
    }
    
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
  
  public var sourceNIDAlias : UInt16?
  
  public var destinationNodeId : UInt64?
  
  public var destinationNIDAlias : UInt16?
  
  public var flags : LCCCANFrameFlag = .onlyFrame
  
  public var eventId : UInt64?
  
  public var otherContent : [UInt8] = []
  
  public var otherContentAsHex : String {
    get {
      var result = ""
      for byte in otherContent {
        result += byte.toHex(numberOfDigits: 2)
      }
      return result
    }
  }
  
  public var isMessageComplete : Bool {
    
    get {
      var result = sourceNodeId != nil && sourceNIDAlias != nil
      if isAddressPresent {
        result = result && destinationNodeId != nil && destinationNIDAlias != nil
      }
      if isEventPresent {
        result = result && eventId != nil
      }
      return result
    }
    
  }
  
  public var canFrameType : OpenLCBMessageCANFrameType
 
  public static func canFrameType(message:OpenLCBMessage) -> OpenLCBMessageCANFrameType {
    
    if !message.isStreamOrDatagram && !message.isSpecial {
      return .globalAndAddressedMTI
    }
    else {
      return .reserved1
    }
  }
  
  public var timeStamp : TimeInterval = 0
  
}
