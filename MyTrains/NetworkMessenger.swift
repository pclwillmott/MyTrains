//
//  NetworkMessenger.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/10/2021.
//

import Foundation
import ORSSerial

public protocol NetworkMessengerDelegate {
  func NetworkMessageReceived(message:NetworkMessage)
  func NetworkTimeOut(message:NetworkMessage)
}

enum TIMING {
  static let STANDARD = 30.0 / 1000.0
}

enum MessengerState {
  case idle
  case spacing
  case waitingForResponse
}

public class NetworkMessenger : NSObject, ORSSerialPortDelegate {

  // Constructor
  
  init(id:String, path:String) {
    self.id = id
    _devicePath = path
    super.init()
    if let sp = ORSSerialPort(path: path) {
      sp.delegate = self
      sp.baudRate = 57600
      sp.numberOfDataBits = 8
      sp.numberOfStopBits = 1
      sp.parity = .none
      sp.usesRTSCTSFlowControl = false
      sp.usesDTRDSRFlowControl = false
      sp.usesDCDOutputFlowControl = false
      serialPort = sp
      sp.open()
    }
  }
  
  // Private Properties
  
  private var serialPort : ORSSerialPort? = nil
  private var buffer : [UInt8] = [UInt8](repeating: 0x00, count:256)
  private var readPtr : Int = 0
  private var writePtr : Int = 0
  private var bufferCount : Int = 0
  private var bufferLock : NSLock = NSLock()
  
  private var loconetSlots = [LoconetSlot?](repeating: nil, count: 120)
  
  private var outputQueue : [NetworkOutputQueueItem] = []
  private var outputQueueLock : NSLock = NSLock()
  private var outputTimer : Timer?
  
  private var observers : [Int:NetworkMessengerDelegate] = [:]
  private var nextObserverKey : Int = 0
  private var nextObserverKeyLock : NSLock = NSLock()
  
  public func addObserver(observer:NetworkMessengerDelegate) -> Int {
    nextObserverKeyLock.lock()
    let id : Int = nextObserverKey
    nextObserverKey += 1
    nextObserverKeyLock.unlock()
    observers[id] = observer
    return id
  }
  
  private var _devicePath : String
  
  public var devicePath : String {
    get {
      return _devicePath
    }
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
        
         serialPort?.send(Data(item!.message.message))
          
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
      else {
        print("here")
      }

    }
    
    outputQueueLock.unlock()
    
    delegate?.NetworkTimeOut(message: item!.message)
    
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
  
  private var messengerState : MessengerState = .idle
  
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
    
  // Public Properties
  
  public var id : String
  
  // public methods
  
  public func powerOn() {
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_GPON.rawValue], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: nil, retryCount: 1)
    
  }
  
  public func powerOff() {
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_GPOFF.rawValue], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: nil, retryCount: 1)

  }
  
  public func powerIdle() {
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_IDLE.rawValue], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: nil, retryCount: 1)

  }
  public func discoverDevices() {
    //0x01
//    let message = NetworkMessage.formLoconetMessage(opCode: .OPC_PEER_XFER, data: Data([0x14, 0x0f, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))
    
//    addToQueue(message: message)

  }
  
  public func requestSlotInfo(address:UInt8) {
    
//    let message = NetworkMessage.formLoconetMessage(opCode: .OPC_LOCO_ADR, data: Data([0x00, address]))
    
//    addToQueue(message: message)

  }
  
  public func setLocoSound(slotNumber:UInt8) {
    
//    let message = NetworkMessage.formLoconetMessage(opCode: .OPC_LOCO_SND, data: Data([slotNumber, loconetSlots[Int(slotNumber)]!.slotByte(byte: .slotSound)]))
    
//    addToQueue(message: message)

  }
  
  public func setLocoDirF(slotNumber:UInt8) {
    
//    let message = NetworkMessage.formLoconetMessage(opCode: .OPC_LOCO_DIRF, data: Data([slotNumber, loconetSlots[Int(slotNumber)]!.slotByte(byte: .slotDirF)]))
    
//    addToQueue(message: message)

  }
  
  public func setLocoSpeed(slotNumber:UInt8) {
    
 //   let message = NetworkMessage.formLoconetMessage(opCode: .OPC_LOCO_SPD, data: Data([slotNumber, loconetSlots[Int(slotNumber)]!.slotByte(byte: .slotSpeed)]))
    
//    addToQueue(message: message)

  }
  
  public func nullMove(slotNumber:UInt8) {
    
//    let message = NetworkMessage.formLoconetMessage(opCode: .OPC_MOVE_SLOTS, data: Data([slotNumber, slotNumber]))
    
//    addToQueue(message: message)

  }
  
  // ORSSerialPortDelegate Methods
  
  public func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
    self.serialPort = nil
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
        print("skip: \(String(format: "%02x", cc))")
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
                delegate?.NetworkMessageReceived(message: networkMessage)
              }

              for observer in observers {
                observer.value.NetworkMessageReceived(message: networkMessage)
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
