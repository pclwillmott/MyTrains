//
//  LocoNetBridge.swift
//  MyTrains
//
//  Created by Paul Willmott on 13/11/2022.
//

import Foundation

public class LocoNetBridge : NSObject, InterfaceDelegate {
  
  // MARK: Constructors
  
  public override init() {
    super.init()
    for slotPage in 0...3 {
      for slotNumber in 1...119 {
        let id = LocoSlotData.encodeID(slotPage: UInt8(slotPage), slotNumber: UInt8(slotNumber))
        slots[id] = LocoSlotData(slotID: id)
      }
    }
  }
  
  // MARK: Private Properties
  
  private var _throttleNetwork : Network?
  
  private var throttleObserverId : Int = -1
  
  private var _slaveNetwork : Network?
  
  private var slaveObserverId : Int = -1
  
  private var slots : [Int:LocoSlotData] = [:]
  
  // MARK: Public Properties
  
  public var throttleNetwork : Network? {
    get {
      return _throttleNetwork
    }
    set(value) {
      if throttleObserverId != -1 {
        throttleNetwork?.interface?.removeObserver(id: throttleObserverId)
        throttleObserverId = -1
      }
      _throttleNetwork = value
      if let interface = _throttleNetwork?.interface {
        throttleObserverId = interface.addObserver(observer: self)
      }
    }
  }
  
  public var slaveNetwork : Network? {
    get {
      return _slaveNetwork
    }
    set(value) {
      if slaveObserverId != -1 {
        slaveNetwork?.interface?.removeObserver(id: slaveObserverId)
        slaveObserverId = -1
      }
      _slaveNetwork = value
      if let interface = _slaveNetwork?.interface {
        slaveObserverId = interface.addObserver(observer: self)
      }
    }
  }

  // MARK: InterfaceDelegate Methods
  
  @objc public func networkMessageReceived(message:NetworkMessage) {
    
    // MARK: THROTTLE NETWORK MESSAGES
    
    if let throttleNetwork = self.throttleNetwork, let slaveNetwork = self.slaveNetwork {
      
      if message.networkId == throttleNetwork.primaryKey {
        
        let messagesToBlock : Set<NetworkMessageType> = [
          .getOpSwDataAP1,
          .getOpSwDataBP1,
          .getOpSwDataP2,
          .opSwDataAP1,
          .opSwDataBP1,
          .opSwDataP2,
          .immPacketOK,
          .setSlotDataOKP1,
          .setSlotDataOKP2,

        ]
        
        if messagesToBlock.contains(message.messageType) {
          return
        }
        
        if let interface = slaveNetwork.interface {
          
          let data = message.message
          
          switch message.messageType {
          case .locoSlotDataP1:
            break
          case .locoSlotDataP2:
            break
          case .setLocoSlotStat1P2:
            let slotPage   = data[1]
            let slotNumber = data[2]
            let id = LocoSlotData.encodeID(slotPage: slotPage, slotNumber: slotNumber)
            if let slot = slots[id] {
              slot.slotStatus1 = data[4]
            }
          case .getLocoSlotData:
            let slotPage   = data[2]
            let slotNumber = data[1]
            let id = LocoSlotData.encodeID(slotPage: slotPage, slotNumber: slotNumber)
            if let slot = slots[id] {
              let response = NetworkMessage(networkId: message.networkId, data: slot.slotDataP2, appendCheckSum: true)
              throttleNetwork.interface?.addToQueue(message: response, delay: MessageTiming.STANDARD)
            }
          case .setLocoSlotDataP2:
            let slotPage   = data[2]
            let slotNumber = data[3]
            let id = LocoSlotData.encodeID(slotPage: slotPage, slotNumber: slotNumber)
            if let slot = slots[id] {
              slot.slotDataP2 = data
              let response = NetworkMessage(networkId: message.networkId, data: [0xb4,0x6e,0x7f], appendCheckSum: true)
              throttleNetwork.interface?.addToQueue(message: response, delay: MessageTiming.STANDARD)
            }
          case .setLocoSlotInUseP2:
            let slotPage   = data[1]
            let slotNumber = data[2]
            let id = LocoSlotData.encodeID(slotPage: slotPage, slotNumber: slotNumber)
            if let slot = slots[id] {
              slot.slotState = .inUse
              let response = NetworkMessage(networkId: message.networkId, data: slot.slotDataP2, appendCheckSum: true)
              throttleNetwork.interface?.addToQueue(message: response, delay: MessageTiming.STANDARD)
            }
          case .getLocoSlotDataSAdrP2:
            
            var slotToUse : LocoSlotData?
            
            let address = Int(data[2])
            
            for (_, slot) in slots {
              if slot.address == address {
                slotToUse = slot
                break
              }
            }
            
            if slotToUse == nil {
              for (_, slot) in slots {
                if slot.slotState == .free {
                  slotToUse = slot
                  slotToUse!.address = address
                  slotToUse!.speed = 0
                  slotToUse!.direction = .forward
                  slotToUse!.throttleID = 0
                  slotToUse!.mobileDecoderType = .dcc128
                  slotToUse!.consistState = .NotLinked
                  break
                }
              }
            }
            
            if slotToUse == nil {
              let response = NetworkMessage(networkId: message.networkId, data: [0xb4, 0x3e, 0x00], appendCheckSum: true)
              throttleNetwork.interface?.addToQueue(message: response, delay: MessageTiming.STANDARD)
            }
            else {
              var response = NetworkMessage(networkId: message.networkId, data: slotToUse!.slotDataP2, appendCheckSum: true)
              throttleNetwork.interface?.addToQueue(message: response, delay: MessageTiming.STANDARD)
            }
            
          default:
            interface.addToQueue(message: message, delay: MessageTiming.STANDARD)
          }
          
        }
        
      }
      
      // MARK: SLAVE NETWORK MESSAGES
      
      else if message.networkId == slaveNetwork.primaryKey {

        let messagesToBlock : Set<NetworkMessageType> = [
          .getOpSwDataAP1,
          .getOpSwDataBP1,
          .getOpSwDataP2,
          .opSwDataAP1,
          .opSwDataBP1,
          .opSwDataP2,
          .immPacket,
          .locoSlotDataP1,
          .locoSlotDataP2,
          .setSlotDataOKP1,
          .setSlotDataOKP2,
          .setLocoSlotStat1P1,
          .setLocoSlotStat1P2,
        ]
        
        if messagesToBlock.contains(message.messageType) {
          return
        }
        
        if let interface = throttleNetwork.interface {
          
          switch message.messageType {
          default:
            interface.addToQueue(message: message, delay: MessageTiming.STANDARD)
          }
          
        }

      }
      
    }
    
  }

}
