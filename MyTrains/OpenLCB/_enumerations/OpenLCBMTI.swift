//
//  OpenLCBMTI.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/04/2023.
//

import Foundation

public enum OpenLCBMTI : UInt16 {
  
  case initializationCompleteFullProtocolRequired        = 0x0100
  case initializationCompleteSimpleSetSufficient         = 0x0101
  case verifyNodeIDAddressed                             = 0x0488
  case verifyNodeIDGlobal                                = 0x0490
  case verifiedNodeIDFullProtocolRequired                = 0x0170
  case verifiedNodeIDSimpleSetSufficient                 = 0x0171
  case optionalInteractionRejected                       = 0x0068
  case terminateDueToError                               = 0x00A8
  case protocolSupportInquiry                            = 0x0828
  case protocolSupportReply                              = 0x0668
  case identifyConsumer                                  = 0x08F4
  case consumerRangeIdentified                           = 0x04A4
  case consumerIdentifiedWithValidityUnknown             = 0x04C7
  case consumerIdentifiedAsCurrentlyValid                = 0x04C4
  case consumerIdentifiedAsCurrentlyInvalid              = 0x04C5
  case consumerIdentified_reserved                       = 0x04C6
  case identifyProducer                                  = 0x0914
  case producerRangeIdentified                           = 0x0524
  case producerIdentifiedWithValidityUnknown             = 0x0547
  case producerIdentifiedAsCurrentlyValid                = 0x0544
  case producerIdentifiedAsCurrentlyInvalid              = 0x0545
  case producerIdentified_reserved                       = 0x0546
  case identifyEventsAddressed                           = 0x0968
  case identifyEventsGlobal                              = 0x0970
  case learnEvent                                        = 0x0594
  case producerConsumerEventReport                       = 0x05B4
  case producerConsumerEventReportWithPayloadLastFrame   = 0x05B5
  case producerConsumerEventReportWithPayloadMiddleFrame = 0x05B6
  case producerConsumerEventReportWithPayloadFirstFrame  = 0x05B7
  case tractionControlCommand                            = 0x05EB
  case tractionControlReply                              = 0x01E9
  case xpressnet                                         = 0x0820
  case remoteButtonRequest                               = 0x0948
  case remoteButtonReply                                 = 0x0549
  case simpleTrainNodeIdentInfoRequest                   = 0x0DA8
  case simpleTrainNodeIdentInfoReply                     = 0x09C8
  case simpleNodeIdentInfoRequest                        = 0x0DE8
  case simpleNodeIdentInfoReply                          = 0x0A08
  case datagram                                          = 0x1C48
  case datagramReceivedOK                                = 0x0A28
  case datagramRejected                                  = 0x0A48
  case streamInitiateRequest                             = 0x0CC8
  case streamInitiateReply                               = 0x0868
  case streamDataSend                                    = 0x1F88
  case streamDataProceed                                 = 0x0888
  case streamDataComplete                                = 0x08A8
  case sendLocoNetMessageReply                           = 0x0688   // 0b0000011010001000
  case unknown                                           = 0xFFFF
  
  // MARK: Public Properties
  
  public var title : String {
    return OpenLCBMTI.titles[self]!
  }
  
  public var isAddressPresent : Bool {
    let mask : UInt16 = 0x0008
    return (self.rawValue & mask) == mask
  }
  
  public var isEventPresent : Bool {
    let mask : UInt16 = 0x0004
    return (self.rawValue & mask) == mask
  }
  
  public var isStreamOrDatagram : Bool {
    let mask : UInt16 = 0x1000
    return (self.rawValue & mask) == mask
  }
  
  public var priority : UInt16 {
    let mask : UInt16 = 0x0c00
    return (self.rawValue & mask) >> 10
  }
  
  public var typeWithinPriority : UInt16 {
    let mask : UInt16 = 0x03e0
    return (self.rawValue & mask) >> 5
  }
  
  public var isSimpleProtocol : Bool {
    let mask : UInt16 = 0x0010
    return (self.rawValue & mask) == mask
  }

  public var modifier : UInt16 {
    let mask : UInt16 = 0x0003
    return self.rawValue & mask
  }
  
  public var isSpecial : Bool {
    let mask : UInt16 = 0x2000
    return (self.rawValue & mask) == mask
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [OpenLCBMTI:String] = [
    .initializationCompleteFullProtocolRequired : String(localized: "Initialization Complete Full Protocol Required"),
    .initializationCompleteSimpleSetSufficient : String(localized: "Initialization Complete Simple Set Sufficient"),
    .verifyNodeIDAddressed : String(localized: "Verify Node ID Addressed"),
    .verifyNodeIDGlobal : String(localized: "Verify Node ID Global"),
    .verifiedNodeIDFullProtocolRequired : String(localized: "Verified Node ID Full Protocol Required"),
    .verifiedNodeIDSimpleSetSufficient : String(localized: "Verified Node ID Simple Set Sufficient"),
    .optionalInteractionRejected : String(localized: "Optional Interaction Rejected"),
    .terminateDueToError : String(localized: "Terminate Due To Error"),
    .protocolSupportInquiry : String(localized: "Protocol Support Inquiry"),
    .protocolSupportReply : String(localized: "Protocol Support Reply"),
    .identifyConsumer : String(localized: "Identify Consumer"),
    .consumerRangeIdentified : String(localized: "Consumer Range Identified"),
    .consumerIdentifiedWithValidityUnknown : String(localized: "Consumer Identified With Validity Unknown"),
    .consumerIdentifiedAsCurrentlyValid : String(localized: "Consumer Identified As Currently Valid"),
    .consumerIdentifiedAsCurrentlyInvalid : String(localized: "Consumer Identified As Currently Invalid"),
    .consumerIdentified_reserved : String(localized: "Consumer Identified Reserved"),
    .identifyProducer : String(localized: "Identify Producer"),
    .producerRangeIdentified : String(localized: "Producer Range Identified"),
    .producerIdentifiedWithValidityUnknown : String(localized: "Producer Identified With Validity Unknown"),
    .producerIdentifiedAsCurrentlyValid : String(localized: "Producer Identified As Currently Valid"),
    .producerIdentifiedAsCurrentlyInvalid : String(localized: "Producer Identified As Currently Invalid"),
    .producerIdentified_reserved : String(localized: "Producer Identified Reserved"),
    .identifyEventsAddressed : String(localized: "Identify Events Addressed"),
    .identifyEventsGlobal : String(localized: "Identify Events Global"),
    .learnEvent : String(localized: "Learn Event"),
    .producerConsumerEventReport : String(localized: "Producer Consumer Event Report"),
    .producerConsumerEventReportWithPayloadLastFrame : String(localized: "Producer Consumer Event Report With Payload Last Frame"),
    .producerConsumerEventReportWithPayloadMiddleFrame : String(localized: "Producer Consumer Event Report With Payload Middle Frame"),
    .producerConsumerEventReportWithPayloadFirstFrame : String(localized: "Producer Consumer Event Report With Payload First Frame"),
    .tractionControlCommand : String(localized: "Traction Control Command"),
    .tractionControlReply : String(localized: "Traction Control Reply"),
    .xpressnet : String(localized: "Xpressnet"),
    .remoteButtonRequest : String(localized: "Remote Button Request"),
    .remoteButtonReply : String(localized: "Remote Button Reply"),
    .simpleTrainNodeIdentInfoRequest : String(localized: "Simple Train Node Ident Info Request"),
    .simpleTrainNodeIdentInfoReply : String(localized: "Simple Train Node Ident Info Reply"),
    .simpleNodeIdentInfoRequest : String(localized: "Simple Node Ident Info Request"),
    .simpleNodeIdentInfoReply : String(localized: "Simple Node Ident Info Reply"),
    .datagram : String(localized: "Datagram"),
    .datagramReceivedOK : String(localized: "Datagram Received OK"),
    .datagramRejected : String(localized: "Datagram Rejected"),
    .streamInitiateRequest : String(localized: "Stream Initiate Request"),
    .streamInitiateReply : String(localized: "Stream Initiate Reply"),
    .streamDataSend : String(localized: "Stream Data Send"),
    .streamDataProceed : String(localized: "Stream Data Proceed"),
    .streamDataComplete : String(localized: "Stream Data Complete"),
    .sendLocoNetMessageReply : String(localized: "Send LocoNet Message Reply"),
    .unknown : String(localized: "Unknown"),
  ]
  
}
