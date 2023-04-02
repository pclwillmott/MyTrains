//
//  LCCPacket.swift
//  MyTrains
//
//  Created by Paul Willmott on 01/04/2023.
//

import Foundation

public class LCCCANFrame : NSObject {

  // MARK: Constructors & Destructors
  
  init(networkId: Int, frame:String) {
    self.networkId = networkId
    self.frame = frame
    self.header = UInt32(frame.prefix(8), radix: 16) ?? 0
    super.init()
  }
  
  // MARK: Private Properties
  
  private let mask_FrameType : UInt32 = 0x08000000
  
  private let mask_VariableField : UInt32 = 0x07fff000
  
  // MARK: Public Properties
  
  public var frame : String
  
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
  
}
