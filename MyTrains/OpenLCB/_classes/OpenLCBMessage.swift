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
    
    guard let canFrameType = frame.openLCBMessageCANFrameType else {
      return nil
    }

    self.timeStamp = frame.timeStamp
    
    self.canFrameType = canFrameType
    
    switch canFrameType {
      
    case .globalAndAddressedMTI:
      
      messageTypeIndicator = frame.openLCBMessageTypeIndicator!
      
      sourceNIDAlias = UInt16(frame.header & 0xfff)
      
      payload = frame.data
      
      if messageTypeIndicator.isAddressPresent, let alias = UInt16(bigEndianData: [payload[0] & 0x0f, payload[1]]) {
        destinationNIDAlias = alias
        flags = OpenLCBCANFrameFlag(rawValue: (payload[0] & 0x30) >> 4)!
        payload.removeFirst(2)
      }
      
      if messageTypeIndicator.isEventPresent, let eventPrefix = UInt16(bigEndianData: [payload[0], payload[1]]) {
        switch eventPrefix {
        case 0x0181: // LocoNet
          eventId = OpenLCBWellKnownEvent.locoNetMessage.rawValue
          payload.removeFirst(2)
        default:
          if let id = UInt64(bigEndianData: [UInt8](payload.prefix(8))) {
            eventId = id
            payload.removeFirst(8)
          }
        }
      }

    case .datagramCompleteInFrame, .datagramFirstFrame, .datagramMiddleFrame, .datagramFinalFrame:
      
      messageTypeIndicator = .datagram
      sourceNIDAlias = UInt16(frame.header & 0xfff)
      destinationNIDAlias = UInt16((frame.header & 0xfff000) >> 12)
      payload = frame.data

    default:
      return nil
    }
    
    super.init()

  }
  
  // MARK: Public Properties
  
  public var messageTypeIndicator : OpenLCBMTI
  
  public var canFrameType : OpenLCBMessageCANFrameType

  public var timeStamp : TimeInterval = 0
  
  public var gatewayNodeId : UInt64?
  
  public var sourceNodeId : UInt64?
  
  public var sourceNIDAlias : UInt16?
  
  public var destinationNodeId : UInt64?
  
  public var destinationNIDAlias : UInt16?

  public var flags : OpenLCBCANFrameFlag = .onlyFrame
  
  public var eventId : UInt64?
  
  public var payload : [UInt8] = []
  
  public var isLocoNetEvent : Bool {
    guard let eventId else {
      return false
    }
    return messageTypeIndicator == .producerConsumerEventReport && ((eventId & 0xffff000000000000) == OpenLCBWellKnownEvent.locoNetMessage.rawValue)
  }
  
  public var locoNetMessage : LocoNetMessage? {
    
    guard let eventId, isLocoNetEvent else {
      return nil
    }

    var data : [UInt8] = []
    
    var firstByte = true
    
    for byte in eventId.bigEndianData {
      if !firstByte && byte == 0xff {
        break
      }
      firstByte = false
      data.append(byte)
    }
    
    data.append(contentsOf: payload)
    
    data.removeFirst(2)
    
    return LocoNetMessage(payload: data)
  
  }
  
  public var datagramType : OpenLCBDatagramType? {
    
    guard messageTypeIndicator == .datagram && payload.count >= 2, let rawValue = UInt16(bigEndianData: [payload[0], payload[1]]) else {
      return nil
    }
    
    return OpenLCBDatagramType(rawValue: rawValue)
    
  }
  
  public var datagramReplyTimeOut : OpenLCBDatagramTimeout? {

    guard messageTypeIndicator == .datagramReceivedOK else {
      return nil
    }
    
    var flags : UInt8 = 0
    
    if payload.count > 0 {
      flags = payload[0]
    }
    
    return OpenLCBDatagramTimeout(rawValue: flags & 0x8f)

  }
  
  public var isLocationServicesEvent : Bool {
    guard messageTypeIndicator == .producerConsumerEventReport, let eventId else {
      return false
    }
    return (eventId & 0xffff000000000000) == 0x0102000000000000
  }
  
  public var scannerNodeId : UInt64? {
    if isLocationServicesEvent, let eventId {
      return eventId & 0x0000ffffffffffff
    }
    return nil
  }
  
  public var locationServicesFlags : UInt16? {
    if isLocationServicesEvent {
      return UInt16(bigEndianData: [payload[0], payload[1]])
    }
    return nil
  }
  
  public var locationServicesFlagEntryExit : OpenLCBLocationServiceFlagEntryExit? {
    if isLocationServicesEvent, let locationServicesFlags {
      return OpenLCBLocationServiceFlagEntryExit(rawValue: locationServicesFlags & OpenLCBLocationServiceFlagEntryExit.mask)
    }
    return nil
  }
    
  public var locationServicesFlagDirectionRelative : OpenLCBLocationServiceFlagDirectionRelative? {
    if isLocationServicesEvent, let locationServicesFlags {
      return OpenLCBLocationServiceFlagDirectionRelative(rawValue: locationServicesFlags & OpenLCBLocationServiceFlagDirectionRelative.mask)
    }
    return nil
  }
  
  public var locationServicesFlagDirectionAbsolute : OpenLCBLocationServiceFlagDirectionAbsolute? {
    if isLocationServicesEvent, let locationServicesFlags {
      return OpenLCBLocationServiceFlagDirectionAbsolute(rawValue: locationServicesFlags & OpenLCBLocationServiceFlagDirectionAbsolute.mask)
    }
    return nil
  }
  
  public var locationServicesFlagContentFormat : OpenLCBLocationServiceFlagContentFormat? {
    if isLocationServicesEvent, let locationServicesFlags {
      return OpenLCBLocationServiceFlagContentFormat(rawValue: locationServicesFlags & OpenLCBLocationServiceFlagContentFormat.mask)
    }
    return nil
  }
  
  public var trainNodeId : UInt64? {
    if isLocationServicesEvent {
      var id : [UInt8] = []
      for index in 2 ... 7 {
        id.append(payload[index])
      }
      let idNumber = UInt64(bigEndianData: id)
      return idNumber
    }
    return nil
  }
  
  public var locationServicesContent : [OpenLCBLocationServicesContentBlock]? {
    if isLocationServicesEvent, let locationServicesFlagContentFormat, locationServicesFlagContentFormat == .standardContentForm {
      var result : [OpenLCBLocationServicesContentBlock] = []
      var data = payload
      data.removeFirst(8)
      while !data.isEmpty {
        let length = Int(data.removeFirst())
        if length > 0 , let blockType = OpenLCBStandardContentBlockType(rawValue: data.removeFirst()) {
          let block : OpenLCBLocationServicesContentBlock = (blockType:blockType, content:[UInt8](data.prefix(length - 1)))
          result.append(block)
          data.removeFirst(length - 1)
        }
      }
      return result
    }
    return nil
  }
  
  public var datagramId : UInt32 {
    return (UInt32(destinationNIDAlias!) << 12) | UInt32(sourceNIDAlias!)
  }

  public var datagramIdReversed : UInt32 {
    return (UInt32(sourceNIDAlias!) << 12) | UInt32(destinationNIDAlias!)
  }

  public var errorCode : OpenLCBErrorCode {
    if payload.count >= 2, let error = UInt16(bigEndianData: [payload[0], payload[1]]) {
      return OpenLCBErrorCode(rawValue: error)!
    }
    return .success
  }

  public var rwReplyFailureErrorCode : OpenLCBErrorCode {
    if datagramType == .readReplyFailureGeneric || datagramType == .writeReplyFailureGeneric {
      if let error = UInt16(bigEndianData: [payload[payload.count - 2], payload[payload.count - 1]]) {
        return OpenLCBErrorCode(rawValue: error)!
      }
    }
    return .success
  }

  public var isAutomaticallyRoutedEvent : Bool {
    if messageTypeIndicator == .producerConsumerEventReport {
      let auto : UInt64 = 0x0100000000000000
      let mask : UInt64 = 0xffff000000000000
      return (eventId! & mask) == auto
    }
    return false
  }
  
  public var eventRange : (startEventId:UInt64, endEventId:UInt64)? {
    get {
      
      if let eventId {
        
        var temp = eventId
        
        let b0 : UInt64 = 0b1
        
        var firstBit = temp & b0
        
        var mask : UInt64 = 0
        
        while temp != 0 && (temp & b0) == firstBit {
          mask = (mask << 1) | b0
          temp >>= 1
        }
        
        let base = eventId & ~mask
        
        return (startEventId: base, endEventId: base | mask)
        
      }
      
      return nil
      
    }
  }
  
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
    
    var result = sourceNodeId != nil && sourceNIDAlias != nil
    let isDatagram = messageTypeIndicator == .datagram
    if messageTypeIndicator.isAddressPresent || isDatagram {
      result = result && destinationNodeId != nil && destinationNIDAlias != nil
    }
    if messageTypeIndicator.isEventPresent && !isDatagram {
      result = result && eventId != nil
    }
    return result

  }
  
  // MARK: Class Methods
  
  public static func canFrameType(message:OpenLCBMessage) -> OpenLCBMessageCANFrameType {
    
    if !message.messageTypeIndicator.isStreamOrDatagram && !message.messageTypeIndicator.isSpecial {
      return .globalAndAddressedMTI
    }
    else if message.messageTypeIndicator == .datagram {
      return .datagramFirstFrame
    }
    
    return .reserved1
    
  }
  
}
