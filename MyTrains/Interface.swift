//
//  Interface.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/12/2021.
//

import Foundation
import ORSSerial
import Cocoa

enum InterfaceState {
  case idle
  case spacing
  case waitingForResponse
}

public class Interface : LocoNetDevice, ORSSerialPortDelegate  {
  
  // MARK: Constructors
  
  init(device:LocoNetDevice) {
    super.init(primaryKey: device.primaryKey)
    self.networkId = device.networkId
    self.serialNumber = device.serialNumber
    self.softwareVersion = device.softwareVersion
    self.hardwareVersion = device.hardwareVersion
    self.boardId = device.boardId
    self.locoNetProductId = device.locoNetProductId
    self.optionSwitches0 = device.optionSwitches0
    self.optionSwitches1 = device.optionSwitches1
    self.optionSwitches2 = device.optionSwitches2
    self.optionSwitches3 = device.optionSwitches3
    self.devicePath = device.devicePath
    self.baudRate = device.baudRate
    self.deviceName = device.deviceName
    self.flowControl = device.flowControl
    self.isStandAloneLoconet = device.isStandAloneLoconet
  }

  // MARK: Destructors
  
  deinit {
    close()
    serialPort = nil
  }
  
  // MARK: Private Properties
  
  @objc dynamic private var serialPort : ORSSerialPort?
  
  private var buffer : [UInt8] = [UInt8](repeating: 0x00, count:256)
  
  private var readPtr : Int = 0
  
  private var writePtr : Int = 0
  
  private var bufferCount : Int = 0
  
  private var bufferLock : NSLock = NSLock()
  
  private var outputQueue : [NetworkOutputQueueItem] = []
  
  private var outputQueueLock : NSLock = NSLock()
  
  private var outputTimer : Timer?
  
  private var observers : [Int:InterfaceDelegate] = [:]
  
  private var nextObserverKey : Int = 0
  
  private var nextObserverKeyLock : NSLock = NSLock()
  
  private var interfaceState : InterfaceState = .idle

  // MARK: Public Properties
  
  public var interfaceName : String {
    get {
      if let info = locoNetProductInfo {
        return "\(info.productName) SN: \(serialNumber)"
      }
      return deviceName
    }
  }
  
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
  
  public var partialSerialNumberLow : Int = -1
  
  public var partialSerialNumberHigh : Int = -1
  
  // MARK: Private Methods
  
  private func sendMessage() {
    
    var startTimer = false
    
    var delay : TimeInterval = 0.0
    
    var timeout : NetworkMessage?
    
    outputQueueLock.lock()
    
    if outputQueue.count > 0 && interfaceState == .idle {
        
      let item = outputQueue[0]
      
      if item.retryCount > 0 {
      
        send(data: Data(item.message.message))
        
        if item.responseExpected {
          interfaceState = .waitingForResponse
        }
        else {
          interfaceState = .spacing
          outputQueue.remove(at: 0)
        }
        
        item.retryCount -= 1
          
        delay = item.delay
        
        startTimer = true
        
      }
      else {
        
        if item.timeoutCode != .none {
          timeout = NetworkMessage(networkId: networkId, timeoutCode: item.timeoutCode)
        }
        
        outputQueue.remove(at: 0)

      }

    }
    
    outputQueueLock.unlock()
    
    if let timeoutMessage = timeout {
      for observer in observers {
        observer.value.networkMessageReceived?(message: timeoutMessage)
      }
    }
    
    if startTimer {
      startSpacingTimer(timeInterval: delay)
    }
    
  }
 
  @objc func spacingTimer() {
    stopSpacingTimer()
    outputQueueLock.lock()
    interfaceState = .idle
    outputQueueLock.unlock()
    sendMessage()
  }
  
  func startSpacingTimer(timeInterval:TimeInterval) {
    outputTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(spacingTimer), userInfo: nil, repeats: false)
  }
  
  func stopSpacingTimer() {
    outputTimer?.invalidate()
    outputTimer = nil
    outputQueueLock.lock()
    interfaceState = .idle
    outputQueueLock.unlock()
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
  
  override public func displayString() -> String {
    return interfaceName
  }
  
  public func addToQueue(message:NetworkMessage, delay:TimeInterval, responses: Set<NetworkMessageType>, retryCount: Int, timeoutCode: TimeoutCode) {
    
    let item = NetworkOutputQueueItem(message: message, delay: delay, responses: responses, retryCount: retryCount, timeoutCode: timeoutCode)
    
    outputQueueLock.lock()
    outputQueue.append(item)
    outputQueueLock.unlock()
    
    sendMessage()
    
  }
  
  public func addToQueue(message:NetworkMessage, delay:TimeInterval) {
    addToQueue(message: message, delay: delay, responses: [], retryCount: 0, timeoutCode: .none)
  }
  
  public func open() {
    
    close()
    
    if let port = ORSSerialPort(path: "/dev/cu.usbmodemDxP431751") {
      serialPort = port
      print(port.path)
    }
    
    if let port = serialPort {
      port.baudRate = baudRate.baudRate
      port.numberOfDataBits = 8
      port.numberOfStopBits = 1
      port.parity = .none
      port.usesRTSCTSFlowControl = false // .rtsCts
      port.usesDTRDSRFlowControl = false
      port.usesDCDOutputFlowControl = false
      port.delegate = self
      port.open()
    }
  
  }
  
  public func close() {
    serialPort?.close()
    serialPort = nil
  }
  
  public func send(data: Data) {
    serialPort?.send(data)
  }
  
  // MARK: ORSSerialPortDelegate Methods
  
  public func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
    print("err")
  }
  
  public func serialPortWasOpened(_ serialPort: ORSSerialPort) {
      print("Close")
    }
    
  public func serialPortWasClosed(_ serialPort: ORSSerialPort) {
      print("Open")
    }
 /*
  public func serialPortWasOpened(_ serialPort: ORSSerialPort) {
    print("port opened")
//    for observer in observers {
//      observer.value.interfaceWasOpened?(interface: self)
//    }
  }
  
  public func serialPortWasClosed(_ serialPort: ORSSerialPort) {
    print("port closed")
 //   for observer in observers {
 //     observer.value.interfaceWasClosed?(interface: self)
 //   }
  }
  */
  public func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
    print("port was removed")
    for observer in observers {
  //    observer.value.interfaceWasDisconnected?(interface: self)
    }
  }
  
  public func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
    
    print("rx data")
    bufferLock.lock()
    bufferCount += data.count
    for x in data {
      buffer[writePtr] = x
      writePtr = (writePtr + 1) & 0xff
    }
    bufferLock.unlock()

    var doAgain : Bool = true
    
    while doAgain {
      
      doAgain = false
      
      // find the start of a message
      
      var opCodeFound : Bool
      
      opCodeFound = false
      
      bufferLock.lock()
      while bufferCount > 0 {
        let cc = buffer[readPtr]
        if (cc != 0) {
          opCodeFound = true
          break
        }
        readPtr = (readPtr + 1) & 0xff
        bufferCount -= 1
      }
      bufferLock.unlock()
      
      if opCodeFound {
        
        var length = (buffer[readPtr] & 0b01100000) >> 5
        
        switch length {
        case 0b00 :
          length = 2
          break
        case 0b01 :
          length = 4
          break
        case 0b10 :
          length = 6
          break
        default :
          length = bufferCount > 1 ? buffer[(readPtr+1) & 0xff] : 0xff
          break
        }
        
        if length < 0xff && bufferCount >= length {
          
          var message : [UInt8] = [UInt8](repeating: 0x00, count:Int(length))
          
          var restart : Bool = false
          
          bufferLock.lock()
          
          var index : Int = 0
          
          while index < length {
            
            let cc = buffer[readPtr]
            
            // check that there are no high bits set in the data bytes
            
            if index > 0 && ((cc & 0x80) != 0x00) {
              restart = true
              break
            }
            
            message[index] = cc
            
            readPtr = (readPtr + 1) & 0xff
            index += 1
            bufferCount -= 1
            
          }
          
          // Do another loop if there are at least 2 bytes in the buffer
          
          doAgain = bufferCount > 1
          
          bufferLock.unlock()
          
          // Process message if no high bits set in data
          
          if !restart {
          
            let networkMessage = NetworkMessage(networkId: networkId, data: message)
            
            if networkMessage.checkSumOK && networkMessage.messageType != .busy {
              
              var stopTimer = false
              
              outputQueueLock.lock()
              
              if interfaceState == .waitingForResponse &&
                outputQueue[0].isValidResponse(messageType: networkMessage.messageType) {
                
                if networkMessage.messageType != .programmerBusy {
                  
                  outputQueue.remove(at: 0)
                  
                  interfaceState = .spacing
                  
                  stopTimer = true
                  
                }
              
              }
              
              outputQueueLock.unlock()
              
              if stopTimer {
                stopSpacingTimer()
              }

              for observer in observers {
                observer.value.networkMessageReceived?(message: networkMessage)
              }
              
              if stopTimer {
                sendMessage()
              }
              
            }

          }
          
        }

      }

    }

  }

}
