//
//  OpenLCBLocationServiceFlag.swift
//  MyTrains
//
//  Created by Paul Willmott on 18/11/2023.
//

import Foundation

public enum OpenLCBLocationServiceFlagEntryExit : UInt16 {
  
  case exit                       = 0b0000000000000000
  case entryWithoutState          = 0b0000000000000001
  case entryWithState             = 0b0000000000000010
  
  public static let mask : UInt16 = 0b0000000000000011

}

public enum OpenLCBLocationServiceFlagDirectionRelative : UInt16 {
  
  case directionRelativeStopped   = 0b0000000000000000
  case directionRelativeForward   = 0b0000000000000100
  case directionRelativeReverse   = 0b0000000000001000
  case directionRelativeUnknown   = 0b0000000000001100
  
  public static let mask : UInt16 = 0b0000000000001100

}

public enum OpenLCBLocationServiceFlagDirectionAbsolute : UInt16 {
  
  case directionAbsoluteStopped   = 0b0000000000000000
  case directionAbsoluteEastNorth = 0b0000000000010000
  case directionAbsoluteWestSouth = 0b0000000000100000
  case directionAbsoluteUnknown   = 0b0000000000110000

  public static let mask : UInt16 = 0b0000000000110000

}

public enum OpenLCBLocationServiceFlagContentFormat : UInt16 {
  
  case occupancyInformationOnly   = 0b0010000000000000
  case standardContentForm        = 0b0100000000000000

  public static let mask : UInt16 = 0b0110000000000000

}
