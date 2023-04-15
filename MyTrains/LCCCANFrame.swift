//
//  LCCPacket.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/04/2023.
//

import Foundation

public class LCCCANFrame : NSObject {

  // MARK: Constructors & Destructors
  
  init?(networkId: Int, message:String) {
    
    // Check that the message conforms to the standard
    
    guard LCCCANFrame.canMessageOK(message: message) else {
      return nil
    }
    
    // Initialise Network Id
    
    self.networkId = networkId
    
    // Create frame string by striping the prefix and suffix
    
    var frame = message
    frame.removeFirst()
    frame.removeFirst()
    frame.removeLast()
    
    // Split into header and data sections
    
    var temp1 = frame.split(separator: "N")
    
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
  
  init?(networkId: Int, message:OpenLCBMessage) {
    
    // Check that the message is complete
    
    guard message.isMessageComplete else {
      return nil
    }
    
    // Initialise Network Id
    
    self.networkId = networkId

    // Build CAN header
    
    header  = 0x18000000 // CAN Prefix
    
    header |= (OpenLCBMessage.canFrameType(message: message).rawValue & 0x07) << 24
    
    header |= UInt32(message.messageTypeIndicator.rawValue & 0x0fff) << 12
    
    header |= UInt32(message.sourceNIDAlias! & 0xfff)
    
    // Build CAN data payload
    
    data = []
    
    if message.isAddressPresent {
      var temp = message.destinationNIDAlias! & 0x0fff
      temp |= UInt16(LCCCANFrameFlag.onlyFrame.rawValue & 0x0f) << 12
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

    for byte in message.otherContent {
      data.append(byte)
    }
    
    // Init super
    
    super.init()
    
    // Done.
    
  }

  init?(networkId: Int, message:OpenLCBMessage, flags: LCCCANFrameFlag, frameNumber: Int) {
    
    // Check that the message is complete
    
    guard message.isMessageComplete else {
      return nil
    }
    
    // Initialise Network Id
    
    self.networkId = networkId

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

    for byte in message.otherContent {
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

  // MARK: Private Properties
  
  private let mask_FrameType : UInt32 = 0x08000000
  
  private let mask_VariableField : UInt32 = 0x07fff000
  
  // MARK: Public Properties
  
  public var header : UInt32
  
  public var data : [UInt8]
  
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
  
  public var networkId : Int

  public var timeStamp : TimeInterval = 0.0
  
  public var timeSinceLastMessage : TimeInterval = 0.0

  public var frameType : LCCCANFrameType {
    get {
      return (header & mask_FrameType) == mask_FrameType ? .openLCBMessage : .canControlFrame
    }
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
  
  public static func createFrameHeader(frameType: LCCCANFrameType, variableField: UInt16, sourceNIDAlias: UInt16) -> String {
    
    var header : UInt32 = 0x10000000
    
    header |= (frameType == .openLCBMessage) ? 0x08000000 : 0
    
    header |= UInt32((variableField & 0x07fff)) << 12
    
    header |= UInt32(sourceNIDAlias & 0x0fff)
    
    return header.toHex(numberOfDigits: 8)
    
  }
  
  public static func canMessageOK(message:String) -> Bool {
    
    // Check for minimum length (":XFN;")
    
    guard message.count >= 5 else {
      return false
    }
 
    // Check for valid prefix and suffix
    
    guard message.prefix(2) == ":X" && message.last == ";" else {
      return false
    }
    
    // Strip off prefix and suffix
    
    var temp1 = message
    
    temp1.removeFirst()
    temp1.removeFirst()
    temp1.removeLast()
    
    // Check that there is only one "N" and split into header and data strings
    
    let temp2 = temp1.split(separator: "N")
    
    guard temp2.count > 0 && temp2.count < 3 else {
      return false
    }
    
    if temp2.count == 1 && temp1.last != "N" {
      return false
    }
    
    // Check that the header is not greater than 8 hex digits
    
    if temp2[0].count > 8 {
      return false
    }
    
    // Check that the data section has two hex digits per byte
    
    if temp2.count > 1 && temp2[1].count % 2 != 0 {
      return false
    }
    
    // Check that the header and data sections only contain hex digits in upper case
    
    let hexDigits : Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]
    
    var index = 0
 
    while index < temp2.count {
      
      for char in temp2[index] {
        guard hexDigits.contains(char) else {
          return false
        }
      }
      
      index += 1
      
    }
    
    // All is well, report success
    
    return true
    
  }
  
}
