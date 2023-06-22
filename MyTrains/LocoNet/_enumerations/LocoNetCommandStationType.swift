//
//  LocoNetCommandStationType.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/06/2023.
//

import Foundation

public enum LocoNetCommandStationType : UInt8 {
  
  case DT200         = 0xff
  case DCS100_DCS200 = 0x78
  case DB150         = 0x00
  case DCS50         = 0x08
  case DCS51         = 0x0c
  case DCS52         = 0x0d
  case DCS210        = 0x1b
  case DCS240        = 0x1c
  case DCS210Plus    = 0x1a
  case DCS240Plus    = 0x1d
 
  public var name : String {
    
    get {
      
      let names : [LocoNetCommandStationType:String] = [
        LocoNetCommandStationType.DT200         : "Digitrax DT200",
        LocoNetCommandStationType.DCS100_DCS200 : "Digitrax DCS100 or DCS200",
        LocoNetCommandStationType.DB150         : "Digitrax DB150",
        LocoNetCommandStationType.DCS50         : "Digitrax DCS50",
        LocoNetCommandStationType.DCS51         : "Digitrax DCS51",
        LocoNetCommandStationType.DCS52         : "Digitrax DCS52",
        LocoNetCommandStationType.DCS210        : "Digitrax DCS210",
        LocoNetCommandStationType.DCS240        : "Digitrax DCS240",
        LocoNetCommandStationType.DCS210Plus    : "Digitrax DCS210+",
        LocoNetCommandStationType.DCS240Plus    : "Digitrax DCS240+",
      ]

      return names[self]!
      
    }
    
  }
  
  public var protocolsSupported : Set<LocoNetProtocol> {
    
    get {
      
      var result : Set<LocoNetProtocol>
      
      switch self {
      case .DT200:
        result = [.protocol0]
      case .DCS100_DCS200, .DB150, .DCS50, .DCS51:
        result = [.protocol0, .protocol1]
      case .DCS210, .DCS240, .DCS52, .DCS210Plus, .DCS240Plus:
        result = [.protocol0, .protocol1, .protocol2]
      }
      
      return result
      
    }
    
  }
  
  public var idleSupportedByDefault : Bool {
    get {
      let commandStationsThatSupportIdle : Set<LocoNetCommandStationType> = [.DT200, .DCS100_DCS200, .DB150]
      return commandStationsThatSupportIdle.contains(self)
    }
  }
  
}
