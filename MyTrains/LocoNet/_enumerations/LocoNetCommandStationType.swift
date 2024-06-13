//
//  LocoNetCommandStationType.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/06/2023.
//

import Foundation

public enum LocoNetCommandStationType : UInt16 {
  
  // MARK: Enumeration
  
  case DCS100_DCS200 = 0x78
  case DB150         = 0x00
  case DCS50         = 0x08
  case DCS51         = 0x0c
  case DCS52         = 0x0d
  case DCS210        = 0x1b
  case DCS240        = 0x1c
  case DCS210Plus    = 0x1a
  case DCS240Plus    = 0x1d
  case DT200         = 0xff
  case standAlone    = 0xffff

  // MARK: Public Properties
  
  public var name : String {
    
    let names : [LocoNetCommandStationType:String] = [
      LocoNetCommandStationType.DT200         : String(localized: "Digitrax DT200"),
      LocoNetCommandStationType.DCS100_DCS200 : String(localized: "Digitrax DCS100 or DCS200"),
      LocoNetCommandStationType.DB150         : String(localized: "Digitrax DB150"),
      LocoNetCommandStationType.DCS50         : String(localized: "Digitrax DCS50"),
      LocoNetCommandStationType.DCS51         : String(localized: "Digitrax DCS51"),
      LocoNetCommandStationType.DCS52         : String(localized: "Digitrax DCS52"),
      LocoNetCommandStationType.DCS210        : String(localized: "Digitrax DCS210"),
      LocoNetCommandStationType.DCS240        : String(localized: "Digitrax DCS240"),
      LocoNetCommandStationType.DCS210Plus    : String(localized: "Digitrax DCS210+"),
      LocoNetCommandStationType.DCS240Plus    : String(localized: "Digitrax DCS240+"),
      LocoNetCommandStationType.standAlone    : String(localized: "Stand Alone LocoNet"),
    ]

    return names[self]!

  }
  
  public var implementsProtocol0 : Bool {
    return protocolsImplemented.contains(.protocol0)
  }
  
  public var implementsProtocol1 : Bool {
    return protocolsImplemented.contains(.protocol1)
  }
  
  public var implementsProtocol2 : Bool {
    return protocolsImplemented.contains(.protocol2)
  }

  public var protocolsImplemented : Set<LocoNetProtocol> {
    
    var result : Set<LocoNetProtocol>
    
    switch self {
    case .DT200:
      result = [.protocol0]
    case .DCS100_DCS200, .DB150, .DCS50, .DCS51:
      result = [.protocol0, .protocol1]
    case .DCS210, .DCS240, .DCS52, .DCS210Plus, .DCS240Plus:
      result = [.protocol0, .protocol1, .protocol2]
    case .standAlone:
      result = []
    }
    
    return result

  }
  
  public var idleSupportedByDefault : Bool {
    let commandStationsThatSupportIdle : Set<LocoNetCommandStationType> = [.DT200, .DCS100_DCS200, .DB150]
    return commandStationsThatSupportIdle.contains(self)
  }
  
  public var programmingTrackExists : Bool {
    let commandStationsWithProgrammingTrack : Set<LocoNetCommandStationType> = [.DCS100_DCS200, .DCS50, .DCS51, .DCS52, .DCS210, .DCS210Plus, .DCS240, .DCS240Plus]
    return commandStationsWithProgrammingTrack.contains(self)
  }
  
}
