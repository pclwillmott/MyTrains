//
//  OpenLCBDatagramType.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/05/2023.
//

import Foundation

public enum OpenLCBDatagramType : UInt8 {
 
  case writeCommandGeneric                              = 0x00
  case writeCommand0xFD                                 = 0x01
  case writeCommand0xFE                                 = 0x02
  case writeCommand0xFF                                 = 0x03
  case writeUnderMaskCommandGeneric                     = 0x08
  case writeUnderMaskCommand0xFD                        = 0x09
  case writeUnderMaskCommand0xFE                        = 0x0a
  case writeUnderMaskCommand0xFF                        = 0x0b
  case writeReplyGeneric                                = 0x10
  case writeReply0xFD                                   = 0x11
  case writeReply0xFE                                   = 0x12
  case writeReply0xFF                                   = 0x13
  case writeReplyFailureGeneric                         = 0x18
  case writeReplyFailure0xFD                            = 0x19
  case writeReplyFailure0xFE                            = 0x1a
  case writeReplyFailure0xFF                            = 0x1b
  case writeStreamCommandGeneric                        = 0x20
  case writeStreamCommand0xFD                           = 0x21
  case writeStreamCommand0xFE                           = 0x22
  case writeStreamCommand0xFF                           = 0x23
  case writeStreamReplyGeneric                          = 0x30
  case writeStreamReply0xFD                             = 0x31
  case writeStreamReply0xFE                             = 0x32
  case writeStreamReply0xFF                             = 0x33
  case writeStreamReplyFailureGeneric                   = 0x38
  case writeStreamReplyFailure0xFD                      = 0x39
  case writeStreamReplyFailure0xFE                      = 0x3a
  case writeStreamReplyFailure0xFF                      = 0x3b
  case readCommandGeneric                               = 0x40
  case readCommand0xFD                                  = 0x41
  case readCommand0xFE                                  = 0x42
  case readCommand0xFF                                  = 0x43
  case readReplyGeneric                                 = 0x50
  case readReply0xFD                                    = 0x51
  case readReply0xFE                                    = 0x52
  case readReply0xFF                                    = 0x53
  case readReplyFailureGeneric                          = 0x58
  case readReplyFailure0xFD                             = 0x59
  case readReplyFailure0xFE                             = 0x5a
  case readReplyFailure0xFF                             = 0x5b
  case readStreamCommandGeneric                         = 0x60
  case readStreamCommand0xFD                            = 0x61
  case readStreamCommand0xFE                            = 0x62
  case readStreamCommand0xFF                            = 0x63
  case readStreamReplyGeneric                           = 0x70
  case readStreamReply0xFD                              = 0x71
  case readStreamReply0xFE                              = 0x72
  case readStreamReply0xFF                              = 0x73
  case readStreamReplyFailureGeneric                    = 0x78
  case readStreamReplyFailure0xFD                       = 0x79
  case readStreamReplyFailure0xFE                       = 0x7a
  case readStreamReplyFailure0xFF                       = 0x7b
  case getConfigurationOptionsCommand                   = 0x80
  case getConfigurationOptionsReply                     = 0x82
  case getAddressSpaceInformationCommand                = 0x84
  case getAddressSpaceInformationReply                  = 0x86
  case getAddressSpaceInformationReplyLowAddressPresent = 0x87
  case LockReserveCommand                               = 0x88
  case LockReserveReply                                 = 0x8a
  case getUniqueIDCommand                               = 0x8c
  case getUniqueIDReply                                 = 0x8d
  case unfreezeCommand                                  = 0xa0
  case freezeCommand                                    = 0xa1
  case updateCompleteCommand                            = 0xa8
  case resetRebootCommand                               = 0xa9
  case reinitializeFactoryResetCommand                  = 0xaa
  
}
