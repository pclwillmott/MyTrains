//
//  ProductCode.swift
//  MyTrains
//
//  Created by Paul Willmott on 21/05/2022.
//

import Foundation

public enum ProductCode : UInt8 {
  
  case LNRP             = 0x01
  case UT4              = 0x04
  case UT6              = 0x06
  case WTL12            = 0x0c
  case DB210Opto        = 0x14
  case DB210            = 0x15
  case DB220            = 0x16
  case DCS210Plus       = 0x1a
  case DCS210           = 0x1b
  case DCS240           = 0x1c
  case PR3              = 0x23
  case PR4              = 0x24
  case DT402            = 0x2a
  case DT500            = 0x32
  case DCS51            = 0x33
  case DCS52            = 0x34
  case DT602            = 0x3e
  case BXPA1            = 0x51
  case BXP88            = 0x58
  case LNWI             = 0x63
  case UR92             = 0x5c
  case UR93             = 0x5d
  case DS74             = 0x74
  case softwareThrottle = 0x7f
  case none             = 0xff
  
  func product() -> LocoNetProduct? {
    if let product = LocoNetProducts.product(productCode: self.rawValue) {
      return product
    }
    return nil
  }
  
  func productName() -> String {
    
    if let prod = self.product() {
      return prod.productName
    }
    
    switch self {
    case .none:
      return "None"
    case .softwareThrottle:
      return "Software Throttle"
    default:
      return "Unknown"
    }
    
  }
  
}
