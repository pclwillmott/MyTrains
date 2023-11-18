//
//  OpenLCBStandardContentBlockType.swift
//  MyTrains
//
//  Created by Paul Willmott on 18/11/2023.
//

import Foundation

public enum OpenLCBStandardContentBlockType : UInt8 {
  
  case none                 = 0x00
  case humanReadable        = 0x01
  case rfid                 = 0x02
  case qrBarcode            = 0x03
  case railCom              = 0x04
  case digitraxTransponding = 0x05
  case positionInformation  = 0x06
  case json                 = 0x07
  case analog               = 0x08
  
}
