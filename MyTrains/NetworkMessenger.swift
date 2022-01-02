//
//  NetworkMessenger.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/10/2021.
//

import Foundation
import ORSSerial

public protocol NetworkMessengerDelegate {
  func networkMessageReceived(message:NetworkMessage)
  func networkTimeOut(message:NetworkMessage)
  func messengerRemoved(id:String)
}

public protocol NetworkInterfaceDelegate {
  func interfaceNotIdentified(messenger:NetworkMessenger)
  func interfaceIdentified(messenger:NetworkMessenger)
  func interfaceRemoved(messenger:NetworkMessenger)
  func statusChanged(messenger:NetworkMessenger)
}

enum TIMING {
  static let STANDARD = 30.0 / 1000.0
  static let DISCOVER = 1.0
}

enum MessengerState {
  case idle
  case spacing
  case waitingForResponse
}

public class NetworkMessenger : NSObject, ORSSerialPortDelegate, NetworkMessengerDelegate {
 
  // MARK: Constructor
  
  init(id:String, devicePath:String) {
    
    self.id = id

    if let interface = interfacesByDevicePath[devicePath] {
      self.interface = interface
    }
    else {
      self.interface = Interface(primaryKey: -1)
      self.interface.devicePath = devicePath
    }

    super.init()

    interface.delegate = self
    self.interface.messenger = self

    if !interface.isConnected {
      interface.open()
    }

  }
  
  // MARK: Destructor
  
  deinit {
    interface.close()
  }
  
  // MARK: Private Properties
  
  private var buffer : [UInt8] = [UInt8](repeating: 0x00, count:256)
  
  private var readPtr : Int = 0
  
  private var writePtr : Int = 0
  
  private var bufferCount : Int = 0
  
  private var bufferLock : NSLock = NSLock()
  
  private var setupLock : NSLock = NSLock()
  
  private var loconetSlots = [LoconetSlot?](repeating: nil, count: 120)
  
  private var outputQueue : [NetworkOutputQueueItem] = []
  
  private var outputQueueLock : NSLock = NSLock()
  
  private var outputTimer : Timer?
  
  private var observers : [Int:NetworkMessengerDelegate] = [:]
  
  private var nextObserverKey : Int = 0
  
  private var nextObserverKeyLock : NSLock = NSLock()
  
  private var messengerState : MessengerState = .idle

  private var observerId : Int = -1
  
  // MARK: Public Properties
  
  public var interface : Interface
  
  public var comboName : String {
    get {
      return interface.displayString()
    }
  }
  
  public var id : String

  public var networkInterfaceDelegate : NetworkInterfaceDelegate? = nil
  
  public var isOpen : Bool {
    get {
      return interface.isOpen
    }
  }
  
  public var isConnected : Bool {
    get {
      return interface.isConnected
    }
  }
  
  // MARK: Private Methods
  
  private func sendMessage() {
    
    outputQueueLock.lock()
    
    var item : NetworkOutputQueueItem?
    
    var delegate : NetworkMessengerDelegate? = nil
    
    var startTimer = false
    
    var delay : TimeInterval = 0.0
    
    if outputQueue.count > 0 {
      
      item = outputQueue[0]
      
      if messengerState == .idle {
        
        if item!.retryCount > 0 {
        
          interface.send(data: Data(item!.message.message))
          
          if item!.responseExpected {
            messengerState = .waitingForResponse
          }
          else {
            messengerState = .spacing
            outputQueue.remove(at: 0)
          }
          
          item!.retryCount -= 1
            
          delay = item!.delay
          
          startTimer = true
          
        }
        else {
          
          delegate = item!.delegate
          outputQueue.remove(at: 0)

        }
        
      }

    }
    
    outputQueueLock.unlock()
    
    delegate?.networkTimeOut(message: item!.message)
    
    if startTimer {
      startSpacingTimer(timeInterval: delay)
    }
    
  }
 
  // Spacing Timer
    
  @objc func spacingTimer() {
    stopSpacingTimer()
    outputQueueLock.lock()
    messengerState = .idle
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
    messengerState = .idle
    outputQueueLock.unlock()
  }
  
  private func decode() {
    
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
          
            let networkMessage = NetworkMessage(interfaceId:self.id, data: message)
            
            if networkMessage.checkSumOK && networkMessage.messageType != .busy {
              
              var stopTimer = false
              
              outputQueueLock.lock()
              
              var delegate : NetworkMessengerDelegate? = nil
              
              if messengerState == .waitingForResponse &&
                outputQueue[0].isValidResponse(messageType: networkMessage.messageType) {
                
                delegate = outputQueue[0].delegate
                
                outputQueue.remove(at: 0)
                
                messengerState = .spacing
                
                stopTimer = true
                
              }
              
              outputQueueLock.unlock()
              
              if stopTimer {
                stopSpacingTimer()
                delegate?.networkMessageReceived(message: networkMessage)
              }

              for observer in observers {
                observer.value.networkMessageReceived(message: networkMessage)
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

    
  // MARK: Public Methods
  
  public func addObserver(observer:NetworkMessengerDelegate) -> Int {
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
  
  public func addToQueue(message:NetworkMessage, delay:TimeInterval, response: [NetworkMessageType], delegate: NetworkMessengerDelegate?, retryCount: Int) {
    
    let item = NetworkOutputQueueItem(message: message, delay: delay, response: response, delegate: delegate, retryCount: retryCount)
    
    outputQueueLock.lock()
    outputQueue.append(item)
    outputQueueLock.unlock()
    
    sendMessage()
    
  }
  
  public func open() {
    interface.open()
  }
  
  public func close() {
    interface.close()
  }
  
  public func powerOn() {
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_GPON.rawValue], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: nil, retryCount: 1)
    
  }
  
  public func powerOff() {
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_GPOFF.rawValue], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: nil, retryCount: 1)

  }
  
  public func getCfgSlotDataP1() {
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_RQ_SL_DATA.rawValue, 0x7f, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: nil, retryCount: 1)

  }
  
  public func getLocoSlotDataP1(forAddress: Int) {
    
    let lo = UInt8(forAddress & 0x7f)
    
    let hi = UInt8(forAddress >> 7)
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_LOCO_ADR.rawValue, hi, lo], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [.locoSlotDataP1, .ack], delegate: nil, retryCount: 5)

  }
  
  public func getLocoSlotDataP2(forAddress: Int) {
    
    let lo = UInt8(forAddress & 0x7f)
    
    let hi = UInt8(forAddress >> 7)
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_LOCO_ADR_P2.rawValue, hi, lo], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [.locoSlotDataP2, .ack], delegate: nil, retryCount: 5)

  }
  
  public func moveSlotsP1(sourceSlotNumber: Int, destinationSlotNumber: Int) {
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_MOVE_SLOTS.rawValue, UInt8(sourceSlotNumber), UInt8(destinationSlotNumber)], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [.locoSlotDataP1, .ack], delegate: nil, retryCount: 5)

  }
  
  public func moveSlotsP2(sourceSlotNumber: Int, sourceSlotPage: Int, destinationSlotNumber: Int, destinationSlotPage: Int) {
    
    let srcPage = UInt8(sourceSlotPage & 0b00000111) | 0b00111000
    let dstPage = UInt8(destinationSlotPage & 0b00000111)
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_D4_GROUP.rawValue, srcPage, UInt8(sourceSlotNumber), dstPage, UInt8(destinationSlotNumber)], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [.locoSlotDataP2, .ack], delegate: nil, retryCount: 5)

  }
  
  public func getInterfaceData() {
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_BUSY.rawValue], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [.interfaceData], delegate: self, retryCount: 1)
    
  }
  
  public func powerIdle() {
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_IDLE.rawValue], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: nil, retryCount: 1)

  }
  
  // MARK: NetworkMessengerDelegate Methods
  
  public func messengerRemoved(id: String) {
  }
  
  public func networkMessageReceived(message: NetworkMessage) {
    if message.messageType == .interfaceData {
      if interface.serialNumber == -1 {
        interface.productCode = ProductCode(rawValue: Int(message.message[14])) ?? .unknown
        interface.partialSerialNumberLow = Int(message.message[6])
        interface.partialSerialNumberHigh = Int(message.message[7])
        interface.save()
        interfaces[interface.primaryKey] = interface
      }
      removeObserver(id: observerId)
      observerId = -1
      networkInterfaceDelegate?.interfaceIdentified(messenger: self)
    }
  }
  
  public func networkTimeOut(message: NetworkMessage) {
    if observerId != -1 {
      removeObserver(id: observerId)
      observerId = -1
      networkInterfaceDelegate?.interfaceNotIdentified(messenger: self)
    }
  }
  
  // MARK: ORSSerialPortDelegate Methods
  
  public func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
    if observerId != -1 {
      removeObserver(id: observerId)
      observerId = -1
    }
    for observer in observers {
      observer.value.messengerRemoved(id: self.id)
    }
    networkInterfaceDelegate?.interfaceRemoved(messenger: self)
    networkInterfaceDelegate?.statusChanged(messenger: self)
  }
  
  public func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
    if observerId != -1 {
      removeObserver(id: observerId)
      observerId = -1
    }
    networkInterfaceDelegate?.interfaceNotIdentified(messenger: self)
  }
  
  public func serialPortWasOpened(_ serialPort: ORSSerialPort) {
    observerId = addObserver(observer: self)
    getInterfaceData()
    networkInterfaceDelegate?.statusChanged(messenger: self)
  }
  
  public func serialPortWasClosed(_ serialPort: ORSSerialPort) {
    networkInterfaceDelegate?.statusChanged(messenger: self)
  }
  
  public func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
    bufferLock.lock()
    bufferCount += data.count
    for x in data {
      buffer[writePtr] = x
      writePtr = (writePtr + 1) & 0xff
    }
    bufferLock.unlock()
    decode()
  }
  
}
