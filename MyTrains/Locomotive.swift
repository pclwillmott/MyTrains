//
//  Locomotive.swift
//  MyTrains
//
//  Created by Paul Willmott on 07/11/2021.
//

import Foundation
import Cocoa

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

public let locomotiveUpdateInterval : TimeInterval = 200.0 / 1000.0

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
    case release
  }
  
  // MARK: Private Properties
  
  
  private var _isInUse : Bool = false
  
  private var stat1 : UInt8 = 0
  
  private var proto : Int = 1
  
  private var _direction : LocomotiveDirection = .forward
  
  private var interfaceDelegateId : Int = -1
  
  private var initState : InitState = .inactive {
    willSet {
      stopTimer()
    }
    didSet {
      if initState == .active || initState == .release {
        startTimer(timeInterval: locomotiveUpdateInterval)
      }
    }
  }
  
  private var lastLocomotiveState : LocomotiveState = (speed: 0, direction: .forward, functions: 0)
  
  private var lastTimeStamp : TimeInterval = -1.0
  
  private var autoRouteActive : Bool = false
  
  private var autoRouteLock : NSLock = NSLock()
  
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
            initState = .release
          }
        }
      }
    }
  }
  
  // NOTE: targetSpeed is in the range 0 to 126.
  
  public var targetSpeed : LocomotiveSpeed = (speed: 0, direction: .forward)
  
  // NOTE: speed is in the range 0 to 126.
  
  public var speed : LocomotiveSpeed = (speed: 0, direction: .forward)
  
  public var isInertial : Bool = true
  
  public var throttleMode : ThrottleMode = .manual
  
  public var route : Route = []
  
  public var r2Forward : Double = 0.0
  
  public var r2Reverse : Double = 0.0
  
  public var slotNumber : Int = -1
  
  public var slotPage : Int = -1
  
  public var originBlock : SwitchBoardItem? {
    didSet {
      if let origin = originBlock, let destination = destinationBlock, let layout = networkController.layout {
        route = layout.findRoute(origin: origin, destination: destination, routeDirection: .next)
      }
      else {
        route = []
      }
    }
  }
  
  public var originBlockPosition : Double = 0.0
  
  public var destinationBlock : SwitchBoardItem? {
    didSet {
      if let origin = originBlock, let destination = destinationBlock, let layout = networkController.layout {
        route = layout.findRoute(origin: origin, destination: destination, routeDirection: .next)
      }
      else {
        route = []
      }
    }
  }

  public var destinationBlockPosition : Double = 0.0
  
  public var currentBlock : SwitchBoardItem?
  
  public var currentBlockPosition : Double = 0.0
  
  public var routeDirection : RouteDirection = .next
  
  public var locomotiveState : LocomotiveState {
    get {
      var result : LocomotiveState

      if initState == .release {
        speed = (speed:0, direction: speed.direction)
        result.functions = 0
      }
      else {
        result.functions = functionSettings
      }
      
      result.speed = speed.speed == 0 ? 0 : speed.speed + 1
      result.direction = speed.direction

      return result
    }
  }
  
  public var distanceTravelled : Double = 0.0
  
  public var autoRouteDistanceTravelled : Double = 0.0
  
  public var autoRouteLength : Double = 0.0
  
  // MARK: Private Methods
  
  @objc func refreshTimerAction() {
    forceRefresh = true
  }
  
  func startRefreshTimer(timeInterval:TimeInterval) {
    refreshTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    RunLoop.current.add(refreshTimer!, forMode: .common)
  }
  
  func stopRefreshTimer() {
    refreshTimer?.invalidate()
    refreshTimer = nil
  }

  @objc func timerAction() {
    
    if let network = self.network, let interface = network.interface, let throttle = _throttleID {
      
      let newTimeStamp = Date.timeIntervalSinceReferenceDate
      
      let spd = lastLocomotiveState.speed == 0 ? 0 : lastLocomotiveState.speed - 1
      
      let velocity = (lastLocomotiveState.direction == .forward) ? speedProfile[spd].bestFitForward : speedProfile[spd].bestFitReverse
      
      let distance = ((newTimeStamp - lastTimeStamp) * velocity)
      
      distanceTravelled += distance
            
      if autoRouteActive {
        autoRouteLock.lock()
        autoRouteDistanceTravelled += distance
        autoRouteLock.unlock()
      }
    
      lastTimeStamp = newTimeStamp
      
      if !isInertial && !autoRouteActive {
        speed = targetSpeed
      }
      
      lastLocomotiveState = interface.updateLocomotiveState(slotNumber: slotNumber, slotPage: slotPage, previousState: lastLocomotiveState, nextState: locomotiveState, throttleID: throttle, forceRefresh: forceRefresh)
      
      for delegate in delegates {
        delegate.value.stateUpdated?(locomotive: self)
      }
      
      if initState == .release {
        if interfaceDelegateId != -1 {
          interface.removeObserver(id:interfaceDelegateId )
          interfaceDelegateId = -1
        }
        stopTimer()
        stat1 = (stat1 & 0b01001111) | 0b00010000
        proto == 1 ? interface.setLocoSlotStat1P1(slotNumber: slotNumber, stat1: stat1) : interface.setLocoSlotStat1P2(slotPage: slotPage, slotNumber: slotNumber, stat1: stat1)
        initState = .inactive
        return
      }
      
      if autoRouteActive {
        
  //      autoRouteLock.lock()
        
        let distanceToDestination = autoRouteLength - autoRouteDistanceTravelled

        // At destination or overshot destination
        
        if distanceToDestination <= 0.0 {
          speed.speed = 0
          autoRouteActive = false
          print("at destination")
        }
        
        // Stopping distance reached or overshot
        
        else if distanceToDestination <= autoRouteDistanceToStop(autoRouteIncrement: 1) + 1.5 {
          speed.speed -= autoRouteStepIncToStop(distance:distanceToDestination)
          speed.speed = max(1,speed.speed)
          print("stopping - \(distanceToDestination) \(autoRouteDistanceToStop(autoRouteIncrement: 1)) \(autoRouteStepIncToStop(distance:distanceToDestination))")
        }
        else {
          
          // Find current block
          
          var index = 0
          
          var distance : Double = 0.0
          
          while index < route.count {
            distance += route[index].distance
            if distance > autoRouteDistanceTravelled {
              break
            }
            index += 1
          }
          
          let routePart = route[index]
          
          let locomotiveMaxSpeed = (speed.direction == .forward ? maxForwardSpeed : maxBackwardSpeed) * unitsSpeed.toCMS
          
          let nBlock = routePart.toSwitchBoardItem
        
          let nBlockMaxSpeed = min(locomotiveMaxSpeed, ((routePart.routeDirection == .next) ? nBlock.dirNextSpeedMax : nBlock.dirPreviousSpeedMax) * nBlock.unitsSpeed.toCMS)
          
          let nBlockStep = speedStepForVelocity(velocity: nBlockMaxSpeed)
          
          // Reduce speed for next block max speed
          
          if speed.speed > nBlockStep {
            
            let distanceToNextBlock = distance - autoRouteDistanceTravelled
            
            speed.speed -= autoRouteStepIncToSpeedStep(distance: distanceToNextBlock, targetSpeed: nBlockStep)
            
            print("reduce speed for next block max speed")
          }
          else {
            
            let cBlock = routePart.fromSwitchBoardItem
            
            let cBlockMaxSpeed = min(locomotiveMaxSpeed, ((routePart.routeDirection == .next) ? cBlock.dirNextSpeedMax : cBlock.dirPreviousSpeedMax) * cBlock.unitsSpeed.toCMS)
            
            let cBlockStep = speedStepForVelocity(velocity: cBlockMaxSpeed)
            
            // Accelerate to max speed
            
            if speed.speed < cBlockStep {
              speed.speed += 1
              print("accelerate to \(cBlockMaxSpeed) \(cBlockStep)")
            }
            
            // Decelerate to speed limit
            
            else if speed.speed > cBlockStep {
              speed.speed -= 1
              print("declerate")
            }
            
          }
          
        }
        
        speed.speed = min(max(speed.speed, 0), 126)
        
    //    autoRouteLock.unlock()
        
      }
      else if isInertial {
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
  
  private func autoRouteDistanceToStop(autoRouteIncrement:Int) -> Double {
    return autoRouteDistanceToSpeedStep(targetSpeed: 0, autoRouteIncrement: autoRouteIncrement)
  }

  private func autoRouteDistanceToSpeedStep(targetSpeed: Int, autoRouteIncrement:Int) -> Double {
    
    var distance = 0.0
    
    var spd = lastLocomotiveState.speed
    
    while spd > targetSpeed {
      
      let profile = speedProfile[spd]
      
      let velocity = (lastLocomotiveState.direction == .forward) ? profile.bestFitForward : profile.bestFitReverse
      
      distance += (locomotiveUpdateInterval * velocity)
      
      spd -= autoRouteIncrement
      
    }
    
    return distance
    
  }

  private func autoRouteStepIncToStop(distance:Double) -> Int {
    return autoRouteStepIncToSpeedStep(distance: distance, targetSpeed: 0)
  }
  
  private func autoRouteStepIncToSpeedStep(distance:Double, targetSpeed: Int) -> Int {
    var increment : Int = 1
    while increment < 10 && autoRouteDistanceToSpeedStep(targetSpeed: targetSpeed, autoRouteIncrement: increment) > distance {
      increment += 1
    }
    return increment
  }
  
  private func speedStepForVelocity(velocity:Double) -> Int {
    if speed.direction == .forward {
      for step in 0...125 {
        if speedProfile[step+1].bestFitForward > velocity {
          return step
        }
      }
    }
    else {
      for step in 0...125 {
        if speedProfile[step+1].bestFitReverse > velocity {
          return step
        }
      }
    }
    return 126
  }
  
  func startTimer(timeInterval:TimeInterval) {
    doBestFit()
    lastTimeStamp = Date.timeIntervalSinceReferenceDate
    distanceTravelled = 0.0
    timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    RunLoop.current.add(timer!, forMode: .common)
    startRefreshTimer(timeInterval: 30.0)
  }
  
  func stopTimer() {
    stopRefreshTimer()
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
      proto = message.messageType == .locoSlotDataP1 ? 1 : 2
      index = proto
      slotData[index] = (slotData[index] & speedSteps.protectMask()) | speedSteps.setMask()
      stat1 = slotData[index]
    }
    
    return slotData
    
  }
  
  // MARK: Public Methods
  
  public func setOriginBlock(block:SwitchBoardItem) {
    
    self.originBlock = block
    
    self.originBlockPosition = block.dimensionA / 2.0
    
    for delegate in delegates {
      delegate.value.stateUpdated?(locomotive: self)
    }
    
  }
  
  public func setDestinationBlock(block:SwitchBoardItem) {
    
    self.destinationBlock = block
    
    self.destinationBlockPosition = block.dimensionA / 2.0
    
    for delegate in delegates {
      delegate.value.stateUpdated?(locomotive: self)
    }
    
  }
  
  public func startAutoRoute() {
    
    if let layout = networkController.layout, let origin = originBlock, let destination = destinationBlock {
      route = layout.findRoute(origin: origin, destination: destination, routeDirection: routeDirection)
    }
    
    if !route.isEmpty {
      
      autoRouteLock.lock()
      
      autoRouteLength = 0.0
      
      for routePart in route {
        autoRouteLength += routePart.distance
      }
      
      let routeDirection = route[route.count-1].routeDirection
      
      autoRouteLength += ((routeDirection == .next) ? destinationBlock!.dirNextStopPosition : destinationBlock!.dirPreviousStopPosition)
      
      autoRouteDistanceTravelled = 0.0
      
      autoRouteActive = true
      
      autoRouteLock.unlock()
      
    }
    
  }
  
  public func stopAutoRoute() {
    
    autoRouteLock.lock()
    
    autoRouteActive = false
    
    autoRouteLock.unlock()
    
  }
  
  public func doBestFit() {
    
    for profile in self.speedProfile {
      profile.bestFitForward = 0.0
      profile.bestFitReverse = 0.0
    }
    
    switch newBestFitMethod {
    case .centralMovingAverage:
      
      for profile in speedProfile {
        
        switch profile.stepNumber {
        case 0:
          profile.bestFitForward = 0.0
          profile.bestFitReverse = 0.0
          break
        case 1, 125:
          profile.bestFitForward = (
            speedProfile[profile.stepNumber-1].newSpeedForward +
            speedProfile[profile.stepNumber].newSpeedForward +
            speedProfile[profile.stepNumber+1].newSpeedForward) / 3.0
          profile.bestFitReverse = (
            speedProfile[profile.stepNumber-1].newSpeedReverse +
            speedProfile[profile.stepNumber].newSpeedReverse +
            speedProfile[profile.stepNumber+1].newSpeedReverse) / 3.0
        case 126:
          profile.bestFitForward = (speedProfile[profile.stepNumber-1].newSpeedForward + speedProfile[profile.stepNumber].newSpeedForward) / 2.0
          profile.bestFitReverse = (speedProfile[profile.stepNumber-1].newSpeedReverse + speedProfile[profile.stepNumber].newSpeedReverse) / 2.0
          break
        default:
          profile.bestFitForward = (speedProfile[profile.stepNumber - 2].newSpeedForward +
                                    speedProfile[profile.stepNumber - 1].newSpeedForward +
                                    speedProfile[profile.stepNumber].newSpeedForward +
                                    speedProfile[profile.stepNumber + 1].newSpeedForward +
                                    speedProfile[profile.stepNumber + 2].newSpeedForward) / 5.0
          
          profile.bestFitReverse = (speedProfile[profile.stepNumber - 2].newSpeedReverse +
                                    speedProfile[profile.stepNumber - 1].newSpeedReverse +
                                    speedProfile[profile.stepNumber].newSpeedReverse +
                                    speedProfile[profile.stepNumber + 1].newSpeedReverse +
                                    speedProfile[profile.stepNumber + 2].newSpeedReverse) / 5.0
        }
      }
    case .straightLine:
      
      var fwdSumX : Int = 0
      var fwdSumY : Double = 0.0
      var fwdNum : Int = 0
      var bwdSumX : Int = 0
      var bwdSumY : Double = 0.0
      var bwdNum : Int = 0

      for profile in speedProfile {
        let x = profile.stepNumber
        if profile.newSpeedForward != 0.0 {
          fwdNum += 1
          fwdSumX += x
          fwdSumY += profile.newSpeedForward
        }
        if profile.newSpeedReverse != 0.0 {
          bwdNum += 1
          bwdSumX += x
          bwdSumY += profile.newSpeedForward
        }
      }
      
      if fwdNum > 0 {

        let meanX = Double(fwdSumX) / Double(fwdNum)
        let meanY = Double(fwdSumY) / Double(fwdNum)
        
        var A : Double = 0.0
        var B : Double = 0.0

        for profile in speedProfile {
          if profile.newSpeedForward != 0.0 {
            let x = profile.stepNumber
            let temp = Double(x) - meanX
            A += (temp * (profile.newSpeedForward - meanY))
            B += (temp * temp)
          }
        }
        
        let gradient = A / B
        
        let intercept = meanY - gradient * meanX
        
        for x in 1...126 {
          speedProfile[x].bestFitForward = gradient * Double(x) + intercept
        }
        
        var SSR : Double = 0.0
        var SST : Double = 0.0
        
        for profile in speedProfile {
          if profile.newSpeedForward != 0.0 {
            var temp = profile.newSpeedForward - profile.bestFitForward
            SSR += (temp * temp)
            temp = profile.newSpeedForward - meanY
            SST += (temp * temp)
          }
        }
        
        r2Forward = SST == 0.0 ? 0.0 : 1.0 - SSR / SST

      }

      if bwdNum > 0 {

        let meanX = Double(bwdSumX) / Double(bwdNum)
        let meanY = Double(bwdSumY) / Double(bwdNum)
        
        var A : Double = 0.0
        var B : Double = 0.0

        for profile in speedProfile {
          if profile.newSpeedReverse != 0.0 {
            let x = profile.stepNumber
            let temp = Double(x) - meanX
            A += (temp * (profile.newSpeedReverse - meanY))
            B += (temp * temp)
          }
        }
        
        let gradient = A / B
        
        let intercept = meanY - gradient * meanX
        
        for x in 1...126 {
          speedProfile[x].bestFitReverse = gradient * Double(x) + intercept
        }
        
        var SSR : Double = 0.0
        var SST : Double = 0.0
        
        for profile in speedProfile {
          if profile.newSpeedReverse != 0.0 {
            var temp = profile.newSpeedReverse - profile.bestFitReverse
            SSR += (temp * temp)
            temp = profile.newSpeedReverse - meanY
            SST += (temp * temp)
          }
        }
        
        r2Reverse = SST == 0.0 ? 0.0 : 1.0 - SSR / SST

      }

    }
    
    for index in 1...speedProfile.count - 1 {
      speedProfile[index].bestFitForward = max(speedProfile[index].bestFitForward, speedProfile[index-1].bestFitForward)
      speedProfile[index].bestFitReverse = max(speedProfile[index].bestFitReverse, speedProfile[index-1].bestFitReverse)
    }
        
  }
  
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
              interface.setLocoSlotDataP1(slotData: wb)
            }
            else {
              initState = .waitingToActivate
              interface.moveSlotsP1(sourceSlotNumber: slotNumber, destinationSlotNumber: slotNumber, timeoutCode: .moveSlots)
            }
          }
          else if initState == .waitingToActivate {
            initState = .waitingForOwnershipConfirmation
            let wb = writeBack(message: message)
            interface.setLocoSlotDataP1(slotData: wb)
          }
        }
        
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
