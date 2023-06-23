//
//  OpenLCBNodeRollingStockLocoNet.swift
//  MyTrains
//
//  Created by Paul Willmott on 23/06/2023.
//

import Foundation

public class OpenLCBNodeRollingStockLocoNet : OpenLCBNodeRollingStock, InterfaceDelegate {
  
  // MARK: Constructors
  
  // MARK: Private Properties
  
  private enum ConfigState {
    case idle
    case slotFetch
    case setInUse
    case writeBack
    case active
  }
  
  private var configState : ConfigState = .idle
  
  private var slotPage : UInt8 = 0
  
  private var slotNumber : UInt8 = 0
  
  private var stat1 : UInt8 = 0
  
  private var forceRefresh : Bool = false
  
  private var refreshTimer : Timer?
  
  private var slotState : LocoNetSlotState {
    get {
      return LocoNetSlotState(rawValue: stat1 & ~LocoNetSlotState.protectMask)!
    }
    set(value) {
      stat1 &= LocoNetSlotState.protectMask
      stat1 |= value.setMask
    }
  }
  
  private var lastLocomotiveState : LocoNetLocomotiveState?
  
  private var standardFunctions : UInt64 = 0
    
  private var expandedFunctions : UInt64 = 0
  
  private var observerId : Int = -1
  
  private var network : Network {
    get {
      return myTrainsController.networks[_rollingStock.networkId]!
    }
  }
  
  private var interface : InterfaceLocoNet? {
    get {
      return network.interface as? InterfaceLocoNet
    }
  }

  // MARK: Public Properties
  
  // MARK: Private Methods
  
  private func readStandardFunctions() {
    
    standardFunctions = 0
    
    var mask : UInt64 = 1
    
    for fn in 0 ... 28 {
      if let fx = functions.getUInt8(address: fn), fx != 0 {
        standardFunctions |= mask
      }
      mask <<= 1
    }
    
  }
  
  private func readExpandedFunctions() {
    
    expandedFunctions = 0
    
    var mask : UInt64 = 1
    
    for fn in 29 ... 68 {
      if let fx = functions.getUInt8(address: fn), fx != 0 {
        expandedFunctions |= mask
      }
      mask <<= 1
    }
    
  }
  
  @objc func refreshTimerAction() {
    guard configState == .active else {
      stopRefreshTimer()
      return
    }
    forceRefresh = true
    updateLocoState()
  }
  
  func startRefreshTimer(timeInterval:TimeInterval) {
    refreshTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(refreshTimerAction), userInfo: nil, repeats: true)
    RunLoop.current.add(refreshTimer!, forMode: .common)
  }
  
  func stopRefreshTimer() {
    refreshTimer?.invalidate()
    refreshTimer = nil
  }

  private func updateLocoState() {
    
    if let interface = self.interface {
      
      var step = UInt8(min(126, Int(setSpeed * 3600.0 / (1000.0 * 1.609344))))
      
      // THIS SHOULD BE DONE WITH A SPEED TABLE
      
      step = step == 0 ? 0 : step + 1
      
      let direction : LocomotiveDirection = (setSpeed == -0.0 || setSpeed < 0.0) ? .reverse : .forward
      
      let nextState = (
        speed: step,
        direction: direction,
        functions: standardFunctions,
        extendedFunctions: expandedFunctions
      )
      
      if let last = lastLocomotiveState {
        let temp = interface.updateLocomotiveState(address: dccAddress, slotNumber: slotNumber, slotPage: slotPage, previousState: last, nextState: nextState, throttleID: 0, forceRefresh: forceRefresh)
        lastLocomotiveState = temp.state
      }
      else {
        let temp = interface.setLocomotiveState(address: dccAddress, slotNumber: slotNumber, slotPage: slotPage, nextState: nextState, throttleID: 0)
        lastLocomotiveState = temp.state
      }
      
      forceRefresh = false
      
    }
    
  }
  
  internal override func attachNode() {
    
    if configState == .active {
      releaseNode()
    }
    
    if let interface = self.interface {
      
      observerId = interface.addObserver(observer: self)
      
      slotPage = 0
      
      slotNumber = 0
      
      stat1 = 0
      
      setSpeed = 0.0
      
      commandedSpeed = 0.0
      
      readStandardFunctions()
      
      readExpandedFunctions()
      
      lastLocomotiveState = nil
      
      configState = .slotFetch

      interface.getLocoSlot(forAddress: dccAddress)
      
    }
    
  }
  
  internal override func releaseNode() {
    
    if let interface = self.interface {
      
      stopRefreshTimer()
      
      setSpeed = 0.0
      
      commandedSpeed = 0.0
      
      updateLocoState()
      
      interface.removeObserver(id: observerId)
      
      slotState = .common
      
      interface.setLocoSlotStat1(slotPage: slotPage, slotNumber: slotNumber, stat1: stat1)

      configState = .idle
      
    }
    
  }
 
  internal override func speedChanged() {
    updateLocoState()
  }
  
  internal override func functionChanged() {
    
    readStandardFunctions()
    
    readExpandedFunctions()
    
    updateLocoState()
    
  }
  
  // MARK: Public Methods
  
  // MARK: InterfaceDelegate Methods
  
  public func networkMessageReceived(message:LocoNetMessage) {
    
    if let interface = self.interface {
      
      switch message.messageType {
      case .locoSlotDataP1:
        let address : UInt16 = UInt16(message.message[4])
        if address == dccAddress {
          slotPage = 0
          slotNumber = message.message[2]
          stat1 = message.message[3]
          switch configState {
          case .slotFetch:
            if slotState != .inUse {
              configState = .setInUse
              interface.moveSlotsP1(sourceSlotNumber: slotNumber, destinationSlotNumber: slotNumber)
            }
          case .setInUse:
            if slotState != .inUse {
              configState = .idle
            }
            else {
              var writeBackMessage = message.message
              writeBackMessage[0] = LocoNetMessageOpcode.OPC_WR_SL_DATA.rawValue
              writeBackMessage[3] &= speedSteps.protectMask()
              writeBackMessage[3] |= speedSteps.setMask()
              configState = .writeBack
              interface.addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [], retryCount: 0, timeoutCode: .none)
            }
          default:
            break
          }
        }
      case .locoSlotDataP2:
        let address : UInt16 = (UInt16(message.message[6]) << 7) | UInt16(message.message[5])
        if address == dccAddress {
          slotPage = message.message[2]
          slotNumber = message.message[3]
          stat1 = message.message[4]
          switch configState {
          case .slotFetch:
            if slotState != .inUse {
              configState = .setInUse
              interface.moveSlotsP2(sourceSlotNumber: slotNumber, sourceSlotPage: slotPage, destinationSlotNumber: slotNumber, destinationSlotPage: slotPage)
            }
          case .setInUse:
            if slotState != .inUse {
              configState = .idle
            }
            else {
              var writeBackMessage = message.message
              writeBackMessage[0] = LocoNetMessageOpcode.OPC_WR_SL_DATA_P2.rawValue
              writeBackMessage[4] &= speedSteps.protectMask()
              writeBackMessage[4] |= speedSteps.setMask()
              writeBackMessage[18] = 0 // Throttle Id low
              writeBackMessage[19] = 0 // Throttle Id high
              configState = .writeBack
              interface.addToQueue(message: message, delay: MessageTiming.STANDARD, responses: [], retryCount: 0, timeoutCode: .none)
            }
          default:
            break
          }
        }
      case .noFreeSlotsP1, .noFreeSlotsP2:
        if configState == .slotFetch {
          configState = .idle
        }
      case .illegalMoveP1, .d4Error:
        if configState == .setInUse {
          configState = .idle
        }
      case .setSlotDataOKP1, .setSlotDataOKP2:
        if configState == .writeBack {
          configState = .active
          updateLocoState()
          startRefreshTimer(timeInterval: 90.0)
        }
      default:
        break
      }
      
    }
    
  }

}
