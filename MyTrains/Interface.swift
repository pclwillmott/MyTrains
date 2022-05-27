//
//  Interface.swift
//  MyTrains
//
//  Created by Paul Willmott on 30/12/2021.
//

import Foundation
import Cocoa

enum InterfaceState {
  case idle
  case spacing
  case waitingForResponse
}

@objc public protocol SlotObserverDelegate {
  @objc optional func slotsUpdated(commandStation:CommandStation)
}

public class Interface : LocoNetDevice, MTSerialPortDelegate {
  
  // MARK: Constructors
  
  // MARK: Destructors
  
  deinit {
    close()
  }
  
  // MARK: Private Properties
  
  private var serialPort : MTSerialPort?
  
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

  internal var _locoSlots : [Int:LocoSlotData] = [:]
  
  private var slotObservers : [Int:SlotObserverDelegate] = [:]
  
  private var nextSlotObserverId = 0
  
  private var slotObserverLock : NSLock = NSLock()
  
  // MARK: Public Properties
  
  public var opSwBankA : NetworkMessage?
  
  public var opSwBankB : NetworkMessage?
  
  public var globalSystemTrackStatus : UInt8?
  
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
  
  override public var locoNetProductId: LocoNetProductId {
    get {
      return super.locoNetProductId
    }
    set(value) {
      super.locoNetProductId = value
      if let info = locoNetProductInfo, info.attributes.contains(.CommandStation) {
        commandStation = self
      }
    }
  }
  
  public var partialSerialNumberLow : Int = -1
  
  public var partialSerialNumberHigh : Int = -1
  
  public var commandStation : Interface?
  
  // MARK: Private Methods
  
  private func slotsUpdated() {
    for kv in slotObservers {
      kv.value.slotsUpdated?(commandStation: self)
    }
  }
  
  private func networkMessageReceived(message: NetworkMessage) {
    
    switch message.messageType {
      
    case .iplDevData:
      
      let iplDevData = IPLDevData(message: message)
      
      var newDevice = true
      
      for kv in networkController.locoNetDevices {
        
        let device = kv.value
        
        if let info = device.locoNetProductInfo, info.productCode == iplDevData.productCode &&
            device.serialNumber == iplDevData.serialNumber {
          
          newDevice = false
          
          device.softwareVersion = iplDevData.softwareVersion
          device.boardId = iplDevData.boardId
          device.networkId = message.networkId
          
          device.save()
          
        }
        
      }
      
      if newDevice {
        
        if let info = iplDevData.productCode.product() {
          
          let device = LocoNetDevice(primaryKey: -1)
          
          device.networkId = message.networkId
          device.boardId = iplDevData.boardId
          device.softwareVersion = iplDevData.softwareVersion
          device.serialNumber = iplDevData.serialNumber
          device.locoNetProductId = info.id
          
          device.save()
          
          networkController.addDevice(device: device)
          
        }
        
      }
    
    case .opSwDataAP1:
      commandStation?.opSwBankA = message
      commandStation?.globalSystemTrackStatus = message.message[7]
      
    case .opSwDataBP1:
      commandStation?.opSwBankB = message
      commandStation?.globalSystemTrackStatus = message.message[7]
     
    case .fastClockDataP1:
      commandStation?.globalSystemTrackStatus = message.message[7]
      
    case .locoSlotDataP1:
      commandStation?.globalSystemTrackStatus = message.message[7]
      let slot = LocoSlotData(locoSlotDataP1: LocoSlotDataP1(networkId: self.networkId, data: message.message))
      _locoSlots[slot.slotID] = slot
      slotsUpdated()

    case .locoSlotDataP2:
      commandStation?.globalSystemTrackStatus = message.message[7]
      let slot = LocoSlotData(locoSlotDataP2: LocoSlotDataP2(networkId: self.networkId, data: message.message))
      _locoSlots[slot.slotID] = slot
      slotsUpdated()

    default:
      break
    }
    
  }
  
  private func sendMessage() {
    
    var startTimer = false
    
    var delay : TimeInterval = 0.0
    
    var timeout : NetworkMessage?
    
    outputQueueLock.lock()
    
    if outputQueue.count > 0 && interfaceState == .idle {
        
      let item = outputQueue[0]
      
      if item.retryCount > 0 {
      
        send(data: item.message.message)
        
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
  
  public func addSlotObserver(observer:SlotObserverDelegate) -> Int {
    slotObserverLock.lock()
    let id = nextSlotObserverId
    nextSlotObserverId += 1
    slotObservers[id] = observer
    slotObserverLock.unlock()
    return id
  }
  
  public func removeSlotObserver(id:Int) {
    slotObserverLock.lock()
    slotObservers.removeValue(forKey: id)
    slotObserverLock.unlock()
  }

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
    
    if let port = MTSerialPort(path: devicePath) {
      port.baudRate = baudRate
      port.numberOfDataBits = 8
      port.numberOfStopBits = 1
      port.parity = .none
      port.usesRTSCTSFlowControl = flowControl == .rtsCts
 //     port.usesDTRDSRFlowControl = false
 //     port.usesDCDOutputFlowControl = false
      port.delegate = self
      port.open()
    }
  
  }
  
  public func close() {
    serialPort?.close()
  }
  
  public func send(data: [UInt8]) {
    serialPort?.write(data:data)
  }
  
  // MARK: MTSerialPortDelegate Methods
  
  public func serialPort(_ serialPort: MTSerialPort, didReceive data: [UInt8]) {
    
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

              networkMessageReceived(message: networkMessage)
              
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
  
  public func serialPortWasRemovedFromSystem(_ serialPort: MTSerialPort) {
    
  }
  
  public func serialPortWasOpened(_ serialPort: MTSerialPort) {
    self.serialPort = serialPort
    for observer in observers {
      observer.value.interfaceWasOpened?(interface: self)
    }
    iplDiscover()
  }
  
  public func serialPortWasClosed(_ serialPort: MTSerialPort) {
    self.serialPort = nil
    for observer in observers {
      observer.value.interfaceWasClosed?(interface: self)
    }
  }

  public static var interfaceDevices : [Int:Interface] {
    
    get {
    
      let conn = Database.getConnection()
      
      let shouldClose = conn.state != .Open
       
      if shouldClose {
        _ = conn.open()
      }
       
      let cmd = conn.createCommand()
       
      cmd.commandText = "SELECT \(columnNames) FROM [\(TABLE.LOCONET_DEVICE)] ORDER BY [\(NETWORK.LOCONET_DEVICE_ID)]"

      var result : [Int:Interface] = [:]
      
      if let reader = cmd.executeReader() {
           
        while reader.read() {
          
          let device = Interface(reader: reader)
          
          if let info = device.locoNetProductInfo {
            if info.attributes.contains(.ComputerInterface) {
              result[device.primaryKey] = device
            }
          }
          
        }
           
        reader.close()
           
      }
      
      if shouldClose {
        conn.close()
      }

      return result
      
    }
    
  }
  
}
