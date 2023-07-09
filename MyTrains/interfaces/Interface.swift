//
//  Interface.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/12/2021.
//

import Foundation

public class Interface : LocoNetDevice, MTSerialPortDelegate {
  
  // MARK: Destructors
  
  deinit {
    if isOpen {
      close()
    }
  }
  
  // MARK: Private Properties
  
  internal var serialPort : MTSerialPort?
  
  internal var buffer : [UInt8] = [UInt8](repeating: 0x00, count:0x1000)
  
  internal var readPtr : Int = 0
  
  internal var writePtr : Int = 0
  
  internal var bufferCount : Int = 0
  
  internal var bufferLock : NSLock = NSLock()
  
  internal var observers : [Int:InterfaceDelegate] = [:]
  
  internal var nextObserverKey : Int = 0
  
  internal var nextObserverKeyLock : NSLock = NSLock()
  
  internal var lastTimeStamp : TimeInterval = Date.timeIntervalSinceReferenceDate

  // MARK: Public Properties
  
  public var isConnected : Bool {
    get {
      return serialPort != nil
    }
  }
  
  public var isOpen : Bool {
    if let port = serialPort {
      return port.isOpen
    }
    return false
  }
  
  // MARK: Private Methods
  
  internal func parseInput() {
  }
  
  internal func addToInputBuffer(data:[UInt8]) {
    
    bufferLock.lock()
    
    bufferCount += data.count
    
    for x in data {
      buffer[writePtr] = x
      writePtr = (writePtr + 1) & 0xfff
    }
    
    bufferLock.unlock()

    parseInput()

  }
  
  // MARK: Public Methods
      
  public func addObserver(observer:InterfaceDelegate) -> Int {
    nextObserverKeyLock.lock()
    let id : Int = nextObserverKey
    nextObserverKey += 1
    nextObserverKeyLock.unlock()
    observers[id] = observer
    return id
  }
  
  public func removeObserver(id:Int) {
    observers.removeValue(forKey: id)
  }
  
  public func open() {
    
    if let port = MTSerialPort(path: devicePath) {
      port.baudRate = baudRate
      port.numberOfDataBits = 8
      port.numberOfStopBits = 1
      port.parity = .none
      port.usesRTSCTSFlowControl = flowControl == .rtsCts
      port.delegate = self
      port.open()
      serialPort = port
    }

  }
  
  public func close() {
    serialPort?.close()
    serialPort = nil
  }
  
  public func send(data: [UInt8]) {
    serialPort?.write(data:data)
  }

  public func send(data:String) {
    serialPort?.write(data:[UInt8](data.utf8))
  }

  // MARK: MTSerialPortDelegate Methods
  
  public func serialPort(_ serialPort: MTSerialPort, didReceive data: [UInt8]) {
    addToInputBuffer(data: data)
  }
  
  public func serialPortWasRemovedFromSystem(_ serialPort: MTSerialPort) {
    for (_, observer) in observers {
      observer.interfaceWasDisconnected?(interface: self)
    }
  }
  
  public func serialPortWasOpened(_ serialPort: MTSerialPort) {
    self.serialPort = serialPort
    for (_, observer) in observers {
      observer.interfaceWasOpened?(interface: self)
    }
  }
  
  public func serialPortWasClosed(_ serialPort: MTSerialPort) {
    self.serialPort = nil
    for (_, observer) in observers {
      observer.interfaceWasClosed?(interface: self)
    }
  }

}
