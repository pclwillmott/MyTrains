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

public class OpenLCBClock : NSObject {
  
  // MARK: Constructors & Destructors
  
  public init(node:OpenLCBNodeMyTrains, type:OpenLCBClockType) {
    
    self.type = type
    
    self.node = node
    
    super.init()
    
    self.calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    
    if isClockGenerator {
   //   date = Date()
      rate = 16.0
    }
    
  }
  
  deinit {
    stoptimer()
  }
  
  // MARK: Private Properties
  
  private var node:OpenLCBNodeMyTrains
  
  private var clock : TimeInterval = 0.0
  
  private var _state : OpenLCBClockState = .stopped
  
  private var _rate : Double = 1.0
  
  private var timer : Timer?
  
  private var syncTimer : Timer?
  
  private var observers : [Int:OpenLCBClockDelegate] = [:]
  
  private var nextObserverId : Int = 0
  
  private var clockDirection : ClockDirection = .forward
  
  private var calendar = Calendar(identifier: .gregorian)
  
  private let specificUpperPartMask : UInt64 = 0xffffffffffff0000
  
  private var triggered : Bool = false
  
  private var lastSend : TimeInterval = 0
  
  private var lastEvents : [UInt64] = []
  
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
  
  public var isClockGenerator : Bool = false
  
  public var date : Date {
    get {
      return Date(timeIntervalSince1970: clock)
    }
    set(value) {
      clock = value.timeIntervalSince1970
    }
  }
  
  public var monthDay : (month:Int, day:Int) {
    get {
      let components = date.dateComponents
      return (month: components.month!, day: components.day!)
    }
    set(value) {
      var components = date.dateComponents
      components.day = value.day
      components.month = value.month
      date = calendar.date(from: components)!
    }
  }

  public var year : Int {
    get {
      let components = date.dateComponents
      return components.year!
    }
    set(value) {
      var components = date.dateComponents
      components.year = value
      date = calendar.date(from: components)!
    }
  }
  
  public var time : (hour:Int, minute:Int, second:Int) {
    get {
      let components = date.dateComponents
      return (hour: components.hour!, minute: components.minute!, second: components.second!)
    }
    set (value) {
      var components = date.dateComponents
      components.hour = value.hour
      components.minute = value.minute
      components.second = value.second
      date = calendar.date(from: components)!
    }
  }

  // MARK: Private Methods

  @objc func timerAction() {
    
    clock += clockDirection.rawValue
    
    let newComponents = date.dateComponents
    
    let newDate = Date().timeIntervalSince1970
    triggered = triggered || (newDate - lastSend) >= 60.0
    
    if triggered && isClockGenerator {

      triggered = false
      lastSend = newDate
      
      var eventsToSend : [UInt64] = []

      for index in 0 ... 4 {
        if let eventIndex = OpenLCBFastClockEventIndex(rawValue: index) {
          var eventId : UInt64 = type.rawValue
          switch eventIndex {
          case .startOrStopEvent:
            eventId |= (state == .running ? 0xf002 : 0xf001)
          case .reportRateEvent:
            eventId |= (0x4000 + UInt64(rate.openLCBClockRate))
          case .reportYearEvent:
            eventId |= UInt64(0x3000 + newComponents.year!)
          case .reportDateEvent:
            eventId |= UInt64(0x2000 + (newComponents.month! << 8) + newComponents.day!)
          case .reportTimeEvent:
            eventId |= UInt64(0x0000 + (newComponents.hour! << 8) + newComponents.minute!)
          }
          if lastEvents[index] != eventId {
            lastEvents[index] = eventId
            eventsToSend.append(eventId)
          }
        }
        
      }
      
      if !eventsToSend.isEmpty, let network = node.networkLayer {
        
        for eventId in eventsToSend {
          network.sendEvent(sourceNodeId: node.nodeId, eventId: eventId)
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
    
    clockDirection = ClockDirection(rawValue: rate.sign) ?? .forward

    timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    
    RunLoop.current.add(timer!, forMode: .common)

  }
  
  private func stoptimer() {
    timer?.invalidate()
    timer = nil
  }

  @objc func syncTimerAction() {
    sendSync()
  }
  
  private func startSyncTimer() {
    
    stopSyncTimer()
    
    let interval = 3.0
    
    syncTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(syncTimerAction), userInfo: nil, repeats: false)
    
    RunLoop.current.add(syncTimer!, forMode: .common)

  }
  
  private func stopSyncTimer() {
    syncTimer?.invalidate()
    syncTimer = nil
  }

  // MARK: Public Methods
  
  private func makeSync() {
    
    lastEvents = [UInt64](repeating: 0, count: 5)

    for index in 0...4 {
      
      if let eventIndex = OpenLCBFastClockEventIndex(rawValue: index) {
        
        var eventId : UInt64 = type.rawValue
        
        switch eventIndex {
        case .startOrStopEvent:
          eventId |= (state == .running ? 0xf002 : 0xf001)
        case .reportRateEvent:
          eventId |= (0x4000 + UInt64(rate.openLCBClockRate))
        case .reportYearEvent:
          eventId |= (0x3000 + UInt64(year))
        case .reportDateEvent:
          let temp = monthDay
          eventId |= UInt64(0x20 + temp.month) << 8
          eventId |= UInt64(temp.day)
        case .reportTimeEvent:
          let temp = time
          eventId |= UInt64(0x00 + temp.hour) << 8
          eventId |= UInt64(temp.minute)
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
      
      for index in 0...4 {
        network.sendProducerIdentifiedValid(sourceNodeId: node.nodeId, eventId: lastEvents[index])
      }
      
      triggered = true
      
    }
    
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
      let eventId = type.rawValue | (state == .running ? 0xf002 : 0xf001)
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
    case .producerConsumerEventReport, .producerIdentifiedAsCurrentlyValid:
      
      let eventId = message.eventId!
      
      if let clockType = OpenLCBClockType(rawValue: eventId & specificUpperPartMask), type == clockType {
        
        let word = UInt16(eventId & ~specificUpperPartMask)
        
        let byte6 = UInt8(word >> 8)
        let byte7 = UInt8(word & 0xff)
        
        switch byte6 & 0xf0 {
        case 0x00, 0x10:
          if !isClockGenerator {
            let hour = Int(byte6)
            let minute = Int(byte7)
            time = (hour: hour, minute: minute, second: 0)
          }
        case 0x20:
          if !isClockGenerator {
            let month = Int(byte6 - 0x20)
            let day = Int(byte7)
            monthDay = (month: month, day: day)
          }
        case 0x30:
          if !isClockGenerator {
            year = Int(word - 0x3000)
          }
        case 0x40:
          if !isClockGenerator {
            rate = Double(openLCBClockRate: word - 0x4000)
          }
        case 0x80, 0x90:
          if isClockGenerator {
            let hour = Int(byte6 - 0x80)
            let minute = Int(byte7)
            time = (hour: hour, minute: minute, second: 0)
            let eventId = type.rawValue | UInt64(hour << 8) | UInt64(minute)
            lastEvents[OpenLCBFastClockEventIndex.reportTimeEvent.rawValue] = eventId
            node.networkLayer?.sendEvent(sourceNodeId: node.nodeId, eventId: eventId)
            startSyncTimer()
          }
        case 0xa0:
          if isClockGenerator {
            let month = Int(byte6 - 0xa0)
            let day = Int(byte7)
            monthDay = (month: month, day: day)
            let eventId = type.rawValue | 0x2000 | UInt64(month << 8) | UInt64(day)
            lastEvents[OpenLCBFastClockEventIndex.reportDateEvent.rawValue] = eventId
            node.networkLayer?.sendEvent(sourceNodeId: node.nodeId, eventId: eventId)
            startSyncTimer()
          }
        case 0xb0:
          if isClockGenerator {
            year = Int(word - 0xb000)
            let eventId = type.rawValue | 0x3000 | UInt64(year)
            lastEvents[OpenLCBFastClockEventIndex.reportYearEvent.rawValue] = eventId
            node.networkLayer?.sendEvent(sourceNodeId: node.nodeId, eventId: eventId)
            startSyncTimer()
          }
        case 0xc0:
          if isClockGenerator {
            rate = Double(openLCBClockRate: word - 0xc000)
            let eventId = type.rawValue | 0x4000 | UInt64(word)
            lastEvents[OpenLCBFastClockEventIndex.reportRateEvent.rawValue] = eventId
            node.networkLayer?.sendEvent(sourceNodeId: node.nodeId, eventId: eventId)
            startSyncTimer()
          }
        case 0xf0:
          switch word {
          case 0xf000:
            if isClockGenerator {
              sendSync()
            }
          case 0xf001:
            stop()
          case 0xf002:
            start()
          case 0xf003:
            break // TODO: Date rollover
          default:
            break
          }
          
        default:
          break
        }
        
      }
    default:
      break
    }
    
  }

  
}
