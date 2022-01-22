//
//  CommandStation.swift
//  MyTrains
//
//  Created by Paul Willmott on 18/12/2021.
//

import Foundation

public protocol CommandStationDelegate {
  func trackStatusChanged(commandStation: CommandStation)
  func locomotiveMessageReceived(message: NetworkMessage)
  func progMessageReceived(message:NetworkMessage)
}

public protocol SlotObserverDelegate {
  func slotsUpdated(locoSlots:[LocoSlotData])
}

public class CommandStation : NetworkMessengerDelegate {
  
  // MARK: Constructors
  
  init(message:IPLDevData) {
    productCode = message.productCode
    serialNumber = message.serialNumber
    softwareVersion = message.softwareVersion
    save()
  }
  
  init(reader:SqliteDataReader) {
    decode(sqliteDataReader: reader)
  }
  
  init() {
  }
  
  // MARK: Destructors
  
  deinit {
    stopTimer()
  }
  
  // MARK: Private Properties
  
  private var _manufacturer : Manufacturer = .Digitrax
  
  private var _productCode : ProductCode = .unknown
  
  private var _serialNumber : Int = -1
  
  private var _hardwareVersion : Double = -1.0
  
  private var _softwareVersion : Double = -1.0
  
  private var modified : Bool = false
  
  private var _messengers : [String:NetworkMessenger] = [:]
  
  private var _observerId : [String:Int] = [:]
  
  private var _implementsProtocol1 : Bool?
  
  private var _implementsProtocol2 : Bool?
  
  private var _programmingTrackIsBusy : Bool?
  
  private var _trackIsPaused : Bool = false
  
  private var _powerIsOn : Bool = false
  
  private var _delegates : [Int:CommandStationDelegate] = [:]
  
  private var _nextDelegateId = 0
  
  private var _delegateLock : NSLock = NSLock()
  
  private var timer : Timer? = nil
  
  private var forceRefresh : Bool = false
  
  private var _locoSlots : [Int:LocoSlotData] = [:]
  
  private var slotObservers : [Int:SlotObserverDelegate] = [:]
  
  private var nextSlotObserverId = 0
  
  private var slotObserverLock : NSLock = NSLock()
  
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
        $0.slotNumber < $1.slotNumber
      }
      
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
  
  public var productCode : ProductCode {
    get {
      return _productCode
    }
    set(value) {
      if value != _productCode {
        _productCode = value
        modified = true
      }
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
      return (manufacturer.rawValue << 24) | (productCode.rawValue << 16) | serialNumber
    }
  }
  
  public var commandStationName : String {
    get {
      return "\(manufacturer) \(productCode) SN: \(serialNumber)"
    }
  }
  
  public var implementsProtocol1 : Bool {
    get {
      return _implementsProtocol1 ?? false
    }
    set(value) {
      var changed = true
      if let x = _implementsProtocol1 {
        changed = x == value
      }
      _implementsProtocol1 = value
      if changed {
        for delegate in _delegates {
          delegate.value.trackStatusChanged(commandStation: self)
        }
      }
    }
  }
  
  public var implementsProtocol2 : Bool {
    get {
      return _implementsProtocol2 ?? false
    }
    set(value) {
      var changed = true
      if let x = _implementsProtocol2 {
        changed = x == value
      }
      _implementsProtocol2 = value
      if changed {
        for delegate in _delegates {
          delegate.value.trackStatusChanged(commandStation: self)
        }
      }
    }
  }
  
  public var programmingTrackIsBusy : Bool {
    get {
      return _programmingTrackIsBusy ?? false
    }
    set(value) {
      var changed = true
      if let x = _programmingTrackIsBusy {
        changed = x == value
      }
      _programmingTrackIsBusy = value
      if changed {
        for delegate in _delegates {
          delegate.value.trackStatusChanged(commandStation: self)
        }
      }
    }
  }
  
  public var trackIsPaused : Bool {
    get {
      return _trackIsPaused
    }
    set(value) {
      _trackIsPaused = value
      for delegate in _delegates {
        delegate.value.trackStatusChanged(commandStation: self)
      }
    }
  }
  
  public var powerIsOn : Bool {
    get {
      return _powerIsOn
    }
    set(value) {
      _powerIsOn = value
      for delegate in _delegates {
        delegate.value.trackStatusChanged(commandStation: self)
      }
    }
  }
  
  // MARK: Private Methods
  
  private func locomotiveMessage(message: NetworkMessage) {
    for delegate in _delegates {
      delegate.value.locomotiveMessageReceived(message: message)
    }
  }
  
  private func progMessage(message: NetworkMessage) {
    for delegate in _delegates {
      delegate.value.progMessageReceived(message: message)
    }
  }
  
  private func slotsUpdated() {
    
    let slots = locoSlots
    
    for kv in slotObservers {
      kv.value.slotsUpdated(locoSlots: slots)
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
  
  public func getProgSlotDataP1() {
    for messenger in _messengers {
      if messenger.value.isOpen {
        messenger.value.getProgSlotDataP1()
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
  
  public func updateLocomotiveState(slotNumber: Int, slotPage: Int, previousState:LocomotiveState, nextState:LocomotiveState) -> LocomotiveState {
    
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
          
          let maskF0F6   = 0b00000000000000000000000001111111
          let maskF7F13  = 0b00000000000000000011111110000000
          let maskF14F20 = 0b00000000000111111100000000000000
          let maskF21F28 = 0b00001111111000000000000000000000
          
          if previous & maskF0F6 != next & maskF0F6 {
            messenger.locoF0F6P2(slotNumber: slotNumber, slotPage: slotPage, functions: next)
          }
          
          if previous & maskF7F13 != next & maskF7F13 {
            messenger.locoF7F13P2(slotNumber: slotNumber, slotPage: slotPage, functions: next)
          }
          
          if previous & maskF14F20 != next & maskF14F20 {
            messenger.locoF14F20P2(slotNumber: slotNumber, slotPage: slotPage, functions: next)
          }
          
          if previous & maskF21F28 != next & maskF21F28 {
            messenger.locoF21F28P2(slotNumber: slotNumber, slotPage: slotPage, functions: next)
          }
          
          if speedChanged || directionChanged || forceRefresh {
            messenger.locoSpdDirP2(slotNumber: slotNumber, slotPage: slotPage, speed: nextState.speed, direction: nextState.direction)
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
  
  public func readCV(cv:Int) {
    for kv in messengers {
      let messenger = kv.value
      if messenger.isOpen {
        messenger.readCV(cv: cv)
        break
      }
    }
  }
    
  public func writeCV(cv:Int, value:Int) {
    for kv in messengers {
      let messenger = kv.value
      if messenger.isOpen {
        messenger.writeCV(cv: cv, value: value)
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
  
  public func messengerRemoved(id: String) {
    _messengers.removeValue(forKey: id)
    _observerId.removeValue(forKey: id)
  }
  
  public func networkMessageReceived(message: NetworkMessage) {
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
        _locoSlots[slot.slotNumber] = slot
        slotsUpdated()
      }
      break
    case .locoSlotDataP2:
      locomotiveMessage(message: message)
      let slot = LocoSlotData(locoSlotDataP2: LocoSlotDataP2(interfaceId: message.interfaceId, data: message.message))
      _locoSlots[slot.slotNumber] = slot
      slotsUpdated()
      break
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
  }
  
  public func networkTimeOut(message: NetworkMessage) {
  }
  
  // MARK: Database Methods
  
  private func decode(sqliteDataReader:SqliteDataReader?) {
    
    if let reader = sqliteDataReader {
      
      if !reader.isDBNull(index: 1) {
        manufacturer = Manufacturer(rawValue: reader.getInt(index: 1)!) ?? .Unknown
      }

      if !reader.isDBNull(index: 2) {
        productCode = ProductCode(rawValue: reader.getInt(index: 2)!) ?? .unknown
      }
      
      if !reader.isDBNull(index: 3) {
        serialNumber = reader.getInt(index: 3)!
      }

      if !reader.isDBNull(index: 4) {
        hardwareVersion = reader.getDouble(index: 4)!
      }

      if !reader.isDBNull(index: 5) {
        softwareVersion = reader.getDouble(index: 5)!
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
        "[\(COMMAND_STATION.SOFTWARE_VERSION)]" +
        ") VALUES (" +
        "@\(COMMAND_STATION.COMMAND_STATION_ID), " +
        "@\(COMMAND_STATION.COMMAND_STATION_NAME), " +
        "@\(COMMAND_STATION.MANUFACTURER), " +
        "@\(COMMAND_STATION.PRODUCT_CODE), " +
        "@\(COMMAND_STATION.SERIAL_NUMBER), " +
        "@\(COMMAND_STATION.HARDWARE_VERSION), " +
        "@\(COMMAND_STATION.SOFTWARE_VERSION)" +
        ")"
      }
      else {
        sql = "UPDATE [\(TABLE.COMMAND_STATION)] SET " +
        "[\(COMMAND_STATION.COMMAND_STATION_NAME)] = @\(COMMAND_STATION.COMMAND_STATION_NAME), " +
        "[\(COMMAND_STATION.MANUFACTURER)] = @\(COMMAND_STATION.MANUFACTURER), " +
        "[\(COMMAND_STATION.PRODUCT_CODE)] = @\(COMMAND_STATION.PRODUCT_CODE), " +
        "[\(COMMAND_STATION.SERIAL_NUMBER)] = @\(COMMAND_STATION.SERIAL_NUMBER), " +
        "[\(COMMAND_STATION.HARDWARE_VERSION)] = @\(COMMAND_STATION.HARDWARE_VERSION), " +
        "[\(COMMAND_STATION.SOFTWARE_VERSION)] = @\(COMMAND_STATION.SOFTWARE_VERSION) " +
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
        "[\(COMMAND_STATION.SOFTWARE_VERSION)]"
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
          result.append(CommandStation(reader: reader))
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

}
