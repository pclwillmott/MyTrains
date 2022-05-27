//
//  CommandStation.swift
//  MyTrains
//
//  Created by Paul Willmott on 18/12/2021.
//

import Foundation

@objc public protocol CommandStationDelegate {
  @objc optional func trackStatusChanged(commandStation: CommandStation)
  @objc optional func locomotiveMessageReceived(message: NetworkMessage)
  @objc optional func progMessageReceived(message:NetworkMessage)
  @objc optional func messageReceived(message:NetworkMessage)
}

public class CommandStation : NSObject {
  
  // MARK: Constructors

  // MARK: Destructors
  
  deinit {
    stopTimer()
  }
  
  // MARK: Private Properties
  
  private var _observerId : [String:Int] = [:]
  
  private var _delegates : [Int:CommandStationDelegate] = [:]
  
  private var _nextDelegateId = 0
  
  private var _delegateLock : NSLock = NSLock()
  
  private var timer : Timer? = nil
  
  private var forceRefresh : Bool = false
  
  private var mostRecentCfgSlotDataP1 : [UInt8] = []

  // MARK: Public Properties
    
  
  
  // MARK: Private Methods
  
  private func locomotiveMessage(message: NetworkMessage) {
    for delegate in _delegates {
      delegate.value.locomotiveMessageReceived?(message: message)
    }
  }
  
  private func progMessage(message: NetworkMessage) {
    for delegate in _delegates {
      delegate.value.progMessageReceived?(message: message)
    }
  }
  
  private func networkMessage(message: NetworkMessage) {
    for delegate in _delegates {
      delegate.value.messageReceived?(message: message)
    }
  }
  
  private func trackStatusChanged() {
    for delegate in _delegates {
      delegate.value.trackStatusChanged?(commandStation: self)
    }
  }
  
  @objc func timerAction() {
    forceRefresh = true
  }
  
  func startTimer(timeInterval:TimeInterval) {
    timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
  }
  
  func stopTimer() {
    timer?.invalidate()
    timer = nil
  }

  // MARK: Public Methods
  
  public func addDelegate(delegate:CommandStationDelegate) -> Int {
    _delegateLock.lock()
    let id = _nextDelegateId
    _nextDelegateId += 1
    _delegates[id] = delegate
    _delegateLock.unlock()
    return id
  }
  
  public func removeDelegate(id:Int) {
    _delegateLock.lock()
    _delegates.removeValue(forKey: id)
    _delegateLock.unlock()
  }
  
  
  public func getLocoSlot(forAddress: Int) {
/*    if forAddress > 0 {
      for kv in _messengers {
        let messenger = kv.value
        if messenger.isOpen {
          if implementsProtocol2 {
            messenger.getLocoSlotDataP2(forAddress: forAddress)
          }
          else {
            messenger.getLocoSlotDataP1(forAddress: forAddress)
          }
          break
        }
      }

    } */
  }
  
  
  public func updateLocomotiveState(slotNumber: Int, slotPage: Int, previousState:LocomotiveState, nextState:LocomotiveState, throttleID: Int) -> LocomotiveState {
 /*
    if timer == nil {
      startTimer(timeInterval: 30.0)
    }
    
    for kv in _messengers {
      
      let messenger = kv.value
      
      if messenger.isOpen {
        
        let speedChanged = previousState.speed != nextState.speed
        
        let directionChanged = previousState.direction != nextState.direction
        
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
              messenger.locoF0F6P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
            }
            
            if previous & maskF7F13 != next & maskF7F13 {
              messenger.locoF7F13P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
            }
            
            if previous & maskF14F20 != next & maskF14F20 {
              messenger.locoF14F20P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
            }
            
            if previous & maskF21F28 != next & maskF21F28 {
              messenger.locoF21F28P2(slotNumber: slotNumber, slotPage: slotPage, functions: next, throttleID: throttleID)
            }
            
            if speedChanged || directionChanged || forceRefresh {
              messenger.locoSpdDirP2(slotNumber: slotNumber, slotPage: slotPage, speed: nextState.speed, direction: nextState.direction, throttleID: throttleID)
            }

          }
          else {
            
            let maskF0F4      = 0b00000000000000000000000000011111
            let maskF5F11     = 0b00000000000000000000111111100000
            let maskF13F19    = 0b00000000000011111110000000000000
            let maskF21F27    = 0b00001111111000000000000000000000
            let maskF12F20F28 = 0b00010000000100000001000000000000
            
            if previous & maskF0F4 != next & maskF0F4 || directionChanged {
              messenger.locoDirF0F4P2(slotNumber: slotNumber, slotPage: slotPage, direction: nextState.direction, functions: next)
            }
            
            if previous & maskF5F11 != next & maskF5F11 {
              messenger.locoF5F11P2(slotNumber: slotNumber, slotPage: slotPage, functions: next)
            }
            
            if previous & maskF12F20F28 != next & maskF12F20F28 {
              messenger.locoF12F20F28P2(slotNumber: slotNumber, slotPage: slotPage, functions: next)
            }
            
            if previous & maskF13F19 != next & maskF13F19 {
              messenger.locoF13F19P2(slotNumber: slotNumber, slotPage: slotPage, functions: next)
            }
            
            if previous & maskF21F27 != next & maskF21F27 {
              messenger.locoF21F27P2(slotNumber: slotNumber, slotPage: slotPage, functions: next)
            }
            
            if speedChanged || forceRefresh {
              messenger.locoSpdP2(slotNumber: slotNumber, slotPage: slotPage, speed: nextState.speed)
            }

          }
          
        }
        else {
          
          let maskF0F4 = 0b00000000000000000000000000011111
          let maskF5F8 = 0b00000000000000000000000111100000
          
          if previous & maskF0F4 != next & maskF0F4 || directionChanged {
            messenger.locoDirF0F4P1(slotNumber: slotNumber, direction: nextState.direction, functions: next)
          }
          
          if previous & maskF5F8 != next & maskF5F8 {
            messenger.locoF5F8P1(slotNumber: slotNumber, functions: next)
          }
          
          // TODO: Add IMMPacket messages for the other functions
          
          if speedChanged || forceRefresh {
            messenger.locoSpdP1(slotNumber: slotNumber, speed: nextState.speed)
          }

        }
        
        forceRefresh = false
        
        break

      }
      
    }
    */
    return nextState

  }
  
  public func setOptionSwitches() {
    
    if mostRecentCfgSlotDataP1.count == 14 {
      
      var message : [UInt8] = []
      
      for index in 2...mostRecentCfgSlotDataP1.count-2 {
        message.append(mostRecentCfgSlotDataP1[index])
      }

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
      /*
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
  
  @objc public func messengerRemoved(id: String) {
    /*
    _messengers.removeValue(forKey: id)
    _observerId.removeValue(forKey: id)
     */
  }
  
  @objc public func networkMessageReceived(message: NetworkMessage) {
    switch message.messageType {
    case .cfgSlotDataP1, .locoSlotDataP1, .fastClockDataP1:
      locomotiveMessage(message: message)
      if message.messageType == .locoSlotDataP1 {
      }
      else if message.messageType == .cfgSlotDataP1 {
        mostRecentCfgSlotDataP1 = message.message
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
        trackStatusChanged()
      }
      break
    case .setLocoSlotDataP2:
      locomotiveMessage(message: message)
    case .noFreeSlotsP2, .noFreeSlotsP1, .setSlotDataOKP1, .setSlotDataOKP2, .illegalMoveP1, .d4Error:
      locomotiveMessage(message: message)
    case .pwrOn:
      powerIsOn = true
  //    getCfgSlotDataP1()
      break
    case .pwrOff:
      powerIsOn = false
  //    getCfgSlotDataP1()
    case .setIdleState:
      trackIsPaused = true
  //    getCfgSlotDataP1()
      break
    case.progCmdAcceptedBlind, .progSlotDataP1, .progCmdAccepted:
      progMessage(message: message)
      break
    default:
      break
    }
    
    if message.willChangeSlot {
      if let slot = _locoSlots[message.slotID] {
        slot.isDirty = true
      }
      else {
        let slot = LocoSlotData(slotID: message.slotID)
        _locoSlots[slot.slotID] = slot
        slotsUpdated()
      }
    }
    
    networkMessage(message: message)
  }
  
}
