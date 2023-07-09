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

    self.timeStamp = frame.timeStamp
    
    if let canFrameType = OpenLCBMessageCANFrameType(rawValue: (frame.header & 0x07000000) >> 24) {
      
      self.canFrameType = canFrameType
      
      switch canFrameType {
      case .globalAndAddressedMTI:
        
        messageTypeIndicator = OpenLCBMTI(rawValue: UInt16((frame.header >> 12) & 0xfff))!
        
        sourceNIDAlias = UInt16(frame.header & 0xfff)
        
        payload = frame.data
        
        var mask : UInt16 = 0x0008
        
        // isAddressPresent
        
        if (messageTypeIndicator.rawValue & mask) == mask, let alias = UInt16(bigEndianData: [payload[0] & 0x0f, payload[1]]) {
          destinationNIDAlias = alias
          let temp = (payload[0] & 0x30) >> 4
          flags = OpenLCBCANFrameFlag(rawValue: temp)!
          payload.removeFirst(2)
        }
        
        mask = 0x0004
        
        if (messageTypeIndicator.rawValue & mask) == mask, let id = UInt64(bigEndianData: [UInt8](payload.prefix(8))) {
          eventId = id
          
          payload.removeFirst(8)
        }

      case .datagramCompleteInFrame, .datagramFirstFrame, .datagramMiddleFrame, .datagramFinalFrame:
        
        messageTypeIndicator = .datagram
        
        sourceNIDAlias = UInt16(frame.header & 0xfff)

        destinationNIDAlias = UInt16((frame.header & 0xfff000) >> 12)
        
        payload = frame.data

      default: // Reserved
        messageTypeIndicator = .unknown
      }
      
      super.init()
      
    }
    else {
      print("failed to find can frame type")
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
  
  public var datagramType : OpenLCBDatagramType? {
    get {
      
      guard messageTypeIndicator == .datagram && payload.count >= 2 else {
        return nil
      }
      
      return OpenLCBDatagramType(rawValue: UInt16(bigEndianData: [payload[0], payload[1]])!)
      
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
  
  public var gatewayNodeId : UInt64?
  
  public var sourceNodeId : UInt64?
  
  public var sourceNIDAlias : UInt16?
  
  public var destinationNodeId : UInt64?
  
  public var destinationNIDAlias : UInt16?
  
  public var datagramId : UInt32 {
    get {
      return (UInt32(destinationNIDAlias!) << 12) | UInt32(sourceNIDAlias!)
    }
  }

  public var datagramIdReversed : UInt32 {
    get {
      return (UInt32(sourceNIDAlias!) << 12) | UInt32(destinationNIDAlias!)
    }
  }

  public var errorCode : OpenLCBErrorCode {
    get {
      if let error = UInt16(bigEndianData: [payload[0], payload[1]]) {
        return OpenLCBErrorCode(rawValue: error) ?? .success
      }
      return .success
    }
  }
  
  public var flags : OpenLCBCANFrameFlag = .onlyFrame
  
  public var eventId : UInt64?
  
  public var payload : [UInt8] = []
  
  public var payloadAsHex : String {
    get {
      var result = ""
      for byte in payload {
        result += byte.toHex(numberOfDigits: 2)
      }
      return result
    }
  }
  
  public var isMessageComplete : Bool {
    
    get {
      var result = sourceNodeId != nil && sourceNIDAlias != nil
      let isDatagram = messageTypeIndicator == .datagram
      if isAddressPresent || isDatagram {
        result = result && destinationNodeId != nil && destinationNIDAlias != nil
      }
      if isEventPresent && !isDatagram {
        result = result && eventId != nil
      }
      return result
    }
    
  }
  
  public var canFrameType : OpenLCBMessageCANFrameType
 
  // MARK: Public Methods
  
  // MARK: Class Methods
  
  public static func canFrameType(message:OpenLCBMessage) -> OpenLCBMessageCANFrameType {
    
    if !message.isStreamOrDatagram && !message.isSpecial {
      return .globalAndAddressedMTI
    }
    else if message.messageTypeIndicator == .datagram {
      return .datagramFirstFrame
    }
    return .reserved1
  }
  
  public var timeStamp : TimeInterval = 0
  
}
