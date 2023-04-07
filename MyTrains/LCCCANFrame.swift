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
    
    frame = message
    frame.removeFirst()
    frame.removeFirst()
    frame.removeLast()
    
    // Split into header and data sections
    
    var temp1 = frame.split(separator: "N")
    
    // Extract header value
    
    self.header = UInt32(temp1[0], radix: 16) ?? 0
    
    // Extract data if present
    
    if temp1.count == 2 {
      
      dataAsString = String(temp1[1])
      
      var temp2 = dataAsString
      
      while temp2.count > 0 {
        data.append(UInt8(temp2.prefix(2), radix: 16) ?? 0)
        temp2.removeFirst(2)
      }
      
    }
    
    // Init super
    
    super.init()
    
    // Done.
    
  }
  
  // MARK: Private Properties
  
  private let mask_FrameType : UInt32 = 0x08000000
  
  private let mask_VariableField : UInt32 = 0x07fff000
  
  // MARK: Public Properties
  
  public var frame : String
  
  public var data : [UInt8] = []
  
  public var dataAsString : String = ""
  
  public var networkId : Int

  public var timeStamp : TimeInterval = 0.0
  
  public var header : UInt32
  
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
  
  public var canFrameFormat : LCCCANFrameFormat {
    get {
      
      if frameType != .canControlFrame {
        return .unknown
      }
      
      let vf = variableField
      
      switch vf {
      case 0x0700:
        return .reserveIdFrame
      case 0x0701:
        return .aliasMapDefinitionFrame
      case 0x0702:
        return .aliasMappingEnquiryFrame
      case 0x0703:
        return .aliasMapResetFrame
      case 0x0710, 0x0711, 0x0712, 0x0713:
        return .errorInformationReport
      default:
        switch vf >> 12 {
        case 7:
          return .checkId7Frame
        case 6:
          return .checkId6Frame
        case 5:
          return .checkId5Frame
        case 4:
          return .checkId4Frame
        default:
          break
        }
      }
      
      return .unknown
      
    }
  }
  
  public var info : String {
    get {
      return "Frame Type: \(frameType)\nVariable Field: \(String(format: "%03x", variableField)) CAN Frame Format: \(canFrameFormat))"
    }
  }
  
  // MARK: Public Class Methods
  
  public static func createFrameHeader(frameType: LCCCANFrameType, variableField: UInt16, sourceNIDAlias: UInt16) -> UInt32 {
    
    var header : UInt32 = 0x10000000
    
    header |= (frameType == .openLCBMessage) ? 0x08000000 : 0
    
    header |= UInt32((variableField & 0x07fff)) << 12
    
    header |= UInt32(sourceNIDAlias & 0x0fff)
    
    return header
    
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
