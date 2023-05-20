//
//  OpenLCBMTI.swift
//  MyTrains
//
//  Created by Paul Willmott on 08/04/2023.
//

import Foundation

public enum OpenLCBMTI : UInt16 {
  
  case initializationCompleteFullProtocolRequired = 0x0100
  case initializationCompleteSimpleSetSufficient  = 0x0101
  case verifyNodeIDNumberAddressed                = 0x0488
  case verifyNodeIDNumberGlobal                   = 0x0490
  case verifiedNodeIDNumberFullProtocolRequired   = 0x0170
  case verifiedNodeIDNumberSimpleSetSufficient    = 0x0171
  case optionalInteractionRejected                = 0x0068
  case terminateDueToError                        = 0x00A8
  case protocolSupportInquiry                     = 0x0828
  case protocolSupportReply                       = 0x0668
  case identifyConsumer                           = 0x08F4
  case consumerRangeIdentified                    = 0x04A4
  case consumerIdentifiedWithValidityUnknown      = 0x04C7
  case consumerIdentifiedAsCurrentlyValid         = 0x04C4
  case consumerIdentifiedAsCurrentlyInvalid       = 0x04C5
  case consumerIdentified_reserved                = 0x04C6
  case identifyProducer                           = 0x0914
  case producerRangeIdentified                    = 0x0524
  case producerIdentifiedWithValidityUnknown      = 0x0547
  case producerIdentifiedAsCurrentlyValid         = 0x0544
  case producerIdentifiedAsCurrentlyInvalid       = 0x0545
  case producerIdentified_reserved                = 0x0546
  case identifyEventsAddressed                    = 0x0968
  case identifyEventsGlobal                       = 0x0970
  case learnEvent                                 = 0x0594
  case producerConsumerEventReport                = 0x05B4
  case tractionControlCommand                     = 0x05E8
  case tractionControlReply                       = 0x01E8
  case tractionProxyCommand_obsolete              = 0x09E9
  case tractionProxyReply_obsolete                = 0x05E9
  case xpressnet                                  = 0x0820
  case remoteButtonRequest                        = 0x0948
  case remoteButtonReply                          = 0x0549
  case simpleTrainNodeIdentInfoRequest            = 0x0DA8
  case simpleTrainNodeIdentInfoReply              = 0x09C8
  case simpleNodeIdentInfoRequest                 = 0x0DE8
  case simpleNodeIdentInfoReply                   = 0x0A08
  case datagram                                   = 0x1C48
  case datagramReceivedOK                         = 0x0A28
  case datagramRejected                           = 0x0A48
  case streamInitiateRequest                      = 0x0CC8
  case streamInitiateReply                        = 0x0868
  case streamDataSend                             = 0x1F88
  case streamDataProceed                          = 0x0888
  case streamDataComplete                         = 0x08A8
  case unknown                                    = 0xFFFF
  
}
