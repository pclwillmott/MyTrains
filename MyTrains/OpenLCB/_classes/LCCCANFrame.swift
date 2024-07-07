//
//  LCCPacket.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/04/2023.
//

import Foundation

public class LCCCANFrame : NSObject {

  // MARK: Constructors & Destructors
    
  init?(message:String) {
    
    guard message.prefix(2) == ":X" && message.last == ";" else {
      return nil
    }
    
    var frame = message
    frame.removeFirst(2)
    frame.removeLast()
    
    let section = frame.split(separator: "N", omittingEmptySubsequences: true)
    
    header = UInt32(hex: section[0])
    
    if section.count == 2 {
      
      var temp = section[1]
      
      while temp.count > 0 {
        data.append(UInt8(hex:temp.prefix(2))!)
        temp.removeFirst(2)
      }
      
    }
    
    super.init()
    
  }
  
  init(header:UInt32, data:[UInt8]) {
    self.header = header
    self.data = data
    super.init()
  }

  init?(message:OpenLCBMessage) {
    
    header  = 0x18000000 // CAN Prefix
    header |= (OpenLCBMessage.canFrameType(message: message).rawValue & 0x07) << 24
    header |= UInt32(message.messageTypeIndicator.rawValue & 0x0fff) << 12
    header |= UInt32(message.sourceNIDAlias! & 0xfff)
    
    data = []
    
    if message.messageTypeIndicator.isAddressPresent {
      var temp = message.destinationNIDAlias! & 0x0fff
      temp |= UInt16(OpenLCBCANFrameFlag.onlyFrame.rawValue & 0x0f) << 12
      data.append(UInt8(temp >> 8))
      data.append(UInt8(temp & 0xff))
    }
    
    if message.messageTypeIndicator.isEventPresent, let eventId = message.eventId {
      data.append(contentsOf: eventId.bigEndianData)
    }

    data.append(contentsOf: message.payload)
    
    timeStamp = message.timeStamp
    
    super.init()
    
  }

  init?(pcerMessage:OpenLCBMessage, payload:[UInt8]) {
    
    header  = 0x18000000 // CAN Prefix
    header |= (OpenLCBMessage.canFrameType(message: pcerMessage).rawValue & 0x07) << 24
    header |= UInt32(pcerMessage.messageTypeIndicator.rawValue & 0x0fff) << 12
    header |= UInt32(pcerMessage.sourceNIDAlias! & 0xfff)
    
    data = payload
    
    timeStamp = pcerMessage.timeStamp
    
    super.init()
    
  }

  init?(message:OpenLCBMessage, flags: OpenLCBCANFrameFlag, payload:[UInt8]) {
    
    header  = 0x18000000 // CAN Prefix
    header |= (OpenLCBMessage.canFrameType(message: message).rawValue & 0x07) << 24
    header |= UInt32(message.messageTypeIndicator.rawValue & 0x0fff) << 12
    header |= UInt32(message.sourceNIDAlias! & 0xfff)
    
    if message.messageTypeIndicator.isAddressPresent {
      var temp = message.destinationNIDAlias! & 0x0fff
      temp |= UInt16(flags.rawValue & 0x0f) << 12
      data.append(UInt8(temp >> 8))
      data.append(UInt8(temp & 0xff))
    }
    
    if message.messageTypeIndicator.isEventPresent, let eventId = message.eventId {
      data.append(contentsOf: eventId.bigEndianData)
    }

    data.append(contentsOf: payload)
    
    timeStamp = message.timeStamp

    super.init()
    
  }

  init?(message:OpenLCBMessage, mti:OpenLCBMTI, payload:[UInt8]) {
    
    header  = 0x18000000 // CAN Prefix
    header |= (OpenLCBMessage.canFrameType(message: message).rawValue & 0x07) << 24
    header |= UInt32(mti.rawValue & 0x0fff) << 12
    header |= UInt32(message.sourceNIDAlias! & 0xfff)
    
    data = payload
    
    timeStamp = message.timeStamp
    
    super.init()
    
  }

  init?(message:OpenLCBMessage, canFrameType:OpenLCBMessageCANFrameType, data: [UInt8]) {
    
    header  = 0x18000000 // CAN Prefix
    header |= (canFrameType.rawValue & 0x07) << 24
    header |= UInt32(message.destinationNIDAlias! & 0x0fff) << 12
    header |= UInt32(message.sourceNIDAlias! & 0xfff)
    
    self.data = data
    
    timeStamp = message.timeStamp
    
    super.init()
    
  }
  
  deinit {
    data.removeAll()
  }

  // MARK: Private Properties
  
  private let mask_FrameType : UInt32 = 0x08000000
  
  // MARK: Public Properties
  
  public var clone : LCCCANFrame {
    return LCCCANFrame(header: header, data: data)
  }
  
  public var header : UInt32
  
  public var data : [UInt8] = []
  
  public var timeStamp : TimeInterval = 0.0
  
  public var splitFrameId : UInt64 {
    
    let mti = OpenLCBMTI(rawValue: UInt16((header >> 12) & 0xfff))!
    
    switch mti {
      
    case .producerConsumerEventReportWithPayloadFirstFrame, .producerConsumerEventReportWithPayloadMiddleFrame, .producerConsumerEventReportWithPayloadLastFrame:
      
      return UInt64(header & 0xffcfff) << 16
      
    default:
      
      var result = UInt64(header) << 16
      result |= UInt64(data[0] & 0x0f) << 8
      result |= UInt64(data[1])
      return result
      
    }
    
  }
  
  public var dataAsHex : String {
    var result = ""
    for byte in data {
      result += byte.toHex(numberOfDigits: 2)
    }
    return result
  }
  
  public var message : String {
    return ":X\(header.toHex(numberOfDigits: 8))N\(dataAsHex);"
  }
  
  public var frameType : OpenLCBCANFrameType {
    return (header & mask_FrameType) == mask_FrameType ? .openLCBMessage : .canControlFrame
  }
    
  public var openLCBMessageCANFrameType : OpenLCBMessageCANFrameType? {
    guard frameType == .openLCBMessage else {
      return nil
    }
    return OpenLCBMessageCANFrameType(rawValue: (header & 0x07000000) >> 24)
  }
  
  public var messageTypeIndicator : OpenLCBMTI? {
    guard frameType == .openLCBMessage, let openLCBMessageCANFrameType, openLCBMessageCANFrameType == .globalAndAddressedMTI else {
      return nil
    }
    return OpenLCBMTI(rawValue: UInt16((header >> 12) & 0xfff))
  }
  
  public var contentField : UInt32 {
    return (header & 0x07fff000) >> 12
  }
  
  public var sourceNIDAlias : UInt16 {
    return UInt16(header & 0x00000fff)
  }
  
  public var controlFrameFormat : OpenLCBCANControlFrameFormat? {
    
    guard frameType == .canControlFrame else {
      return nil
    }
    
    let cf = contentField
    
    if let format = OpenLCBCANControlFrameFormat(rawValue: UInt16(cf & 0x7000)) {
      return format
    }
    
    return OpenLCBCANControlFrameFormat(rawValue: UInt16(cf))

  }
  
  public var info : String {
    
    var result = ""
    for byte in data {
      result += " \(byte.toHex(numberOfDigits: 2))"
    }
    result = "[[\(header.toHex(numberOfDigits: 8))]\(result)"
    result += String(repeating: " ", count: max(0, 35 - result.count)) + "] "
    
    var showPayload = true
    
    switch frameType {
    case .openLCBMessage:
      
      if let message = OpenLCBMessage(frame: self) {
        
        switch message.canFrameType {
        case .globalAndAddressedMTI:
          if let messageTypeIndicator {
            result += "\(messageTypeIndicator.title) "
            if messageTypeIndicator.isAddressPresent {
              result += "\(message.flags.title) "
              if message.payload.isEmpty {
                result += "with no payload "
              }
              else {
                result += "with payload \(message.payloadAsHex) "
              }
              showPayload = false
            }
            if messageTypeIndicator.isEventPresent {
              if let event = OpenLCBWellKnownEvent(rawValue: message.eventId!) {
                result += "\"\(event.title)\""
              }
              else {
                result += message.eventId!.toHexDotFormat(numberOfBytes: 8)
              }
              showPayload = false
            }
            switch messageTypeIndicator {
            case .initializationCompleteSimpleSetSufficient, .initializationCompleteFullProtocolRequired, .verifiedNodeIDSimpleSetSufficient, .verifiedNodeIDFullProtocolRequired:
              result += "\(UInt64(bigEndianData: message.payload)!.toHexDotFormat(numberOfBytes: 6))"
              showPayload = false
            case .datagramRejected:
              let numberOfBytesToAdd = 2 - min(2, message.payload.count)
              message.payload.append(contentsOf: [UInt8](repeating: 0x00, count: numberOfBytesToAdd))
              let errorCode = UInt16(bigEndianData: [UInt8](message.payload.prefix(2)))!
              if let error = OpenLCBErrorCode(rawValue: errorCode) {
                result += "\"\(error.title)\""
              }
              else {
                result += "\(errorCode.toHex(numberOfDigits: 4))"
                showPayload = false
              }
            default:
              break
            }
          }
        default:
          result += "\(message.canFrameType.title) "
          for byte in data {
            result += "\(byte.toHex(numberOfDigits: 2)) "
          }
          showPayload = false
        }
        
      }

    case .canControlFrame:
      if let controlFrameFormat {
        result += "\(controlFrameFormat.title) "
      }
    }
    
    if showPayload {
      if data.isEmpty {
        result += "with no payload"
      }
      else {
        result += "with payload \(dataAsHex)"
      }
    }
    
    return result
    
  }
    
  // MARK: Public Class Methods
  
  public static func createFrameHeader(frameType: OpenLCBCANFrameType, contentField: UInt16, sourceNIDAlias: UInt16) -> UInt32 {
    
    var header : UInt32 = 0x10000000
    header |= (frameType == .openLCBMessage) ? 0x08000000 : 0
    header |= UInt32((contentField & 0x07fff)) << 12
    header |= UInt32(sourceNIDAlias & 0x0fff)
    return header
    
  }
  
  public static func canMessageOK(message:String) -> Bool {
    return message.prefix(2) == ":X" && message.last == ";"
  }
  
}
