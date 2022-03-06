//
//  NetworkMessenger.swift
//  MyTrains
//
//  Created by Paul Willmott on 29/10/2021.
//

import Foundation
import ORSSerial

@objc public protocol NetworkMessengerDelegate {
  @objc optional func networkMessageReceived(message:NetworkMessage)
  @objc optional func networkTimeOut(message:NetworkMessage)
  @objc optional func messengerRemoved(id:String)
}

public protocol NetworkInterfaceDelegate {
  func interfaceNotIdentified(messenger:NetworkMessenger)
  func interfaceIdentified(messenger:NetworkMessenger)
  func interfaceRemoved(messenger:NetworkMessenger)
  func statusChanged(messenger:NetworkMessenger)
}

enum TIMING {
  static let STANDARD = 20.0 / 1000.0
  static let SWREQ = 20.0 / 1000.0
  static let DISCOVER = 1.0
  static let PRMODE = 2.0
  static let CVOP = 2.0
}

enum MessengerState {
  case idle
  case spacing
  case waitingForResponse
}

public enum ProgrammerMode : Int {
  case MS100TerminationDisabled = 0
  case ProgrammerMode = 1
  case MS100TerminationEnabled = 3
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
  
  public var lastProgrammerMode : ProgrammerMode = .MS100TerminationDisabled
  
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
    
    delegate?.networkTimeOut?(message: item!.message)
    
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
                
                if networkMessage.messageType != .programmerBusy {
                  
                  delegate = outputQueue[0].delegate
                  
                  outputQueue.remove(at: 0)
                  
                  messengerState = .spacing
                  
                  stopTimer = true
                  
                }
              
              }
              
              outputQueueLock.unlock()
              
              if stopTimer {
                stopSpacingTimer()
                delegate?.networkMessageReceived?(message: networkMessage)
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
  
  public func getCfgSlotDataP2() {
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_RQ_SL_DATA.rawValue, 0x7f, 0x40], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: nil, retryCount: 1)

  }
  
  public func getProgSlotDataP1() {
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_RQ_SL_DATA.rawValue, 0x7c, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.CVOP, response: [.progSlotDataP1], delegate: nil, retryCount: 10)

  }
  
  public func getLocoSlotDataP1(slotNumber: Int) {
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_RQ_SL_DATA.rawValue, UInt8(slotNumber), 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: nil, retryCount: 1)

  }
  
  public func getLocoSlotDataP2(slotPage: Int, slotNumber: Int) {
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_RQ_SL_DATA.rawValue, UInt8(slotNumber), UInt8(slotPage) | 0b01000000], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: nil, retryCount: 1)

  }
  
  public func getLocoSlotDataP1(forAddress: Int) {
    
    let lo = UInt8(forAddress & 0x7f)
    
    let hi = UInt8(forAddress >> 7)
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_LOCO_ADR.rawValue, hi, lo], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [.locoSlotDataP1, .noFreeSlotsP1, .slotNotImplemented], delegate: nil, retryCount: 5)

  }
  
  public func getLocoSlotDataP2(forAddress: Int) {
    
    let lo = UInt8(forAddress & 0x7f)
    
    let hi = UInt8(forAddress >> 7)
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_LOCO_ADR_P2.rawValue, hi, lo], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [.locoSlotDataP2, .noFreeSlotsP2, .slotNotImplemented], delegate: nil, retryCount: 5)

  }
  
  public func swState(switchNumber: Int) {
    
    let lo = UInt8((switchNumber - 1) & 0x7f)
    
    let hi = UInt8((switchNumber - 1) >> 7)
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_SW_STATE.rawValue, lo, hi], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [.swState], delegate: nil, retryCount: 2)

  }
  
  public func swReq(switchNumber: Int, state:OptionSwitchState) {
    
    let lo = UInt8((switchNumber - 1) & 0x7f)
    
    let bit : UInt8 = state == .closed ? 0x30 : 0x10
    
    let hi = UInt8((switchNumber - 1) >> 7) | bit
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_SW_REQ.rawValue, lo, hi], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.SWREQ, response: [], delegate: nil, retryCount: 1)

  }
  
  public func setLocoSlotDataP1(slotData: [UInt8]) {
    
    var data = [UInt8](repeating: 0, count: 13)
    
    data[0] = NetworkMessageOpcode.OPC_WR_SL_DATA.rawValue
    data[1] = 14
    
    for index in 0...slotData.count-1 {
      data[index + 2] = slotData[index]
    }
    
    let message = NetworkMessage(interfaceId: id, data: data, appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [.setSlotDataOKP1, .ack], delegate: nil, retryCount: 1)

  }

  public func setLocoSlotDataP2(slotData: [UInt8]) {
    
    var data = [UInt8](repeating: 0, count: 20)
    
    data[0] = NetworkMessageOpcode.OPC_WR_SL_DATA_P2.rawValue
    data[1] = 21
    
    for index in 0...slotData.count-1 {
      data[index + 2] = slotData[index]
    }
    
    let message = NetworkMessage(interfaceId: id, data: data, appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [.setSlotDataOKP2, .ack], delegate: nil, retryCount: 1)

  }

  public func clearLocoSlotDataP1(slotNumber:Int) {
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_WR_SL_DATA.rawValue, 0x0e, UInt8(slotNumber), 0b00000011, 0x00, 0x00, 0b00100000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [.setSlotDataOKP1, .ack], delegate: nil, retryCount: 1)

  }
  
  public func clearLocoSlotDataP2(slotPage: Int, slotNumber:Int) {
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_WR_SL_DATA_P2.rawValue, 0x15, UInt8(slotPage), UInt8(slotNumber), 0b00000011, 0x00, 0x00, 0x00, 0x00, 0x00, 0b00100000, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [.setSlotDataOKP2,.ack], delegate: nil, retryCount: 1)

  }
  
  public func moveSlotsP1(sourceSlotNumber: Int, destinationSlotNumber: Int) {
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_MOVE_SLOTS.rawValue, UInt8(sourceSlotNumber), UInt8(destinationSlotNumber)], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [.locoSlotDataP1, .illegalMoveP1], delegate: nil, retryCount: 5)

  }
  
  public func moveSlotsP2(sourceSlotNumber: Int, sourceSlotPage: Int, destinationSlotNumber: Int, destinationSlotPage: Int) {
    
    let srcPage = UInt8(sourceSlotPage & 0b00000111) | 0b00111000
    let dstPage = UInt8(destinationSlotPage & 0b00000111)
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_D4_GROUP.rawValue, srcPage, UInt8(sourceSlotNumber), dstPage, UInt8(destinationSlotNumber)], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [.locoSlotDataP2, .illegalMoveP2, .locoSlotDataP1], delegate: nil, retryCount: 5)

  }
  
  public func getInterfaceData() {
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_BUSY.rawValue], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [.interfaceData], delegate: self, retryCount: 3)
    
  }
  
  public func setProgMode(mode: ProgrammerMode) {
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_PR_MODE.rawValue, 0x10, UInt8(mode.rawValue), 0x00, 0x00], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.PRMODE, response: [], delegate: self, retryCount: 1)

    lastProgrammerMode = mode
    
  }
  
  public func readCV(progMode:ProgrammingMode, cv:Int, address: Int) {
    
    var pcmd : UInt8 = 0
    
    switch progMode {
    case .directMode:
      pcmd = 0b00101011
    case .operationsMode:
      pcmd = 0b00100111
    case .pagedMode:
      pcmd = 0b00100011
    case .physicalRegister:
      pcmd = 0b00010011
    }
    
    var hopsa : UInt8 = 0
    var lopsa : UInt8 = 0
    
    if progMode == .operationsMode {
      lopsa = UInt8(address & 0x7f)
      hopsa = UInt8(address >> 7)
    }
    
    let cvAdjusted = cv - 1
    
    let cvh : Int = (cvAdjusted & 0b0000001000000000) == 0b0000001000000000 ? 0b00100000 : 0x00 |
                    (cvAdjusted & 0b0000000100000000) == 0b0000000100000000 ? 0b00010000 : 0x00 |
                    (cvAdjusted & 0b0000000010000000) == 0b0000000010000000 ? 0b00000001 : 0x00

    let message = NetworkMessage(interfaceId: id, data:
        [
          NetworkMessageOpcode.OPC_WR_SL_DATA.rawValue,
          0x0e,
          0x7c,
          pcmd,
          0x00,
          hopsa, // HOPSA
          lopsa, // LOPSA
          0x00,
          UInt8(cvh & 0x7f),
          UInt8(cvAdjusted & 0x7f),
          0x00,
          0x00,
          0x00
        ],
        appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.CVOP, response: [.progCmdAccepted, .progCmdAcceptedBlind], delegate: self, retryCount: 10)
    
  }
  
  
  public func writeCV(progMode: ProgrammingMode, cv:Int, address: Int, value: Int) {
    
    var pcmd : UInt8 = 0
    
    switch progMode {
    case .directMode:
      pcmd = 0b01101011
    case .operationsMode:
      pcmd = 0b01101111
    case .pagedMode:
      pcmd = 0b01100011
    case .physicalRegister:
      pcmd = 0b01010011
    }
    
    var hopsa : UInt8 = 0
    var lopsa : UInt8 = 0
    
    if progMode == .operationsMode {
      lopsa = UInt8(address & 0x7f)
      hopsa = UInt8(address >> 7)
    }
    
   let cvAdjusted = cv - 1
    
    let cvh : Int = (cvAdjusted & 0b0000001000000000) == 0b0000001000000000 ? 0b00100000 : 0x00 |
                    (cvAdjusted & 0b0000000100000000) == 0b0000000100000000 ? 0b00010000 : 0x00 |
                    (cvAdjusted & 0b0000000010000000) == 0b0000000010000000 ? 0b00000001 : 0x00 |
                    (value & 0b10000000) == 0b10000000 ? 0b00000010 : 0x00

    let message = NetworkMessage(interfaceId: id, data:
        [
          NetworkMessageOpcode.OPC_WR_SL_DATA.rawValue,
          0x0e,
          0x7c,
          pcmd,
          0x00,
          hopsa,
          lopsa,
          0x00,
          UInt8(cvh & 0x7f),
          UInt8(cvAdjusted & 0x7f),
          UInt8(value & 0x7f),
          0x00,
          0x00
        ],
        appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.CVOP, response: [.progCmdAccepted, .progCmdAcceptedBlind], delegate: self, retryCount: 10)
    
  }
  
  public func locoDirF0F4P1(slotNumber: Int, direction:LocomotiveDirection, functions: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    var dirf : UInt8 = 0
    
    dirf |= direction == .forward        ? 0b00100000 : 0b00000000
    dirf |= functions & maskF0 == maskF0 ? 0b00010000 : 0b00000000
    dirf |= functions & maskF1 == maskF1 ? 0b00000001 : 0b00000000
    dirf |= functions & maskF2 == maskF2 ? 0b00000010 : 0b00000000
    dirf |= functions & maskF3 == maskF3 ? 0b00000100 : 0b00000000
    dirf |= functions & maskF4 == maskF4 ? 0b00001000 : 0b00000000
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_LOCO_DIRF.rawValue, slot, dirf], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: self, retryCount: 1)
    
  }
  
  public func locoDirF0F4P2(slotNumber: Int, slotPage: Int, direction:LocomotiveDirection, functions: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = 0b00100000 | UInt8(slotPage & 0x07)
    
    var dirf : UInt8 = 0
    
    dirf |= direction == .forward        ? 0b00100000 : 0b00000000
    dirf |= functions & maskF0 == maskF0 ? 0b00010000 : 0b00000000
    dirf |= functions & maskF1 == maskF1 ? 0b00000001 : 0b00000000
    dirf |= functions & maskF2 == maskF2 ? 0b00000010 : 0b00000000
    dirf |= functions & maskF3 == maskF3 ? 0b00000100 : 0b00000000
    dirf |= functions & maskF4 == maskF4 ? 0b00001000 : 0b00000000
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x06, dirf], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: self, retryCount: 1)
    
  }
  
  public func locoF5F8P1(slotNumber: Int, functions: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    var fnx : UInt8 = 0
    
    fnx |= functions & maskF5 == maskF5 ? 0b00000001 : 0b00000000
    fnx |= functions & maskF6 == maskF6 ? 0b00000010 : 0b00000000
    fnx |= functions & maskF7 == maskF7 ? 0b00000100 : 0b00000000
    fnx |= functions & maskF8 == maskF8 ? 0b00001000 : 0b00000000
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_LOCO_SND.rawValue, slot, fnx], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: self, retryCount: 1)
    
  }
  
  public func locoF0F6P2(slotNumber: Int, slotPage: Int, functions: Int, throttleID: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = UInt8(slotPage & 0x07) | 0b00010000
    
    let tid = UInt8(throttleID & 0x7f)
    
    var fnx : UInt8 = 0
    
    fnx |= functions & maskF0 == maskF0 ? 0b00010000 : 0b00000000
    fnx |= functions & maskF1 == maskF1 ? 0b00000001 : 0b00000000
    fnx |= functions & maskF2 == maskF2 ? 0b00000010 : 0b00000000
    fnx |= functions & maskF3 == maskF3 ? 0b00000100 : 0b00000000
    fnx |= functions & maskF4 == maskF4 ? 0b00001000 : 0b00000000
    fnx |= functions & maskF5 == maskF5 ? 0b00100000 : 0b00000000
    fnx |= functions & maskF6 == maskF6 ? 0b01000000 : 0b00000000

    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_D5_GROUP.rawValue, page, slot, tid, fnx], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: self, retryCount: 1)
    
  }
  
  public func locoF5F11P2(slotNumber: Int, slotPage: Int, functions: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = 0b00100000 | UInt8(slotPage & 0x07)
    
    var dirf : UInt8 = 0
    
    dirf |= functions & maskF5  == maskF5  ? 0b00000001 : 0b00000000
    dirf |= functions & maskF6  == maskF6  ? 0b00000010 : 0b00000000
    dirf |= functions & maskF7  == maskF7  ? 0b00000100 : 0b00000000
    dirf |= functions & maskF8  == maskF8  ? 0b00001000 : 0b00000000
    dirf |= functions & maskF9  == maskF9  ? 0b00010000 : 0b00000000
    dirf |= functions & maskF10 == maskF10 ? 0b00100000 : 0b00000000
    dirf |= functions & maskF11 == maskF11 ? 0b01000000 : 0b00000000

    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x07, dirf], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: self, retryCount: 1)
    
  }
  
  public func locoF7F13P2(slotNumber: Int, slotPage: Int, functions: Int, throttleID: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = UInt8(slotPage & 0x07) | 0b00011000
    
    let tid = UInt8(throttleID & 0x7f)

    var fnx : UInt8 = 0
    
    fnx |= functions & maskF7  == maskF7  ? 0b00000001 : 0b00000000
    fnx |= functions & maskF8  == maskF8  ? 0b00000010 : 0b00000000
    fnx |= functions & maskF9  == maskF9  ? 0b00000100 : 0b00000000
    fnx |= functions & maskF10 == maskF10 ? 0b00001000 : 0b00000000
    fnx |= functions & maskF11 == maskF11 ? 0b00010000 : 0b00000000
    fnx |= functions & maskF12 == maskF12 ? 0b00100000 : 0b00000000
    fnx |= functions & maskF13 == maskF13 ? 0b01000000 : 0b00000000

    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_D5_GROUP.rawValue, page, slot, tid, fnx], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: self, retryCount: 1)
    
  }
  
  public func locoF12F20F28P2(slotNumber: Int, slotPage: Int, functions: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = 0b00100000 | UInt8(slotPage & 0x07)
    
    var dirf : UInt8 = 0
    
    dirf |= functions & maskF12 == maskF12  ? 0b00000001 : 0b00000000
    dirf |= functions & maskF20 == maskF20  ? 0b00000010 : 0b00000000
    dirf |= functions & maskF28 == maskF28  ? 0b00000100 : 0b00000000
 
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x05, dirf], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: self, retryCount: 1)
    
  }
  
  public func locoF13F19P2(slotNumber: Int, slotPage: Int, functions: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = 0b00100000 | UInt8(slotPage & 0x07)
    
    var dirf : UInt8 = 0
    
    dirf |= functions & maskF13 == maskF13 ? 0b00000001 : 0b00000000
    dirf |= functions & maskF14 == maskF14 ? 0b00000010 : 0b00000000
    dirf |= functions & maskF15 == maskF15 ? 0b00000100 : 0b00000000
    dirf |= functions & maskF16 == maskF16 ? 0b00001000 : 0b00000000
    dirf |= functions & maskF17 == maskF17 ? 0b00010000 : 0b00000000
    dirf |= functions & maskF18 == maskF18 ? 0b00100000 : 0b00000000
    dirf |= functions & maskF19 == maskF19 ? 0b01000000 : 0b00000000

    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x08, dirf], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: self, retryCount: 1)
    
  }

  public func locoF14F20P2(slotNumber: Int, slotPage: Int, functions: Int, throttleID: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = UInt8(slotPage & 0x07) | 0b00100000
    
    let tid = UInt8(throttleID & 0x7f)

    var fnx : UInt8 = 0
    
    fnx |= functions & maskF14 == maskF14 ? 0b00000001 : 0b00000000
    fnx |= functions & maskF15 == maskF15 ? 0b00000010 : 0b00000000
    fnx |= functions & maskF16 == maskF16 ? 0b00000100 : 0b00000000
    fnx |= functions & maskF17 == maskF17 ? 0b00001000 : 0b00000000
    fnx |= functions & maskF18 == maskF18 ? 0b00010000 : 0b00000000
    fnx |= functions & maskF19 == maskF19 ? 0b00100000 : 0b00000000
    fnx |= functions & maskF20 == maskF20 ? 0b01000000 : 0b00000000

    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_D5_GROUP.rawValue, page, slot, tid, fnx], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: self, retryCount: 1)
    
  }
  
  public func locoF21F27P2(slotNumber: Int, slotPage: Int, functions: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = 0b00100000 | UInt8(slotPage & 0x07)
    
    var dirf : UInt8 = 0
    
    dirf |= functions & maskF21 == maskF21 ? 0b00000001 : 0b00000000
    dirf |= functions & maskF22 == maskF22 ? 0b00000010 : 0b00000000
    dirf |= functions & maskF23 == maskF23 ? 0b00000100 : 0b00000000
    dirf |= functions & maskF24 == maskF24 ? 0b00001000 : 0b00000000
    dirf |= functions & maskF25 == maskF25 ? 0b00010000 : 0b00000000
    dirf |= functions & maskF26 == maskF26 ? 0b00100000 : 0b00000000
    dirf |= functions & maskF27 == maskF27 ? 0b01000000 : 0b00000000

    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x09, dirf], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: self, retryCount: 1)
    
  }
  
  public func locoF21F28P2(slotNumber: Int, slotPage: Int, functions: Int, throttleID: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = UInt8(slotPage & 0x07) | UInt8(functions & maskF28 == maskF28 ? 0b00110000 : 0b00101000)
    
    let tid = UInt8(throttleID & 0x7f)

    var fnx : UInt8 = 0
    
    fnx |= functions & maskF21 == maskF21 ? 0b00000001 : 0b00000000
    fnx |= functions & maskF22 == maskF22 ? 0b00000010 : 0b00000000
    fnx |= functions & maskF23 == maskF23 ? 0b00000100 : 0b00000000
    fnx |= functions & maskF24 == maskF24 ? 0b00001000 : 0b00000000
    fnx |= functions & maskF25 == maskF25 ? 0b00010000 : 0b00000000
    fnx |= functions & maskF26 == maskF26 ? 0b00100000 : 0b00000000
    fnx |= functions & maskF27 == maskF27 ? 0b01000000 : 0b00000000

    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_D5_GROUP.rawValue, page, slot, tid, fnx], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: self, retryCount: 1)
    
  }
  
  public func locoSpdP1(slotNumber: Int, speed: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let spd = UInt8(speed & 0x7f)
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_LOCO_SPD.rawValue, slot, spd], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: nil, retryCount: 1)

  }
  
  public func locoSpdDirP2(slotNumber: Int, slotPage: Int, speed: Int, direction: LocomotiveDirection, throttleID: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = UInt8(slotPage & 0x07) | (direction == .forward ? 0b00001000 : 0b00000000)
    
    let spd = UInt8(speed & 0x7f)
    
    let tid = UInt8(throttleID & 0x7f)

    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_D5_GROUP.rawValue, page, slot, tid, spd], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: nil, retryCount: 1)

  }
  
  public func locoSpdP2(slotNumber: Int, slotPage: Int, speed: Int) {
    
    let slot = UInt8(slotNumber & 0x7f)
    
    let page = UInt8(slotPage & 0x07) | 0b00100000
    
    let spd = UInt8(speed & 0x7f)
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_D4_GROUP.rawValue, page, slot, 0x04, spd], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: nil, retryCount: 1)

  }
  
  public func powerIdle() {
    
    let message = NetworkMessage(interfaceId: id, data: [NetworkMessageOpcode.OPC_IDLE.rawValue], appendCheckSum: true)
    
    addToQueue(message: message, delay: TIMING.STANDARD, response: [], delegate: nil, retryCount: 1)

  }
  
  // MARK: NetworkMessengerDelegate Methods
  
  @objc public func networkMessageReceived(message: NetworkMessage) {
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
  
  @objc public func networkTimeOut(message: NetworkMessage) {
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
      observer.value.messengerRemoved?(id: self.id)
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
