//
//  OpenLCBLocoNetCommandStation.swift
//  MyTrains
//
//  Created by Paul Willmott on 07/04/2024.
//

import Foundation

private let numberOfSlots = 476

private let slotsPerBank = 119

public class OpenLCBLocoNetCommandStationSlot {
  
  // MARK: Constructors & Destructors
  
  init?(slotId:Int) {
    guard slotId >= 0 && slotId < numberOfSlots else {
      return nil
    }
    self.slotId = slotId
  }
  
  // MARK: Private Properties
  
  // MARK: Public Properties
  
  // slotId ranges from 0 to 475
  public var slotId : Int
  
  // slotNumber ranges from 1 to 119
  public var slotNumber : UInt8 {
    return UInt8(slotId % slotsPerBank) + 1
  }
  
  // slotBank ranges from 0 to 3
  public var slotBank : UInt8 {
    return UInt8(slotId / slotsPerBank)
  }
  
  public var dccAddress : UInt16 = 0
  
  public var speed : UInt8 = 0
  
  public var function : [UInt8] = [UInt8](repeating: 0, count: 29)
  
  public var direction : LocomotiveDirection = .forward
  
  public var state : LocoNetSlotState = .free
  
  public var purgeTime : TimeInterval = 0
  
  public var trainNodeId : UInt64?
  
  // MARK: Private Methods
  
  // MARK: Public Methods
  
}

public class OpenLCBLocoNetCommandStation : OpenLCBNodeVirtual {

  // MARK: Constructors & Destructors
  
  override public init(nodeId: UInt64) {
    
    super.init(nodeId: nodeId)
    
    for slotId in 0 ... numberOfSlots - 1 {
      if slotId < slotsPerBank {
        freeStandardSlots.insert(slotId)
      }
      else {
        freeExpandedSlots.insert(slotId)
      }
    }
    
  }
  
  deinit {
    slot.removeAll()
    freeExpandedSlots.removeAll()
    freeStandardSlots.removeAll()
    inUseSlots.removeAll()
  }
  
  // MARK: Private Properties
  
  private var slot : [Int:OpenLCBLocoNetCommandStationSlot] = [:]
  
  private var freeStandardSlots : Set<Int> = []
  
  private var freeExpandedSlots : Set<Int> = []
  
  private var inUseSlots : Set<Int> = []
  
  // MARK: Public Properties
  
  public var isPowerUp : Bool = true
  
  public var isTrackIdle : Bool = false
  
  // MARK: Private Methods
  
  private func getFreeStandardSlot() -> OpenLCBLocoNetCommandStationSlot? {
    
    guard !freeStandardSlots.isEmpty else {
      return nil
    }
    
    let id = freeStandardSlots.removeFirst()
    
    inUseSlots.insert(id)
    
    let newSlot = OpenLCBLocoNetCommandStationSlot(slotId: id)!
      
    slot[id] = newSlot
      
    return newSlot
      
  }

  private func getFreeExpandedSlot() -> OpenLCBLocoNetCommandStationSlot? {
    
    guard !freeExpandedSlots.isEmpty else {
      return nil
    }
    
    let id = freeExpandedSlots.removeFirst()
    
    inUseSlots.insert(id)
    
    let newSlot = OpenLCBLocoNetCommandStationSlot(slotId: id)!
      
    slot[id] = newSlot
      
    return newSlot
      
  }
  
  private func releaseSlot(slotId:Int) {
    
    slot.removeValue(forKey: slotId)
    
    inUseSlots.remove(slotId)
    
    if slotId < slotsPerBank {
      freeStandardSlots.insert(slotId)
    }
    else {
      freeExpandedSlots.insert(slotId)
    }
    
  }

  // MARK: Public Methods
  
}

