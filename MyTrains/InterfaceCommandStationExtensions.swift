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
      
      for slot in _locoSlots {
        slots.append(slot.value)
      }

      return slots.sorted {
        $0.slotID < $1.slotID
      }
      
    }
  }
  
  // MARK: Public Methods
  
  public func getLocoSlot(forAddress: Int) {
    
    getLocoSlot(forAddress: forAddress, locoNetProtocol: implementsProtocol2 ? 2 : 1)
    
  }

  public func getLocoSlot(forAddress: Int, locoNetProtocol: Int) {
    
    if forAddress > 0 {
      
      if locoNetProtocol == 2 {
        getLocoSlotDataP2(forAddress: forAddress, timeoutCode: .getLocoSlotData)
      }
      else {
        getLocoSlotDataP1(forAddress: forAddress, timeoutCode: .getLocoSlotData)
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
  
  public func updateLocomotiveState(slotNumber: Int, slotPage: Int, previousState:LocomotiveState, nextState:LocomotiveState, throttleID: Int, forceRefresh: Bool) -> LocomotiveStateWithTimeStamp {
 
    var timeStamp : TimeInterval?
    
    if isOpen {
      
      let speedChanged = previousState.speed != nextState.speed
      
      let directionChanged = previousState.direction != nextState.direction
      
      if speedChanged || directionChanged {
        timeStamp = Date.timeIntervalSinceReferenceDate
      }
      
      let previous = previousState.functions
      
      let next = nextState.functions

      if implementsProtocol2 {
        
        let useD5Group = true
        
        if useD5Group {
          
          let maskF0F6   = 0b00000000000000000000000001111111
          let maskF7F13  = 0b00000000000000000011111110000000
          let maskF14F20 = 0b00000000000111111100000000000000
          let maskF21F28 = 0b00011111111000000000000000000000
          
          if previous & maskF0F6 != next & maskF0F6 {
            locoF0F6P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
          }
          
          if previous & maskF7F13 != next & maskF7F13 {
            locoF7F13P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
          }
          
          if previous & maskF14F20 != next & maskF14F20 {
            locoF14F20P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
          }
          
          if previous & maskF21F28 != next & maskF21F28 {
            locoF21F28P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
          }
          
          if speedChanged || directionChanged || forceRefresh {
            locoSpdDirP2(slotNumber: slotNumber, slotPage: slotPage, speed: nextState.speed, direction: nextState.direction, throttleID: throttleID)
          }

        }
        else {
          
          let maskF0F4      = 0b00000000000000000000000000011111
          let maskF5F11     = 0b00000000000000000000111111100000
          let maskF13F19    = 0b00000000000011111110000000000000
          let maskF21F27    = 0b00001111111000000000000000000000
          let maskF12F20F28 = 0b00010000000100000001000000000000
          
          if previous & maskF0F4 != next & maskF0F4 || directionChanged {
            locoDirF0F4P2(slotNumber: slotNumber, slotPage: slotPage, direction: nextState.direction, functions: next)
          }
          
          if previous & maskF5F11 != next & maskF5F11 {
            locoF5F11P2(slotNumber: slotNumber, slotPage: slotPage, functions: next)
          }
          
          if previous & maskF12F20F28 != next & maskF12F20F28 {
            locoF12F20F28P2(slotNumber: slotNumber, slotPage: slotPage, functions: next)
          }
          
          if previous & maskF13F19 != next & maskF13F19 {
            locoF13F19P2(slotNumber: slotNumber, slotPage: slotPage, functions: next)
          }
          
          if previous & maskF21F27 != next & maskF21F27 {
            locoF21F27P2(slotNumber: slotNumber, slotPage: slotPage, functions: next)
          }
          
          if speedChanged || forceRefresh {
            locoSpdP2(slotNumber: slotNumber, slotPage: slotPage, speed: nextState.speed)
          }

        }
        
      }
      else {
        
        let maskF0F4 = 0b00000000000000000000000000011111
        let maskF5F8 = 0b00000000000000000000000111100000
        
        if previous & maskF0F4 != next & maskF0F4 || directionChanged {
          locoDirF0F4P1(slotNumber: slotNumber, direction: nextState.direction, functions: next)
        }
        
        if previous & maskF5F8 != next & maskF5F8 {
          locoF5F8P1(slotNumber: slotNumber, functions: next)
        }
        
        // TODO: Add IMMPacket messages for the other functions
        
        if speedChanged || forceRefresh {
          locoSpdP1(slotNumber: slotNumber, speed: nextState.speed)
        }

      }
      
    }

    return (state: nextState, timeStamp: timeStamp)

  }

}
