//
//  NetworkMessenger.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/10/2021.
//

import Foundation
import ORSSerial

public protocol LoconetMessengerDelegate {
  func LoconetSensorMessageReceived(message:LoconetSensorMessage)
  func LoconetSwitchRequestMessageReceived(message:LoconetSwitchRequestMessage)
  func LoconetSlotDataMessageReceived(message:LoconetSlotDataMessage)
  func LoconetTurnoutOutputMessageReceived(message:LoconetTurnoutOutputMessage)
  func LoconetLongAcknowledgeMessageReceived(message:LoconetLongAcknowledgeMessage)
  func LoconetRequestSlotDataMessageReceived(message:LoconetRequestSlotDataMessage)
}

public protocol NetworkMessengerDelegate {
  func NetworkMessageReceived(message:NetworkMessage)
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
      startOutputQueue()
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
  
  private var outputQueue : [LoconetOutputQueueItem] = []
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
  
  // Output Queue Timer
    
  @objc func handleOutputQueue() {
    outputQueueLock.lock()
    if outputQueue.count > 0 {
      serialPort?.send(outputQueue[0].message)
      outputQueue.remove(at: 0)
    }
    outputQueueLock.unlock()
  }
  
  func addToQueue(message:Data) {
    let item = LoconetOutputQueueItem(message: message)
    outputQueueLock.lock()
    outputQueue.append(item)
    outputQueueLock.unlock()
  }
  
  func startOutputQueue() {
    outputTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(handleOutputQueue), userInfo: nil, repeats: true)
  }
  
  func stopOutputQueue() {
    outputTimer?.invalidate()
  }
    
  // Public Properties
  
  public var id : String
  
  public var delegate : LoconetMessengerDelegate? = nil
  
  // public methods
  
  public func powerOn() {
    
    let message = NetworkMessage.formLoconetMessage(opCode: .OPC_GPON, data: Data([]))
    
    addToQueue(message: message)
    
  }
  
  public func powerOff() {
    
    let message = NetworkMessage.formLoconetMessage(opCode: .OPC_GPOFF, data: Data([]))
    
    addToQueue(message: message)

  }
  
  public func powerIdle() {
    
    let message = NetworkMessage.formLoconetMessage(opCode: .OPC_IDLE, data: Data([]))
    
    addToQueue(message: message)

  }
  public func discoverDevices() {
    //0x01
    let message = NetworkMessage.formLoconetMessage(opCode: .OPC_PEER_XFER, data: Data([0x14, 0x0f, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]))
    
    addToQueue(message: message)

  }
  
  public func requestSlotInfo(address:UInt8) {
    
    let message = NetworkMessage.formLoconetMessage(opCode: .OPC_LOCO_ADR, data: Data([0x00, address]))
    
    addToQueue(message: message)

  }
  
  public func setLocoSound(slotNumber:UInt8) {
    
    let message = NetworkMessage.formLoconetMessage(opCode: .OPC_LOCO_SND, data: Data([slotNumber, loconetSlots[Int(slotNumber)]!.slotByte(byte: .slotSound)]))
    
    addToQueue(message: message)

  }
  
  public func setLocoDirF(slotNumber:UInt8) {
    
    let message = NetworkMessage.formLoconetMessage(opCode: .OPC_LOCO_DIRF, data: Data([slotNumber, loconetSlots[Int(slotNumber)]!.slotByte(byte: .slotDirF)]))
    
    addToQueue(message: message)

  }
  
  public func setLocoSpeed(slotNumber:UInt8) {
    
    let message = NetworkMessage.formLoconetMessage(opCode: .OPC_LOCO_SPD, data: Data([slotNumber, loconetSlots[Int(slotNumber)]!.slotByte(byte: .slotSpeed)]))
    
    addToQueue(message: message)

  }
  
  public func nullMove(slotNumber:UInt8) {
    
    let message = NetworkMessage.formLoconetMessage(opCode: .OPC_MOVE_SLOTS, data: Data([slotNumber, slotNumber]))
    
    addToQueue(message: message)

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
          
            let loconetMessage = NetworkMessage(interfaceId:self.id, message: message)
            
            if loconetMessage.checkSumOK {
              
              for observer in observers {
                observer.value.NetworkMessageReceived(message: loconetMessage)
              }
              
              let opCode = loconetMessage.opCode
              
              switch opCode {
              case .OPC_UNKNOWN:
                print("OPC_UNKNOWN \(String(format: "%02X", loconetMessage.opCodeRawValue))")
                print("message Length = \(loconetMessage.messageLength)")
                var ss:String = ""
                for x in message {
                  ss += String(format:"%02x", x) + " "
                }
                print("\(ss)\n")
                break
              case .OPC_BUSY:
                // Ignore these opcodes
                break
    /*          case .OPC_GPOFF:
                break
              case .OPC_GPON:
                break
              case .OPC_IDLE:
                break
              case .OPC_LOCO_SPD:
                break
              case .OPC_LOCO_DIRF:
                break
              case .OPC_LOCO_SND:
                break */
              case .OPC_SW_REQ, .OPC_SW_ACK, .OPC_SW_STATE:
                delegate?.LoconetSwitchRequestMessageReceived(message: LoconetSwitchRequestMessage(interfaceId:self.id, message: message))
                break
              case .OPC_SW_REP:
                if (message[2] & 0b01000000) != 0x00 {
                  delegate?.LoconetSensorMessageReceived(message: LoconetSensorMessage(interfaceId:self.id, message: message))
                }
                else {
                  delegate?.LoconetTurnoutOutputMessageReceived(message: LoconetTurnoutOutputMessage(interfaceId:self.id, message: message))
                }
                break
              case .OPC_INPUT_REP:
                delegate?.LoconetSensorMessageReceived(message: LoconetSensorMessage(interfaceId:self.id, message: message))
               break
              case .OPC_LONG_ACK:
                delegate?.LoconetLongAcknowledgeMessageReceived(message: LoconetLongAcknowledgeMessage(interfaceId:self.id, message: message))
                break
    /*          case .OPC_SLOT_STAT1:
                break
              case .OPC_CONSIST_FUNC:
                break
              case .OPC_UNLINK_SLOTS:
                break
              case .OPC_LINK_SLOTS:
                break
              case .OPC_MOVE_SLOTS:
                break
     */
              case .OPC_PEER_XFER:
                if loconetMessage.messageLength == 16 {
                  let pxm = PeerXferMessage(interfaceId: self.id, message: message)
                  print("PEER_XFER: \(pxm.sourceId) to \(pxm.destId)")
                  print("\(pxm.messageHex)")
                  for x in pxm.peerXferMessage {
                    print("\(String(format: "%02x ", x))")
                  }
                }
                else {
                  let pxm = PeerXferMessage20(interfaceId: self.id, message: message)
                  print("PEER_XFER_20: \(pxm.sourceId) to \(pxm.destId)")
                  print("Hex: \(pxm.messageHex)")
                  for x in pxm.peerXferMessage {
                    print("\(String(format: "%02x ", x))")
                  }
                }
                break
              case .OPC_RQ_SL_DATA:
                delegate?.LoconetRequestSlotDataMessageReceived(message: LoconetRequestSlotDataMessage(interfaceId:self.id, message: message))
                break
                /*
              case .OPC_SW_ACK:
                break
              case .OPC_LOCO_ADR:
                break */
              case .OPC_SL_RD_DATA /*, .OPC_WR_SL_DATA */:
                if message[2] == 0x7b {
                  let fcm = FastClockMessage(interfaceId: self.id, message: message)
                  print("\(fcm.hours):\(fcm.minutes).\(fcm.seconds) \(String(format:"%04x",fcm.ticks)) \(fcm.dataValid)")
                }
                else {
                  let lsdm = LoconetSlotDataMessage(interfaceId: self.id, message: message)
                  let slot = LoconetSlot(interfaceId: self.id, message: message)
                  lsdm.slot = slot
                  let sn = Int(slot.slotNumber)
                  loconetSlots[sn] = nil
                  loconetSlots[sn] = slot
                  delegate?.LoconetSlotDataMessageReceived(message: lsdm)
                }
                break
              default:
                print("\(opCode)")
                var ss:String = ""
                for x in message {
                  ss += String(format:"%02x", x) + " "
                }
                print(ss)
                break
              }
              
            }

          }
          
        }

      }

    }
    
  }

}
