//
//  Programmer.swift
//  MyTrains
//
//  Created by Paul Willmott on 06/03/2022.
//

import Foundation

public enum ProgrammerType {
  case commandStation
  case programmer
}

@objc public protocol ProgrammerDelegate {
  @objc optional func progMessageReceived(message:NetworkMessage)
}

public class Programmer : NSObject, NetworkMessengerDelegate, CommandStationDelegate {
  
  // MARK: Constructors
  
  public init(commandStation: CommandStation) {
    _programmerType = .commandStation
    self._commandStation = commandStation
    super.init()
    _commandStationDelegateId = commandStation.addDelegate(delegate: self)
  }
  
  public init(programmer: NetworkMessenger) {
    _programmerType = .programmer
    self._programmer = programmer
    super.init()
    _messengerDelegateId = programmer.addObserver(observer: self)
  }
  
  // MARK: Destructors
  
  deinit {
    
    if _commandStationDelegateId != -1 {
      _commandStation?.removeDelegate(id: _commandStationDelegateId)
    }
    
    if _messengerDelegateId != -1 {
      _programmer?.removeObserver(id: _messengerDelegateId)
    }
    
  }
  
  // MARK: Private Properties
  
  private var _programmerType : ProgrammerType
  
  private var _commandStation : CommandStation?
  
  private var _programmer : NetworkMessenger?
  
  private var _savedProgrammerMode : ProgrammerMode = .MS100TerminationDisabled
  
  private var _nextObserverId : Int = 1
  
  private var _observers : [Int:ProgrammerDelegate] = [:]
  
  private var _observerLock : NSLock = NSLock()
  
  private var _commandStationDelegateId : Int = -1
  
  private var _messengerDelegateId : Int = -1
  
  // MARK: Public Properties
  
  public var programmerType : ProgrammerType {
    get {
      return _programmerType
    }
  }
  
  public var name : String {
    get {
      return programmerType == .programmer ? _programmer!.comboName : _commandStation!.commandStationName
    }
  }
  
  // MARK: Private Methods
  
  private func progMessage(message:NetworkMessage) {
    for kv in _observers {
      kv.value.progMessageReceived?(message: message)
    }
  }
  
  // MARK: Public Methods
  
  public func addDelegate(delegate: ProgrammerDelegate) -> Int {
//    _observerLock.lock()
    let id = _nextObserverId
    _nextObserverId += 1
    _observers[id] = delegate
//    _observerLock.unlock()
    return id
  }
  
  public func removeDelegate(id: Int) {
//    _observerLock.lock()
    _observers.removeValue(forKey: id)
//    _observerLock.unlock()
  }
  
  public func readCV(progMode: ProgrammingMode, cv:Int, address: Int) {
    DispatchQueue.main.async {
      self.programmerType == .programmer ? self._programmer?.readCV(progMode: progMode, cv: cv, address: address) : self._commandStation?.readCV(progMode: progMode, cv: cv, address: address)
    }
  }
    
  public func writeCV(progMode: ProgrammingMode, cv:Int, address: Int, value:Int) {
    DispatchQueue.main.async {
      self.programmerType == .programmer ? self._programmer?.writeCV(progMode: progMode, cv: cv, address: address, value: value) : self._commandStation?.writeCV(progMode: progMode, cv: cv, address: address, value: value)
    }
  }
  
  public func enterProgMode() {
    if let programmer = _programmer {
      _savedProgrammerMode = programmer.lastProgrammerMode
//      programmer.setProgMode(mode: .ProgrammerMode)
    }
  }
  
  public func exitProgMode() {
    if let programmer = _programmer {
 //     programmer.setProgMode(mode: .MS100TerminationDisabled)
    }
  }
  
  public func getProgSlotDataP1() {
    DispatchQueue.main.async {
      self.programmerType == .programmer ? self._programmer?.getProgSlotDataP1() : self._commandStation?.getProgSlotDataP1()
    }
  }
  
  // MARK: NetworkMessengerDelegate Methods
  
  @objc public func networkMessageReceived(message:NetworkMessage) {
    if programmerType == .commandStation {
      return
    }
    switch message.messageType {
    case.progCmdAcceptedBlind, .progSlotDataP1, .progCmdAccepted:
      DispatchQueue.main.async {
        self.progMessage(message: message)
      }
    default:
      break
    }
  }
  
  // MARK: CommandStationDelegate Methods
  
  @objc public func progMessageReceived(message:NetworkMessage) {
    if programmerType == .programmer {
      return
    }
    progMessage(message: message)
  }

  // MARK: Class Methods
  
  public static func programmers() -> [Programmer] {
    
    var result : [Programmer] = []
    
    for kv in networkController.commandStations {
      if kv.value.messengers.count > 0 {
        let programmer = Programmer(commandStation: kv.value)
        result.append(programmer)
      }
    }
    
    for messenger in networkController.networkMessengers {
      if messenger.interface.productCode == ProductCode.PR4 {
        if messenger.isOpen {
          let programmer = Programmer(programmer: messenger)
          result.append(programmer)
        }
      }
    }
    
    return result.sorted {$0.name < $1.name}
    
  }

}

