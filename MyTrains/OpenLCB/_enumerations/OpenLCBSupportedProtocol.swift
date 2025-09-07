// -----------------------------------------------------------------------------
// OpenLCBSupportedProtocol.swift
// MyTrains
//
// Copyright © 2025 Paul C. L. Willmott. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy 
// of this software and associated documentation files (the “Software”), to deal 
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
// copies of the Software, and to permit persons to whom the Software is 
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in 
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
// SOFTWARE.
// -----------------------------------------------------------------------------
//
// Revision History:
//
//     07/09/2025  Paul Willmott - OpenLCBSupportedProtocol.swift created
// -----------------------------------------------------------------------------

import Foundation

public enum OpenLCBSupportedProtocol : UInt64, CaseIterable {
  
  // MARK: Enumeration
  
  case simpleProtocolSubset                  = 0x8000000000000000
  case datagramProtocol                      = 0x4000000000000000
  case streamProtocol                        = 0x2000000000000000
  case memoryConfigurationProtocol           = 0x1000000000000000
  case reservationProtocol                   = 0x0800000000000000
  case eventExchangeProtocol                 = 0x0400000000000000
  case identificationProtocol                = 0x0200000000000000
  case teachingLearningConfigurationProtocol = 0x0100000000000000
  case remoteButtonProtocol                  = 0x0080000000000000
  case abbreviatedDefaultCDIProtocol         = 0x0040000000000000
  case displayProtocol                       = 0x0020000000000000
  case simpleNodeInformationProtocol         = 0x0010000000000000
  case configurationDescriptionInformation   = 0x0008000000000000
  case trainControlProtocol                  = 0x0004000000000000
  case functionDescriptionInformation        = 0x0002000000000000
  // Missing: Reserved. Shall be sent as 0 and ignored on receipt.
  // Missing: Reserved. Shall be sent as 0 and ignored on receipt.
  case functionConfiguration                 = 0x0000400000000000
  case firmwareUpgradeProtocol               = 0x0000200000000000
  case firmwareUpgradeActive                 = 0x0000100000000000

  // MARK: Public Properties
  
  public var title : String {
    return OpenLCBSupportedProtocol.titles[self]!
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [OpenLCBSupportedProtocol:String] = [
    .simpleProtocolSubset                  : String(localized: "Simple Protocol Subset"),
    .datagramProtocol                      : String(localized: "Datagram Protocol"),
    .streamProtocol                        : String(localized: "Stream Protocol"),
    .memoryConfigurationProtocol           : String(localized: "Memory Configuration Protocol"),
    .reservationProtocol                   : String(localized: "Reservation Protocol"),
    .eventExchangeProtocol                 : String(localized: "Event Exchange (Producer/Consumer) Protocol"),
    .identificationProtocol                : String(localized: "Identification Protocol"),
    .teachingLearningConfigurationProtocol : String(localized: "Teaching/Learning Configuration Protocol"),
    .remoteButtonProtocol                  : String(localized: "Remote Button Protocol"),
    .abbreviatedDefaultCDIProtocol         : String(localized: "Abbreviated Default CDI Protocol"),
    .displayProtocol                       : String(localized: "Display Protocol"),
    .simpleNodeInformationProtocol         : String(localized: "Simple Node Information Protocol"),
    .configurationDescriptionInformation   : String(localized: "Configuration Description Information"),
    .trainControlProtocol                  : String(localized: "Train Control Protocol"),
    .functionDescriptionInformation        : String(localized: "Function Description Information"),
    .functionConfiguration                 : String(localized: "Function Configuration"),
    .firmwareUpgradeProtocol               : String(localized: "Firmware Upgrade Protocol"),
    .firmwareUpgradeActive                 : String(localized: "Firmware Upgrade Active"),
  ]
  
}
