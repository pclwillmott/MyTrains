//
//  Locomotive.swift
//  MyTrains
//
//  Created by Paul Willmott on 07/11/2021.
//

import Foundation

public class Locomotive {
  
  init(locomotiveId:String, address:UInt16, interface:NetworkMessenger) {
    self.locomotiveId = locomotiveId
    self.address = address
    self.interface = interface
  }
  
  public var locomotiveId : String
  
  public var address : UInt16
  
  public var slot : LoconetSlot? = nil
  
  private var interface : NetworkMessenger
  
  public func requestSlotInfo() {
    interface.requestSlotInfo(address: UInt8(address))
  }
  
  // These methods assume that the slot has been assigned
  
  public func nullMove() {
    if let slot = self.slot {
      interface.nullMove(slotNumber: slot.slotNumber)
    }
  }
  
  public var sound1 : Bool {
    get {
      return slot!.sound1
    }
    set(value) {
      if let slot = self.slot {
        slot.sound1 = value
        interface.setLocoSound(slotNumber: slot.slotNumber)
      }
    }
  }

  public var sound2 : Bool {
    get {
      return slot!.sound2
    }
    set(value) {
      if let slot = self.slot {
        slot.sound2 = value
        interface.setLocoSound(slotNumber: slot.slotNumber)
      }
    }
  }

  public var sound3 : Bool {     
    get {
      return slot!.sound3
    }
    set(value) {
      if let slot = self.slot {
        slot.sound3 = value
        interface.setLocoSound(slotNumber: slot.slotNumber)
      }
    }
  }

  public var sound4 : Bool {
    get {
      return slot!.sound4
    }
    set(value) {
      if let slot = self.slot {
        slot.sound4 = value
        interface.setLocoSound(slotNumber: slot.slotNumber)
      }
    }
  }

  public var stateF0 : Bool {
    get {
      return slot!.stateF1
    }
    set(value) {
      if let slot = self.slot {
        slot.stateF0 = value
        interface.setLocoDirF(slotNumber: slot.slotNumber)
      }
    }
  }

  public var stateF1 : Bool {
    get {
      return slot!.stateF1
    }
    set(value) {
      if let slot = self.slot {
        slot.stateF1 = value
        interface.setLocoDirF(slotNumber: slot.slotNumber)
      }
    }
  }

  public var stateF2 : Bool {
    get {
      return slot!.stateF2
    }
    set(value) {
      if let slot = self.slot {
        slot.stateF2 = value
        interface.setLocoDirF(slotNumber: slot.slotNumber)
      }
    }
  }

  public var stateF3 : Bool {
    get {
      return slot!.stateF3
    }
    set(value) {
      if let slot = self.slot {
        slot.stateF3 = value
        interface.setLocoDirF(slotNumber: slot.slotNumber)
      }
    }
  }

  public var stateF4 : Bool {
    get {
      return slot!.stateF4
    }
    set(value) {
      if let slot = self.slot {
        slot.stateF4 = value
        interface.setLocoDirF(slotNumber: slot.slotNumber)
      }
    }
  }

  public var locoDirection : LoconetLocoDirection {
    get {
      return slot!.locoDirection
    }
    set(value) {
      if let slot = self.slot {
        slot.locoDirection = value
        interface.setLocoDirF(slotNumber: slot.slotNumber)
      }
    }
  }

  public var speed : UInt8 {
    get {
      return slot!.speed
    }
    set(value) {
      if let slot = self.slot {
        slot.speed = value & 0x7f
        interface.setLocoSpeed(slotNumber: slot.slotNumber)
      }
    }
  }

}
