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
    
    slotPage = 0
    
    slotNumber = locoSlotDataP1.slotNumber
    
    slotID = LocoSlotData.getID(slotNumber: slotNumber)
    
    address = locoSlotDataP1.address
    
    slotState = locoSlotDataP1.slotState
    
    consistState = locoSlotDataP1.consistState
    
    mobileDecoderType = locoSlotDataP1.mobileDecoderType
    
    direction = locoSlotDataP1.direction
    
    speed = locoSlotDataP1.speed
    
    throttleID = locoSlotDataP1.throttleID
    
    functions = locoSlotDataP1.functions
    
    isF9F28Available = locoSlotDataP1.isF9F28Available
    
    isP1 = true
 
  }
  
  init(locoSlotDataP2: LocoSlotDataP2) {
    
    slotPage = locoSlotDataP2.slotPage
    
    slotNumber = locoSlotDataP2.slotNumber
    
    slotID = LocoSlotData.getID(slotPage: slotPage, slotNumber: slotNumber)
    
    address = locoSlotDataP2.address
    
    slotState = locoSlotDataP2.slotState
    
    consistState = locoSlotDataP2.consistState
    
    mobileDecoderType = locoSlotDataP2.mobileDecoderType
    
    direction = locoSlotDataP2.direction
    
    speed = locoSlotDataP2.speed
    
    throttleID = locoSlotDataP2.throttleID
    
    functions = locoSlotDataP2.functions
    
    isF9F28Available = locoSlotDataP2.isF9F28Available
    
    isP1 = false

  }
  
  init(slotID: Int) {
    
    self.slotID = slotID
    
    let decoded = LocoSlotData.decodeID(slotID: slotID)
    
    slotPage = decoded.page
    
    slotNumber = decoded.number
    
    isP1 = decoded.isP1
    
    address = 0
    
    slotState = .free
    
    consistState = .NotLinked
    
    mobileDecoderType = .unknown
    
    direction = .forward
    
    speed = 0
    
    throttleID = 0
    
    functions = 0
    
    isF9F28Available = false
    
    isDirty = true

  }
  
  // MARK: Private Properties
  
  // MARK: Public Properties
  
  public var slotID : Int
  
  public var slotPage : Int
  
  public var slotNumber : Int
  
  public var address : Int
  
  public var slotState : SlotState
  
  public var consistState : ConsistState
  
  public var mobileDecoderType : SpeedSteps
  
  public var direction : LocomotiveDirection
  
  public var speed : Int
  
  public var throttleID : Int
  
  public var functions : Int
  
  public var isF9F28Available : Bool
  
  public var displaySlotNumber : String {
    get {
      return isP1 ? "\(slotNumber)" : "\(slotPage).\(slotNumber)"
    }
  }
  
  public var locomotiveName : String {
    get {
      for locomotive in networkController.locomotives {
        if address == locomotive.value.address {
          return locomotive.value.locomotiveName
        }
      }
      return "Unknown"
    }
  }
  
  public var isP1 : Bool
  
  public var isDirty : Bool = false
  
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

  // MARK: Class Methods
  
  public static func getID(slotNumber:Int) -> Int {
    return slotNumber << 1
  }

  public static func getID(slotPage:Int, slotNumber:Int) -> Int {
    return slotPage << 8 | slotNumber << 1 | 0x01
  }
  
  public static func decodeID(slotID: Int) -> (page: Int, number: Int, isP1 : Bool) {
    
    let isP1 = (slotID & 1) == 1
    
    let page = slotID >> 8
    
    let number = (slotID >> 1) & 0xff
    
    return (page: page, number: number, isP1: isP1)
    
  }
  
}
