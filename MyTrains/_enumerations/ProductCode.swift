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
  case DCS240Plus       = 0x1d
  case PR3              = 0x23
  case PR4              = 0x24
  case DT402            = 0x2a
  case DT500            = 0x32
  case DCS51            = 0x33
  case DCS52            = 0x34
  case DT602            = 0x3e
  case SE74             = 0x46
  case PM74             = 0x4a
  case BXPA1            = 0x51
  case BXP88            = 0x58
  case LNWI             = 0x63
  case UR92             = 0x5c
  case UR93             = 0x5d
  case DS74             = 0x74
  case DS78V            = 0x7c
  case softwareThrottle = 0x7f
  case none             = 0xff
  
  public var product : LocoNetProduct? {
    return LocoNetProducts.product(productCode: self.rawValue)
  }
  
  public var locoNetProductId : DeviceId? {
    guard let product else {
      return nil
    }
    return product.id
  }
  
  public var productName : String {
    
    if let product {
      return product.productName
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
