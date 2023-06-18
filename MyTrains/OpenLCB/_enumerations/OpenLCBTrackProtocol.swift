//
//  OpenLCBTrackProtocol.swift
//  MyTrains
//
//  Created by Paul Willmott on 18/06/2023.
//

import Foundation

public enum OpenLCBTrackProtocol : UInt8 {
  
  case anyTrackProtocol                     = 0b00000
  case nativeOpenLCBNode                    = 0b00001
  case mfxM4                                = 0b00010
  case marklinMotorolaAny                   = 0b00100
  case marklinMotorolaProtocolVersionI      = 0b00101
  case marklinMotorolaProtocolVersionII     = 0b00110
  case marklinMotorolaProtocolVersionIIF5F8 = 0b00111
  case dccDefaultAddressSpaceAnySpeedSteps  = 0b01000
  case dccDefaultAddressSpace14SpeedSteps   = 0b01001
  case dccDefaultAddressSpace28SpeedSteps   = 0b01010
  case dccDefaultAddressSpace128SpeedSteps  = 0b01011
  case dccLongAddressSpaceAnySpeedSteps     = 0b01100
  case dccLongAddressSpace14SpeedSteps      = 0b01101
  case dccLongAddressSpace28SpeedSteps      = 0b01110
  case dccLongAddressSpace128SpeedSteps     = 0b01111

  // MARK: Public Properties
  
  public var forceLongAddress : Bool {
    let mask : UInt8 = 0b01100
    return (self.rawValue & mask) == mask
  }
  
  // MARK: Static Properties
  
  public static var trackProtocolMask : UInt8 {
    return 0b00011111
  }
  
}
