//
//  OpenLCBClock.swift
//  MyTrains
//
//  Created by Paul Willmott on 26/05/2023.
//

import Foundation

private enum ClockDirection : Double {
  case forward  =  1.0
  case backward = -1.0
}

public enum OpenLCBCustomClockEventPrefixType : UInt8 {
  case clockNodeId   = 0
  case userSpecified = 1
}

public enum OpenLCBFastClockEventIndex : Int {
  case startOrStopEvent = 0
  case reportRateEvent = 1
  case reportYearEvent = 2
  case reportDateEvent = 3
  case reportTimeEvent = 4
}

public enum OpenLCBFastClockSubCode : UInt64 {
  
  case reportTimeEventId   = 0x0000
  case reportDateEventId   = 0x2000
  case reportYearEventId   = 0x3000
  case reportRateEventId   = 0x4000
  case setTimeEventId      = 0x8000
  case setTimeEventId2     = 0x9000
  case setDateEventId      = 0xa000
  case setYearEventId      = 0xb000
  case setRateEventId      = 0xc000
  case queryEventId        = 0xf000
  case stopEventId         = 0xf001
  case startEventId        = 0xf002
  case dateRolloverEventId = 0xf003
  
  public var index : OpenLCBFastClockEventIndex? {
    get {
      switch self {
      case .reportTimeEventId, .setTimeEventId:
        return .reportTimeEvent
      case .reportDateEventId, .setDateEventId:
        return .reportDateEvent
      case .reportYearEventId, .setYearEventId:
        return .reportYearEvent
      case .reportRateEventId, .setRateEventId:
        return .reportRateEvent
      case .stopEventId:
        return .startOrStopEvent
      case .startEventId:
        return .startOrStopEvent
      default:
        return nil
      }
    }
  }
  
}

public class OpenLCBClock : OpenLCBNodeVirtual {
  
  // MARK: Constructors & Destructors
  
  public override init(nodeId:UInt64) {
    
    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: 64, isReadOnly: false, description: "")
    
    super.init(nodeId: nodeId)
    
    virtualNodeType = MyTrainsVirtualNodeType.clockNode
    
    configuration.delegate = self

    memorySpaces[configuration.space] = configuration

    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressOperatingMode)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressClockType)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressCustomClockEventPrefixType)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressUserSpecifiedEventPrefix)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressRunningState)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressCurrentDateTime)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressCurrentRate)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressResetToInitialState)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressResetToFactoryDefaults)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressPowerOnRunningState)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressInitialDateTime)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressDefaultDateTime)
    registerVariable(space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, address: addressInitialRate)

    initCDI(filename: "MyTrains Clock")
    
    dateFormatter.timeZone = Date().dateComponents.timeZone
    dateFormatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
    
    if !memorySpacesInitialized {
      resetToFactoryDefaults()
    }
    
  }
  
  deinit {
    stopTimer()
  }
  
  // MARK: Private Properties
  
  private let secPerDay : TimeInterval = 86400.0
  
  private var timer : Timer?
  
  private var syncTimer : Timer?
  
  private var rolloverTimer : Timer?
  
  private var observers : [Int:OpenLCBClockDelegate] = [:]
  
  private var nextObserverId : Int = 0
  
  private var clockDirection : ClockDirection {
    get {
      return ClockDirection(rawValue: rate.sign) ?? .forward
    }
  }
  
  private var dateFormatter = ISO8601DateFormatter()
  
  private let specificUpperPartMask : UInt64 = 0xffffffffffff0000
  
  private var triggered : Bool = false
  
  private var lastSend : TimeInterval = 0
  
  private var lastEvents : [UInt64] = [UInt64](repeating: 0, count: 5)
  
  private var calendar : Calendar = Calendar(identifier: .gregorian)
  
  private var specificEvents : Set<UInt64> = []
  
  private var rebooted = false
  
  private let baseEventLookup : [OpenLCBClockType:UInt64] =
  [
    OpenLCBClockType.fastClock       : 0x0101000001000000,
    OpenLCBClockType.realTimeClock   : 0x0101000001010000,
    OpenLCBClockType.alternateClock1 : 0x0101000001020000,
    OpenLCBClockType.alternateClock2 : 0x0101000001030000
  ]

  // Configuration varaible addresses
  
  internal let addressOperatingMode              : Int =  0
  internal let addressClockType                  : Int =  1
  internal let addressCustomClockEventPrefixType : Int =  2
  internal let addressUserSpecifiedEventPrefix   : Int =  3
  internal let addressRunningState               : Int = 11
  internal let addressCurrentDateTime            : Int = 12
  internal let addressCurrentRate                : Int = 32
  internal let addressResetToInitialState        : Int = 36
  internal let addressResetToFactoryDefaults     : Int = 37
  internal let addressPowerOnRunningState        : Int = 38
  internal let addressInitialDateTime            : Int = 39
  internal let addressDefaultDateTime            : Int = 40
  internal let addressInitialRate                : Int = 60
  
  // MARK: Public Properties
  
  public var configuration : OpenLCBMemorySpace
  
  public var operatingMode : OpenLCBClockOperatingMode {
    get {
      return OpenLCBClockOperatingMode(rawValue: configuration.getUInt8(address: addressOperatingMode)!)!
    }
    set(value) {
      configuration.setUInt(address: addressOperatingMode, value: value.rawValue)
    }
  }
  
  public var setToFactoryDefaults : OpenLCBEnabledDisabledState {
    get {
      return OpenLCBEnabledDisabledState(rawValue: configuration.getUInt8(address: addressResetToFactoryDefaults)!)!
    }
    set(value) {
      configuration.setUInt(address: addressResetToFactoryDefaults, value: value.rawValue)
    }
  }

  public var setToInitialState : OpenLCBEnabledDisabledState {
    get {
      return OpenLCBEnabledDisabledState(rawValue: configuration.getUInt8(address: addressResetToInitialState)!)!
    }
    set(value) {
      configuration.setUInt(address: addressResetToInitialState, value: value.rawValue)
    }
  }

  public var subState : OpenLCBClockSubState = .rebooting
  
  public var isClockGenerator : Bool {
    get {
      return operatingMode == .master
    }
  }
  
  public var rate : Double {
    get {
      return Double(configuration.getFloat(address: addressCurrentRate)!)
    }
    set(value) {
      configuration.setFloat(address: addressCurrentRate, value: Float(value))
    }
  }
  
  public var initialRate : Double {
    get {
      return Double(configuration.getFloat(address: addressInitialRate)!)
    }
    set(value) {
      configuration.setFloat(address: addressInitialRate, value: Float(value))
    }
  }
  
  public var clockState : OpenLCBClockState {
    get {
      return OpenLCBClockState(rawValue: configuration.getUInt8(address: addressRunningState)!)!
    }
    set(value) {
      configuration.setUInt(address: addressRunningState, value: value.rawValue)
    }
  }
  
  public var initialDateTime : OpenLCBClockInitialDateTime {
    get {
      return OpenLCBClockInitialDateTime(rawValue: configuration.getUInt8(address: addressInitialDateTime)!)!
    }
    set(value) {
      configuration.setUInt(address: addressInitialDateTime, value: value.rawValue)
    }
  }
  
  public var powerOnClockState : OpenLCBClockState {
    get {
      return OpenLCBClockState(rawValue: configuration.getUInt8(address: addressPowerOnRunningState)!)!
    }
    set(value) {
      configuration.setUInt(address: addressPowerOnRunningState, value: value.rawValue)
    }
  }
  
  public var type : OpenLCBClockType { 
    get {
      return OpenLCBClockType(rawValue: configuration.getUInt8(address: addressClockType)!)!
    }
    set(value) {
      configuration.setUInt(address: addressClockType, value: value.rawValue)
    }
  }
  
  public var customClockEventPrefixType: OpenLCBCustomClockEventPrefixType {
    get {
      return OpenLCBCustomClockEventPrefixType(rawValue: configuration.getUInt8(address: addressCustomClockEventPrefixType)!)!
    }
    set(value) {
      configuration.setUInt(address: addressCustomClockEventPrefixType, value: value.rawValue)
    }
  }
  
  public var customClockEventPrefixUserSpecified : UInt64 {
    get {
      return configuration.getUInt64(address: addressUserSpecifiedEventPrefix)!
    }
    set(value) {
      configuration.setUInt(address: addressUserSpecifiedEventPrefix, value: value)
    }
  }
  
  public var baseEventId : UInt64 {
    get {
      if type == .customClock {
        return customClockEventPrefixType == .clockNodeId ? nodeId : customClockEventPrefixUserSpecified
      }
      return baseEventLookup[type]!
    }
  }
  
  public var dateTime : String {
    get {
      return configuration.getString(address: addressCurrentDateTime, count: 20)!
    }
    set(value) {
      var newValue : String
      var newDate : Date
      if let date = dateFormatter.date(from: value) {
        newValue = String(value.prefix(19))
        newDate = date
      }
      else {
        newValue = "1970-01-01T00:00:00"
        newDate = Date(timeIntervalSince1970: 0.0)
      }
      configuration.setString(address: addressCurrentDateTime, value: newValue, fieldSize: 20)
      date = newDate
    }
  }

  public var defaultDateTime : String {
    get {
      return configuration.getString(address: addressDefaultDateTime, count: 20)!
    }
    set(value) {
      var newValue : String
      if let _ = dateFormatter.date(from: value) {
        newValue = value
      }
      else {
        newValue = "1970-01-01T00:00:00"
      }
      configuration.setString(address: addressDefaultDateTime, value: newValue, fieldSize: 20)
    }
  }

  public var date : Date {
    get {
      
      var components = DateComponents()
      
      components.year              = year
      components.month             = month
      components.day               = day
      components.hour              = hour
      components.minute            = minute
      components.second            = second
      
      // Nullify the remaining fields to avoid confusion about what the date should be based on
      
      components.yearForWeekOfYear = nil
      components.weekOfYear        = nil
      components.weekday           = nil
      components.era               = nil
      components.isLeapMonth       = nil
      components.quarter           = nil
      components.weekOfMonth       = nil
      
      return calendar.date(from: components)!
      
    }
    set(value) {
      
      let components = value.dateComponents
      
      year   = components.year!
      month  = components.month!
      day    = components.day!
      hour   = components.hour!
      minute = components.minute!
      second = 0 // components.second!
      
    }
  }
  
  public var year : Int = 1970
  
  public var month : Int = 1
  
  public var day : Int = 1
  
  public var hour : Int = 0
  
  public var minute : Int = 0
  
  public var second : Int = 0
  
  // MARK: Private Methods

  internal override func resetReboot() {
    
    super.resetReboot()
    
    rebooted = true
    
    subState = .rebooting
    
    timer?.invalidate()
    timer = nil
    
    syncTimer?.invalidate()
    syncTimer = nil
    
    year = 1970
    
    month = 1
    
    day = 1
    
    hour = 0
    
    minute = 0
    
    second = 0

    triggered = false
    
    lastSend  = 0
    
    lastEvents = [UInt64](repeating: 0, count: 5)

    updateObservers()
    
    rate = initialRate
    
    clockState = .stopped
    
    switch operatingMode {
    case .master:
      switch initialDateTime {
      case .computerDateTime:
        let dt = dateFormatter.string(from: Date())
        dateTime = dt
      case .defaultDateTime:
        dateTime = defaultDateTime
      }
      if powerOnClockState == .running {
        subState = .running
        startClock()
      }
      else {
        subState = .stopped
      }
    case .slave:
      subState = .idle
      networkLayer!.sendClockQuery(sourceNodeId: nodeId, baseEventId: baseEventId)
    }
    
    updateObservers()
    
  }
  
  internal override func resetToFactoryDefaults() {
    
    super.resetToFactoryDefaults()
    
    acdiManufacturerSpaceVersion = 4
    
    manufacturerName    = virtualNodeType.manufacturerName
    nodeModelName       = virtualNodeType.name
    nodeHardwareVersion = "v0.1"
    nodeSoftwareVersion = "v0.1"
    
    acdiUserSpaceVersion = 2
    
    userNodeName        = ""
    userNodeDescription = ""
    
    operatingMode = .slave
    
    type = .fastClock
    
    customClockEventPrefixType = .clockNodeId
    
    customClockEventPrefixUserSpecified = (nodeId << 16)
    
    powerOnClockState = .stopped
    
    initialDateTime = .computerDateTime
    
    defaultDateTime = "1970-01-01T00:00:00"
    
    initialRate = 1.0
    
    rate = initialRate
    
    clockState = powerOnClockState
    
    saveMemorySpaces()
    
  }
  
  private func sendStartClockPreamble() {
    if let network = networkLayer {
      makeSync()
      var eventId = baseEventId | 0xffff
      network.sendProducerRangeIdentified(sourceNodeId: nodeId, eventId: eventId)
      network.sendConsumerRangeIdentified(sourceNodeId: nodeId, eventId: eventId)
      eventId = encodeStopStartEvent(state: clockState)
      lastEvents[OpenLCBFastClockEventIndex.startOrStopEvent.rawValue] = eventId
      network.sendEvent(sourceNodeId: nodeId, eventId: eventId)
      sendSync()
    }
  }
  
  private func isLeapYear(year:Int) -> Bool {
    return ( (year % 4 == 0) && (year % 100 != 0) ) || (year % 400 == 0)
  }
  
  private func daysInMonth(month:Int, year:Int) -> Int {
    var days : [Int] = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    if isLeapYear(year: year) {
      days[1] = 29
    }
    return days[month - 1]
  }
  
  @objc func timerAction() {
    
    var rollover = false
    
    var minuteRollover = false
    
    switch clockDirection {
    case .forward:
      second += 1
      if second == 60 {                                        // Seconds in the range 0 ... 59
        second = 0
        minute += 1
        minuteRollover = true
        if minute == 60 {                                      // Minutes in the range 0 ... 59
          minute = 0
          hour += 1
          if hour == 24 {                                      // Hour in the range 0 ... 23
            hour = 0
            if isClockGenerator {
              rollover = true
              day += 1
              if day > daysInMonth(month: month, year: year) { // Day in range 1 ... Days in Month
                day = 1
                month += 1
                if month == 13 {                               // Month in the range 1 ... 12
                  month = 1
                  year += 1
                  if year == 4096 {                            // Year in the range 0 ... 4095
                    year = 0
                  }
                }
              }
            }
          }
        }
      }
    case .backward:
      second -= 1
      if second == -1 {                                       // Seconds in the range 0 ... 59
        second = 59
        minute -= 1
        minuteRollover = true
        if minute == -1 {                                     // Minutes in the range 0 ... 59
          minute = 59
          hour -= 1
          if hour == -1 {                                     // Hour in the range 0 ... 23
            hour = 23
            if isClockGenerator {
              rollover = true
              day -= 1
              if day == 0 {                                   // Day in range 1 ... Days in Month
                month -= 1
                day = daysInMonth(month: month, year: year)
                if month == 0 {                               // Month in the range 1 ... 12
                  month = 12
                  year -= 1
                  if year == 0 {                              // Year in the range 0 ... 4095
                    year = 4095
                  }
                }
              }
            }
          }
        }
      }
    }
    
    let str = String(dateFormatter.string(from: date).prefix(19))
    configuration.setString(address: addressCurrentDateTime, value: str, fieldSize: 20)
    
    if minuteRollover && isClockGenerator, let network = networkLayer {
      
      if rollover {
        network.sendEvent(sourceNodeId: nodeId, eventId: encodeDateRolloverEvent())
        startRolloverTimer()
      }

      let eventId = encodeTimeEvent(subCode: .reportTimeEventId, hour: hour, minute: minute)
          
      let newDate = Date().timeIntervalSince1970
      triggered = triggered || (newDate - lastSend) > 59.0
      
      if specificEvents.contains(eventId) {
        triggered = true
      }
      
      if triggered || rollover {
        lastEvents[OpenLCBFastClockEventIndex.reportTimeEvent.rawValue] = eventId
        network.sendEvent(sourceNodeId: nodeId, eventId: eventId)
        triggered = false
        lastSend = newDate
      }

    }
       
    updateObservers()
    
  }
  
  private func startTimer() {
    
    stopTimer()
    
    guard rate != 0.0 else {
      clockState = .stopped
      return
    }
    
    let interval = 1.0 / abs(rate)
    
    timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    
    RunLoop.current.add(timer!, forMode: .common)

  }
  
  private func stopTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  private func updateObservers() {
    for (_, observer) in observers {
      DispatchQueue.main.async {
        observer.clockTick(clock: self)
      }
    }
  }

  @objc func rolloverTimerAction() {
    
    syncTimer?.invalidate()
    syncTimer = nil
    
    if let networkLayer = networkLayer {
      
      var eventsToSend : [(index:OpenLCBFastClockEventIndex, eventId:UInt64)] = []
      
      eventsToSend.append((index: .reportYearEvent, eventId: encodeYearEvent(subCode: .reportYearEventId, year: year)))
      
      eventsToSend.append((index: .reportDateEvent, eventId: encodeDateEvent(subCode: .reportDateEventId, month: month, day: day)))
      
      for (index, eventId) in eventsToSend {
        lastEvents[index.rawValue] = eventId
        networkLayer.sendEvent(sourceNodeId: nodeId, eventId: eventId)
      }
      
    }
    
  }
  
  private func startRolloverTimer() {
    
    let interval = 3.0
    
    rolloverTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(rolloverTimerAction), userInfo: nil, repeats: false)
    
    RunLoop.current.add(rolloverTimer!, forMode: .common)

  }
  
  @objc func syncTimerAction() {
    sendSync()
  }
  
  private func startSyncTimer() {
    
    stopSyncTimer()
    
    lastSend = 0.0
    
    let interval = 3.0
    
    syncTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(syncTimerAction), userInfo: nil, repeats: false)
    
    RunLoop.current.add(syncTimer!, forMode: .common)

  }
  
  private func stopSyncTimer() {
    syncTimer?.invalidate()
    syncTimer = nil
  }
  
  private func makeSync() {
    
    lastEvents = [UInt64](repeating: 0, count: 5)

    for index in 0 ... 4 {
      
      if let eventIndex = OpenLCBFastClockEventIndex(rawValue: index) {
        
        var eventId : UInt64
        
        switch eventIndex {
        case .startOrStopEvent:
          eventId = encodeStopStartEvent(state: clockState)
        case .reportRateEvent:
          eventId = encodeRateEvent(subCode: .reportRateEventId, rate: rate)
        case .reportYearEvent:
          eventId = encodeYearEvent(subCode: .reportYearEventId, year: year)
        case .reportDateEvent:
          eventId = encodeDateEvent(subCode: .reportDateEventId, month: month, day: day)
        case .reportTimeEvent:
          eventId = encodeTimeEvent(subCode: .reportTimeEventId, hour: hour, minute: minute)
        }
        
        lastEvents[index] = eventId
        
      }
      
    }
    
  }
  
  private func sendSync() {
    
    if let network = networkLayer {
      
      for index in 0 ... 4 {
        network.sendProducerIdentified(sourceNodeId: nodeId, eventId: lastEvents[index], validity: .valid)
      }
      
      triggered = true
      
      lastSend = 0.0
      
    }
    
  }
  
  // MARK: Public Methods

  public func encodeTimeEvent(subCode:OpenLCBFastClockSubCode, hour:Int, minute:Int) -> UInt64 {
    return baseEventId | subCode.rawValue | (UInt64(hour) << 8) | UInt64(minute)
  }
  
  public func encodeDateEvent(subCode:OpenLCBFastClockSubCode, month:Int, day:Int) -> UInt64 {
    return baseEventId | subCode.rawValue | (UInt64(month) << 8) | UInt64(day)
  }
  
  public func encodeYearEvent(subCode:OpenLCBFastClockSubCode, year:Int) -> UInt64 {
    return baseEventId | subCode.rawValue | UInt64(year)
  }

  public func encodeRateEvent(subCode:OpenLCBFastClockSubCode, rate:Double) -> UInt64 {
    return baseEventId | subCode.rawValue | UInt64(rate.openLCBClockRate)
  }

  public func encodeStopStartEvent(state:OpenLCBClockState) -> UInt64 {
    let subCode : OpenLCBFastClockSubCode = (state == .stopped) ? .stopEventId : .startEventId
    return baseEventId | subCode.rawValue
  }
  
  public func encodeDateRolloverEvent() -> UInt64 {
    let subCode : OpenLCBFastClockSubCode = .dateRolloverEventId
    return baseEventId | subCode.rawValue
  }

  public func startClock() {
   
    clockState = .running
    
    subState = .running
        
    if let network = networkLayer {
      if isClockGenerator {
        sendStartClockPreamble()
      }
      else {
        let eventId = baseEventId | 0xffff
        network.sendConsumerRangeIdentified(sourceNodeId: nodeId, eventId: eventId)
        network.sendClockQuery(sourceNodeId: nodeId, baseEventId: baseEventId)
      }
    }
    
    startTimer()

  }
  
  public func stopClock() {
    
    stopTimer()
    
    clockState = .stopped
    
    subState = .stopped
    
    if isClockGenerator, let network = networkLayer {
      let eventId = encodeStopStartEvent(state: clockState)
      lastEvents[OpenLCBFastClockEventIndex.startOrStopEvent.rawValue] = eventId
      network.sendEvent(sourceNodeId: nodeId, eventId: eventId)
    }
    
  }
  
  public func addObserver(observer:OpenLCBClockDelegate) -> Int {
    let id = nextObserverId
    nextObserverId += 1
    observers[id] = observer
    return id
  }
  
  public func removeObserver(observerId:Int) {
    observers.removeValue(forKey: observerId)
  }
  
  public override func start() {
    super.start()
  }
  
  public override func stop() {
    stopClock()
    super.stop()
  }
  
  public override func variableChanged(space: OpenLCBMemorySpace, address: Int) {
    
    if space.space == configuration.space {
      
      switch address {
      case addressClockType:
        break
      case addressCurrentRate:
        if clockState == .running {
          stopTimer()
          startTimer()
        }
        break
      case addressInitialRate:
        break
      case addressRunningState:
        clockState == .running ? startClock() : stopClock()
        break
      case addressOperatingMode:
        break
      case addressCurrentDateTime:
        dateTime = dateTime
        if isClockGenerator {
          var eventToSend : [(index:OpenLCBFastClockEventIndex, eventId:UInt64)] = []
          eventToSend.append((index: .reportTimeEvent, eventId:encodeTimeEvent(subCode: .reportTimeEventId, hour: hour, minute: minute)))
          eventToSend.append((index: .reportDateEvent, eventId:encodeDateEvent(subCode: .reportDateEventId, month: month, day: day)))
          eventToSend.append((index:.reportYearEvent, eventId:encodeYearEvent(subCode: .reportYearEventId, year: year)))
          for (index, eventId) in eventToSend {
            lastEvents[index.rawValue] = eventId
            networkLayer?.sendEvent(sourceNodeId: nodeId, eventId: eventId)
          }
          startSyncTimer()
       }

      case addressDefaultDateTime:
        break
      case addressInitialDateTime:
        break
      case addressPowerOnRunningState:
        break
      case addressResetToInitialState:
        if setToInitialState == .enabled {
          resetReboot()
          setToInitialState = .disabled
        }
      case addressResetToFactoryDefaults:
        if setToFactoryDefaults == .enabled {
          resetToFactoryDefaults()
          setToFactoryDefaults = .disabled
        }
      case addressUserSpecifiedEventPrefix:
        break
      case addressCustomClockEventPrefixType:
        break
      default:
        break
      }

      updateObservers()
      
    }

  }
  
  // MARK: OpenLCBMemorySpaceDelegate Methods
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    super.openLCBMessageReceived(message: message)
    
    switch message.messageTypeIndicator {
    case .consumerIdentifiedAsCurrentlyInvalid, .consumerIdentifiedAsCurrentlyValid, .consumerIdentifiedWithValidityUnknown:

      if isClockGenerator {
        
        let eventId = message.eventId!
        
        if (eventId & specificUpperPartMask) == baseEventId {
          specificEvents.insert(eventId)
        }
        
      }
      
    case .producerConsumerEventReport, .producerIdentifiedAsCurrentlyValid:
      
      let eventId = message.eventId!
      
      if (eventId & specificUpperPartMask) == baseEventId {
        
        var word = UInt16(eventId & ~specificUpperPartMask)
        
        var code = OpenLCBFastClockSubCode(rawValue: UInt64(word)) ?? OpenLCBFastClockSubCode(rawValue: UInt64(word & 0xf000))
        
        if code == .setTimeEventId2 {
          code = .setTimeEventId
        }
        
        if let subCode = code {
          
          word -= UInt16(subCode.rawValue)
          
          let byte6 = Int(word >> 8)
          let byte7 = Int(word & 0xff)
          
          var eventToSend : [(index:OpenLCBFastClockEventIndex, eventId:UInt64)] = []
          
          switch subCode {
          case .reportTimeEventId:
            if !isClockGenerator {
              hour = byte6
              minute = byte7
              second = 0
            }
          case .reportDateEventId:
            if !isClockGenerator {
              month = byte6
              day = byte7
            }
          case .reportYearEventId:
            if !isClockGenerator {
              year = Int(word)
            }
          case .reportRateEventId:
            if !isClockGenerator {
              rate = Double(openLCBClockRate: word)
            }
          case .setTimeEventId, .setTimeEventId2:
            hour = byte6
            minute = byte7
            second = 0
            if isClockGenerator {
              eventToSend.append((index: .reportTimeEvent, eventId:encodeTimeEvent(subCode: .reportTimeEventId, hour: byte6, minute: byte7)))
            }
          case .setDateEventId:
            month = byte6
            day = byte7
            if isClockGenerator {
              eventToSend.append((index: .reportDateEvent, eventId:encodeDateEvent(subCode: .reportDateEventId, month: byte6, day: byte7)))
            }
          case .setYearEventId:
            year = Int(word)
            if isClockGenerator {
              eventToSend.append((index:.reportYearEvent, eventId:encodeYearEvent(subCode: .reportYearEventId, year: Int(word))))
            }
          case .setRateEventId:
            rate = Double(openLCBClockRate: word)
            if isClockGenerator {
              eventToSend.append((index: .reportRateEvent, eventId:encodeRateEvent(subCode: .reportRateEventId, rate: rate)))
            }
          case .queryEventId:
            if isClockGenerator {
              sendSync()
            }
          case .stopEventId:
            if clockState == .running {
              stopClock()
            }
          case .startEventId:
            if clockState == .stopped {
              startClock()
            }
          case .dateRolloverEventId:
            if !isClockGenerator {
              switch clockDirection {
              case .forward:
                day += 1
                if day > daysInMonth(month: month, year: year) {
                  day = 1
                  month += 1
                  if month == 13 {
                    month = 1
                    year += 1
                    if year == 4096 {
                      year = 0
                    }
                  }
                }
              case .backward:
                day -= 1
                if day == 0 {
                  month -= 1
                  if month == 0 {
                    month = 12
                    year -= 1
                    if year == -1 {
                      year = 4095
                    }
                  }
                  day = daysInMonth(month: month, year: year)
                }
              }
            }
          }
          
          if let (index, eventId) = eventToSend.first {
            lastEvents[index.rawValue] = eventId
            networkLayer?.sendEvent(sourceNodeId: nodeId, eventId: eventId)
            startSyncTimer()
          }
          
        }
                                                 
      }
    default:
      break
    }
    
  }
  
}
