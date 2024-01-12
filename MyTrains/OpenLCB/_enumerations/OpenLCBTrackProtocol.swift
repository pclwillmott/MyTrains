//
//  OpenLCBTrackProtocol.swift
//  MyTrains
//
//  Created by Paul Willmott on 18/06/2023.
//

import Foundation
import AppKit

public enum OpenLCBTrackProtocol : UInt8 {
  
  case anyTrackProtocol                     = 0b00000
  case nativeOpenLCBNode                    = 0b00001
  case mfxM4                                = 0b00010
  case marklinMotorolaAny                   = 0b00100
  case marklinMotorolaProtocolVersionI      = 0b00101
  case marklinMotorolaProtocolVersionII     = 0b00110
  case marklinMotorolaProtocolVersionIIF5F8 = 0b00111
  case dccDefaultAddressSpaceAnySpeedSteps  = 0b01000
  case dccDefaultAddressSpace14SpeedSteps   = 0b01001
  case dccDefaultAddressSpace28SpeedSteps   = 0b01010
  case dccDefaultAddressSpace128SpeedSteps  = 0b01011
  case dccLongAddressSpaceAnySpeedSteps     = 0b01100
  case dccLongAddressSpace14SpeedSteps      = 0b01101
  case dccLongAddressSpace28SpeedSteps      = 0b01110
  case dccLongAddressSpace128SpeedSteps     = 0b01111

  // MARK: Public Properties
  
  public var forceLongAddress : Bool {
    let mask : UInt8 = 0b01100
    return (self.rawValue & mask) == mask
  }
  
  // MARK: Public Methods
  
  public func isMatch(address:UInt16, speedSteps:SpeedSteps) -> Bool {
    
    if (self.rawValue & 0b11000) != 0b01000 {
      return self == .anyTrackProtocol
    }
    
    var result : Bool
    
    if (self.rawValue & 0b00100) == 0b00100 {
      result = address > 127
    }
    else {
      result = address < 128
    }
    
    switch self.rawValue & 0b11 {
    case 0b01:
      result = result && (speedSteps == .dcc14)
    case 0b10:
      result = result && (speedSteps == .dcc28)
    case 0b11:
      result = result && (speedSteps == .dcc128)
    default:
      break
    }

    return result
    
  }
  
  // MARK: Static Properties
  
  public static var trackProtocolMask : UInt8 {
    return 0b00011111
  }
  
  private static let titles : [OpenLCBTrackProtocol:String] = [
    anyTrackProtocol                     : "Any Track Protocol",
    nativeOpenLCBNode                    : "Native OpenLCB Train Node",
    mfxM4                                : "MFX / M4 Track Protocol",
    marklinMotorolaAny                   : "Marklin-Motorola Any Version",
    marklinMotorolaProtocolVersionI      : "Marklin-Motorola Protocol Version I",
    marklinMotorolaProtocolVersionII     : "Marklin-Motorola Protocol Version II",
    marklinMotorolaProtocolVersionIIF5F8 : "Marklin-Motorola Protocol Version II + F5-F8",
    dccDefaultAddressSpaceAnySpeedSteps  : "DCC Default Address Space Any Speed Steps",
    dccDefaultAddressSpace14SpeedSteps   : "DCC Default Address Space 14 Speed Steps",
    dccDefaultAddressSpace28SpeedSteps   : "DCC Default Address Space 28 Speed Steps",
    dccDefaultAddressSpace128SpeedSteps  : "DCC Default Address Space 128 Speed Steps",
    dccLongAddressSpaceAnySpeedSteps     : "DCC Long Address Space Any Speed Steps",
    dccLongAddressSpace14SpeedSteps      : "DCC Long Address Space 14 Speed Steps",
    dccLongAddressSpace28SpeedSteps      : "DCC Long Address Space 28 Speed Steps",
    dccLongAddressSpace128SpeedSteps     : "DCC Long Address Space 128 Speed Steps",
  ]
  
  // MARK: Static Methods
  
  public static let defaultValue : OpenLCBTrackProtocol = .anyTrackProtocol
  
  public static func populate(comboBox:NSComboBox) {
    comboBox.removeAllItems()
    var temp : [String] = []
    for (_, title) in titles {
      temp.append(title)
    }
    temp.sort {$0 < $1}
    comboBox.addItems(withObjectValues: temp)
    select(comboBox: comboBox, value: .defaultValue)
  }
  
  public static func select(comboBox:NSComboBox, value:OpenLCBTrackProtocol) {
    let key = titles[value]!
    for index in 0 ... comboBox.numberOfItems - 1 {
      if comboBox.itemObjectValue(at: index) as! String == key {
        comboBox.selectItem(at: index)
        return
      }
    }
    comboBox.selectItem(at: Int(value.rawValue))
  }

  public static func selected(comboBox: NSComboBox) -> OpenLCBTrackProtocol {
    let temp = comboBox.itemObjectValue(at: comboBox.indexOfSelectedItem) as! String
    for (key, item) in titles {
      if temp == item {
        return key
      }
    }
    return defaultValue
  }


}
