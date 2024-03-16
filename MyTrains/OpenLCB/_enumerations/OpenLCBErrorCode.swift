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
  case permanentErrorInvalidArgumentsFirmwareDataIncompatibleWithHardware    = 0x1088
  case permanentErrorInvalidArgumentsFirmwareDataInvalidOrCorrupted          = 0x1089
  case permanentErrorReserved9                                               = 0x1090
  case permanentErrorReserved10                                              = 0x10a0
  case permanentErrorReserved11                                              = 0x10b0
  case permanentErrorReserved12                                              = 0x10c0
  case permanentErrorReserved13                                              = 0x10d0
  case permanentErrorReserved14                                              = 0x10e0
  case permanentErrorReserved15                                              = 0x10f0
  case temporaryErrorNotFurtherSpecified                                     = 0x2000
  case temporaryErrorTimeOut                                                 = 0x2010
  case temporaryErrorTimeOutWaitingForEndFrame                               = 0x2011
  case temporaryErrorBufferUnavailable                                       = 0x2020
  case temporaryErrorReserved3                                               = 0x2030
  case temporaryErrorOutOfOrder                                              = 0x2040
  case temporaryErrorOutOfOrderMiddleOrEndFrameWithoutStartFrame             = 0x2041
  case temporaryErrorOutOfOrderStartFrameBeforeFinishingPreviousMessage      = 0x2042
  case temporaryErrorOutOfOrderFirstPartOfLocoNetMessageBeforeFinishingPreviousMessage      = 0x2043
  case temporaryErrorOutOfOrderFinalPartOfLocoNetMessageBeforeFirstPart      = 0x2044
  case temporaryErrorReserved5                                               = 0x2050
  case temporaryErrorReserved6                                               = 0x2060
  case temporaryErrorReserved7                                               = 0x2070
  case temporaryErrorTransferError                                           = 0x2080
  case temporaryErrorLocoNetCollision                                        = 0x2081
  case temporaryErrorTransferErrorFailedChecksum                             = 0x2088
  case temporaryErrorReserved9                                               = 0x2090
  case temporaryErrorReserved10                                              = 0x20a0
  case temporaryErrorReserved11                                              = 0x20b0
  case temporaryErrorReserved12                                              = 0x20c0
  case temporaryErrorReserved13                                              = 0x20d0
  case temporaryErrorReserved14                                              = 0x20e0
  case temporaryErrorReserved15                                              = 0x20f0
  case acceptFlag                                                            = 0x8000
  
  // MARK: Public Properties
  
  public var bigEndianData : [UInt8] {
    return self.rawValue.bigEndianData
  }
  
  public var title : String {
    return OpenLCBErrorCode.titles[self]!
  }
  
  public var isPermanent : Bool {
    let mask : UInt16 = 0x1000
    return (self.rawValue & mask) == mask
  }

  public var isTemporary : Bool {
    let mask : UInt16 = 0x2000
    return (self.rawValue & mask) == mask
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
  
  // MARK: Private Class Properties
  
  private static let titles : [OpenLCBErrorCode:String] = [
    .success : String(localized: "Success"),
    .permanentError : String(localized: "Permanent Error"),
    .permanentErrorReserved1 : String(localized: "Permanent Error Reserved 1"),
    .permanentErrorSourceNotPermitted : String(localized: "Permanent Error Source Not Permitted"),
    .permanentErrorNotFound : String(localized: "Permanent Error Not Found"),
    .permanentErrorAlreadyExists : String(localized: "Permanent Error Already Exists"),
    .permanentErrorNoConnection : String(localized: "Permanent Error No Connection"),
    .permanentErrorNoDecoderDetected : String(localized: "Permanent Error No Decoder Detected"),
    .permanentErrorNotImplemented : String(localized: "Permanent Error Not Implemented"),
    .permanentErrorNotImplementedSubcommandUnknown : String(localized: "Permanent Error Not Implemented Subcommand Unknown"),
    .permanentErrorNotimplementedDatagramTypeStreamTypeOrCommandUnknown : String(localized: "Permanent Error Not Implemented Datagram Type, Stream Type, Or Command Unknown"),
    .permanentErrorNotimplementedUnknownMTIOrTransportProtocolNotSupported : String(localized: "Permanent Error Not Implemented Unknown MTI Or Transport Protocol Not Supported"),
    .permanentErrorReserved5 : String(localized: "Permanent Error Reserved 5"),
    .permanentErrorReserved6 : String(localized: "Permanent Error Reserved 6"),
    .permanentErrorReserved7 : String(localized: "Permanent Error Reserved 7"),
    .permanentErrorInvalidArguments : String(localized: "Permanent Error Invalid Arguments"),
    .permanentErrorAddressSpaceUnknown : String(localized: "Permanent Error Address Space Unknown"),
    .permanentErrorAddressOutOfBounds : String(localized: "Permanent Error Address Out Of Bounds"),
    .permanentErrorWriteAccessToReadOnlySpace : String(localized: "Permanent Error Write Access To Read Only Space"),
    .permanentErrorReadCVFailed : String(localized: "Permanent Error Read CV Failed"),
    .permanentErrorWriteCVFailed : String(localized: "Permanent Error Write CV Failed"),
    .permanentErrorInvalidArgumentsFirmwareDataIncompatibleWithHardware : String(localized: "Permanent Error Invalid Arguments Firmware Data Incompatible With Hardware"),
    .permanentErrorInvalidArgumentsFirmwareDataInvalidOrCorrupted : String(localized: "Permanent Error Invalid Arguments Firmware Data Invalid Or Corrupted"),
    .permanentErrorReserved9 : String(localized: "Permanent Error Reserved 9"),
    .permanentErrorReserved10 : String(localized: "Permanent Error Reserved 10"),
    .permanentErrorReserved11 : String(localized: "Permanent Error Reserved 11"),
    .permanentErrorReserved12 : String(localized: "Permanent Error Reserved 12"),
    .permanentErrorReserved13 : String(localized: "Permanent Error Reserved 13"),
    .permanentErrorReserved14 : String(localized: "Permanent Error Reserved 14"),
    .permanentErrorReserved15 : String(localized: "Permanent Error Reserved 15"),
    .temporaryErrorNotFurtherSpecified : String(localized: "Temporary Error Not Further Specified"),
    .temporaryErrorTimeOut : String(localized: "Temporary Error Time Out"),
    .temporaryErrorTimeOutWaitingForEndFrame : String(localized: "Temporary Error Time Out Waiting For End Frame"),
    .temporaryErrorBufferUnavailable : String(localized: "Temporary Error Buffer Unavailable"),
    .temporaryErrorReserved3 : String(localized: "Temporary Error Reserved 3"),
    .temporaryErrorOutOfOrder : String(localized: "Temporary Error Out Of Order"),
    .temporaryErrorOutOfOrderMiddleOrEndFrameWithoutStartFrame : String(localized: "Temporary Error Out Of Order Middle Or End Frame Without Start Frame"),
    .temporaryErrorOutOfOrderStartFrameBeforeFinishingPreviousMessage : String(localized: "Temporary Error Out Of Order Start Frame Before Finishing Previous Message"),
    .temporaryErrorReserved5 : String(localized: "Temporary Error Reserved 5"),
    .temporaryErrorReserved6 : String(localized: "Temporary Error Reserved 6"),
    .temporaryErrorReserved7 : String(localized: "Temporary Error Reserved 7"),
    .temporaryErrorTransferError : String(localized: "Temporary Error Transfer Error"),
    .temporaryErrorLocoNetCollision : String(localized: "Temporary Error LocoNet Collision"),
    .temporaryErrorTransferErrorFailedChecksum : String(localized: "Temporary Error Transfer Error Failed Checksum"),
    .temporaryErrorReserved9 : String(localized: "Temporary Error Reserved 9"),
    .temporaryErrorReserved10 : String(localized: "Temporary Error Reserved 10"),
    .temporaryErrorReserved11 : String(localized: "Temporary Error Reserved 11"),
    .temporaryErrorReserved12 : String(localized: "Temporary Error Reserved 12"),
    .temporaryErrorReserved13 : String(localized: "Temporary Error Reserved 13"),
    .temporaryErrorReserved14 : String(localized: "Temporary Error Reserved 14"),
    .temporaryErrorReserved15 : String(localized: "Temporary Error Reserved 15"),
    .acceptFlag : String(localized: "Accept Flag"),
  ]

}
