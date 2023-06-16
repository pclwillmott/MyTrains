//
//  FastClock.swift
//  MyTrains
//
//  Created by Paul Willmott on 04/12/2022.
//

import Foundation

public protocol FastClockDelegate {
  func fastClockTick(fastClock:FastClock)
}

public class FastClock {
  
  // MARK: Constructors & Destructors
  
  public init() {
    
    epoch = UserDefaults.standard.double(forKey: DEFAULT.FAST_CLOCK_EPOCH)
    
    referenceTime = UserDefaults.standard.double(forKey: DEFAULT.FAST_CLOCK_REFERENCE_TIME)
    
    scaleFactor = FastClockScaleFactor(rawValue:  UserDefaults.standard.integer(forKey: DEFAULT.FAST_CLOCK_SCALE_FACTOR)) ?? FastClockScaleFactor.defaultValue
    
    startTimer()
    
  }
  
  deinit {
    stoptimer()
  }
  
  // MARK: Private Properties
  
  private var timer : Timer?
  
  private var observers : [Int:FastClockDelegate] = [:]
  
  private var nextObserverId : Int = 0
  
  // MARK: Public Properties
  
  // UTC time of what clock should show when set
  public var epoch : TimeInterval {
    didSet {
      UserDefaults.standard.set(epoch, forKey: DEFAULT.FAST_CLOCK_EPOCH)
      startTimer()
    }
  }
  
  // UTC time when clock set
  public var referenceTime : TimeInterval {
    didSet {
      UserDefaults.standard.set(referenceTime, forKey: DEFAULT.FAST_CLOCK_REFERENCE_TIME)
      startTimer()
    }
  }
  
  public var scaleFactor : FastClockScaleFactor {
    didSet {
      UserDefaults.standard.set(scaleFactor.rawValue, forKey: DEFAULT.FAST_CLOCK_SCALE_FACTOR)
      startTimer()
    }
  }
  
  public var scaleTime : TimeInterval {
    get {
      let date = Date()
      let tsince = date.timeIntervalSince1970
      let tscale = (tsince - referenceTime) * Double(scaleFactor.rawValue)
      let newTime = referenceTime + tscale + (epoch - referenceTime)
      return newTime
    }
  }
  
  public var scaleDate : Date {
    get {
      return Date(timeIntervalSince1970: scaleTime)
    }
  }
  
  public var scaleTimeDecoded : (day:DayOfWeek, hour:Int, minute:Int, seconds:Int) {
    get {
      /*
      var sec = Int(scaleTime)
      let days = sec / 86400
      let d = (days + 3) % 7
      let day = DayOfWeek(rawValue: d) ?? DayOfWeek.defaultValue
      sec -= days * 86400
      let hr = sec / 3600
      sec -= hr * 3600
      let min = sec / 60
      sec -= min * 60
      */
      
      let date = Date(timeIntervalSince1970: scaleTime)
      let components = date.dateComponents
      
      let day = DayOfWeek(rawValue: components.weekday!) ?? .defaultValue
      let hr = components.hour!
      let min = components.minute!
      let sec = components.second!
      
      return (day:day, hour:hr, minute:min, seconds:sec)
      
    }
  }
  
  public var isEnabled : Bool = true {
    didSet {
      
    }
  }
  
  public var displayTime : String {
    let dec = scaleTimeDecoded
    let ft = String(format: "%02i:%02i:%02i", dec.hour,dec.minute,dec.seconds)
    return "\(dec.day.title.prefix(3)) \(ft)"
  }
  
  // MARK: Private Methods
  
  @objc func timerAction() {
    
    for (_, observer) in observers {
      observer.fastClockTick(fastClock: self)
    }
    
    let dec = scaleTimeDecoded
    
    if false && isEnabled && dec.seconds == 0 {
      
      let data : [UInt8] =
      [
        LocoNetMessageOpcode.OPC_SL_RD_DATA.rawValue,
        0x0e,
        0x7b,
        UInt8(scaleFactor.rawValue),
        0x7f,
        0x7f,
        UInt8((255 - (60 - dec.minute)) & 0x7f),
        0x00,
        UInt8((256 - (24 - dec.hour)) & 0x7f),
        UInt8(dec.day.rawValue),
        0x40,
        0x7f,
        0x7f,
      ]
      
      
      if let layout = myTrainsController.layout {
        for network in layout.networks {
          if let interface = network.interface as? InterfaceLocoNet {
            let message = LocoNetMessage(networkId: interface.networkId, data: data, appendCheckSum: true)
            interface.addToQueue(message: message, delay: MessageTiming.STANDARD)
          }
        }
      }
      
    }
    
  }
  
  func startTimer() {
    
    stoptimer()
    
    guard scaleFactor != .off else {
      return
    }
    
    let interval : TimeInterval = 1.0 / Double(scaleFactor.rawValue)
    
    timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    
    RunLoop.current.add(timer!, forMode: .common)
    
  }
  
  func stoptimer() {
    timer?.invalidate()
    timer = nil
  }
  
  // MARK: Public Methods

  public func addObserver(observer:FastClockDelegate) -> Int {
    let id = nextObserverId
    nextObserverId += 1
    observers[id] = observer
    return id
  }
  
  public func removeObserver(observerId:Int) {
    observers[observerId] = nil
  }
  
}
