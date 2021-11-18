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
                    //  "/dev/cu.usbmodemDxP470881"
                      // "/dev/cu.usbmodemDtrxA0BA1"
    ]
    
    var index : Int = 1
    for connection in connections {
      let loconetMessenger = LoconetMessenger(id: "id\(index)", path: connection)
      loconetMessengers[loconetMessenger.id] = loconetMessenger
      loconetMessenger.delegate = self
      index += 1
    }
    
    if let interface1 = loconetMessengers["id1"] {
      add(locomotive: Locomotive(locomotiveId: "Class 25",  address: 10, interface: interface1))
      add(locomotive: Locomotive(locomotiveId: "Class 121", address: 11, interface: interface1))
      add(locomotive: Locomotive(locomotiveId: "Class 128", address: 12, interface: interface1))
      interface1.powerOn()
      for loco in locomotivesByAddress {
        loco.value.requestSlotInfo()
      }
    }
    
  }
  
  private var loconetMessengers : [String:LoconetMessenger] = [:]
  
  private var locomotivesByName    : [String:Locomotive] = [:]
  private var locomotivesByAddress : [UInt16:Locomotive] = [:]

  public func add(locomotive:Locomotive) {
    locomotivesByName[locomotive.locomotiveId] = locomotive
    locomotivesByAddress[locomotive.address] = locomotive
  }
  
  // LoconetMessenger Delegate Functions
  
  public func LoconetSensorMessageReceived(message: LoconetSensorMessage) {
    
  }
  
  public func LoconetSwitchRequestMessageReceived(message: LoconetSwitchRequestMessage) {
    
  }
  
  public func LoconetSlotDataMessageReceived(message: LoconetSlotDataMessage) {
    if let slot = message.slot {
      
      print("id:            \(message.interfaceId)")
      print("opCode:        \(message.opCode)")
      print("slotNumber:    \(String(format:"0x%02x", slot.slotNumber))")
      print("locoAddress:   \(slot.locoAddress)")
      print("speedType:     \(slot.speedType)")
      print("speed:         \(slot.speed)")
      print("XCNT:          \(slot.stateXCNT)")
      print("locoDirection: \(slot.locoDirection)")
      print("stateF0:       \(slot.stateF0)")
      print("stateF1:       \(slot.stateF1)")
      print("stateF2:       \(slot.stateF2)")
      print("stateF3:       \(slot.stateF3)")
      print("stateF4:       \(slot.stateF4)")
      print("sound1:        \(slot.sound1)")
      print("sound2:        \(slot.sound2)")
      print("sound3:        \(slot.sound3)")
      print("sound4:        \(slot.sound4)")
      print("decoderType:   \(slot.decoderType)")
      print("locoUsage:     \(slot.locoUsage)")
      print("progTrackBusy: \(slot.progTrackBusy)")
      print("MLOK1:         \(slot.MLOK1)")
      print("trackPaused:   \(slot.trackPaused)")
      print("trackPower:    \(slot.trackPower)")
      print("")

      if slot.slotNumber > 0 && slot.slotNumber < 120 {
        if let locomotive = locomotivesByAddress[slot.locoAddress] {
          locomotive.slot = slot
          /*
          if slot.locoUsage != .inUse {
            locomotive.nullMove()
          }
           */
          /*
          locomotive.stateF2 = false    
          
          locomotive.stateF3 = false
          locomotive.stateF4 = false
          locomotive.sound1 = false
          locomotive.sound2 = false
          locomotive.sound3 = false
          locomotive.sound4 = false
           
          locomotive.locoDirection = .backwards
           
          locomotive.speed = 60
           */
        }
        else {
          print("LoconetSlotDataMessageReceived: loco with address \(slot.locoAddress) not found")
        }
      }
      else {
        print("LoconetSlotDataMessageReceived: special slot number \(slot.slotNumber)")
      }
    }
    else {
      print("LoconetSlotDataMessageReceived: slot is nil")
    }
  }
  
  public func LoconetTurnoutOutputMessageReceived(message: LoconetTurnoutOutputMessage) {
    
  }
  
  public func LoconetLongAcknowledgeMessageReceived(message: LoconetLongAcknowledgeMessage) {
    
  }
  
  public func LoconetRequestSlotDataMessageReceived(message: LoconetRequestSlotDataMessage) {
    
  }
  
  
}
