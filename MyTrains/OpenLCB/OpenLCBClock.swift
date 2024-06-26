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
    
    super.init(nodeId: nodeId)

    var configurationSize = 0
    
    initSpaceAddress(&addressOperatingMode, 1, &configurationSize)
    initSpaceAddress(&addressClockType, 1, &configurationSize)
    initSpaceAddress(&addressCustomClockEventPrefixType, 1, &configurationSize)
    initSpaceAddress(&addressUserSpecifiedEventPrefix, 8, &configurationSize)
    initSpaceAddress(&addressRunningState, 1, &configurationSize)
    initSpaceAddress(&addressCurrentDateTime, 20, &configurationSize)
    initSpaceAddress(&addressCurrentRate, 4, &configurationSize)
    initSpaceAddress(&addressResetToInitialState, 1, &configurationSize)
    initSpaceAddress(&addressResetToFactoryDefaults, 1, &configurationSize)
    initSpaceAddress(&addressPowerOnRunningState, 1, &configurationSize)
    initSpaceAddress(&addressInitialDateTime, 1, &configurationSize)
    initSpaceAddress(&addressDefaultDateTime, 20, &configurationSize)
    initSpaceAddress(&addressInitialRate, 4, &configurationSize)

    configuration = OpenLCBMemorySpace.getMemorySpace(nodeId: nodeId, space: OpenLCBNodeMemoryAddressSpace.configuration.rawValue, defaultMemorySize: configurationSize, isReadOnly: false, description: "")
    
    if let configuration {
      
      virtualNodeType = MyTrainsVirtualNodeType.clockNode
      
      isFullProtocolRequired = true
      
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
      
      dateFormatter?.timeZone = Date().dateComponents.timeZone
      dateFormatter?.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime]
      
      if !memorySpacesInitialized {
        resetToFactoryDefaults()
      }
      
      if operatingMode == .master {
        eventRangesProduced = [
          EventRange(startId: baseEventId, mask: 0xffff)!,
        ]
      }
      else {
        eventRangesConsumed = [
          EventRange(startId: baseEventId, mask: 0xffff)!,
        ]
      }
      
      cdiFilename = "MyTrains Clock"
      
    }
    
  }
  
  deinit {
    
    timer?.invalidate()
    timer = nil
    
    syncTimer?.invalidate()
    syncTimer = nil
    
    rolloverTimer?.invalidate()
    rolloverTimer = nil
    
    observers.removeAll()
    
    dateFormatter = nil
    
    lastEvents.removeAll()
    
    calendar = nil

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
  
  private var dateFormatter : ISO8601DateFormatter? = ISO8601DateFormatter()
  
  private let specificUpperPartMask : UInt64 = 0xffffffffffff0000
  
  private var triggered : Bool = false
  
  private var lastSend : TimeInterval = 0
  
  private var lastEvents : [UInt64] = [UInt64](repeating: 0, count: 5)
  
  private var calendar : Calendar? = Calendar(identifier: .gregorian)
  
  private var specificEvents : Set<UInt64> = []
  
  private var rebooted = false
  
  private let baseEventLookup : [OpenLCBClockType:UInt64] =
  [
    .fastClock       : 0x0101000001000000,
    .realTimeClock   : 0x0101000001010000,
    .alternateClock1 : 0x0101000001020000,
    .alternateClock2 : 0x0101000001030000,
  ]

  // Configuration variable addresses
  
  internal var addressOperatingMode              = 0
  internal var addressClockType                  = 0
  internal var addressCustomClockEventPrefixType = 0
  internal var addressUserSpecifiedEventPrefix   = 0
  internal var addressRunningState               = 0
  internal var addressCurrentDateTime            = 0
  internal var addressCurrentRate                = 0
  internal var addressResetToInitialState        = 0
  internal var addressResetToFactoryDefaults     = 0
  internal var addressPowerOnRunningState        = 0
  internal var addressInitialDateTime            = 0
  internal var addressDefaultDateTime            = 0
  internal var addressInitialRate                = 0
  
  // MARK: Public Properties
  
  public var operatingMode : OpenLCBClockOperatingMode {
    get {
      return OpenLCBClockOperatingMode(rawValue: configuration!.getUInt8(address: addressOperatingMode)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressOperatingMode, value: value.rawValue)
    }
  }
  
  public var setToFactoryDefaults : OpenLCBEnabledDisabledState {
    get {
      return OpenLCBEnabledDisabledState(rawValue: configuration!.getUInt8(address: addressResetToFactoryDefaults)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressResetToFactoryDefaults, value: value.rawValue)
    }
  }

  public var setToInitialState : OpenLCBEnabledDisabledState {
    get {
      return OpenLCBEnabledDisabledState(rawValue: configuration!.getUInt8(address: addressResetToInitialState)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressResetToInitialState, value: value.rawValue)
    }
  }

  public var subState : OpenLCBClockSubState = .rebooting
  
  public var isClockGenerator : Bool {
    return operatingMode == .master
  }
  
  public var rate : Double {
    get {
      return Double(configuration!.getFloat(address: addressCurrentRate)!)
    }
    set(value) {
      configuration!.setFloat(address: addressCurrentRate, value: Float(value))
      if clockState == .running {
        stopTimer()
        startTimer()
      }
    }
  }
  
  public var initialRate : Double {
    get {
      return Double(configuration!.getFloat(address: addressInitialRate)!)
    }
    set(value) {
      configuration!.setFloat(address: addressInitialRate, value: Float(value))
    }
  }
  
  public var clockState : OpenLCBClockState {
    get {
      return OpenLCBClockState(rawValue: configuration!.getUInt8(address: addressRunningState)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressRunningState, value: value.rawValue)
    }
  }
  
  public var initialDateTime : OpenLCBClockInitialDateTime {
    get {
      return OpenLCBClockInitialDateTime(rawValue: configuration!.getUInt8(address: addressInitialDateTime)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressInitialDateTime, value: value.rawValue)
    }
  }
  
  public var powerOnClockState : OpenLCBClockState {
    get {
      return OpenLCBClockState(rawValue: configuration!.getUInt8(address: addressPowerOnRunningState)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressPowerOnRunningState, value: value.rawValue)
    }
  }
  
  public var type : OpenLCBClockType { 
    get {
      return OpenLCBClockType(rawValue: configuration!.getUInt8(address: addressClockType)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressClockType, value: value.rawValue)
    }
  }
  
  public var customClockEventPrefixType: OpenLCBCustomClockEventPrefixType {
    get {
      return OpenLCBCustomClockEventPrefixType(rawValue: configuration!.getUInt8(address: addressCustomClockEventPrefixType)!)!
    }
    set(value) {
      configuration!.setUInt(address: addressCustomClockEventPrefixType, value: value.rawValue)
    }
  }
  
  public var customClockEventPrefixUserSpecified : UInt64 {
    get {
      return configuration!.getUInt64(address: addressUserSpecifiedEventPrefix)!
    }
    set(value) {
      configuration!.setUInt(address: addressUserSpecifiedEventPrefix, value: value)
    }
  }
  
  public var baseEventId : UInt64 {

    if type == .customClock {
      return customClockEventPrefixType == .clockNodeId ? nodeId : customClockEventPrefixUserSpecified
    }
    
    return baseEventLookup[type]!
    
  }
  
  public var dateTime : String {
    get {
      return configuration!.getString(address: addressCurrentDateTime, count: 20)!
    }
    set(value) {
      var newValue : String
      var newDate : Date
      if let date = dateFormatter?.date(from: value) {
        newValue = String(value.prefix(19))
        newDate = date
      }
      else {
        newValue = "1970-01-01T00:00:00"
        newDate = Date(timeIntervalSince1970: 0.0)
      }
      configuration!.setString(address: addressCurrentDateTime, value: newValue, fieldSize: 20)
      date = newDate
    }
  }

  public var defaultDateTime : String {
    get {
      return configuration!.getString(address: addressDefaultDateTime, count: 20)!
    }
    set(value) {
      var newValue : String
      if let _ = dateFormatter?.date(from: value) {
        newValue = value
      }
      else {
        newValue = "1970-01-01T00:00:00"
      }
      configuration!.setString(address: addressDefaultDateTime, value: newValue, fieldSize: 20)
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
      
      return calendar!.date(from: components)!
      
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
        let dt = dateFormatter!.string(from: Date())
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
      sendClockQuery(baseEventId: baseEventId)
    }
    
    updateObservers()
    
  }
  
  internal override func resetToFactoryDefaults() {
    
    super.resetToFactoryDefaults()
    
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
  
  override internal func customizeDynamicCDI(cdi:String) -> String {
    
    var result = OpenLCBClockOperatingMode.insertMap(cdi: cdi)
    result = OpenLCBClockType.insertMap(cdi: result)
    result = ClockCustomIdType.insertMap(cdi: result)
    result = OpenLCBClockState.insertMap(cdi: result)
    result = EnableState.insertMap(cdi: result)
    result = OpenLCBClockInitialDateTime.insertMap(cdi: result)

    return result
    
  }
  
  private func sendStartClockPreamble() {
    makeSync()
    var eventId = baseEventId | 0xffff
    eventId = encodeStopStartEvent(state: clockState)
    lastEvents[OpenLCBFastClockEventIndex.startOrStopEvent.rawValue] = eventId
    sendEvent(eventId: eventId)
    sendSync()
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
    
    let str = String(dateFormatter!.string(from: date).prefix(19))
    configuration!.setString(address: addressCurrentDateTime, value: str, fieldSize: 20)
    
    if minuteRollover && isClockGenerator {
      
      if rollover {
        sendEvent(eventId: encodeDateRolloverEvent())
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
        sendEvent(eventId: eventId)
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
    
    var eventsToSend : [(index:OpenLCBFastClockEventIndex, eventId:UInt64)] = []
    
    eventsToSend.append((index: .reportYearEvent, eventId: encodeYearEvent(subCode: .reportYearEventId, year: year)))
    
    eventsToSend.append((index: .reportDateEvent, eventId: encodeDateEvent(subCode: .reportDateEventId, month: month, day: day)))
    
    for (index, eventId) in eventsToSend {
      lastEvents[index.rawValue] = eventId
      sendEvent(eventId: eventId)
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
    
    for index in 0 ... 4 {
      sendProducerIdentified(eventId: lastEvents[index], validity: .valid)
    }
    
    triggered = true
    
    lastSend = 0.0

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
        
    if isClockGenerator {
      sendStartClockPreamble()
    }
    else {
 //     let eventId = baseEventId | 0xffff
      sendClockQuery(baseEventId: baseEventId)
    }

    startTimer()

  }
  
  public func stopClock() {
    
    stopTimer()
    
    clockState = .stopped
    
    subState = .stopped
    
    if isClockGenerator {
      let eventId = encodeStopStartEvent(state: clockState)
      lastEvents[OpenLCBFastClockEventIndex.startOrStopEvent.rawValue] = eventId
      sendEvent(eventId: eventId)
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
    startClock()
  }
  
  public override func stop() {
    stopClock()
    super.stop()
  }
  
  public override func variableChanged(space: OpenLCBMemorySpace, address: Int) {
    
    if space.space == configuration!.space {
      
      var eventRangesMayHaveChanged = false
      
      switch address {
      case addressClockType:
        eventRangesMayHaveChanged = true
      case addressCurrentRate:
        if clockState == .running {
          stopTimer()
          startTimer()
        }
      case addressInitialRate:
        break
      case addressRunningState:
        clockState == .running ? startClock() : stopClock()
        break
      case addressOperatingMode:
        eventRangesMayHaveChanged = true
      case addressCurrentDateTime:
        dateTime = dateTime
        if isClockGenerator {
          var eventToSend : [(index:OpenLCBFastClockEventIndex, eventId:UInt64)] = []
          eventToSend.append((index: .reportTimeEvent, eventId:encodeTimeEvent(subCode: .reportTimeEventId, hour: hour, minute: minute)))
          eventToSend.append((index: .reportDateEvent, eventId:encodeDateEvent(subCode: .reportDateEventId, month: month, day: day)))
          eventToSend.append((index:.reportYearEvent, eventId:encodeYearEvent(subCode: .reportYearEventId, year: year)))
          for (index, eventId) in eventToSend {
            lastEvents[index.rawValue] = eventId
            sendEvent(eventId: eventId)
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
        eventRangesMayHaveChanged = true
      case addressCustomClockEventPrefixType:
        eventRangesMayHaveChanged = true
      default:
        break
      }
      
      if eventRangesMayHaveChanged {
        
        eventRangesConsumed = []
        eventRangesProduced = []
        
        if operatingMode == .master {
          eventRangesProduced = [
            EventRange(startId: baseEventId, mask: 0xffff)!,
          ]
        }
        else {
          eventRangesConsumed = [
            EventRange(startId: baseEventId, mask: 0xffff)!,
          ]
        }
       
        for eventRange in eventRangesConsumed {
          sendConsumerRangeIdentified(eventId: eventRange.eventId)
        }

        for eventRange in eventRangesProduced {
          sendProducerRangeIdentified(eventId: eventRange.eventId)
        }

      }

      updateObservers()
      
    }

  }
  
  // MARK: OpenLCBMemorySpaceDelegate Methods
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public override func openLCBMessageReceived(message: OpenLCBMessage) {
    
    super.openLCBMessageReceived(message: message)
    
    switch message.messageTypeIndicator {
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
            sendEvent(eventId: eventId)
            startSyncTimer()
          }
          
        }
                                                 
      }
      
    case .consumerIdentifiedAsCurrentlyInvalid, .consumerIdentifiedAsCurrentlyValid, .consumerIdentifiedWithValidityUnknown:

      if isClockGenerator {
        
        let eventId = message.eventId!
        
        if (eventId & specificUpperPartMask) == baseEventId {
          specificEvents.insert(eventId)
        }
        
      }
      
    default:
      break
    }
    
  }
  
}
