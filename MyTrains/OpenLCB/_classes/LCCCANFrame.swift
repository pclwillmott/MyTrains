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
    
    // Check that the message conforms to the standard
    
    guard LCCCANFrame.canMessageOK(message: message) else {
      return nil
    }
    
    // Create frame string by striping the prefix and suffix
    
    var frame = message
    frame.removeFirst()
    frame.removeFirst()
    frame.removeLast()
    
    // Split into header and data sections
    
    let temp1 = frame.split(separator: "N")
    
    // Extract header value
    
    self.header = UInt32(hex: temp1[0])
    
    // Extract data if present
    
    data = []
    
    if temp1.count == 2 {
      
      var temp2 = temp1[1]
      
      while temp2.count > 0 {
        data.append(UInt8(hex:temp2.prefix(2)))
        temp2.removeFirst(2)
      }
      
    }
    
    // Init super
    
    super.init()
    
    // Done.
    
  }

  init?(message:OpenLCBMessage) {
    
    // Check that the message is complete
    
    guard message.isMessageComplete else {
      return nil
    }
    
    // Build CAN header
    
    header  = 0x18000000 // CAN Prefix
    
    header |= (OpenLCBMessage.canFrameType(message: message).rawValue & 0x07) << 24
    
    header |= UInt32(message.messageTypeIndicator.rawValue & 0x0fff) << 12
    
    header |= UInt32(message.sourceNIDAlias! & 0xfff)
    
    // Build CAN data payload
    
    data = []
    
    if message.isAddressPresent {
      var temp = message.destinationNIDAlias! & 0x0fff
      temp |= UInt16(OpenLCBCANFrameFlag.onlyFrame.rawValue & 0x0f) << 12
      data.append(UInt8(temp >> 8))
      data.append(UInt8(temp & 0xff))
    }
    
    if message.isEventPresent {
      var mask : UInt64 = 0xff00000000000000
      let eventId = message.eventId!
      for index in 0...7 {
        data.append(UInt8((eventId & mask) >> ((7 - index) * 8)))
        mask >>= 8
      }
    }

    for byte in message.payload {
      data.append(byte)
    }
    
    // Init super
    
    super.init()
    
    // Done.
    
  }

  init?(pcerMessage:OpenLCBMessage, payload:[UInt8]) {
    
    // Check that the message is complete
    
    var message = pcerMessage
    
    guard message.isMessageComplete else {
      return nil
    }
    
    // Build CAN header
    
    header  = 0x18000000 // CAN Prefix
    
    header |= (OpenLCBMessage.canFrameType(message: message).rawValue & 0x07) << 24
    
    header |= UInt32(message.messageTypeIndicator.rawValue & 0x0fff) << 12
    
    header |= UInt32(message.sourceNIDAlias! & 0xfff)
    
    // Build CAN data payload
    
    data.append(contentsOf: payload)
    
    // Init super
    
    super.init()
    
    // Done.
    
  }

  init?(message:OpenLCBMessage, flags: OpenLCBCANFrameFlag, frameNumber: Int) {
    
    // Check that the message is complete
    
    guard message.isMessageComplete else {
      return nil
    }
    
    // Build CAN header
    
    header  = 0x18000000 // CAN Prefix
    
    header |= (OpenLCBMessage.canFrameType(message: message).rawValue & 0x07) << 24
    
    header |= UInt32(message.messageTypeIndicator.rawValue & 0x0fff) << 12
    
    header |= UInt32(message.sourceNIDAlias! & 0xfff)
    
    // Build CAN data payload
    
    data = []
    
    if message.isAddressPresent {
      var temp = message.destinationNIDAlias! & 0x0fff
      temp |= UInt16(flags.rawValue & 0x0f) << 12
      data.append(UInt8(temp >> 8))
      data.append(UInt8(temp & 0xff))
    }
    
    if message.isEventPresent {
      var mask : UInt64 = 0xff00000000000000
      let eventId = message.eventId!
      for index in 0...7 {
        data.append(UInt8((eventId & mask) >> ((7 - index) * 8)))
        mask >>= 8
      }
    }

    for byte in message.payload {
      data.append(byte)
    }
    
    var numberToRemove = (frameNumber - 1) * 6
    
    while numberToRemove > 0 {
      data.remove(at: 2)
      numberToRemove -= 1
    }
    
    while data.count > 8 {
      data.removeLast()
    }

    
    // Init super
    
    super.init()
    
    // Done.
    
  }

  init?(message:OpenLCBMessage, mti:OpenLCBMTI, payload:[UInt8]) {
    
    // Check that the message is complete
    
    guard message.isMessageComplete else {
      return nil
    }
    
    // Build CAN header
    
    header  = 0x18000000 // CAN Prefix
    
    header |= (OpenLCBMessage.canFrameType(message: message).rawValue & 0x07) << 24
    
    header |= UInt32(mti.rawValue & 0x0fff) << 12
    
    header |= UInt32(message.sourceNIDAlias! & 0xfff)
    
    // Build CAN data payload
    
    data = payload
    
    // Init super
    
    super.init()
    
    // Done.
    
  }

  init?(message:OpenLCBMessage, canFrameType:OpenLCBMessageCANFrameType, data: [UInt8]) {
    
    // Check that the message is complete
    
    guard message.isMessageComplete else {
      return nil
    }
    
    // Build CAN header
    
    header  = 0x18000000 // CAN Prefix
    
    header |= (canFrameType.rawValue & 0x07) << 24
    
    header |= UInt32(message.destinationNIDAlias! & 0x0fff) << 12
    
    header |= UInt32(message.sourceNIDAlias! & 0xfff)
    
    // Build CAN data payload
    
    self.data = data
    
    // Init super
    
    super.init()
    
    // Done.
    
  }

  // MARK: Private Properties
  
  private let mask_FrameType : UInt32 = 0x08000000
  
  private let mask_VariableField : UInt32 = 0x07fff000
  
  // MARK: Public Properties
  
  public var header : UInt32
  
  public var data : [UInt8] = []
  
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
    get {
      var result = ""
      for byte in data {
        result += byte.toHex(numberOfDigits: 2)
      }
      return result
    }
  }
  
  public var message : String {
    get {
      return ":X\(header.toHex(numberOfDigits: 8))N\(dataAsHex);"
    }
  }
  
  public var timeStamp : TimeInterval = 0.0
  
  public var timeSinceLastMessage : TimeInterval = 0.0

  public var frameType : OpenLCBCANFrameType {
    get {
      return (header & mask_FrameType) == mask_FrameType ? .openLCBMessage : .canControlFrame
    }
  }
  
  
  public var openLCBMessageCANFrameType : OpenLCBMessageCANFrameType? {
    guard frameType == .openLCBMessage else {
      return nil
    }
    return OpenLCBMessageCANFrameType(rawValue: (header & 0x07000000) >> 24)
  }
  
  public var openLCBMessageTypeIndicator : OpenLCBMTI? {
    guard frameType == .openLCBMessage, let openLCBMessageCANFrameType, openLCBMessageCANFrameType == .globalAndAddressedMTI else {
      return nil
    }
    return OpenLCBMTI(rawValue: UInt16((header >> 12) & 0xfff))!
  }
  
  public var variableField : UInt32 {
    get {
      return (header & mask_VariableField) >> 12
    }
  }
  
  public var sourceNIDAlias : UInt16 {
    return UInt16(header & 0x00000FFF)
  }
  
  public var canControlFrameFormat : OpenLCBCANControlFrameFormat {
    
    get {
      
      if frameType == .canControlFrame {
        
        let vf = variableField
        
        if let format = OpenLCBCANControlFrameFormat(rawValue: UInt16(vf & 0x7000)) {
          return format
        }
        
        if let format = OpenLCBCANControlFrameFormat(rawValue: UInt16(vf)) {
          return format
        }
        
      }
      
      return .unknown
      
    }
    
  }
  
  public var info : String {
    get {
      switch frameType {
      case .openLCBMessage:
        return "Frame Type: \(frameType) Alias: \(sourceNIDAlias.toHex(numberOfDigits: 3)) \n"

      case .canControlFrame:
        return "Frame Type: \(frameType) Alias: \(sourceNIDAlias.toHex(numberOfDigits: 3)) CAN Control Frame Format: \(canControlFrameFormat))\n"
      }
    }
  }
  
  // MARK: Public Class Methods
  
  public static func createFrameHeader(frameType: OpenLCBCANFrameType, variableField: UInt16, sourceNIDAlias: UInt16) -> String {
    
    var header : UInt32 = 0x10000000
    
    header |= (frameType == .openLCBMessage) ? 0x08000000 : 0
    
    header |= UInt32((variableField & 0x07fff)) << 12
    
    header |= UInt32(sourceNIDAlias & 0x0fff)
    
    return header.toHex(numberOfDigits: 8)
    
  }
  
  public static func canMessageOK(message:String) -> Bool {
    return message.prefix(2) == ":X" && message.last == ";"
  }
  
}