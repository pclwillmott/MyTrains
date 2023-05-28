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

public class OpenLCBClock : NSObject {
  
  // MARK: Constructors & Destructors
  
  public init(node:OpenLCBNodeMyTrains, type:OpenLCBClockType) {
    
    self.type = type
    
    self.node = node
    
    super.init()
    
    if isClockGenerator {
      date = Date()
      rate = 1.0
    }
    
  }
  
  deinit {
    stoptimer()
  }
  
  // MARK: Private Properties
  
  private var node:OpenLCBNodeMyTrains
  
  private var timeClock : TimeInterval = 0.0
  
  private var dateClock : TimeInterval = 0.0
  
  private let secPerDay : TimeInterval = 86400.0
  
  private var _state : OpenLCBClockState = .stopped
  
  private var _rate : Double = 1.0
  
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
  
  private let specificUpperPartMask : UInt64 = 0xffffffffffff0000
  
  private var triggered : Bool = false
  
  private var lastSend : TimeInterval = 0
  
  private var lastEvents : [UInt64] = []
  
  private var calendar : Calendar = Calendar(identifier: .gregorian)
  
  private var specificEvents : Set<UInt64> = []
  
  // MARK: Public Properties
  
  public var type : OpenLCBClockType
  
  public var rate : Double {
    get {
      return _rate
    }
    set(value) {
      if _rate != value {
        _rate = value
        if state == .running {
          startTimer()
        }
      }
    }
  }
  
  public var state : OpenLCBClockState {
    get {
      return _state
    }
  }
  
  public var isClockGenerator : Bool = true
  
  public var date : Date {
    get {
      return Date(timeIntervalSince1970: dateClock)
    }
    set(value) {
      let interval = value.timeIntervalSince1970
      dateClock = interval - interval.truncatingRemainder(dividingBy: secPerDay)
    }
  }
  
  public var time : Date {
    get {
      return Date(timeIntervalSince1970: timeClock)
    }
    set(value) {
      timeClock = value.timeIntervalSince1970.truncatingRemainder(dividingBy: secPerDay)
    }
  }

  public var dateTime : Date {
    get {
      return Date(timeIntervalSince1970: timeClock + dateClock)
    }
    set(value) {
      time = value
      date = value
    }
  }
  
  public var monthDay : (month:Int, day:Int) {
    get {
      let components = date.dateComponents
      return (month: components.month!, day: components.day!)
    }
    set(value) {
      var components = date.dateComponents
      components.yearForWeekOfYear = nil
      components.day = value.day
      components.month = value.month
      components.weekOfYear = nil
      components.weekday = nil
      components.era = nil
      components.isLeapMonth = nil
      components.quarter = nil
      components.weekOfMonth = nil
      date = calendar.date(from: components)!
    }
  }

  public var year : Int {
    get {
      let components = date.dateComponents
      return components.year!
    }
    set(value) {
      var components : DateComponents = date.dateComponents
      components.year = value
      components.yearForWeekOfYear = nil
      components.weekOfYear = nil
      components.weekday = nil
      components.era = nil
      components.isLeapMonth = nil
      components.quarter = nil
      components.weekOfMonth = nil
      date = calendar.date(from: components)!
      components = date.dateComponents
    }
  }
  
  public var hms : (hour:Int, minute:Int, second:Int) {
    get {
      let components = time.dateComponents
      return (hour: components.hour!, minute: components.minute!, second: components.second!)
    }
    set (value) {
      var components = time.dateComponents
      components.yearForWeekOfYear = nil
      components.hour = value.hour
      components.minute = value.minute
      components.second = value.second
      components.weekOfYear = nil
      components.weekday = nil
      components.era = nil
      components.isLeapMonth = nil
      components.quarter = nil
      components.weekOfMonth = nil
      time = calendar.date(from: components)!
    }
  }

  // MARK: Private Methods

  @objc func timerAction() {
    
    var rollover = false
    
    switch clockDirection {
    case .forward:
      timeClock += 1.0
      if timeClock == secPerDay {
        rollover = true
        timeClock = 0.0
      }
    case .backward:
      timeClock -= 1.0
      if timeClock == -1.0 {
        rollover = true
        timeClock = secPerDay - 1
      }
    }
    
    let newDate = Date().timeIntervalSince1970
    triggered = triggered || (newDate - lastSend) > 59.0
    
    if isClockGenerator, let network = node.networkLayer {
      
      if rollover {
        dateClock += clockDirection.rawValue * secPerDay
        let eventId = encodeDateRolloverEvent()
        network.sendEvent(sourceNodeId: node.nodeId, eventId: eventId)
        startRolloverTimer()
      }

      let newComponents = dateTime.dateComponents
      
      let eventId = encodeTimeEvent(subCode: .reportTimeEventId, hour: newComponents.hour!, minute: newComponents.minute!)
          
      if lastEvents[OpenLCBFastClockEventIndex.reportTimeEvent.rawValue] != eventId {
        
        if specificEvents.contains(eventId) {
          triggered = true
        }
        
        if triggered {
          lastEvents[OpenLCBFastClockEventIndex.reportTimeEvent.rawValue] = eventId
          network.sendEvent(sourceNodeId: node.nodeId, eventId: eventId)
          triggered = false
          lastSend = newDate
        }
          
      }

    }
        
    for (_, observer) in observers {
      DispatchQueue.main.async {
        observer.clockTick(clock: self)
      }
    }
    
  }
  
  private func startTimer() {
    
    stoptimer()
    
    guard rate != 0.0 else {
      _state = .stopped
      return
    }
    
    let interval = 1.0 / abs(rate)
    
    timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    
    RunLoop.current.add(timer!, forMode: .common)

  }
  
  private func stoptimer() {
    timer?.invalidate()
    timer = nil
  }

  @objc func rolloverTimerAction() {
    
    syncTimer?.invalidate()
    syncTimer = nil
    
    if let networkLayer = node.networkLayer {
      
      var eventsToSend : [(index:OpenLCBFastClockEventIndex, eventId:UInt64)] = []
      
      let newComponents = dateTime.dateComponents
      
      eventsToSend.append((index: .reportYearEvent, eventId: encodeYearEvent(subCode: .reportYearEventId, year: newComponents.year!)))
      
      eventsToSend.append((index: .reportDateEvent, eventId: encodeDateEvent(subCode: .reportDateEventId, month: newComponents.month!, day: newComponents.day!)))
      
      for (index, eventId) in eventsToSend {
        lastEvents[index.rawValue] = eventId
        networkLayer.sendEvent(sourceNodeId: node.nodeId, eventId: eventId)
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
          eventId = encodeStopStartEvent(state: state)
        case .reportRateEvent:
          eventId = encodeRateEvent(subCode: .reportRateEventId, rate: rate)
        case .reportYearEvent:
          eventId = encodeYearEvent(subCode: .reportYearEventId, year: year)
        case .reportDateEvent:
          let temp = monthDay
          eventId = encodeDateEvent(subCode: .reportDateEventId, month: temp.month, day: temp.day)
        case .reportTimeEvent:
          let temp = hms
          eventId = encodeTimeEvent(subCode: .reportTimeEventId, hour: temp.hour, minute: temp.minute)
        }
        
        lastEvents[index] = eventId
        
      }
      
    }
    
  }
  
  private func sendSync() {
    
    if let network = node.networkLayer {
      
      if lastEvents.isEmpty {
        makeSync()
      }
      
      for index in 0 ... 4 {
        network.sendProducerIdentifiedValid(sourceNodeId: node.nodeId, eventId: lastEvents[index])
      }
      
      triggered = true
      
      lastSend = 0.0
      
    }
    
  }
  
  // MARK: Public Methods

  public func encodeTimeEvent(subCode:OpenLCBFastClockSubCode, hour:Int, minute:Int) -> UInt64 {
    return type.rawValue | subCode.rawValue | (UInt64(hour) << 8) | UInt64(minute)
  }
  
  public func encodeDateEvent(subCode:OpenLCBFastClockSubCode, month:Int, day:Int) -> UInt64 {
    return type.rawValue | subCode.rawValue | (UInt64(month) << 8) | UInt64(day)
  }
  
  public func encodeYearEvent(subCode:OpenLCBFastClockSubCode, year:Int) -> UInt64 {
    return type.rawValue | subCode.rawValue | UInt64(year)
  }

  public func encodeRateEvent(subCode:OpenLCBFastClockSubCode, rate:Double) -> UInt64 {
    return type.rawValue | subCode.rawValue | UInt64(rate.openLCBClockRate)
  }

  public func encodeStopStartEvent(state:OpenLCBClockState) -> UInt64 {
    let subCode : OpenLCBFastClockSubCode = (state == .stopped) ? .stopEventId : .startEventId
    return type.rawValue | subCode.rawValue
  }
  
  public func encodeDateRolloverEvent() -> UInt64 {
    let subCode : OpenLCBFastClockSubCode = .dateRolloverEventId
    return type.rawValue | subCode.rawValue
  }

  public func start() {
    
    guard state == .stopped else {
      return
    }
    
    _state = .running
    
    if let network = node.networkLayer {
      if isClockGenerator {
        let eventId = type.rawValue | 0xffff
        network.sendProducerRangeIdentified(sourceNodeId: node.nodeId, eventId: eventId)
        network.sendConsumerRangeIdentified(sourceNodeId: node.nodeId, eventId: eventId)
        sendSync()
      }
      else {
        let eventId = type.rawValue | 0xffff
        network.sendConsumerRangeIdentified(sourceNodeId: node.nodeId, eventId: eventId)
        network.sendClockQuery(sourceNodeId: node.nodeId, clockType: type)
      }
    }
    
    startTimer()

  }
  
  public func stop() {
    
    guard state == .running else {
      return
    }
    
    _state = .stopped
    stoptimer()
    
    if isClockGenerator, let network = node.networkLayer {
      let eventId = encodeStopStartEvent(state: state)
      lastEvents[OpenLCBFastClockEventIndex.startOrStopEvent.rawValue] = eventId
      network.sendEvent(sourceNodeId: node.nodeId, eventId: eventId)
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
  
  // MARK: OpenLCBNetworkLayerDelegate Methods
  
  public func openLCBMessageReceived(message: OpenLCBMessage) {
    
    switch message.messageTypeIndicator {
    case .consumerIdentifiedAsCurrentlyInvalid, .consumerIdentifiedAsCurrentlyValid, .consumerIdentifiedWithValidityUnknown:

      if isClockGenerator {
        
        let eventId = message.eventId!
        
        if let clockType = OpenLCBClockType(rawValue: eventId & specificUpperPartMask), type == clockType {
          specificEvents.insert(eventId)
        }
        
      }
      
    case .producerConsumerEventReport, .producerIdentifiedAsCurrentlyValid:
      
      let eventId = message.eventId!
      
      if let clockType = OpenLCBClockType(rawValue: eventId & specificUpperPartMask), type == clockType {
        
        var word = UInt16(eventId & ~specificUpperPartMask)
        
        let code = OpenLCBFastClockSubCode(rawValue: UInt64(word)) ?? OpenLCBFastClockSubCode(rawValue: UInt64(word & 0xf000))
        
        if let subCode = code {
          
          word -= UInt16(subCode.rawValue)
          
          let byte6 = Int(word >> 8)
          let byte7 = Int(word & 0xff)
          
          var eventToSend : [UInt64] = []
          
          switch subCode {
          case .reportTimeEventId:
            if !isClockGenerator {
              hms = (hour: byte6, minute: byte7, second: 0)
            }
          case .reportDateEventId:
            if !isClockGenerator {
              monthDay = (month: byte6, day: byte7)
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
            if isClockGenerator {
              hms = (hour: byte6, minute: byte7, second: 0)
              eventToSend.append(encodeTimeEvent(subCode: .reportTimeEventId, hour: byte6, minute: byte7))
            }
          case .setDateEventId:
            if isClockGenerator {
              monthDay = (month: byte6, day: byte7)
              eventToSend.append(encodeDateEvent(subCode: .reportDateEventId, month: byte6, day: byte7))
            }
          case .setYearEventId:
            if isClockGenerator {
              year = Int(word)
              eventToSend.append(encodeYearEvent(subCode: .reportYearEventId, year: Int(word)))
            }
          case .setRateEventId:
            if isClockGenerator {
              rate = Double(openLCBClockRate: word)
              eventToSend.append(encodeRateEvent(subCode: .reportRateEventId, rate: rate))
            }
          case .queryEventId:
            if isClockGenerator {
              sendSync()
            }
          case .stopEventId:
            stop()
          case .startEventId:
            start()
          case .dateRolloverEventId:
            if !isClockGenerator {
              switch clockDirection {
              case .forward:
                timeClock = 0.0
              case .backward:
                timeClock = secPerDay - 1.0
              }
              dateClock += secPerDay * rate.sign
            }
          }
          
          if let eventId = eventToSend.first {
            lastEvents[subCode.index!.rawValue] = eventId
            node.networkLayer?.sendEvent(sourceNodeId: node.nodeId, eventId: eventId)
            startSyncTimer()
          }
          
        }
                                                 
      }
    default:
      break
    }
    
  }
  
}
