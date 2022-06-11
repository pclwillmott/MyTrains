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

public enum TrackGauge : Int {
  case em         = 0
  case ho         = 1
  case n          = 2
  case o          = 3
  case o14        = 4
  case oo         = 5
  case ooo        = 6
  case p4         = 7
  case s          = 8
  case scaleSeven = 9
  case tt         = 10
  case tt3        = 11
  case unknown    = 0xffff
}

public enum LengthUnit : Int {
  case millimeters = 0
  case centimeters = 1
  case meters = 2
  case inches = 3
  case feet = 4
}

public enum SpeedUnit : Int {
  case kilometersPerHour = 0
  case milesPerHour = 1
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

public class Locomotive : RollingStock {
  
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
  
  private var commandStationDelegateId : Int = -1
  
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
        if let net = network, let cs = net.commandStation {
          if _isInUse {
   //         commandStationDelegateId = cs.addDelegate(delegate: self)
            initState = .waitingForSlot
     //       cs.getLocoSlot(forAddress: address)
          }
          else {
            stopTimer()
       //     cs.removeDelegate(id: commandStationDelegateId)
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
  
  public var functionSettings : Int {
    get {
      var result = 0
      var mask = 1
      for locoFunc in functions {
        result |= locoFunc.stateToSend ? mask : 0
        mask <<= 1
      }
      return result
    }
  }
  
  public var locomotiveState : LocomotiveState {
    get {
      var result : LocomotiveState
      
      result.speed = speed.speed == 0 ? 0 : speed.speed + 1
      result.direction = speed.direction
      result.functions = functionSettings
      return result
    }
  }
  
  public var decoderManufacturerName : String {
    get {
      return "" // NMRA.manufacturerName(code: getCV(cvNumber: 8).cvValue)
    }
  }
  
  public var consistAddress : Int {
    get {
      if let cv19 = getCV(cvNumber: 19) {
        return cv19.cvValue & 0x7f
      }
      return 0
    }
    set(value) {
      if let cv19 = getCV(cvNumber: 19) {
        var newCV19 = cv19.cvValue & 0b10000000
        newCV19 |= value & 0x7f
        cv19.cvValue = newCV19
      }
    }
  }
  
  public var isAdvancedConsist : Bool {
    get {
      return consistAddress != 0
    }
  }
  
  public var consistRelativeDirection : LocomotiveDirection {
    get {
      if let cv19 = getCV(cvNumber: 19) {
        let mask = 0b10000000
        return (cv19.cvValue & mask) == mask ? .reverse : .forward
      }
      return .forward
    }
    set(value) {
      if let cv19 = getCV(cvNumber: 19) {
        let mask = 0b10000000
        var newCV19 = cv19.cvValue & ~mask
        newCV19 |= value == .reverse ? mask : 0
        cv19.cvValue = newCV19
      }
    }
  }
  
  public var consistAddressActiveF1 : Bool {
    get {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00000001
        return cv21.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00000001
        var newCV21 = cv21.cvValue & ~mask
        newCV21 |= value ? mask : 0
        cv21.cvValue = newCV21
      }
    }
  }
  
  public var consistAddressActiveF2 : Bool {
    get {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00000010
        return cv21.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00000010
        var newCV21 = cv21.cvValue & ~mask
        newCV21 |= value ? mask : 0
        cv21.cvValue = newCV21
      }
    }
  }
  
  public var consistAddressActiveF3 : Bool {
    get {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00000100
        return cv21.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00000100
        var newCV21 = cv21.cvValue & ~mask
        newCV21 |= value ? mask : 0
        cv21.cvValue = newCV21
      }
    }
  }
  
  public var consistAddressActiveF4 : Bool {
    get {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00001000
        return cv21.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00001000
        var newCV21 = cv21.cvValue & ~mask
        newCV21 |= value ? mask : 0
        cv21.cvValue = newCV21
      }
    }
  }
  
  public var consistAddressActiveF5 : Bool {
    get {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00010000
        return cv21.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00010000
        var newCV21 = cv21.cvValue & ~mask
        newCV21 |= value ? mask : 0
        cv21.cvValue = newCV21
      }
    }
  }
  
  public var consistAddressActiveF6 : Bool {
    get {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00100000
        return cv21.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b00100000
        var newCV21 = cv21.cvValue & ~mask
        newCV21 |= value ? mask : 0
        cv21.cvValue = newCV21
      }
    }
  }
  
  public var consistAddressActiveF7 : Bool {
    get {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b01000000
        return cv21.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b01000000
        var newCV21 = cv21.cvValue & ~mask
        newCV21 |= value ? mask : 0
        cv21.cvValue = newCV21
      }
    }
  }
  
  public var consistAddressActiveF8 : Bool {
    get {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b10000000
        return cv21.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv21 = getCV(cvNumber: 21) {
        let mask = 0b10000000
        var newCV21 = cv21.cvValue & ~mask
        newCV21 |= value ? mask : 0
        cv21.cvValue = newCV21
      }
    }
  }
  
  public var consistAddressActiveF9 : Bool {
    get {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00000100
        return cv22.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00000100
        var newCV22 = cv22.cvValue & ~mask
        newCV22 |= value ? mask : 0
        cv22.cvValue = newCV22
      }
    }
  }
  
  public var consistAddressActiveF10 : Bool {
    get {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00001000
        return cv22.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00001000
        var newCV22 = cv22.cvValue & ~mask
        newCV22 |= value ? mask : 0
        cv22.cvValue = newCV22
      }
    }
  }
  
  public var consistAddressActiveF11 : Bool {
    get {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00010000
        return cv22.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00010000
        var newCV22 = cv22.cvValue & ~mask
        newCV22 |= value ? mask : 0
        cv22.cvValue = newCV22
      }
    }
  }
  
  public var consistAddressActiveF12 : Bool {
    get {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00100000
        return cv22.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00100000
        var newCV22 = cv22.cvValue & ~mask
        newCV22 |= value ? mask : 0
        cv22.cvValue = newCV22
      }
    }
  }
  
  public var consistAddressActiveF0Forward : Bool {
    get {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00000001
        return cv22.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00000001
        var newCV22 = cv22.cvValue & ~mask
        newCV22 |= value ? mask : 0
        cv22.cvValue = newCV22
      }
    }
  }
  
  public var consistAddressActiveF0Reverse : Bool {
    get {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00000010
        return cv22.cvValue & mask == mask
      }
      return false
    }
    set(value) {
      if let cv22 = getCV(cvNumber: 22) {
        let mask = 0b00000010
        var newCV22 = cv22.cvValue & ~mask
        newCV22 |= value ? mask : 0
        cv22.cvValue = newCV22
      }
    }
  }
  
  public var isShortAddress : Bool {
    get {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00100000
        return (cv29.cvValue & mask) == 0
      }
      return true
    }
    set(value) {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00100000
        var newCV29 = cv29.cvValue & ~mask
        newCV29 |= value ? 0 : mask
        cv29.cvValue = newCV29
      }
    }
  }
  
  public var isSpeedTableCV2CV5CV6 : Bool {
    get {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00010000
        return (cv29.cvValue & mask) == 0
      }
      return false
    }
    set(value) {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00010000
        var newCV29 = cv29.cvValue & ~mask
        newCV29 |= value ? 0 : mask
        cv29.cvValue = newCV29
      }
    }
  }
  
  public var isRailComEnabled : Bool {
    get {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00001000
        return (cv29.cvValue & mask) == mask
      }
      return true
    }
    set(value) {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00001000
        var newCV29 = cv29.cvValue & ~mask
        newCV29 |= value ? mask : 0
        cv29.cvValue = newCV29
      }
    }
  }
  
  public var isAnalogOperationEnabled : Bool {
    get {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00000100
        return (cv29.cvValue & mask) == mask
      }
      return true
    }
    set(value) {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00000100
        var newCV29 = cv29.cvValue & ~mask
        newCV29 |= value ? mask : 0
        cv29.cvValue = newCV29
      }
    }
  }
  
  public var is14Steps : Bool {
    get {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00000010
        return (cv29.cvValue & mask) == 0
      }
      return false
    }
    set(value) {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00000010
        var newCV29 = cv29.cvValue & ~mask
        newCV29 |= value ? 0 : mask
        cv29.cvValue = newCV29
      }
    }
  }
  
  public var isNormalDirectionOfTravelForward : Bool {
    get {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00000001
        return (cv29.cvValue & mask) == 0
      }
      return true
    }
    set(value) {
      if let cv29 = getCV(cvNumber: 29) {
        let mask = 0b00000001
        var newCV29 = cv29.cvValue & ~mask
        newCV29 |= value ? 0 : mask
        cv29.cvValue = newCV29
      }
    }
  }
  
  // MARK: Private Methods
  
  @objc func timerAction() {
    
    if let net = network, let cs = net.commandStation, let throttle = _throttleID {
      
      if !isInertial {
        speed = targetSpeed
      }
      
  //    lastLocomotiveState = cs.updateLocomotiveState(slotNumber: slotNumber, slotPage: slotPage, previousState: lastLocomotiveState, nextState: locomotiveState, throttleID: throttle)
      
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
 //     slotData[index] = (slotData[index] & SpeedSteps.protectMask()) | mobileDecoderType.setMask()
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
  
  // MARK: CommandStationDelegate Methods
  
  @objc public func locomotiveMessageReceived(message: NetworkMessage) {
    
    if let net = network, let cs = net.commandStation {
      
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
     //         cs.setLocoSlotDataP1(slotData: wb)
            }
            else {
              initState = .waitingToActivate
      //        cs.moveSlots(sourceSlotNumber: slotNumber, sourceSlotPage: slotPage, destinationSlotNumber: slotNumber, destinationSlotPage: slotPage)
            }
          }
          else if initState == .waitingToActivate {
            initState = .waitingForOwnershipConfirmation
            let wb = writeBack(message: message)
    //        cs.setLocoSlotDataP1(slotData: wb)
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
       //       cs.setLocoSlotDataP2(slotData: wb)
            }
            else {
              initState = .waitingToActivate
        //      cs.moveSlots(sourceSlotNumber: slotNumber, sourceSlotPage: slotPage, destinationSlotNumber: slotNumber, destinationSlotPage: slotPage)
            }
          }
          else if initState == .waitingToActivate {
            initState = .waitingForOwnershipConfirmation
            let wb = writeBack(message: message)
      //      cs.setLocoSlotDataP2(slotData: wb)
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
  
  // MARK: Class Public Methods
  
  public static var locomotives : [Int:Locomotive] {
    
    get {
    
      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
        _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = "SELECT \(columnNames) FROM [\(TABLE.ROLLING_STOCK)] ORDER BY [\(ROLLING_STOCK.ROLLING_STOCK_NAME)]"

      var result : [Int:Locomotive] = [:]
      
      if let reader = cmd.executeReader() {
           
        while reader.read() {
          let locomotive = Locomotive(reader: reader)
          result[locomotive.primaryKey] = locomotive
        }
           
        reader.close()
           
      }
      
      if shouldClose {
        conn.close()
      }

      return result
      
    }
    
  }
  
  public static func decoderAddress(cv17: Int, cv18: Int) -> Int {
    return (cv17 << 8 | cv18) - 49152
  }
  
  public static func cv17(address: Int) -> Int {
    let temp = address + 49152
    return temp >> 8
  }
  
  public static func cv18(address: Int) -> Int {
    let temp = address + 49152
    return temp & 0xff
  }
  
}
