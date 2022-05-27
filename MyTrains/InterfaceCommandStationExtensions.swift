//
//  InterfaceCommandStationExtensions.swift
//  MyTrains
//
//  Created by Paul Willmott on 27/05/2022.
//

import Foundation

extension Interface {
  
  // MARK: Public Properties
  
  public var implementsProtocol1 : Bool {
    get {
      if let cs = commandStation, let trk = cs.globalSystemTrackStatus {
        return (trk & 0b00000100) == 0b00000100
      }
      return false
    }
  }
  
  public var implementsProtocol2 : Bool {
    get {
      if let cs = commandStation, let trk = cs.globalSystemTrackStatus {
        return (trk & 0b01000000) == 0b01000000
      }
      return false
    }
  }
  
  public var programmingTrackIsBusy : Bool {
    get {
      if let cs = commandStation, let trk = cs.globalSystemTrackStatus {
        return (trk & 0b00001000) == 0b00001000
      }
      return false
    }
  }
  
  public var trackIsPaused : Bool {
    get {
      if let cs = commandStation, let trk = cs.globalSystemTrackStatus {
        return (trk & 0b00000010) == 0b00000000
      }
      return false
    }
  }
  
  public var powerIsOn : Bool {
    get {
      if let cs = commandStation, let trk = cs.globalSystemTrackStatus {
        return (trk & 0b00000001) == 0b00000001
      }
      return false
    }
  }

  public var locoSlots : [LocoSlotData] {
    get {
      
      var slots : [LocoSlotData] = []
      
      if let cs = commandStation {
        for slot in cs._locoSlots {
          slots.append(slot.value)
        }
      }
      
      return slots.sorted {
        $0.slotID < $1.slotID
      }
      
    }
  }
  
  public var maxSlotNumber : (page:Int, number:Int)? {
    get {
      
      if let cs = commandStation, let info = cs.locoNetProductInfo {
        
        // TODO: This needs to be expanded for all command stations, and to take into account OpSw settings.
        
        switch info.id {
        case .DCS210PLUS:
          return (page:0, number:100)
        case .DCS210:
          return (page:0, number:100)
        case .DCS240:
          return (page:3, number:48)
        default:
          break
        }
        
      }
      
      return nil
      
    }
  }

}
