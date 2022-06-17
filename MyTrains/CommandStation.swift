//
//  CommandStation.swift
//  MyTrains
//
//  Created by Paul Willmott on 18/12/2021.
//

import Foundation


public class CommandStation : NSObject {
  
  // MARK: Constructors

  // MARK: Destructors
  
  deinit {
  }
  
  // MARK: Private Properties
  
  private var mostRecentCfgSlotDataP1 : [UInt8] = []

  // MARK: Public Properties
    
  
  
  // MARK: Private Methods
  
  // MARK: Public Methods
  
  
  
  
  
  public func setOptionSwitches() {
    
    if mostRecentCfgSlotDataP1.count == 14 {
      
      var message : [UInt8] = []
      
      for index in 2...mostRecentCfgSlotDataP1.count-2 {
        message.append(mostRecentCfgSlotDataP1[index])
      }
      /*
      for opsw in optionSwitches {
        
        let def = opsw.switchDefinition
        
        if def.definitionType == .standard {
          if def.switchNumber < 48 && def.switchNumber % 8 != 0 {
            let byte = def.configByte - 2
            let bit = def.configBit
            let mask : UInt8 = 1 << bit
            let safeMask :UInt8 = ~mask
            let value : UInt8 = opsw.newState == .closed ? mask : 0
            message[byte] = (message[byte] & safeMask) | value
          }
        }
        else {
          opsw.defaultDecoderType = opsw.newDefaultDecoderType
          let byte = 5 - 2
          var bit = 4
          var mask : UInt8 = 1 << bit
          var safeMask :UInt8 = ~mask
          var value : UInt8 = opsw.getState(switchNumber: 21) == .closed ? mask : 0
          message[byte] = (message[byte] & safeMask) | value
          bit = 5
          mask = 1 << bit
          safeMask = ~mask
          value = opsw.getState(switchNumber: 22) == .closed ? mask : 0
          message[byte] = (message[byte] & safeMask) | value
          bit = 6
          mask = 1 << bit
          safeMask = ~mask
          value = opsw.getState(switchNumber: 23) == .closed ? mask : 0
          message[byte] = (message[byte] & safeMask) | value
        }
      }
      
      for kv in messengers {
        let messenger = kv.value
        if messenger.isOpen {
          messenger.setLocoSlotDataP1(slotData: message)
          break
        }
      }
       */
    }
  }
  
  
  // MARK: NetworkMessengerDelegate Methods
  
  @objc public func networkMessageReceived(message: NetworkMessage) {
    switch message.messageType {
    case .opSwDataAP1, .locoSlotDataP1, .fastClockDataP1:
 //     locomotiveMessage(message: message)
      if message.messageType == .locoSlotDataP1 {
      }
      else if message.messageType == .opSwDataAP1 {
        mostRecentCfgSlotDataP1 = message.message
        /*
        for opsw in optionSwitches {
          let byte = opsw.switchDefinition.configByte
          if opsw.switchDefinition.definitionType == .standard {
            if byte != -1 {
              let mask = 1 << opsw.switchDefinition.configBit
              let value : OptionSwitchState = (Int(message.message[byte]) & mask) == mask ? .closed : .thrown
              opsw.state = value
            }
          }
          else {
            let byte = 5
            var bit = 4
            var mask = 1 << bit
            var value : OptionSwitchState = (Int(message.message[byte]) & mask) == mask ? .closed : .thrown
            opsw.setState(switchNumber: 21, value: value)
            bit = 5
            mask = 1 << bit
            value = (Int(message.message[byte]) & mask) == mask ? .closed : .thrown
            opsw.setState(switchNumber: 22, value: value)
            bit = 6
            mask = 1 << bit
            value = (Int(message.message[byte]) & mask) == mask ? .closed : .thrown
            opsw.setState(switchNumber: 23, value: value)
          }
        }
        save()
         */
   //     trackStatusChanged()
      }
      break
    default:
      break
    }
    
//    networkMessage(message: message)
  }
  
}
