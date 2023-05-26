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

public class OpenLCBClock : NSObject {
  
  // MARK: Constructors & Destructors
  
  public init(node:OpenLCBNodeMyTrains, type:OpenLCBClockType) {
    
    self.type = type
    
    self.node = node
    
    super.init()
    
    self.calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    
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
  
  private var observers : [Int:OpenLCBClockDelegate] = [:]
  
  private var nextObserverId : Int = 0
  
  private var clockDirection : ClockDirection = .forward
  
  private var calendar = Calendar(identifier: .gregorian)
  
  private let specificUpperPartMask : UInt64 = 0xffffffffffff0000

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

  // MARK: Public Methods
  
  private func sendSync() {
    
  }
  
  public func start() {
    
    guard state == .stopped else {
      return
    }
    
    _state = .running
    startTimer()
    
    if let network = node.networkLayer {
      if isClockGenerator {
        let eventId = type.rawValue | 0xffff
        network.sendProducerRangeIdentified(sourceNodeId: node.nodeId, eventId: eventId)
        network.sendConsumerRangeIdentified(sourceNodeId: node.nodeId, eventId: eventId)
      }
      else {
        let eventId = type.rawValue | 0xffff
        network.sendConsumerRangeIdentified(sourceNodeId: node.nodeId, eventId: eventId)
        network.sendClockQuery(sourceNodeId: node.nodeId, clockType: type)
      }
    }

  }
  
  public func stop() {
    
    guard state == .running else {
      return
    }
    
    _state = .stopped
    stoptimer()
    
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
          let hour = Int(byte6)
          let minute = Int(byte7)
          time = (hour: hour, minute: minute, second: 0)
        case 0x20:
          let month = Int(byte6 - 0x20)
          let day = Int(byte7)
          monthDay = (month: month, day: day)
        case 0x30:
          year = Int(word - 0x3000)
        case 0x40:
          var temp = word - 0x4000
          let isNegative = (temp & 0x0800) == 0x0800
          let fraction = Double(temp & 0b11) * 0.25
          temp >>= 2
          temp |= isNegative ? 0b1111110000000000 : 0
          let intValue = Int16(bitPattern: temp)
          rate = Double(intValue) + (isNegative ? (1.0 - fraction) : fraction)
        case 0x80, 0x90:
          let hour = Int(byte6 - 0x80)
          let minute = Int(byte7)
          time = (hour: hour, minute: minute, second: 0)
        case 0xa0:
          let month = Int(byte6 - 0xa0)
          let day = Int(byte7)
          monthDay = (month: month, day: day)
        case 0xb0:
          year = Int(word - 0xb000)
        case 0xc0:
          var temp = word - 0xc000
          let isNegative = (temp & 0x0800) == 0x0800
          let fraction = Double(temp & 0b11) * 0.25
          temp >>= 2
          temp |= isNegative ? 0b1111110000000000 : 0
          let intValue = Int16(bitPattern: temp)
          rate = Double(intValue) + (isNegative ? (1.0 - fraction) : fraction)
        case 0xF0:
          switch word {
          case 0xf000:
            break // TODO: QueryEventId
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
