//
//  LocoSlotData.swift
//  MyTrains
//
//  Created by Paul Willmott on 22/01/2022.
//

import Foundation

public class LocoSlotData {
  
  // MARK: Constructors
  
  init(locoSlotDataP1: LocoSlotDataP1) {
    
    slotNumber = locoSlotDataP1.slotNumber << 1
    
    displaySlotNumber = "\(locoSlotDataP1.slotNumber)"
    
    address = locoSlotDataP1.address
    
    slotState = locoSlotDataP1.slotState
    
    mobileDecoderType = locoSlotDataP1.mobileDecoderType
    
    direction = locoSlotDataP1.direction
    
    speed = locoSlotDataP1.speed
    
    throttleID = locoSlotDataP1.throttleID
    
    functions = locoSlotDataP1.functions
    
    isF9F28Available = locoSlotDataP1.isF9F28Available
 
    if locoSlotDataP1.slotState == .free {
      for cs in networkController.commandStations {
        cs.value.moveSlots(sourceSlotNumber: locoSlotDataP1.slotNumber, sourceSlotPage: locoSlotDataP1.slotPage, destinationSlotNumber: locoSlotDataP1.slotNumber, destinationSlotPage: locoSlotDataP1.slotPage)
      }
    }
    else {
      for cs in networkController.commandStations {
        cs.value.getLocoSlot(forAddress: locoSlotDataP1.address+1)
      }
    }
  }
  
  init(locoSlotDataP2: LocoSlotDataP2) {
    
    slotNumber = locoSlotDataP2.slotPage << 8 | locoSlotDataP2.slotNumber << 1 | 0x01
    
    displaySlotNumber = "\(locoSlotDataP2.slotPage).\(locoSlotDataP2.slotNumber)"
    
    address = locoSlotDataP2.address
    
    slotState = locoSlotDataP2.slotState
    
    mobileDecoderType = locoSlotDataP2.mobileDecoderType
    
    direction = locoSlotDataP2.direction
    
    speed = locoSlotDataP2.speed
    
    throttleID = locoSlotDataP2.throttleID
    
    functions = locoSlotDataP2.functions
    
    isF9F28Available = locoSlotDataP2.isF9F28Available

    if locoSlotDataP2.slotState == .free {
      for cs in networkController.commandStations {
        cs.value.moveSlots(sourceSlotNumber: locoSlotDataP2.slotNumber, sourceSlotPage: locoSlotDataP2.slotPage, destinationSlotNumber: locoSlotDataP2.slotNumber, destinationSlotPage: locoSlotDataP2.slotPage)
      }
    }
    else {
      for cs in networkController.commandStations {
        cs.value.getLocoSlot(forAddress: locoSlotDataP2.address+1)
      }
    }
  }
  
  // MARK: Private Properties
  
  // MARK: Public Properties
  
  public var slotNumber : Int
  
  public var address : Int
  
  public var slotState : SlotState
  
  public var mobileDecoderType : MobileDecoderType
  
  public var direction : LocomotiveDirection
  
  public var speed : Int
  
  public var throttleID : Int
  
  public var functions : Int
  
  public var isF9F28Available : Bool
  
  public var displaySlotNumber : String
  
  // MARK: Public Methods
  
  public func displayFunctionState(functionNumber: Int) -> String {
    
    if functionNumber < 0 || functionNumber > 28 {
      return "err"
    }
    
    if functionNumber > 8 && !isF9F28Available {
      return "?"
    }
    
    let mask = 1 << functionNumber
    
    return (functions & mask) == mask ? "on" : "off"
    
  }
  
}
