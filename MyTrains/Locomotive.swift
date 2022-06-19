//
//  Locomotive.swift
//  MyTrains
//
//  Created by Paul Willmott on 07/11/2021.
//

import Foundation
import Cocoa

public enum SpeedSteps : Int {
  case analog = 0
  case dcc14 = 1
  case dcc28 = 2
  case dcc28A = 3
  case dcc28T = 4
  case dcc128 = 5
  case dcc128A = 6
  case unknown = 0xffff
  
  public func protectMask() -> UInt8 {
    return 0b11111000
  }
  
  public func setMask() -> UInt8 {
    
    var mask : UInt8 = 0
    
    switch self {
    case .dcc28:
      mask = 0b000
    case .dcc28T:
      mask = 0b001
    case .dcc14:
      mask = 0b010
    case .dcc128:
      mask = 0b011
    case .dcc28A:
      mask = 0b100
    case .dcc128A:
      mask = 0b111
    default:
      break
    }
    
    return mask
    
  }
  
}

public enum LocomotiveDirection {
  case forward
  case reverse
}

@objc public protocol LocomotiveDelegate {
  @objc optional func stateUpdated(locomotive: Locomotive)
  @objc optional func stealZap(locomotive: Locomotive)
}

public typealias LocomotiveSpeed = (speed: Int, direction: LocomotiveDirection)

public typealias LocomotiveState = (speed:Int, direction:LocomotiveDirection, functions:Int)

public let maskF0  = 0b00000000000000000000000000000001
public let maskF1  = 0b00000000000000000000000000000010
public let maskF2  = 0b00000000000000000000000000000100
public let maskF3  = 0b00000000000000000000000000001000
public let maskF4  = 0b00000000000000000000000000010000
public let maskF5  = 0b00000000000000000000000000100000
public let maskF6  = 0b00000000000000000000000001000000
public let maskF7  = 0b00000000000000000000000010000000
public let maskF8  = 0b00000000000000000000000100000000
public let maskF9  = 0b00000000000000000000001000000000
public let maskF10 = 0b00000000000000000000010000000000
public let maskF11 = 0b00000000000000000000100000000000
public let maskF12 = 0b00000000000000000001000000000000
public let maskF13 = 0b00000000000000000010000000000000
public let maskF14 = 0b00000000000000000100000000000000
public let maskF15 = 0b00000000000000001000000000000000
public let maskF16 = 0b00000000000000010000000000000000
public let maskF17 = 0b00000000000000100000000000000000
public let maskF18 = 0b00000000000001000000000000000000
public let maskF19 = 0b00000000000010000000000000000000
public let maskF20 = 0b00000000000100000000000000000000
public let maskF21 = 0b00000000001000000000000000000000
public let maskF22 = 0b00000000010000000000000000000000
public let maskF23 = 0b00000000100000000000000000000000
public let maskF24 = 0b00000001000000000000000000000000
public let maskF25 = 0b00000010000000000000000000000000
public let maskF26 = 0b00000100000000000000000000000000
public let maskF27 = 0b00001000000000000000000000000000
public let maskF28 = 0b00010000000000000000000000000000

public class Locomotive : RollingStock, InterfaceDelegate {
  
  // MARK: Constructors

  // MARK: Destructors
  
  deinit {
  }
  
  // MARK: Private Enums
  
  private enum InitState {
    case inactive
    case waitingForSlot
    case waitingToActivate
    case waitingForOwnershipConfirmation
    case active
  }
  
  // MARK: Private Properties
  
  
  private var _isInUse : Bool = false
  
  private var _direction : LocomotiveDirection = .forward
  
  private var _targetSpeed : LocomotiveSpeed = (speed: 0, direction: .forward)
  
  private var _isInertial : Bool = true
  
  private var interfaceDelegateId : Int = -1
  
  private var initState : InitState = .inactive {
    willSet {
      stopTimer()
    }
    didSet {
      if initState == .active {
        startTimer(timeInterval: 200.0 / 1000.0)
      }
    }
  }
  
  private var _speed  : LocomotiveSpeed = (speed: 0, direction: .forward)
  
  private var lastLocomotiveState : LocomotiveState = (speed: 0, direction: .forward, functions: 0)
  
  private var timer : Timer? = nil
  
  internal var refreshTimer : Timer?
  
  internal var forceRefresh : Bool = false
  
  private var delegates : [Int:LocomotiveDelegate] = [:]
  
  private var nextDelegateId : Int = 0
  
  private var _throttleID : Int?
  
  // MARK: Public properties
  
  public var network : Network? {
    get {
      return networkController.networks[networkId]
    }
  }
  
  public var isInUse : Bool {
    
    get {
      return _isInUse
    }
    
    set(value) {
      if value != _isInUse {
        _isInUse = value
        if let network = self.network, let interface = network.interface {
          if _isInUse {
            interfaceDelegateId = interface.addObserver(observer: self)
            initState = .waitingForSlot
            interface.getLocoSlot(forAddress: mDecoderAddress)
          }
          else {
            stopTimer()
            interface.removeObserver(id: interfaceDelegateId)
            initState = .inactive
          }
        }
      }
    }
  }
  
  // NOTE: targetSpeed is in the range 0 to 126.
  
  public var targetSpeed : LocomotiveSpeed {
    get {
      return _targetSpeed
    }
    set(value) {
      _targetSpeed = value
    }
  }
  
  // NOTE: speed is in the range 0 to 126.
  
  public var speed : LocomotiveSpeed {
    get {
      return _speed
    }
    set(value) {
      _speed = value
    }
  }
  
  public var isInertial : Bool {
    get {
      return _isInertial
    }
    set(value) {
      if value != _isInertial {
        _isInertial = value
      }
    }
  }
  
  public var slotNumber : Int = -1
  
  public var slotPage : Int = -1
  
  public var locomotiveState : LocomotiveState {
    get {
      var result : LocomotiveState
      
      result.speed = speed.speed == 0 ? 0 : speed.speed + 1
      result.direction = speed.direction
      result.functions = functionSettings
      return result
    }
  }
  
  
  // MARK: Private Methods
  
  @objc func refreshTimerAction() {
    forceRefresh = true
  }
  
  func startRefreshTimer(timeInterval:TimeInterval) {
    refreshTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
  }
  
  func stopRefreshTimer() {
    refreshTimer?.invalidate()
    refreshTimer = nil
  }

  @objc func timerAction() {
    
    if let network = self.network, let interface = network.interface, let throttle = _throttleID {
      
      if !isInertial {
        speed = targetSpeed
      }
      
      lastLocomotiveState = interface.updateLocomotiveState(slotNumber: slotNumber, slotPage: slotPage, previousState: lastLocomotiveState, nextState: locomotiveState, throttleID: throttle, forceRefresh: forceRefresh)
      
      for delegate in delegates {
        delegate.value.stateUpdated?(locomotive: self)
      }
      
      if isInertial {
        let tsign = targetSpeed.direction == .forward ? 1 : -1
        let ts = targetSpeed.speed * tsign
        let csign = speed.direction == .forward ? 1 : -1
        var cs = speed.speed * csign
        if ts != cs {
          let increment = ts <= cs ? -1 : 1
          cs += increment
          cs = increment < 0 ? max(ts,cs) : min(ts,cs)
          let newDirection : LocomotiveDirection = cs >= 0 ? .forward : .reverse
          let newSpeed = abs(cs)
          speed = (speed: newSpeed, direction: newDirection)
        }
      }
      
    }
    
  }
  
  func startTimer(timeInterval:TimeInterval) {
    timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
  }
  
  func stopTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  private func stealZAP() {
    for delegate in delegates {
      delegate.value.stealZap?(locomotive: self)
    }
  }
  
  private func writeBack(message:NetworkMessage) -> [UInt8] {

    var slotData = message.slotData

    if let throttleID = _throttleID {
      var index = slotData.count - 2
      slotData[index+0] = UInt8(throttleID & 0x7f)
      slotData[index+1] = UInt8(throttleID >> 8)
      index = message.messageType == .locoSlotDataP1 ? 1 : 2
      slotData[index] = (slotData[index] & speedSteps.protectMask()) | speedSteps.setMask()
    }
    
    return slotData
    
  }
  
  // MARK: Public Methods
  
  override public func save() {
    rollingStockType = .locomotive
    super.save()
  }
  
  public func addDelegate(delegate:LocomotiveDelegate) -> Int {
    let id = nextDelegateId
    nextDelegateId += 1
    delegates[id] = delegate
    return id
  }
  
  public func removeDelegate(withKey: Int) {
    delegates.removeValue(forKey: withKey)
  }
  
  // MARK: InterfaceDelegate Methods
  
  @objc public func networkMessageReceived(message: NetworkMessage) {
    
    if let network = self.network, let interface = network.interface {
      
      if _throttleID == nil {
        _throttleID = networkController.softwareThrottleID
      }
            
      switch message.messageType {
      case .locoSlotDataP1:
        let locoSlotDataP1 = LocoSlotDataP1(networkId: message.networkId, data: message.message)
        if locoSlotDataP1.address == mDecoderAddress {
          slotPage = locoSlotDataP1.slotPage
          slotNumber = locoSlotDataP1.slotNumber
          if initState == .waitingForSlot {
            let spd = locoSlotDataP1.speed < 2 ? 0 : locoSlotDataP1.speed - 1
            let dir = locoSlotDataP1.direction
            speed = (speed:spd, direction: dir)
            if locoSlotDataP1.slotState == .inUse {
              initState = .waitingForOwnershipConfirmation
              let wb = writeBack(message: message)
              interface.setLocoSlotDataP1(slotData: wb, timeoutCode: .setLocoSlotData)
            }
            else {
              initState = .waitingToActivate
              interface.moveSlotsP1(sourceSlotNumber: slotNumber, destinationSlotNumber: slotNumber, timeoutCode: .moveSlots)
            }
          }
          else if initState == .waitingToActivate {
            initState = .waitingForOwnershipConfirmation
            let wb = writeBack(message: message)
            interface.setLocoSlotDataP1(slotData: wb, timeoutCode: .setLocoSlotData)
          }
        }
        break
      case .setLocoSlotDataP2:
        
        let locoSlotDataP2 = LocoSlotDataP2(networkId: message.networkId, data: message.message)

        if locoSlotDataP2.address == mDecoderAddress {
          
          if initState == .active {
            
            if let throttleID = _throttleID {
              
              let tid = locoSlotDataP2.throttleID
              
              if throttleID != tid  {
                stealZAP()
              }
            }
          }
        }

      case .locoSlotDataP2:
        
        let locoSlotDataP2 = LocoSlotDataP2(networkId: message.networkId, data: message.message)
        
        if locoSlotDataP2.address == mDecoderAddress {
          
          slotPage = locoSlotDataP2.slotPage
          slotNumber = locoSlotDataP2.slotNumber

          if initState == .waitingForSlot {
            
            if let throttleID = _throttleID {
              
              let tid = locoSlotDataP2.throttleID
              
              if locoSlotDataP2.slotState == .inUse && throttleID != tid  {
                
                let alert = NSAlert()

                alert.messageText = "Steal?"
                alert.informativeText = "This locomotive is in use by another throttle. Do you wish to steal?"
                alert.addButton(withTitle: "Yes")
                alert.addButton(withTitle: "No")
                alert.alertStyle = .warning

                if alert.runModal() == NSApplication.ModalResponse.alertSecondButtonReturn {
                  stealZAP()
                  break
                }
              }
                
            }

            let spd = locoSlotDataP2.speed < 2 ? 0 : locoSlotDataP2.speed - 1
            let dir = locoSlotDataP2.direction
            speed = (speed:spd, direction: dir)
            
            if locoSlotDataP2.slotState == .inUse {
              initState = .waitingForOwnershipConfirmation
              let wb = writeBack(message: message)
              interface.setLocoSlotDataP2(slotData: wb, timeoutCode: .setLocoSlotData)
            }
            else {
              initState = .waitingToActivate
              interface.moveSlotsP2(sourceSlotNumber: slotNumber, sourceSlotPage: slotPage, destinationSlotNumber: slotNumber, destinationSlotPage: slotPage, timeoutCode: .moveSlots)
            }
          }
          else if initState == .waitingToActivate {
            initState = .waitingForOwnershipConfirmation
            let wb = writeBack(message: message)
            
            interface.setLocoSlotDataP2(slotData: wb, timeoutCode: .setLocoSlotData)
          }
        }
        break
      case .setSlotDataOKP1, .setSlotDataOKP2:
        initState = .active
      case .noFreeSlotsP1, .noFreeSlotsP2:
        initState = .inactive
      default:
        break
      }
        
    }
    
  }
    
  // MARK: LocomotiveFunctionDelegate Methods
  
  public func changeState(locomotiveFunction: DecoderFunction) {
  }
  
}
