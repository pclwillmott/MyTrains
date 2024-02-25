//
//  OpenLCBDatagramType.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/05/2023.
//

import Foundation

public enum OpenLCBDatagramType : UInt16 {
 
  case writeCommandGeneric                              = 0x2000
  case writeCommand0xFD                                 = 0x2001
  case writeCommand0xFE                                 = 0x2002
  case writeCommand0xFF                                 = 0x2003
  case writeUnderMaskCommandGeneric                     = 0x2008
  case writeUnderMaskCommand0xFD                        = 0x2009
  case writeUnderMaskCommand0xFE                        = 0x200a
  case writeUnderMaskCommand0xFF                        = 0x200b
  case writeReplyGeneric                                = 0x2010
  case writeReply0xFD                                   = 0x2011
  case writeReply0xFE                                   = 0x2012
  case writeReply0xFF                                   = 0x2013
  case writeReplyFailureGeneric                         = 0x2018
  case writeReplyFailure0xFD                            = 0x2019
  case writeReplyFailure0xFE                            = 0x201a
  case writeReplyFailure0xFF                            = 0x201b
  case writeStreamCommandGeneric                        = 0x2020
  case writeStreamCommand0xFD                           = 0x2021
  case writeStreamCommand0xFE                           = 0x2022
  case writeStreamCommand0xFF                           = 0x2023
  case writeStreamReplyGeneric                          = 0x2030
  case writeStreamReply0xFD                             = 0x2031
  case writeStreamReply0xFE                             = 0x2032
  case writeStreamReply0xFF                             = 0x2033
  case writeStreamReplyFailureGeneric                   = 0x2038
  case writeStreamReplyFailure0xFD                      = 0x2039
  case writeStreamReplyFailure0xFE                      = 0x203a
  case writeStreamReplyFailure0xFF                      = 0x203b
  case readCommandGeneric                               = 0x2040
  case readCommand0xFD                                  = 0x2041
  case readCommand0xFE                                  = 0x2042
  case readCommand0xFF                                  = 0x2043
  case readReplyGeneric                                 = 0x2050
  case readReply0xFD                                    = 0x2051
  case readReply0xFE                                    = 0x2052
  case readReply0xFF                                    = 0x2053
  case readReplyFailureGeneric                          = 0x2058
  case readReplyFailure0xFD                             = 0x2059
  case readReplyFailure0xFE                             = 0x205a
  case readReplyFailure0xFF                             = 0x205b
  case readStreamCommandGeneric                         = 0x2060
  case readStreamCommand0xFD                            = 0x2061
  case readStreamCommand0xFE                            = 0x2062
  case readStreamCommand0xFF                            = 0x2063
  case readStreamReplyGeneric                           = 0x2070
  case readStreamReply0xFD                              = 0x2071
  case readStreamReply0xFE                              = 0x2072
  case readStreamReply0xFF                              = 0x2073
  case readStreamReplyFailureGeneric                    = 0x2078
  case readStreamReplyFailure0xFD                       = 0x2079
  case readStreamReplyFailure0xFE                       = 0x207a
  case readStreamReplyFailure0xFF                       = 0x207b
  case getConfigurationOptionsCommand                   = 0x2080
  case getConfigurationOptionsReply                     = 0x2082
  case getAddressSpaceInformationCommand                = 0x2084
  case getAddressSpaceInformationReply                  = 0x2086
  case getAddressSpaceInformationReplyLowAddressPresent = 0x2087
  case lockReserveCommand                               = 0x2088
  case lockReserveReply                                 = 0x208a
  case getUniqueEventIDCommand                          = 0x208c
  case getUniqueEventIDReply                            = 0x208d
  case unfreezeCommand                                  = 0x20a0
  case freezeCommand                                    = 0x20a1
  case updateCompleteCommand                            = 0x20a8
  case resetRebootCommand                               = 0x20a9
  case reinitializeFactoryResetCommand                  = 0x20aa
  case sendLocoNetMessage                               = 0x3000 // Unofficial
  case getUniqueNodeIDCommand                           = 0x3001 // Unofficial
  case getUniqueNodeIDReply                             = 0x3002 // Unofficial
  
  // MARK: Public Properties
  
  public var bigEndianData : [UInt8] {
    return self.rawValue.bigEndianData
  }
  
  public var title : String {
    return OpenLCBDatagramType.titles[self]!
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [OpenLCBDatagramType:String] = [
    .writeCommandGeneric : String(localized: "Write Command"),
    .writeCommand0xFD : String(localized: "Write Command (Configuration Space)"),
    .writeCommand0xFE : String(localized: "Write Command (All Memory)"),
    .writeCommand0xFF : String(localized: "Write Command (CDI)"),
    .writeUnderMaskCommandGeneric : String(localized: "Write Under Mask Command"),
    .writeUnderMaskCommand0xFD : String(localized: "Write Under Mask Command (Configuration Space)"),
    .writeUnderMaskCommand0xFE : String(localized: "Write Under Mask Command (All Memory)"),
    .writeUnderMaskCommand0xFF : String(localized: "Write Under Mask Command (CDI)"),
    .writeReplyGeneric : String(localized: "Write Reply"),
    .writeReply0xFD : String(localized: "Write Reply (Configuration Space)"),
    .writeReply0xFE : String(localized: "Write Reply (All Memory)"),
    .writeReply0xFF : String(localized: "Write Reply (CDI)"),
    .writeReplyFailureGeneric : String(localized: "Write Reply Failure"),
    .writeReplyFailure0xFD : String(localized: "Write Reply Failure (Configuration Space)"),
    .writeReplyFailure0xFE : String(localized: "Write Reply Failure (All Memory)"),
    .writeReplyFailure0xFF : String(localized: "Write Reply Failure (CDI)"),
    .writeStreamCommandGeneric : String(localized: "Write Stream Command"),
    .writeStreamCommand0xFD : String(localized: "Write Stream Command (Configuration Space)"),
    .writeStreamCommand0xFE : String(localized: "Write Stream Command (All Memory)"),
    .writeStreamCommand0xFF : String(localized: "Write Stream Command (CDI)"),
    .writeStreamReplyGeneric : String(localized: "Write Stream Reply"),
    .writeStreamReply0xFD : String(localized: "Write Stream Reply (Configuration Space)"),
    .writeStreamReply0xFE : String(localized: "Write Stream Reply (All Memory)"),
    .writeStreamReply0xFF : String(localized: "Write Stream Reply (CDI)"),
    .writeStreamReplyFailureGeneric : String(localized: "Write Stream Reply Failure"),
    .writeStreamReplyFailure0xFD : String(localized: "Write Stream Reply Failure (Configuration Space)"),
    .writeStreamReplyFailure0xFE : String(localized: "Write Stream Reply Failure (All Memory)"),
    .writeStreamReplyFailure0xFF : String(localized: "Write Stream Reply Failure (CDI)"),
    .readCommandGeneric : String(localized: "Read Command"),
    .readCommand0xFD : String(localized: "Read Command (Configuration Space)"),
    .readCommand0xFE : String(localized: "Read Command (All Memory)"),
    .readCommand0xFF : String(localized: "Read Command (CDI)"),
    .readReplyGeneric : String(localized: "Read Reply"),
    .readReply0xFD : String(localized: "Read Reply (Configuration Space)"),
    .readReply0xFE : String(localized: "Read Reply (All Memory)"),
    .readReply0xFF : String(localized: "Read Reply (CDI)"),
    .readReplyFailureGeneric : String(localized: "Read Reply Failure"),
    .readReplyFailure0xFD : String(localized: "Read Reply Failure (Configuration Space)"),
    .readReplyFailure0xFE : String(localized: "Read Reply Failure (All Memory)"),
    .readReplyFailure0xFF : String(localized: "Read Reply Failure (CDI)"),
    .readStreamCommandGeneric : String(localized: "Read Stream Command"),
    .readStreamCommand0xFD : String(localized: "Read Stream Command (Configuration Space)"),
    .readStreamCommand0xFE : String(localized: "Read Stream Command (All Memory)"),
    .readStreamCommand0xFF : String(localized: "Read Stream Command (CDI)"),
    .readStreamReplyGeneric : String(localized: "Read Stream Reply"),
    .readStreamReply0xFD : String(localized: "Read Stream Reply (Configuration Space)"),
    .readStreamReply0xFE : String(localized: "Read Stream Reply (All Memory)"),
    .readStreamReply0xFF : String(localized: "Read Stream Reply (CDI)"),
    .readStreamReplyFailureGeneric : String(localized: "Read Stream Reply Failure"),
    .readStreamReplyFailure0xFD : String(localized: "Read Stream Reply Failure (Configuration Space)"),
    .readStreamReplyFailure0xFE : String(localized: "Read Stream Reply Failure (All Memory)"),
    .readStreamReplyFailure0xFF : String(localized: "Read Stream Reply Failure (CDI)"),
    .getConfigurationOptionsCommand : String(localized: "Get Configuration Options Command"),
    .getConfigurationOptionsReply : String(localized: "Get Configuration Options Reply"),
    .getAddressSpaceInformationCommand : String(localized: "Get Address Space Information Command"),
    .getAddressSpaceInformationReply : String(localized: "Get Address Space Information Reply"),
    .getAddressSpaceInformationReplyLowAddressPresent : String(localized: "Get Address Space Information Reply Low Address Present"),
    .lockReserveCommand : String(localized: "Lock Reserve Command"),
    .lockReserveReply : String(localized: "Lock Reserve Reply"),
    .getUniqueEventIDCommand : String(localized: "Get Unique Event ID Command"),
    .getUniqueEventIDReply : String(localized: "Get Unique Event ID Reply"),
    .unfreezeCommand : String(localized: "Unfreeze Command"),
    .freezeCommand : String(localized: "Freeze Command"),
    .updateCompleteCommand : String(localized: "Update Complete Command"),
    .resetRebootCommand : String(localized: "Reset Reboot Command"),
    .reinitializeFactoryResetCommand : String(localized: "Reinitialize/Factory Reset Command"),
    .sendLocoNetMessage : String(localized: "Send LocoNet Message Command"),
    .getUniqueNodeIDCommand : String(localized: "Get Unique Node ID Command"),
    .getUniqueNodeIDReply : String(localized: "Get Unique Node ID Reply"),
  ]
  
}
