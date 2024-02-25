//
//  OpenLCBCANFrameType.swift
//  MyTrains
//
//  Created by Paul Willmott on 09/04/2023.
//

import Foundation

public enum OpenLCBCANControlFrameFormat : UInt16 {
  
  case reserveIdFrame           = 0x0700
  case aliasMapDefinitionFrame  = 0x0701
  case aliasMappingEnquiryFrame = 0x0702
  case aliasMapResetFrame       = 0x0703
  case errorInformationReport0  = 0x0710
  case errorInformationReport1  = 0x0711
  case errorInformationReport2  = 0x0712
  case errorInformationReport3  = 0x0713
  case checkId7Frame            = 0x7000
  case checkId6Frame            = 0x6000
  case checkId5Frame            = 0x5000
  case checkId4Frame            = 0x4000
  
  // MARK: Public Properties
  
  public var isCheckIdFrame : Bool {
    return (self.rawValue & 0x7000) != 0
  }
  
  public var title : String {
    return OpenLCBCANControlFrameFormat.titles[self]!
  }
  
  // MARK: Private Class Properties
  
  private static let titles : [OpenLCBCANControlFrameFormat:String] = [
    .reserveIdFrame : String(localized: "Reserve ID Frame"),
    .aliasMapDefinitionFrame : String(localized: "Alias Map Definition Frame"),
    .aliasMappingEnquiryFrame : String(localized: "Alias Mapping Enquiry Frame"),
    .aliasMapResetFrame : String(localized: "Alias Map Reset Frame"),
    .errorInformationReport0 : String(localized: "Error Information Report 0"),
    .errorInformationReport1 : String(localized: "Error Information Report 1"),
    .errorInformationReport2 : String(localized: "Error Information Report 2"),
    .errorInformationReport3 : String(localized: "Error Information Report 3"),
    .checkId7Frame : String(localized: "Check ID 7 Frame"),
    .checkId6Frame : String(localized: "Check ID 6 Frame"),
    .checkId5Frame : String(localized: "Check ID 5 Frame"),
    .checkId4Frame : String(localized: "Check ID 4 Frame"),
  ]
  
}
