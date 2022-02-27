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

@objc public protocol SlotObserverDelegate {
  @objc optional func slotsUpdated(commandStation:CommandStation)
}

public enum CommandStationModel : Int {
  case dcs210 = 0
  case dcs210Plus = 1
  case dcs240 = 2
  case unknown = 0xffff
}

public class CommandStation : NSObject, NetworkMessengerDelegate {
  
  // MARK: Constructors
  
  init(message:IPLDevData) {
    super.init()
    productCode = message.productCode
    serialNumber = message.serialNumber
    softwareVersion = message.softwareVersion
    if optionSwitches.count == 0 && model != .unknown {
      let defs = CommandStationOptionSwitch.switches(commandStationModel: model)
      for def in defs {
        let opsw = CommandStationOptionSwitch(commandStation: self, switchNumber: def.switchNumber, switchDefinition: def)
        opsw.state = def.defaultState
        optionSwitches.append(opsw)
      }
    }
    modified = true
    save()
  }
  
  init(reader:SqliteDataReader) {
    super.init()
    decode(sqliteDataReader: reader)
    if optionSwitches.count == 0 && model != .unknown {
      let defs = CommandStationOptionSwitch.switches(commandStationModel: model)
      for def in defs {
        let opsw = CommandStationOptionSwitch(commandStation: self, switchNumber: def.switchNumber, switchDefinition: def)
        optionSwitches.append(opsw)
      }
    }
  }
  
  // MARK: Destructors
  
  deinit {
    stopTimer()
  }
  
  // MARK: Private Properties
  
  private var _manufacturer : Manufacturer = .Digitrax
  
  private var _serialNumber : Int = -1
  
  private var _hardwareVersion : Double = -1.0
  
  private var _softwareVersion : Double = -1.0
  
  private var modified : Bool = false
  
  private var _messengers : [String:NetworkMessenger] = [:]
  
  private var _observerId : [String:Int] = [:]
  
  private var _delegates : [Int:CommandStationDelegate] = [:]
  
  private var _nextDelegateId = 0
  
  private var _delegateLock : NSLock = NSLock()
  
  private var timer : Timer? = nil
  
  private var forceRefresh : Bool = false
  
  private var _locoSlots : [Int:LocoSlotData] = [:]
  
  private var slotObservers : [Int:SlotObserverDelegate] = [:]
  
  private var nextSlotObserverId = 0
  
  private var slotObserverLock : NSLock = NSLock()
  
  private var mostRecentCfgSlotDataP1 : [UInt8] = []

  // MARK: Public Properties
  
  public var messengers : [String:NetworkMessenger] {
    get {
      return _messengers
    }
  }
  
  public var locoSlots : [LocoSlotData] {
    get {
      
      var slots : [LocoSlotData] = []
      
      for slot in _locoSlots {
        slots.append(slot.value)
      }
      
      return slots.sorted {
        $0.slotID < $1.slotID
      }
      
    }
  }
  
  public var optionSwitches : [CommandStationOptionSwitch] = []
  
  public var model : CommandStationModel {
    get {
      switch productCode {
      case .DCS210:
        return .dcs210
      case .DCS210Plus:
        return .dcs210Plus
      case .DCS240:
        return .dcs240
      default:
        return .unknown
      }
    }
  }
  
  public var optionSwitches0 : Int64 = 0 {
    didSet {
      modified = true
    }
  }
  
  public var optionSwitches1 : Int64 = 0 {
    didSet {
      modified = true
    }
  }
  
  public var optionSwitches2 : Int64 = 0 {
    didSet {
      modified = true
    }
  }
  
  public var optionSwitches3 : Int64 = 0 {
    didSet {
      modified = true
    }
  }
  
  public var manufacturer : Manufacturer {
    get {
      return _manufacturer
    }
    set(value) {
      if value != _manufacturer {
        _manufacturer = value
        modified = true
      }
    }
  }
  
  public var productCode : ProductCode  = .unknown {
    didSet {
      modified = true
    }
  }
  
  public var serialNumber : Int {
    get {
      return _serialNumber
    }
    set(value) {
      if value != _serialNumber {
        _serialNumber = value
        modified = true
      }
    }
  }
  
  public var hardwareVersion : Double {
    get {
      return _hardwareVersion
    }
    set(value) {
      if value != hardwareVersion {
        _hardwareVersion = value
        modified = true
      }
    }
  }
  
  public var softwareVersion : Double {
    get {
      return _softwareVersion
    }
    set(value) {
      if value != _softwareVersion {
        _softwareVersion = value
        modified = true
      }
    }
  }
  
  public var commandStationId : Int {
    get {
      return CommandStation.commandStationID(manufacturer: manufacturer, productCode: productCode, serialNumber: serialNumber)
    }
  }
  
  public var commandStationName : String {
    get {
      return "\(manufacturer) \(productCode) SN: \(serialNumber)"
    }
  }
  
  public var maxSlotNumber : (page:Int, number:Int)? {
    get {
      switch productCode {
      case .DCS210Plus:
        return (page:0, number:100)
      case .DCS210:
        return (page:0, number:100)
      case .DCS240:
        return (page:3, number:48)
      default:
        return nil
      }
    }
  }
  
  public var implementsProtocol1 : Bool = false {
    didSet {
      trackStatusChanged()
    }
  }
  
  public var implementsProtocol2 : Bool = false {
    didSet {
      trackStatusChanged()
    }
  }
  
  public var programmingTrackIsBusy : Bool = false {
    didSet {
      trackStatusChanged()
    }
  }
  
  public var trackIsPaused : Bool = false {
    didSet {
      trackStatusChanged()
    }
  }
  
  public var powerIsOn : Bool = false {
    didSet {
      trackStatusChanged()
    }
  }
  
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
  
  private func slotsUpdated() {
    for kv in slotObservers {
      kv.value.slotsUpdated?(commandStation: self)
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
  
  public func addMessenger(messenger:NetworkMessenger) {
    if let _ = _messengers[messenger.id] {
    }
    else {
      _messengers[messenger.id] = messenger
      _observerId[messenger.id] = messenger.addObserver(observer: self)
      messenger.getCfgSlotDataP1()
    }
  }
  
  public func removeMessenger(messenger:NetworkMessenger) {
    messenger.removeObserver(id: _observerId[messenger.id]!)
    _messengers.removeValue(forKey: messenger.id)
    _observerId.removeValue(forKey: messenger.id)
  }
  
  public func addSlotObserver(observer:SlotObserverDelegate) -> Int {
    slotObserverLock.lock()
    let id = nextSlotObserverId
    nextSlotObserverId += 1
    slotObservers[id] = observer
    slotObserverLock.unlock()
    return id
  }
  
  public func removeSlotObserver(id:Int) {
    slotObserverLock.lock()
    slotObservers.removeValue(forKey: id)
    slotObserverLock.unlock()
  }

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
  
  public func getCfgSlotDataP1() {
    for messenger in _messengers {
      if messenger.value.isOpen {
        messenger.value.getCfgSlotDataP1()
        break
      }
    }
  }
  
  public func getCfgSlotDataP2() {
    for messenger in _messengers {
      if messenger.value.isOpen {
        messenger.value.getCfgSlotDataP2()
        break
      }
    }
  }
  
  public func setLocoSlotDataP1(slotData:[UInt8]) {
    for messenger in _messengers {
      if messenger.value.isOpen {
        messenger.value.setLocoSlotDataP1(slotData: slotData)
        break
      }
    }
  }
  
  public func setLocoSlotDataP2(slotData:[UInt8]) {
    for messenger in _messengers {
      if messenger.value.isOpen {
        messenger.value.setLocoSlotDataP2(slotData: slotData)
        break
      }
    }
  }
  
  public func getProgSlotDataP1() {
    for messenger in _messengers {
      if messenger.value.isOpen {
        messenger.value.getProgSlotDataP1()
        break
      }
    }
  }
  
  public func swState(switchNumber: Int) {
    for messenger in _messengers {
      if messenger.value.isOpen {
        messenger.value.swState(switchNumber: switchNumber)
        break
      }
    }
  }
  
  public func swReq(switchNumber: Int, state:OptionSwitchState) {
    for messenger in _messengers {
      if messenger.value.isOpen {
        messenger.value.swReq(switchNumber: switchNumber, state: state)
        break
      }
    }
  }
  
  public func getLocoSlot(forAddress: Int) {
    if forAddress > 0 {
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

    }
  }
  
  public func moveSlots(sourceSlotNumber: Int, sourceSlotPage: Int, destinationSlotNumber: Int, destinationSlotPage: Int) {
    for kv in _messengers {
      let messenger = kv.value
      if messenger.isOpen {
        if implementsProtocol2 {
          messenger.moveSlotsP2(sourceSlotNumber: sourceSlotNumber, sourceSlotPage: sourceSlotPage, destinationSlotNumber: destinationSlotNumber, destinationSlotPage: destinationSlotPage)
        }
        else {
          messenger.moveSlotsP1(sourceSlotNumber: sourceSlotNumber, destinationSlotNumber: destinationSlotNumber)
        }
        break
      }
    }
  }
  
  public func updateLocomotiveState(slotNumber: Int, slotPage: Int, previousState:LocomotiveState, nextState:LocomotiveState, throttleID: Int) -> LocomotiveState {
    
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
      for kv in messengers {
        let messenger = kv.value
        if messenger.isOpen {
          messenger.setLocoSlotDataP1(slotData: message)
          break
        }
      }
    }
  }
  
  public func powerOn() {
    for kv in messengers {
      let messenger = kv.value
      if messenger.isOpen {
         messenger.powerOn()
        break
      }
    }
  }
  
  public func powerOff() {
    for kv in messengers {
      let messenger = kv.value
      if messenger.isOpen {
         messenger.powerOff()
        break
      }
    }
  }
  
  public func powerIdle() {
    for kv in messengers {
      let messenger = kv.value
      if messenger.isOpen {
         messenger.powerIdle()
        break
      }
    }
  }
  
  public func clearLocoSlotDataP1(slotNumber:Int) {
    for kv in messengers {
      let messenger = kv.value
      if messenger.isOpen {
         messenger.clearLocoSlotDataP1(slotNumber: slotNumber)
        break
      }
    }
  }

  public func clearLocoSlotDataP2(slotPage: Int, slotNumber:Int) {
    for kv in messengers {
      let messenger = kv.value
      if messenger.isOpen {
        messenger.clearLocoSlotDataP2(slotPage: slotPage, slotNumber: slotNumber)
        break
      }
    }
  }

  public func readCV(progMode: ProgrammingMode, cv:Int, address: Int) {
    for kv in messengers {
      let messenger = kv.value
      if messenger.isOpen {
        messenger.readCV(progMode: progMode, cv: cv, address: address)
        break
      }
    }
  }
    
  public func writeCV(progMode: ProgrammingMode, cv:Int, address: Int, value:Int) {
    for kv in messengers {
      let messenger = kv.value
      if messenger.isOpen {
        messenger.writeCV(progMode: progMode, cv: cv, address: address, value: value)
        break
      }
    }
  }
  
  public func getLocoSlotDataP1(slotNumber: Int) {
    for kv in messengers {
      let messenger = kv.value
      if messenger.isOpen {
        messenger.getLocoSlotDataP1(slotNumber: slotNumber)
        break
      }
    }
  }
    
  public func getLocoSlotDataP2(slotPage: Int, slotNumber: Int) {
    for kv in messengers {
      let messenger = kv.value
      if messenger.isOpen {
        messenger.getLocoSlotDataP2(slotPage: slotPage, slotNumber: slotNumber)
        break
      }
    }
  }
    
  // MARK: NetworkMessengerDelegate Methods
  
  @objc public func messengerRemoved(id: String) {
    _messengers.removeValue(forKey: id)
    _observerId.removeValue(forKey: id)
  }
  
  @objc public func networkMessageReceived(message: NetworkMessage) {
    switch message.messageType {
    case .cfgSlotDataP1, .locoSlotDataP1, .fastClockDataP1:
      let trk = message.message[7]
      implementsProtocol2    = (trk & 0b01000000) == 0b01000000
      programmingTrackIsBusy = (trk & 0b00001000) == 0b00001000
      implementsProtocol1    = (trk & 0b00000100) == 0b00000100
      trackIsPaused          = (trk & 0b00000010) == 0b00000000
      powerIsOn              = (trk & 0b00000001) == 0b00000001
      locomotiveMessage(message: message)
      if message.messageType == .locoSlotDataP1 {
        let slot = LocoSlotData(locoSlotDataP1: LocoSlotDataP1(interfaceId: message.interfaceId, data: message.message))
        _locoSlots[slot.slotID] = slot
        slotsUpdated()
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
    case .locoSlotDataP2:
      let trk = message.message[7]
      implementsProtocol2    = (trk & 0b01000000) == 0b01000000
      programmingTrackIsBusy = (trk & 0b00001000) == 0b00001000
      implementsProtocol1    = (trk & 0b00000100) == 0b00000100
      trackIsPaused          = (trk & 0b00000010) == 0b00000000
      powerIsOn              = (trk & 0b00000001) == 0b00000001
      locomotiveMessage(message: message)
      let slot = LocoSlotData(locoSlotDataP2: LocoSlotDataP2(interfaceId: message.interfaceId, data: message.message))
      _locoSlots[slot.slotID] = slot
      slotsUpdated()
      break
    case .noFreeSlotsP2, .noFreeSlotsP1, .setSlotDataOKP1, .setSlotDataOKP2, .illegalMoveP1, .illegalMoveP2:
      locomotiveMessage(message: message)
    case .pwrOn:
      powerIsOn = true
      getCfgSlotDataP1()
      break
    case .pwrOff:
      powerIsOn = false
      getCfgSlotDataP1()
    case .setIdleState:
      trackIsPaused = true
      getCfgSlotDataP1()
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
  
  // MARK: Database Methods
  
  private func decode(sqliteDataReader:SqliteDataReader?) {
    
    if let reader = sqliteDataReader {
      
      "[\(COMMAND_STATION.COMMAND_STATION_ID)], " +
      "[\(COMMAND_STATION.COMMAND_STATION_NAME)], " +
      "[\(COMMAND_STATION.MANUFACTURER)], " +
      "[\(COMMAND_STATION.PRODUCT_CODE)], " +
      "[\(COMMAND_STATION.SERIAL_NUMBER)], " +
      "[\(COMMAND_STATION.HARDWARE_VERSION)], " +
      "[\(COMMAND_STATION.SOFTWARE_VERSION)], " +
      "[\(COMMAND_STATION.OPTION_SWITCHES_0)], " +
      "[\(COMMAND_STATION.OPTION_SWITCHES_1)], " +
      "[\(COMMAND_STATION.OPTION_SWITCHES_2)], " +
      "[\(COMMAND_STATION.OPTION_SWITCHES_3)]"
      
      if !reader.isDBNull(index: 2) {
        manufacturer = Manufacturer(rawValue: reader.getInt(index: 2)!) ?? .Unknown
      }

      if !reader.isDBNull(index: 3) {
        productCode = ProductCode(rawValue: reader.getInt(index: 3)!) ?? .unknown
      }
      
      if !reader.isDBNull(index: 4) {
        serialNumber = reader.getInt(index: 4)!
      }

      if !reader.isDBNull(index: 5) {
        hardwareVersion = reader.getDouble(index: 5)!
      }

      if !reader.isDBNull(index: 6) {
        softwareVersion = reader.getDouble(index: 6)!
      }

      if !reader.isDBNull(index: 7) {
        optionSwitches0 = reader.getInt64(index: 7)!
      }

      if !reader.isDBNull(index: 8) {
        optionSwitches1 = reader.getInt64(index: 8)!
      }

      if !reader.isDBNull(index: 9) {
        optionSwitches2 = reader.getInt64(index: 9)!
      }

      if !reader.isDBNull(index: 10) {
        optionSwitches3 = reader.getInt64(index: 10)!
      }

    }
    
    modified = false
    
  }

  public func save() {
    
    if modified {
      
      var sql = ""
      
      if !Database.codeExists(tableName: TABLE.COMMAND_STATION, primaryKey: COMMAND_STATION.COMMAND_STATION_ID, code: commandStationId)! {
        sql = "INSERT INTO [\(TABLE.COMMAND_STATION)] (" +
        "[\(COMMAND_STATION.COMMAND_STATION_ID)], " +
        "[\(COMMAND_STATION.COMMAND_STATION_NAME)], " +
        "[\(COMMAND_STATION.MANUFACTURER)], " +
        "[\(COMMAND_STATION.PRODUCT_CODE)], " +
        "[\(COMMAND_STATION.SERIAL_NUMBER)], " +
        "[\(COMMAND_STATION.HARDWARE_VERSION)], " +
        "[\(COMMAND_STATION.SOFTWARE_VERSION)]," +
        "[\(COMMAND_STATION.OPTION_SWITCHES_0)]," +
        "[\(COMMAND_STATION.OPTION_SWITCHES_1)]," +
        "[\(COMMAND_STATION.OPTION_SWITCHES_2)]," +
        "[\(COMMAND_STATION.OPTION_SWITCHES_3)]" +
        ") VALUES (" +
        "@\(COMMAND_STATION.COMMAND_STATION_ID), " +
        "@\(COMMAND_STATION.COMMAND_STATION_NAME), " +
        "@\(COMMAND_STATION.MANUFACTURER), " +
        "@\(COMMAND_STATION.PRODUCT_CODE), " +
        "@\(COMMAND_STATION.SERIAL_NUMBER), " +
        "@\(COMMAND_STATION.HARDWARE_VERSION), " +
        "@\(COMMAND_STATION.SOFTWARE_VERSION)," +
        "@\(COMMAND_STATION.OPTION_SWITCHES_0)," +
        "@\(COMMAND_STATION.OPTION_SWITCHES_1)," +
        "@\(COMMAND_STATION.OPTION_SWITCHES_2)," +
        "@\(COMMAND_STATION.OPTION_SWITCHES_3)" +
        ")"
      }
      else {
        sql = "UPDATE [\(TABLE.COMMAND_STATION)] SET " +
        "[\(COMMAND_STATION.COMMAND_STATION_NAME)] = @\(COMMAND_STATION.COMMAND_STATION_NAME), " +
        "[\(COMMAND_STATION.MANUFACTURER)] = @\(COMMAND_STATION.MANUFACTURER), " +
        "[\(COMMAND_STATION.PRODUCT_CODE)] = @\(COMMAND_STATION.PRODUCT_CODE), " +
        "[\(COMMAND_STATION.SERIAL_NUMBER)] = @\(COMMAND_STATION.SERIAL_NUMBER), " +
        "[\(COMMAND_STATION.HARDWARE_VERSION)] = @\(COMMAND_STATION.HARDWARE_VERSION), " +
        "[\(COMMAND_STATION.SOFTWARE_VERSION)] = @\(COMMAND_STATION.SOFTWARE_VERSION), " +
        "[\(COMMAND_STATION.OPTION_SWITCHES_0)] = @\(COMMAND_STATION.OPTION_SWITCHES_0), " +
        "[\(COMMAND_STATION.OPTION_SWITCHES_1)] = @\(COMMAND_STATION.OPTION_SWITCHES_1), " +
        "[\(COMMAND_STATION.OPTION_SWITCHES_2)] = @\(COMMAND_STATION.OPTION_SWITCHES_2), " +
        "[\(COMMAND_STATION.OPTION_SWITCHES_3)] = @\(COMMAND_STATION.OPTION_SWITCHES_3) " +
        "WHERE [\(COMMAND_STATION.COMMAND_STATION_ID)] = @\(COMMAND_STATION.COMMAND_STATION_ID)"
      }

      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
         _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = sql
      
      cmd.parameters.addWithValue(key: "@\(COMMAND_STATION.COMMAND_STATION_ID)", value: commandStationId)
      cmd.parameters.addWithValue(key: "@\(COMMAND_STATION.COMMAND_STATION_NAME)", value: commandStationName)
      cmd.parameters.addWithValue(key: "@\(COMMAND_STATION.MANUFACTURER)", value: manufacturer.rawValue)
      cmd.parameters.addWithValue(key: "@\(COMMAND_STATION.PRODUCT_CODE)", value: productCode.rawValue)
      cmd.parameters.addWithValue(key: "@\(COMMAND_STATION.SERIAL_NUMBER)", value: serialNumber)
      cmd.parameters.addWithValue(key: "@\(COMMAND_STATION.HARDWARE_VERSION)", value: hardwareVersion)
      cmd.parameters.addWithValue(key: "@\(COMMAND_STATION.SOFTWARE_VERSION)", value: softwareVersion)
      cmd.parameters.addWithValue(key: "@\(COMMAND_STATION.OPTION_SWITCHES_0)", value: optionSwitches0)
      cmd.parameters.addWithValue(key: "@\(COMMAND_STATION.OPTION_SWITCHES_1)", value: optionSwitches1)
      cmd.parameters.addWithValue(key: "@\(COMMAND_STATION.OPTION_SWITCHES_2)", value: optionSwitches2)
      cmd.parameters.addWithValue(key: "@\(COMMAND_STATION.OPTION_SWITCHES_3)", value: optionSwitches3)

      _ = cmd.executeNonQuery()

      if shouldClose {
        conn.close()
      }
      
      modified = false
      
    }

  }

  // MARK: Class Properties
  
  public static var columnNames : String {
    get {
      return
        "[\(COMMAND_STATION.COMMAND_STATION_ID)], " +
        "[\(COMMAND_STATION.COMMAND_STATION_NAME)], " +
        "[\(COMMAND_STATION.MANUFACTURER)], " +
        "[\(COMMAND_STATION.PRODUCT_CODE)], " +
        "[\(COMMAND_STATION.SERIAL_NUMBER)], " +
        "[\(COMMAND_STATION.HARDWARE_VERSION)], " +
        "[\(COMMAND_STATION.SOFTWARE_VERSION)], " +
        "[\(COMMAND_STATION.OPTION_SWITCHES_0)], " +
        "[\(COMMAND_STATION.OPTION_SWITCHES_1)], " +
        "[\(COMMAND_STATION.OPTION_SWITCHES_2)], " +
        "[\(COMMAND_STATION.OPTION_SWITCHES_3)]"
    }
  }
  
  public static var commandStations : [CommandStation] {
    
    get {
    
      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
        _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = "SELECT \(columnNames) FROM [\(TABLE.COMMAND_STATION)]"

      var result : [CommandStation] = []
      
      if let reader = cmd.executeReader() {
           
        while reader.read() {
          let cs = CommandStation(reader: reader)
          result.append(cs)
        }
           
        reader.close()
           
      }
      
      if shouldClose {
        conn.close()
      }

      return result.sorted {
        $0.commandStationName < $1.commandStationName
      }
      
    }
    
  }
  
  public static var commandStationsDictionary : [Int:CommandStation] {
    get {
      var result : [Int:CommandStation] = [:]
      let css = CommandStation.commandStations
      for cs in css {
        result[cs.commandStationId] = cs
      }
      return result
    }
  }
  
  public static func commandStationID(manufacturer: Manufacturer, productCode: ProductCode, serialNumber: Int) -> Int {
    return (manufacturer.rawValue << 24) | (productCode.rawValue << 16) | serialNumber
  }

}
