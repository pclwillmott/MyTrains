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
  case LockReserveCommand                               = 0x2088
  case LockReserveReply                                 = 0x208a
  case getUniqueIDCommand                               = 0x208c
  case getUniqueIDReply                                 = 0x208d
  case unfreezeCommand                                  = 0x20a0
  case freezeCommand                                    = 0x20a1
  case updateCompleteCommand                            = 0x20a8
  case resetRebootCommand                               = 0x20a9
  case reinitializeFactoryResetCommand                  = 0x20aa
  case sendlocoNetMessage                               = 0x3000
  case sendLocoNetMessageReply                          = 0x3010
  
}
