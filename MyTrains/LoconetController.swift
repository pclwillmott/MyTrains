//
//  LoconetController.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/11/2021.
//

import Foundation

public class LoconetController : LoconetMessengerDelegate  {
  
  init() {
  
    let connections = ["/dev/cu.usbmodemDxP431751"
//                    ,  "/dev/cu.usbmodemDxP470881"
    ]
    
    var index : Int = 1
    for connection in connections {
      var loconetMessenger = LoconetMessenger(id: "id\(index)", path: connection)
      loconetMessengers[loconetMessenger.id] = loconetMessenger
      loconetMessenger.delegate = self
      index += 1
    }
    
  }
  
  private var loconetMessengers : [String:LoconetMessenger] = [:]
  
  private var loconetSlots : [String:LoconetSlot] = [:]
  
  // LoconetMessenger Delegate Functions
  
  public func LoconetSensorMessageReceived(message: LoconetSensorMessage) {
    
  }
  
  public func LoconetSwitchRequestMessageReceived(message: LoconetSwitchRequestMessage) {
    
  }
  
  public func LoconetSlotDataMessageReceived(message: LoconetSlotDataMessage) {
    loconetSlots[message.slot.slotId] = message.slot
  }
  
  public func LoconetTurnoutOutputMessageReceived(message: LoconetTurnoutOutputMessage) {
    
  }
  
  public func LoconetLongAcknowledgeMessageReceived(message: LoconetLongAcknowledgeMessage) {
    
  }
  
  public func LoconetRequestSlotDataMessageReceived(message: LoconetRequestSlotDataMessage) {
    
  }
  
  
}
