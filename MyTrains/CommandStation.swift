//
//  CommandStation.swift
//  MyTrains
//
//  Created by Paul Willmott on 18/12/2021.
//

import Foundation

public protocol CommandStationDelegate {
  func trackStatusChanged(commandStation:CommandStation)
}

public class CommandStation : NetworkMessengerDelegate {
  
  init(message:IPLDevData) {
    productCode = message.productCode
    serialNumber = message.serialNumber
    softwareVersion = message.softwareVersion
  }
  
  public var manufacturer : Manufacturer = .unknown
  
  public var productCode : ProductCode = .unknown
  
  public var serialNumber : Int = -1
  
  public var hardwareVersion : Double = -1.0
  
  public var softwareVersion : Double = -1.0
  
  private var _interfaces : [String:NetworkMessenger] = [:]
  
  private var _observerId : [String:Int] = [:]
  
  public func addInterface(interface:NetworkMessenger) {
    if let _ = _interfaces[interface.id] {
    }
    else {
      _interfaces[interface.id] = interface
      _observerId[interface.id] = interface.addObserver(observer: self)
    }
  }
  
  public func removeInterface(interface:NetworkMessenger) {
    interface.removeObserver(id: _observerId[interface.id]!)
    _interfaces.removeValue(forKey: interface.id)
    _observerId.removeValue(forKey: interface.id)
  }
  
  public func messengerRemoved(id: String) {
    _interfaces.removeValue(forKey: id)
    _observerId.removeValue(forKey: id)
  }
  
  public func networkMessageReceived(message: NetworkMessage) {
    switch message.messageType {
    case .cfgSlotDataP1, .locoSlotDataP1, .fastClockDataP1:
      let trk = message.message[7]
      implementsProtocol2    = (trk & 0b0100000) == 0b0100000
      programmingTrackIsBusy = (trk & 0b0001000) == 0b0001000
      implementsProtocol1    = (trk & 0b0000100) == 0b0000100
      trackIsPaused          = (trk & 0b0000010) == 0b0000010
      powerIsOn              = (trk & 0b0000001) == 0b0000001
      break
    default:
      break
    }
  }
  
  public func networkTimeOut(message: NetworkMessage) {
    
  }
  
  private var _implementsProtocol1 : Bool?
  private var _implementsProtocol2 : Bool?
  private var _programmingTrackIsBusy : Bool?
  private var _trackIsPaused : Bool?
  private var _powerIsOn : Bool?
  
  private var _delegates : [Int:CommandStationDelegate] = [:]
  private var _nextDelegateId = 0
  private var _delegateLock : NSLock = NSLock()

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
      return _trackIsPaused ?? false
    }
    set(value) {
      var changed = true
      if let x = _trackIsPaused {
        changed = x == value
      }
      _trackIsPaused = value
      if changed {
        for delegate in _delegates {
          delegate.value.trackStatusChanged(commandStation: self)
        }
      }
    }
  }
  
  public var powerIsOn : Bool {
    get {
      return _powerIsOn ?? false
    }
    set(value) {
      var changed = true
      if let x = _powerIsOn {
        changed = x == value
      }
      _powerIsOn = value
      if changed {
        for delegate in _delegates {
          delegate.value.trackStatusChanged(commandStation: self)
        }
      }
    }
  }

}
