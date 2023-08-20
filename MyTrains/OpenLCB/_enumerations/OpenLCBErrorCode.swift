//
//  OpenLCBErrorCode.swift
//  MyTrains
//
//  Created by Paul Willmott on 16/04/2023.
//

import Foundation

public enum OpenLCBErrorCode : UInt16 {
  
  case success                                                               = 0x0000
  case permanentError                                                        = 0x1000
  case permanentErrorReserved1                                               = 0x1010
  case permanentErrorSourceNotPermitted                                      = 0x1020
  case permanentErrorNotFound                                                = 0x1030
  case permanentErrorAlreadyExists                                           = 0x1032
  case permanentErrorNoConnection                                            = 0x1033
  case permanentErrorNoDecoderDetected                                       = 0x1034
  case permanentErrorNotImplemented                                          = 0x1040
  case permanentErrorNotImplementedSubcommandUnknown                         = 0x1041
  case permanentErrorNotimplementedDatagramTypeStreamTypeOrCommandUnknown    = 0x1042
  case permanentErrorNotimplementedUnknownMTIOrTransportProtocolNotSupported = 0x1043
  case permanentErrorReserved5                                               = 0x1050
  case permanentErrorReserved6                                               = 0x1060
  case permanentErrorReserved7                                               = 0x1070
  case permanentErrorInvalidArguments                                        = 0x1080
  case permanentErrorAddressSpaceUnknown                                     = 0x1081
  case permanentErrorAddressOutOfBounds                                      = 0x1082
  case permanentErrorWriteAccessToReadOnlySpace                              = 0x1083
  case permanentErrorReadCVFailed                                            = 0x1084
  case permanentErrorWriteCVFailed                                           = 0x1085
  case permanentErrorReserved9                                               = 0x1090
  case permanentErrorReserved10                                              = 0x10a0
  case permanentErrorReserved11                                              = 0x10b0
  case permanentErrorReserved12                                              = 0x10c0
  case permanentErrorReserved13                                              = 0x10d0
  case permanentErrorReserved14                                              = 0x10e0
  case permanentErrorReserved15                                              = 0x10f0
  case temporaryErrorNotFurtherNotSpecified                                  = 0x2000
  case temporaryErrorTimeOut                                                 = 0x2010
  case temporaryErrorTimeOutWaitingForEndFrame                               = 0x2011
  case temporaryErrorBufferUnavailable                                       = 0x2020
  case temporaryErrorReserved3                                               = 0x2030
  case temporaryErrorOutOfOrder                                              = 0x2040
  case temporaryErrorOutOfOrderMiddleOrEndFrameWithoutStartFrame             = 0x2041
  case temporaryErrorOutOfOrderStartFrameBeforeFinishingPreviousMessage      = 0x2042
  case temporaryErrorReserved5                                               = 0x2050
  case temporaryErrorReserved6                                               = 0x2060
  case temporaryErrorReserved7                                               = 0x2070
  case temporaryErrorTransferError                                           = 0x2080
  case temporaryErrorLocoNetCollision                                        = 0x2081
  case temporaryErrorReserved9                                               = 0x2090
  case temporaryErrorReserved10                                              = 0x20a0
  case temporaryErrorReserved11                                              = 0x20b0
  case temporaryErrorReserved12                                              = 0x20c0
  case temporaryErrorReserved13                                              = 0x20d0
  case temporaryErrorReserved14                                              = 0x20e0
  case temporaryErrorReserved15                                              = 0x20f0
  case acceptFlag                                                            = 0x8000
  
  public var bigEndianData : [UInt8] {
    get {
      return self.rawValue.bigEndianData
    }
  }
  
  public var isPermanent : Bool {
    get {
      let mask : UInt16 = 0x1000
      return (self.rawValue & mask) == mask
    }
  }

  public var isTemporary : Bool {
    get {
      let mask : UInt16 = 0x2000
      return (self.rawValue & mask) == mask
    }
  }
  
  public var userMessage : String {
    
    switch self {
    case .permanentErrorNoDecoderDetected:
      return "no decoder detected"
    case .permanentErrorWriteCVFailed:
      return "no write acknowledge from decoder"
    case .permanentErrorReadCVFailed:
      return "no read compare acknowledge from decoder"
    default:
      return "\(self)"
    }
    
  }

}
